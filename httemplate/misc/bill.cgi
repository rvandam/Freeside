<!-- $Id: bill.cgi,v 1.5 2002-01-30 14:18:09 ivan Exp $ -->
<%

#untaint custnum
my($query) = $cgi->keywords;
$query =~ /^(\d*)$/;
my $custnum = $1;
my $cust_main = qsearchs('cust_main',{'custnum'=>$custnum});
die "Can't find customer!\n" unless $cust_main;

my $error = $cust_main->bill(
#                          'time'=>$time
                         );
#&eidiot($error) if $error;

unless ( $error ) {
  $cust_main->apply_payments;
  $cust_main->apply_credits;

  $error = $cust_main->collect(
  #                             'invoice-time'=>$time,
  #                             'batch_card'=> 'yes',
                               'batch_card'=> 'no',
                               'report_badcard'=> 'yes',
                              );
}
#&eidiot($error) if $error;

if ( $error ) {
  &idiot($error);
} else {
  print $cgi->redirect(popurl(2). "view/cust_main.cgi?$custnum");
}
%>
