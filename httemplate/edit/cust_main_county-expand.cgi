<!-- $Id: cust_main_county-expand.cgi,v 1.6 2002-01-30 14:18:08 ivan Exp $ -->
<%

my($taxnum, $delim, $expansion );
if ( $cgi->param('error') ) {
  $taxnum = $cgi->param('taxnum');
  $delim = $cgi->param('delim');
  $expansion = $cgi->param('expansion');
} else {
  my ($query) = $cgi->keywords;
  $query =~ /^(\d+)$/
    or die "Illegal taxnum!";
  $taxnum = $1;
  $delim = 'n';
  $expansion = '';
}

my $cust_main_county = qsearchs('cust_main_county',{'taxnum'=>$taxnum})
  or die "cust_main_county.taxnum $taxnum not found";
die "Can't expand entry!" if $cust_main_county->getfield('county');

my $p1 = popurl(1);
print header("Tax Rate (expand)", menubar(
  'Main Menu' => popurl(2),
));

print qq!<FONT SIZE="+1" COLOR="#ff0000">Error: !, $cgi->param('error'),
      "</FONT>"
  if $cgi->param('error');

print <<END;
    <FORM ACTION="${p1}process/cust_main_county-expand.cgi" METHOD=POST>
      <INPUT TYPE="hidden" NAME="taxnum" VALUE="$taxnum">
      Separate by
END
print '<INPUT TYPE="radio" NAME="delim" VALUE="n"';
print ' CHECKED' if $delim eq 'n';
print '>line (rumor has it broken on some browsers) or',
      '<INPUT TYPE="radio" NAME="delim" VALUE="s"';
print ' CHECKED' if $delim eq 's';
print '>whitespace.';
print <<END;
      <BR><INPUT TYPE="submit" VALUE="Submit">
      <BR><TEXTAREA NAME="expansion" ROWS=100>$expansion</TEXTAREA>
    </FORM>
    </CENTER>
  </BODY>
</HTML>
END

%>
