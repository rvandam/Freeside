<!-- $Id: unsusp_pkg.cgi,v 1.3 2002-01-30 14:18:09 ivan Exp $ -->
<%

#untaint pkgnum
my ($query) = $cgi->keywords;
$query =~ /^(\d+)$/ || die "Illegal pkgnum";
my $pkgnum = $1;

my $cust_pkg = qsearchs('cust_pkg',{'pkgnum'=>$pkgnum});

my $error = $cust_pkg->unsuspend;
&eidiot($error) if $error;

print $cgi->redirect(popurl(2). "view/cust_main.cgi?".$cust_pkg->getfield('custnum'));

%>
