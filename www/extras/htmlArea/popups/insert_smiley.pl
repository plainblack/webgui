#!/usr/bin/perl -w

use strict;

my ($httpSmileysPath, $fileSmileysPath, @smileys, $smile, $pos, $columns);

# $fileSmileysPath = '/home/WebGUI/www/extras/smileys'; # Define this if you're having problems determinating 
							# the path to the smileys dir automaticcally.

$httpSmileysPath = "/extras/smileys";  			# Web path to the smileys dir
$columns = 3;						# Smileys column width

# ------------------------------------------------------------------------------------------

if(defined($ENV{SCRIPT_FILENAME}) && $fileSmileysPath eq '') {
	$fileSmileysPath = $ENV{SCRIPT_FILENAME};
	$fileSmileysPath =~ s#(/[^/]+){3}$##;     # Two dirs up from this script level
	$fileSmileysPath .= "/smileys";
}

print <<EOM;
<!-- Content-type: text/html //-->

<html style="width:200px; Height: 200px;">
 <head>
  <title>Insert Smileys</title>
<style>
  html, body, button, div, input, select, fieldset { font-family: MS Shell Dlg; font-size: 8pt; };
</style>

<script language="javascript">
function insertSmiley() {
        var img = window.event.srcElement;
        if (img) {
                var src = img.src.replace(/^[a-z]*:[/][/][^/]*/, "");
                window.returnValue = '<IMG border=0 align=absmiddle src=' + src + '>';
        window.close();
        }
}
</script>

<script language='JavaScript' type='text/javascript'>
function cancel() {
window.returnValue = null;
window.close();
}
</script>
</head>

<body bgcolor="#D6D3CE" topmargin=15 leftmargin=10>
<div align="center">
<FIELDSET style="width:80%">
<LEGEND>Choose a smiley to insert</LEGEND>
<br><table align="center" border="0" cellpadding="4" cellspacing="0">
<tr>
EOM

opendir(DIR,$fileSmileysPath) or die "Couldn't open $fileSmileysPath\n";
@smileys = readdir(DIR);
closedir(DIR);
$pos = 0;
foreach $smile (@smileys)
{
   chomp($smile);
   next if ($smile !~ /gif$|jpg$|jpeg$|bmp$/);
   if ($pos++ >= $columns) {
      print "</tr><tr>\n";
      $pos = 1;
   }

   print '<td valign="top" align="center"><IMG onclick='."'insertSmiley()'".' border=0 src="'.$httpSmileysPath.'/'.$smile.'"></td>'."\n";
   
}
print "</tr></table></FIELDSET></div></body></html>";


