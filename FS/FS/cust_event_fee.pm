package FS::cust_event_fee;

use strict;
use base qw( FS::Record FS::FeeOrigin_Mixin );
use FS::Record qw( qsearch qsearchs );

=head1 NAME

FS::cust_event_fee - Object methods for cust_event_fee records

=head1 SYNOPSIS

  use FS::cust_event_fee;

  $record = new FS::cust_event_fee \%hash;
  $record = new FS::cust_event_fee { 'column' => 'value' };

  $error = $record->insert;

  $error = $new_record->replace($old_record);

  $error = $record->delete;

  $error = $record->check;

=head1 DESCRIPTION

An FS::cust_event_fee object links a billing event that charged a fee
(an L<FS::cust_event>) to the resulting invoice line item (an 
L<FS::cust_bill_pkg> object).  FS::cust_event_fee inherits from FS::Record 
and FS::FeeOrigin_Mixin.  The following fields are currently supported:

=over 4

=item eventfeenum - primary key

=item eventnum - key of the cust_event record that required the fee to be 
created.  This is a unique column; there's no reason for a single event 
instance to create more than one fee.

=item billpkgnum - key of the cust_bill_pkg record representing the fee 
on an invoice.  This is also a unique column but can be NULL to indicate
a fee that hasn't been billed yet.  In that case it will be billed the next
time billing runs for the customer.

=item feepart - key of the fee definition (L<FS::part_fee>).

=item nextbill - 'Y' if the fee should be charged on the customer's next
bill, rather than causing a bill to be produced immediately.

=back

=head1 METHODS

=over 4

=item new HASHREF

Creates a new event-fee link.  To add the record to the database, 
see L<"insert">.

=cut

sub table { 'cust_event_fee'; }

=item insert

Adds this record to the database.  If there is an error, returns the error,
otherwise returns false.

=item delete

Delete this record from the database.

=item replace OLD_RECORD

Replaces the OLD_RECORD with this one in the database.  If there is an error,
returns the error, otherwise returns false.

=item check

Checks all fields to make sure this is a valid example.  If there is
an error, returns the error, otherwise returns false.  Called by the insert
and replace methods.

=cut

sub check {
  my $self = shift;

  my $error = 
    $self->ut_numbern('eventfeenum')
    || $self->ut_foreign_key('eventnum', 'cust_event', 'eventnum')
    || $self->ut_foreign_keyn('billpkgnum', 'cust_bill_pkg', 'billpkgnum')
    || $self->ut_foreign_key('feepart', 'part_fee', 'feepart')
    || $self->ut_flag('nextbill')
  ;
  return $error if $error;

  $self->SUPER::check;
}

=back

=head1 CLASS METHODS

=over 4

=item _by_cust CUSTNUM[, PARAMS]

See L<FS::FeeOrigin_Mixin/by_cust>. This is the implementation for 
event-triggered fees.

=cut

sub _by_cust {
  my $class = shift;
  my $custnum = shift or return;
  my %params = @_;
  $custnum =~ /^\d+$/ or die "bad custnum $custnum";

  # silliness
  my $where = ($params{hashref} && keys (%{ $params{hashref} }))
              ? 'AND'
              : 'WHERE';
  qsearch({
    table     => 'cust_event_fee',
    addl_from => 'JOIN cust_event USING (eventnum) ' .
                 'JOIN part_event USING (eventpart) ',
    extra_sql => "$where eventtable = 'cust_main' ".
                 "AND cust_event.tablenum = $custnum",
    %params
  }),
  qsearch({
    table     => 'cust_event_fee',
    addl_from => 'JOIN cust_event USING (eventnum) ' .
                 'JOIN part_event USING (eventpart) ' .
                 'JOIN cust_bill ON (cust_event.tablenum = cust_bill.invnum)',
    extra_sql => "$where eventtable = 'cust_bill' ".
                 "AND cust_bill.custnum = $custnum",
    %params
  }),
  qsearch({
    table     => 'cust_event_fee',
    addl_from => 'JOIN cust_event USING (eventnum) ' .
                 'JOIN part_event USING (eventpart) ' .
                 'JOIN cust_pay_batch ON (cust_event.tablenum = cust_pay_batch.paybatchnum)',
    extra_sql => "$where eventtable = 'cust_pay_batch' ".
                 "AND cust_pay_batch.custnum = $custnum",
    %params
  }),
  qsearch({
    table     => 'cust_event_fee',
    addl_from => 'JOIN cust_event USING (eventnum) ' .
                 'JOIN part_event USING (eventpart) ' .
                 'JOIN cust_pkg ON (cust_event.tablenum = cust_pkg.pkgnum)',
    extra_sql => "$where eventtable = 'cust_pkg' ".
                 "AND cust_pkg.custnum = $custnum",
    %params
  })
}

=item cust_bill

See L<FS::FeeOrigin_Mixin/cust_bill>. This version simply returns the event
object if the event is an invoice event.

=cut

sub cust_bill {
  my $self = shift;
  my $object = $self->cust_event->cust_X;
  if ( $object->isa('FS::cust_bill') ) {
    return $object;
  } else {
    return '';
  }
}

=item cust_pkg

See L<FS::FeeOrigin_Mixin/cust_bill>. This version simply returns the event
object if the event is a package event.

=cut

sub cust_pkg {
  my $self = shift;
  my $object = $self->cust_event->cust_X;
  if ( $object->isa('FS::cust_pkg') ) {
    return $object;
  } else {
    return '';
  }
}

=head1 BUGS

=head1 SEE ALSO

L<FS::cust_event>, L<FS::FeeOrigin_Mixin>, L<FS::Record>

=cut

1;

