#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2002 Plain Black Software.
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


my (@files, $cmd, $namespace, $i, $file, $confdir, @plugins, $plugin, $plugdir);
if ($^O =~ /Win/i) {
        $confdir = $webguiRoot."\\etc\\";
        $plugdir = $webguiRoot."\\sbin\\Hourly\\";
} else {
        $confdir = $webguiRoot."/etc/";
        $plugdir = $webguiRoot."/sbin/Hourly/";
}

if (opendir (PLUGDIR,$plugdir)) {
	@files = readdir(PLUGDIR);
        foreach $file (@files) {
                if ($file =~ /(.*?)\.pm$/) {
                        $namespace = $1;
                        $cmd = "use Hourly::".$namespace;
                        eval($cmd);
			$plugins[$i] = "Hourly::".$namespace."::process";
			$i++;
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
					foreach $plugin (@plugins) {
						&$plugin($dbh);
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



