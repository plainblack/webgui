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
sub audit {
        my ($log, $data);
        $log = FileHandle->new(">>".$session{config}{logfile}) or fatalError("Can't open log file for audit.");
        $data = localtime(time)." ".$0." AUDIT: ".$session{user}{username}." (".$session{user}{userId}.") ".$_[0]."\n";
        print $log $data;
        $session{debug}{audit} .= $data."<p>";
        $log->close;
}

#-------------------------------------------------------------------
sub fatalError {
        my ($key, $log, $cgi, $logfile, $config);
	if (exists $session{cgi}) {
		$cgi = $session{cgi};
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
        print "<h1>WebGUI Fatal Error</h1>Something unexpected happened that caused this system to fault.<p>" if ($session{setting}{showDebug}); 
	$log = FileHandle->new(">>$logfile") or print "Can't open log file: ".$logfile
		."\n<p>Check your WebGUI configuration file to set the path of the log file, 
		and check to be sure the web server has the privileges to write to the log file.";
        print $0." at ".localtime(time)." reported:<br>" if ($session{setting}{showDebug});
	print $log localtime(time)." ".$0." FATAL: ".$_[0]."\n";
        print $_[0] if ($session{setting}{showDebug});
        print "<p><h3>Caller</h3><table border=1><tr><td valign=top>" if ($session{setting}{showDebug});
        print "<b>Level 1</b><br>".join("<br>",caller(1)) if ($session{setting}{showDebug});
	print $log "\t".join(",",caller(1))."\n";
        print "</td><td valign=top>"."<b>Level 2</b><br>".join("<br>",caller(2)) if ($session{setting}{showDebug});
	print $log "\t".join(",",caller(2))."\n";
        print "</td><td valign=top>"."<b>Level 3</b><br>".join("<br>",caller(3)) if ($session{setting}{showDebug});
	print $log "\t".join(",",caller(3))."\n";
        print "</td><td valign=top>"."<b>Level 4</b><br>".join("<br>",caller(4)) if ($session{setting}{showDebug});
	print $log "\t".join(",",caller(4))."\n";
        print "</td></tr></table>" if ($session{setting}{showDebug});
	print "<h3>Form Variables</h3>" if ($session{setting}{showDebug});
	print $log "\t";
	if (exists $session{form}) {
        	foreach $key (keys %{$session{form}}) {
                	print $key." = ".$session{form}{$key}."<br>" if ($session{setting}{showDebug});
                	print $log $key."=".$session{form}{$key}." ";
        	}
		print $log "\n";
	} else {
		print "Cannot retrieve session information." if ($session{setting}{showDebug});
		print $log "Session not accessible for form variable dump.\n";
	}
	print $log "\n";
	$log->close;
        unless ($session{setting}{showDebug}) {
                print WebGUI::International::get(416).'<br>';
		print '<br>'.$session{setting}{companyName};
		print '<br>'.$session{setting}{companyEmail};
		print '<br>'.$session{setting}{companyURL};
	}
	print '<h3>Session Variables</h3><table bgcolor="#ffffff" style="color: #000000; font-size: 10pt; font-family: helvetica;">';
        while (my ($section, $hash) = each %session) {
        	while (my ($key, $value) = each %$hash) {
                	if (ref $value eq 'ARRAY') {
                        	$value = '['.join(', ',@$value).']';
                        } elsif (ref $value eq 'HASH') {
                                $value = '{'.join(', ',map {"$_ => $value->{$_}"} keys %$value).'}';
                        }
                        print '<tr><td align="right"><b>'.$section.'.'.$key.':</b></td><td>'.$value.'</td>';
                }
                print '<tr height=10><td>&nbsp;</td><td>&nbsp</td></tr>';
        }
        print '</table>';
        exit;
}

#-------------------------------------------------------------------
sub warn {
        my ($log);
        $log = FileHandle->new(">>".$session{config}{logfile}) or fatalError("Can't open log file for warning.");
        print $log localtime(time)." ".$0." WARNING: ".$_[0]."\n";
        $session{debug}{warning} .= localtime(time)." ".$0." WARNING: ".$_[0]."<p>";
	$log->close;
}

1;

