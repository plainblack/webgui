#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2002 Plain Black LLC.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

 
our $webguiRoot;

BEGIN {
        $webguiRoot = $ARGV[0] || "..";
        unshift (@INC, $webguiRoot."/lib");
}

use DBI;
use strict qw(subs vars);
use Data::Config;
use WebGUI::Utility;


my (@files, $cmd, $namespace, $file, $slash, $confdir, %plugins, $plugdir, $exclude);
$slash = ($^O =~ /Win/i) ? "\\" : "/";
$confdir = $webguiRoot.$slash."etc".$slash;
$plugdir = $webguiRoot.$slash."sbin".$slash."Hourly".$slash;

if (opendir (PLUGDIR,$plugdir)) {
	@files = readdir(PLUGDIR);
        foreach $file (@files) {
                if ($file =~ /(.*?)\.pm$/) {
                        $namespace = $1;
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
                if ($file =~ /(.*?)\.conf$/ && $file ne "some_other_site.conf") {
                        my ($config);
                        $config = new Data::Config $confdir.$file;
                        unless ($config->param('dsn') eq "") {    
				my $dbh;
				unless (eval {$dbh = DBI->connect($config->param('dsn'),$config->param('dbuser'),$config->param('dbpass'))}) {
                                        print "Can't connect to ".$config->param('dsn')." with info provided. Skipping.\n";
                                } else {
					foreach $namespace (keys %plugins) {
						$exclude = $config->param('excludeHourly');
						$exclude =~ s/ //g;
						unless (isIn($namespace, split(/,/,$exclude))) {
							$cmd = $plugins{$namespace};
							&$cmd($dbh);
						}
					}
                                        $dbh->disconnect();
                                } 
			} else {
				print "$file has some problems. Skipping\n";
			}
		}
	}
	closedir(CONFDIR);
} else {
        print "Can't open $confdir.\n";
	exit;
}



