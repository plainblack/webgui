package WebGUI::ErrorHandler;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2002 Plain Black LLC.
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
        my ($key, $log, $cgi, $logfile, $config, $friendly);
	if (exists $session{cgi}) {
		$cgi = $session{cgi};
		$friendly = 1 if ($session{setting}{onCriticalError} eq "friendly");
		print WebGUI::Session::httpHeader();
	} else {
		use CGI;
		$cgi = CGI->new;
		print $cgi->header;
	}
	if (exists $session{config}{logfile}) {
		$logfile = $session{config}{logfile};
	} else {
		use Data::Config;
        	$config = new Data::Config '../etc/WebGUI.conf';
		$logfile = $config->param('logfile');
	}
        print "<h1>WebGUI Fatal Error</h1>Something unexpected happened that caused this system to fault.<p>" unless ($friendly); 
	$log = FileHandle->new(">>$logfile") or print "Can't open log file.";
        print $0." at ".localtime(time)." reported:<br>" unless ($friendly);
	print $log localtime(time)." ".$0." FATAL: ".$_[0]."\n";
        print $_[0] unless ($friendly);
        print "<p><h3>Caller</h3><table border=1><tr><td valign=top>" unless ($friendly);
        print "<b>Level 1</b><br>".join("<br>",caller(1)) unless ($friendly);
	print $log "\t".join(",",caller(1))."\n";
        print "</td><td valign=top>"."<b>Level 2</b><br>".join("<br>",caller(2)) unless ($friendly);
	print $log "\t".join(",",caller(2))."\n";
        print "</td><td valign=top>"."<b>Level 3</b><br>".join("<br>",caller(3)) unless ($friendly);
	print $log "\t".join(",",caller(3))."\n";
        print "</td><td valign=top>"."<b>Level 4</b><br>".join("<br>",caller(4)) unless ($friendly);
	print $log "\t".join(",",caller(4))."\n";
        print "</td></tr></table>" unless ($friendly);
	print "<h3>Form Variables</h3>" unless ($friendly);
	print $log "\t";
	if (exists $session{form}) {
        	foreach $key (keys %{$session{form}}) {
                	print $key." = ".$session{form}{$key}."<br>" unless ($friendly);
                	print $log $key."=".$session{form}{$key}." ";
        	}
		print $log "\n";
	} else {
		print "Cannot retrieve session information." unless ($friendly);
		print $log "Session not accessible for form variable dump.\n";
	}
	print $log "\n";
	$log->close;
        if ($friendly) {
                print WebGUI::International::get(416).'<br>';
		print '<br>'.$session{setting}{companyName};
		print '<br>'.$session{setting}{companyEmail};
		print '<br>'.$session{setting}{companyURL};
	}
        exit;
}

#-------------------------------------------------------------------
sub warn {
        my ($log, $logfile, $config);
        if (exists $session{config}{logfile}) {
                $logfile = $session{config}{logfile};
        } else {
                use Data::Config;
                $config = new Data::Config '../etc/WebGUI.conf';
                $logfile = $config->param('logfile');
        }
        $log = FileHandle->new(">>".$logfile) or fatalError("Can't open log file for warning.");
        print $log localtime(time)." ".$0." WARNING: ".$_[0]."\n";
	$log->close;
}

1;

