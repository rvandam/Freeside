package FS::XMLRPC;

use strict;
use vars qw( @ISA $DEBUG );
use Frontier::RPC2;
use FS::Record qw( qsearch qsearchs );
use FS::cust_main qw( smart_search );

@ISA = qw( );

$DEBUG = 1;

=head1 NAME

FS::XMLRPC - Object methods for handling XMLRPC requests

=head1 SYNOPSIS

  use FS::XMLRPC;

  $xmlrpc = new FS::XMLRPC;

  ($error, $response_xml) = $xmlrpc->serve($request_xml);

=head1 DESCRIPTION

The FS::XMLRPC object is a mechanisim to access read-only data from freeside's subroutines.  It does not, at least not at this point, give you the ability to access methods of freeside objects remotely.  It can, however, be used to call subroutines such as FS::cust_main::smart_search and FS::Record::qsearch.

See the serve method below for calling syntax.

=head1 METHODS

=over 4

=item new

Provides a FS::XMLRPC object used to handle incoming XMLRPC requests.

=cut

sub new {

  my $class = shift;
  my $self = {};
  bless($self, $class);

  $self->{_coder} = new Frontier::RPC2;

  return $self;

}

=item serve REQUEST_XML_SCALAR

The serve method takes a scalar containg an XMLRPC request for one of freeside's subroutines (not object methods).  Parameters passed in the 'methodCall' will be passed as a list to the subroutine untouched.  The return value of the called subroutine _must_ be a freeside object reference (eg. qsearchs) or a list of freeside object references (eg. qsearch, smart_search), _and_, the object(s) returned must support the hashref method.  This will be checked first by calling UNIVERSAL::can('FS::class::subroutine', 'hashref').

Return value is an XMLRPC methodResponse containing the results of the call.  The result of the subroutine call itself will be coded in the methodResponse as an array of structs, regardless of whether there was many or a single object returned.  In other words, after you decode the response, you'll always have an array.

=cut

sub serve {

  my ($self, $request_xml) = (shift, shift);
  my $response_xml;

  my $coder = $self->{_coder};
  my $call = $coder->decode($request_xml);
  
  warn "Got methodCall with method_name='" . $call->{method_name} . "'"
    if $DEBUG;

  $response_xml = $coder->encode_response(&_serve($call->{method_name}, $call->{value}));

  return ('', $response_xml);

}

sub _serve { #Subroutine, not method

  my ($method_name, $params) = (shift, shift);

  use Data::Dumper;

  #die 'Called _serve without parameters' unless ref($params) eq 'ARRAY';
  $params = [] unless (ref($params) eq 'ARRAY');

  my ($class, $sub) = split(/\./, $method_name);
  my $fssub = "FS::${class}::${sub}";
  warn "fssub: ${fssub}" if $DEBUG;
  warn "params: " . Dumper($params) if $DEBUG;

  unless (UNIVERSAL::can("FS::${class}", $sub)) {
    warn "FS::XMLRPC: Can't call undefined subroutine '${fssub}'";
    # Should we encode an error in the response,
    # or just break silently to the remote caller and complain locally?
    return [];
  }

  my @result;
  eval { 
    no strict 'refs';
    my $fssub = "FS::${class}::${sub}";
    @result = (&$fssub(@$params));
  };

  if ($@) {
    warn "FS::XMLRPC: Error while calling '${fssub}': $@";
    return [];
  }

  warn Dumper(@result);

  if (grep { UNIVERSAL::can($_, 'hashref') ? 0 : 1 } @result) {
    warn "FS::XMLRPC: One or more objects returned from '${fssub}' doesn't " .
         "support the 'hashref' method.";
    return [];
  } else {
    return [ map { $_->hashref } @result ];
  }

}

=head1 BUGS

Probably lots.

=head1 SEE ALSO

L<Frontier::RPC2>.

=cut

1;

