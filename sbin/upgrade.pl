#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2002 Plain Black LLC.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

our ($webguiRoot, $mysql);
$mysql = "/usr/bin/mysql";
$mysqldump = "/usr/bin/mysqldump";
$backupDir = $ARGV[0] || "/data/backups";

BEGIN {
        $webguiRoot = "..";
        unshift (@INC, $webguiRoot."/lib");
}

#-----------------------------------------
# NO NEED TO MODIFY BELOW THIS LINE


if  (!($^O =~ /Win/i) && $> !=  0) {
	print "You must be the super user to use this utility.\n";
	exit;
}


use Data::Config;
use DBI;
use WebGUI::SQL;

$|=1;
my ($upgrade, @files, $file, $dbh, $config, $dir, %upgrade, %config);


print "\nLooking for upgrade files...\n";
if ($^O =~ /Win/i) {
        $dir = $webguiRoot."\\docs\\upgrades\\";
} else {
        $dir = $webguiRoot."/docs/upgrades/";
}
opendir(DIR,$dir) or die "Couldn't open $dir\n";
@files = readdir(DIR);
closedir(DIR);
foreach $file (@files) {
	if ($file =~ /upgrade_(\d+\.\d+.\d+)-(\d+\.\d+\.\d+)\.(\w+)/) {
		if (checkVersion($1)) {
			if ($3 eq "sql") {
				print "Found upgrade script from $1 to $2.\n";
				$upgrade{$1}{sql} = $dir.$file;
			} elsif ($3 eq "pl") {
				print "Found upgrade executable from $1 to $2.\n";
				$upgrade{$1}{pl} = $dir.$file;
			}
			$upgrade{$1}{from} = $1;
			$upgrade{$1}{to} = $2;
		}
	}
}



print "\nGetting site configs...\n";
if ($^O =~ /Win/i) {
        $dir = $webguiRoot."\\etc\\";
} else {
        $dir = $webguiRoot."/etc/";
}
opendir (DIR,$dir) or die "Can't open $dir\n";
@files=readdir(DIR);
closedir(DIR);
foreach $file (@files) {
	if ($file =~ /(.*?)\.conf$/ && $file ne "some_other_site.conf") {
		print "Found $file.\n";
		$config{$file}{configFile} = $dir.$file;
		my $config = new Data::Config $config{$file}{configFile};
		$config{$file}{dsn} = $config->param('dsn');
		$config{$file}{dsn} =~ /DBI\:mysql\:(\w+).*/;
		$config{$file}{db} = $1;
		$config{$file}{dbuser} = $config->param('dbuser');
		$config{$file}{dbpass} = $config->param('dbpass');
		$dbh = DBI->connect($config{$file}{dsn},$config{$file}{dbuser},$config{$file}{dbpass});
		($config{$file}{version}) = WebGUI::SQL->quickArray("select webguiVersion from webguiVersion order by dateApplied desc, webguiVersion desc limit 1",$dbh);
		$dbh->disconnect;
	}
}



print "\nREADY TO BEGIN UPGRADES\n";
mkdir($backupDir);
mkdir($backupDir."/db");

foreach $config (keys %config) {
	while ($upgrade{$config{$config}{version}}{sql} ne "") {
		$upgrade = $upgrade{$config{$config}{version}}{from};
		print "\n".$config{$config}{db}." ".$upgrade{$upgrade}{from}."-".$upgrade{$upgrade}{to}."\n";
		print "\tBacking up $config{$config}{db} ($upgrade{$upgrade}{from}).\n";
		mkdir($backupDir."/db/".$config{$config}{db});
		system($mysqldump." -u".$config{$config}{dbuser}." -p".$config{$config}{dbpass}." --add-drop-table ".$config{$config}{db}." > ".$backupDir."/db/".$config{$config}{db}."/".$upgrade{$upgrade}{from}.".sql");
		print "\tUpgrading to $upgrade{$upgrade}{to}.\n";
		system($mysql." -u".$config{$config}{dbuser}." -p".$config{$config}{dbpass}." --add-drop-table ".$config{$config}{db}." < ".$upgrade{$upgrade}{sql});
		$config{$config}{version} = $upgrade{$upgrade}{to};
	}
}

print "\nUPGRADES COMPLETE\n";

print "Please restart your web server and test your sites.\n";

print "\nNOTE: If you have not already done so, please consult\ndocs/gotcha.txt for possible upgrade complications.\n\n";


#-----------------------------------------
# checkVersion($versionNumber)
#-----------------------------------------
# Version number must be 3.5.1 or greater
# in order to be upgraded by this utility.
#-----------------------------------------
sub checkVersion {
	$_[0] =~ /(\d+)\.(\d+).(\d+)/;
        if ($1 > 3) {
        	return 1;
        } elsif ($1 == 3) {
        	if ($2 > 5) {
                	return 1;
                } elsif ($2 == 5) {
                	if ($3 > 0) {
                        	return 1;
                        } else {
				return 0;
			}
                } else {
			return 0;
		}
        } else {
		return 0;
	}
}





