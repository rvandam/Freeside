<%
#<!-- $Id: REAL_cust_pkg.cgi,v 1.1 2001-10-15 14:58:03 ivan Exp $ -->

my $pkgnum = $cgi->param('pkgnum') or die;
my $old = qsearchs('cust_pkg',{'pkgnum'=>$pkgnum});
my %hash = $old->hash;
$hash{'setup'} = $cgi->param('setup') ? str2time($cgi->param('setup')) : '';
$hash{'bill'} = $cgi->param('bill') ? str2time($cgi->param('bill')) : '';
my $new = new FS::cust_pkg \%hash;

my $error = $new->replace($old);

if ( $error ) {
  $cgi->param('error', $error);
  print $cgi->redirect(popurl(2). "REAL_cust_pkg.cgi?". $cgi->query_string );
} else { 
  print $cgi->redirect(popurl(3). "view/cust_pkg.cgi?". $pkgnum);
}

%>
