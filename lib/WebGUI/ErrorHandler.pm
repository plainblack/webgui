package ErrorHandler;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001 Plain Black Software.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use FileHandle;
use WebGUI::Session;

#-------------------------------------------------------------------
sub fatalError {
        my ($key, $logfile);
        print Session::httpHeader();
	$logfile = FileHandle->new(">".$session{config}{logfile}) or die "Can't open log file.";
	print $logfile localtime(time);
        print "<h1>WebGUI Fatal Error</h1>Something unexpected happened that caused this system to fault. Please send this message to ";#.$session{setting}{adminEmail}."<p>";
        print $0." at ".localtime(time)." reported:<br>";
        print $_[0];
        print "<p><h3>Caller</h3><table border=1><tr><td valign=top>";
        print "<b>Level 1</b><br>".join("<br>",caller(1));
        print "</td><td valign=top>"."<b>Level 2</b><br>".join("<br>",caller(2));
        print "</td><td valign=top>"."<b>Level 3</b><br>".join("<br>",caller(3));
        print "</td><td valign=top>"."<b>Level 4</b><br>".join("<br>",caller(4));
        print "</td></tr></table><p><h3>Form Variables</h3>";
        #foreach $key (keys %{$session(form}}) {
        #        print $key." = ".$session{form}{$key}."<br>";
        #}
	$logfile->close();
        exit;
}



