#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2006 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

 
our $webguiRoot;

BEGIN {
        $webguiRoot = "..";
        unshift (@INC, $webguiRoot."/lib");
}

use DBI;
use Getopt::Long;
use strict qw(subs vars);
use WebGUI::Session;
use WebGUI::Utility;

$|=1;

my $verbose;
my $help;

GetOptions(
        'help'=>\$help,
        'verbose'=>\$verbose
);

if ($help) {
	print <<STOP;


Usage: perl $0

Options:

        --help		Displays this message.

	--verbose	Displays output describing the scheduler's
			activities.

STOP
	exit;
}

print "\nStarting.\n\n" if ($verbose);

my (@files, $cmd, $namespace, $file, $slash, $confdir, %plugins, $plugdir, $exclude);
$slash = ($^O =~ /^Win/i) ? "\\" : "/";
$confdir = $webguiRoot.$slash."etc".$slash;
$plugdir = $webguiRoot.$slash."sbin".$slash."Hourly".$slash;

print "Locating plug-ins:\n" if ($verbose);
if (opendir (PLUGDIR,$plugdir)) {
	@files = readdir(PLUGDIR);
        foreach $file (@files) {
                if ($file =~ /(.*?)\.pm$/) {
                        $namespace = $1;
			print "\tFound ".$namespace."\n" if ($verbose);
                        $cmd = "use Hourly::".$namespace;
                        eval($cmd);
			$plugins{$namespace} = "Hourly::".$namespace."::process";
                }
        }
        closedir(PLUGDIR);
} else {
	print "Can't open $plugdir.\n";
	exit;
}


if (opendir (CONFDIR,$confdir)) {
        @files = readdir(CONFDIR);
        foreach $file (@files) {
                if ($file =~ /(.*?)\.conf$/ && $file ne "some_other_site.conf" && !($file =~ /log\.conf/ || $file =~ /(.*?)log\.conf$/)) {
			print "\nProcessing ".$file.":\n" if ($verbose);
			my $startTime = time();
			WebGUI::Session::open($webguiRoot,$file);
			if ($session{setting}{specialState} eq "upgrading") {
				print "\nSkipping because this site is undergoing an upgrade.\n" if ($verbose);
				WebGUI::Session::close();
				next;
			}
			WebGUI::Session::refreshUserInfo(3,$session{dbh});
			foreach $namespace (keys %plugins) {
				my $taskTime = time();
				print "\t".$namespace if ($verbose);
				$exclude = $session{config}{excludeHourly};
				$exclude =~ s/ //g;
				unless (isIn($namespace, split(/,/,$exclude))) {
					$cmd = $plugins{$namespace};
					&$cmd($verbose);
				}
				print " (".(time()-$taskTime)." seconds)\n" if ($verbose);
			}
			WebGUI::Session::end($session{var}{sessionId});
			WebGUI::Session::close();
			print "\tTOTAL TIME: ".(time()-$startTime)." seconds\n" if ($verbose);
		}
	}
	closedir(CONFDIR);
} else {
        print "Can't open $confdir.\n";
	exit;
}

print "\nFinished.\n" if ($verbose);


