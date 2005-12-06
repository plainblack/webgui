#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2005 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

our ($webguiRoot);

BEGIN {
        $webguiRoot = "..";
        unshift (@INC, $webguiRoot."/lib");
}

use DBI;
use File::Path;
use Getopt::Long;
use strict;
use WebGUI::Config;
use WebGUI::Session;
use WebGUI::Setting;
use WebGUI::SQL;

my $help;
my $history;
my $override;
my $quiet;
my $mysql = "/usr/bin/mysql";
my $mysqldump = "/usr/bin/mysqldump";
my $backupDir = "/tmp/backups";
my $skipBackup;
my $doit;

GetOptions(
        'help'=>\$help,
        'history'=>\$history,
        'override'=>\$override,
        'quiet'=>\$quiet,
	'mysql=s'=>\$mysql,
	'doit'=>\$doit,
	'mysqldump=s'=>\$mysqldump,
	'backupDir=s'=>\$backupDir,
	'skipbackup'=>\$skipBackup
);


if ($help){
        print <<STOP;


Usage: perl $0 --doit

Options:

	--backupDir	The folder where backups should be
			created. Defaults to '/data/backups'.

	--doit		This flag is required. You MUST include this
			flag in your command line or the upgrade
                        will not run.

        --help          Display this help message and exit.

	--history	Displays the upgrade history for each of
			your sites. Note that running with this
			flag will NOT run the upgrade.

	--mysql		The path to your mysql client executable.
			Defaults to '/usr/bin/mysql'.

	--mysqldump	The path to your mysqldump executable.
			Defaults to '/usr/bin/mysqldump'.

        --override      This utility is designed to be run as
                        a privileged user on Linux style systems.
                        If you wish to run this utility without
                        being the super user, then use this flag,
                        but note that it may not work as
                        intended.

        --quiet         Disable output unless there's an error.

	--skipBackup	Backups will not be performed during the
			upgrade.

STOP
        exit;
}



unless ($doit) {
	print <<STOP;

+--------------------------------------------------------------------+
|                                                                    |
|                         W  A  R  N  I  N  G                        |
|                                                                    |
| There are no guarantees of any kind provided with this software.   |
| This utility has been tested rigorously, and has performed without |
| error or consequence in our labs, and on our production servers    |
| for many years. However, there is no substitute for a good backup  |
| of your software and data before performing any kind of upgrade.   |
|                                                                    |
| BEFORE YOU UPGRADE you should definitely read docs/gotcha.txt to   |
| find out what things you should know about that will affect your   |
| upgrade.                                                           |
|                                                                    |
+--------------------------------------------------------------------+
|                                                                    |
| For more information about this utility type:                      |
|                                                                    |
| perl upgrade.pl --help                                             |
|                                                                    |
+--------------------------------------------------------------------+

STOP
	exit;
}


if (!($^O =~ /^Win/i) && $> != 0 && !$override) {
	print "You must be the super user to use this utility.\n";
	exit;
}

## Globals

$| = 1;
our $perl = $^X;
our $slash;
if ($^O =~ /^Win/i) {
	$slash = "\\";
} else {
	$slash = "/";
}
our $upgradesPath = $webguiRoot.$slash."docs".$slash."upgrades".$slash;
our (%upgrade, %config);


## Find site configs.

print "\nGetting site configs...\n" unless ($quiet);
my $configs = WebGUI::Config::readAllConfigs($webguiRoot);
foreach my $filename (keys %{$configs}) {
	print "\tProcessing $filename.\n" unless ($quiet);
	$config{$filename}{configFile} = $filename;
	$config{$filename}{dsn} = $configs->{$filename}{dsn};
	my $temp = _parseDSN($config{$filename}{dsn}, ['database', 'host', 'port']);
	if ($temp->{'driver'} eq "mysql") {
		$config{$filename}{db} = $temp->{'database'};
		$config{$filename}{host} = $temp->{'host'};
		$config{$filename}{port} = $temp->{'port'};
		$config{$filename}{dbuser} = $configs->{$filename}{dbuser};
		$config{$filename}{dbpass} = $configs->{$filename}{dbpass};
		$config{$filename}{mysqlCLI} = $configs->{$filename}{mysqlCLI};
		$config{$filename}{mysqlDump} = $configs->{$filename}{mysqlDump};
		$config{$filename}{backupPath} = $configs->{$filename}{backupPath};
		my $dbh = DBI->connect($config{$filename}{dsn},$config{$filename}{dbuser},$config{$filename}{dbpass});
		($config{$filename}{version}) = WebGUI::SQL->quickArray("select webguiVersion from webguiVersion 
			order by dateApplied desc, webguiVersion desc limit 1",$dbh);
		unless ($history) {
			print "\tPreparing site for upgrade.\n" unless ($quiet);
				WebGUI::Session::open($webguiRoot,$filename);
				WebGUI::Setting::remove('specialState');
				WebGUI::Setting::add('specialState','upgrading');
				WebGUI::Session::close();
				rmtree($configs->{$filename}{uploadsPath}.$slash."temp");
		}
		$dbh->disconnect;
	} else {
		delete $config{$filename};
		print "\tSkipping non-MySQL database.\n" unless ($quiet);
	}
}

if ($history) {
	print "\nDisplaying upgrade history for each site.\n";
	require WebGUI::DateTime;
	foreach my $file (keys %config) {
		print "\n".$file."\n";
		my $dbh = DBI->connect($config{$file}{dsn},$config{$file}{dbuser},$config{$file}{dbpass});
		my $sth = WebGUI::SQL->read("select * from webguiVersion order by dateApplied asc, webguiVersion asc",$dbh);
		while (my $data = $sth->hashRef) {
			print "\t".sprintf("%-8s  %-15s  %-15s",
				$data->{webguiVersion},
				WebGUI::DateTime::epochToHuman($data->{dateApplied},"%y-%m-%d"),
				$data->{versionType})."\n";
		}
		$sth->finish;
		$dbh->disconnect;		
	}
	exit;
}

## Find upgrade files.

print "\nLooking for upgrade files...\n" unless ($quiet);
opendir(DIR,$upgradesPath) or die "Couldn't open $upgradesPath\n";
my @files = readdir(DIR);
closedir(DIR);
foreach my $file (@files) {
	if ($file =~ /^upgrade_(\d+\.\d+\.\d+)-(\d+\.\d+\.\d+)\.(pl|sql)$/) {
		if (checkVersion($1)) {
			if ($3 eq "sql") {
				print "\tFound upgrade script from $1 to $2.\n" unless ($quiet);
				$upgrade{$1}{sql} = $file;
			} elsif ($3 eq "pl") {
				print "\tFound upgrade executable from $1 to $2.\n" unless ($quiet);
				$upgrade{$1}{pl} = $file;
			}
			$upgrade{$1}{from} = $1;
			$upgrade{$1}{to} = $2;
		}
	}
}

print "\nREADY TO BEGIN UPGRADES\n" unless ($quiet);

my $notRun = 1;
			
chdir($upgradesPath);
foreach my $filename (keys %config) {
	my $clicmd = $config{$filename}{mysqlCLI} || $mysql;
	my $dumpcmd = $config{$filename}{mysqlDump} || $mysqldump;
	my $backupTo = $config{$filename}{backupPath} || $backupDir;
	mkdir($backupTo);
	while ($upgrade{$config{$filename}{version}}{sql} ne "" || $upgrade{$config{$filename}{version}}{pl} ne "") {
		my $upgrade = $upgrade{$config{$filename}{version}}{from};
		unless ($skipBackup) {
			print "\n".$config{$filename}{db}." ".$upgrade{$upgrade}{from}."-".$upgrade{$upgrade}{to}."\n" unless ($quiet);
			print "\tBacking up $config{$filename}{db} ($upgrade{$upgrade}{from})..." unless ($quiet);
			my $cmd = qq!$dumpcmd -u"$config{$filename}{dbuser}" -p"$config{$filename}{dbpass}"!;
			$cmd .= " --host=".$config{$filename}{host} if ($config{$filename}{host});
			$cmd .= " --port=".$config{$filename}{port} if ($config{$filename}{port});
			$cmd .= " --add-drop-table --databases ".$config{$filename}{db}." > "
				.$backupTo.$slash.$config{$filename}{db}."_".$upgrade{$upgrade}{from}.".sql";
			unless (system($cmd)) {
				print "OK\n" unless ($quiet);
			} else {
				print "Failed!\n" unless ($quiet);
				fatalError();
			}
		}
		if ($upgrade{$upgrade}{sql} ne "") {
			print "\tUpgrading to ".$upgrade{$upgrade}{to}."..." unless ($quiet);
			my $cmd = qq!$clicmd -u"$config{$filename}{dbuser}" -p"$config{$filename}{dbpass}"!;
			$cmd .= " --host=".$config{$filename}{host} if ($config{$filename}{host});
			$cmd .= " --port=".$config{$filename}{port} if ($config{$filename}{port});
			$cmd .= " --database=".$config{$filename}{db}." < ".$upgrade{$upgrade}{sql};
			unless (system($cmd)) {
				print "OK\n" unless ($quiet);
			} else {
                		print "Failed!\n" unless ($quiet);
				fatalError();
                	}
		}
		if ($upgrade{$upgrade}{pl} ne "") {
			my $cmd = $perl." ".$upgrade{$upgrade}{pl}." --configFile=".$filename;
			$cmd .= " --quiet" if ($quiet);
			if (system($cmd)) {
				print "\tProcessing upgrade executable failed!\n";
				fatalError();
			}
		}
		$config{$filename}{version} = $upgrade{$upgrade}{to};
		$notRun = 0;
	}
	WebGUI::Session::open("../..",$filename);
	print "\tSetting site upgrade completed..." unless ($quiet);
	WebGUI::Setting::remove('specialState');
	WebGUI::Session::close();
	print "OK\n" unless ($quiet);
}

if ($notRun) {
	print "\nNO UPGRADES NECESSARY\n\n" unless ($quiet);
} else {
	unless ($quiet) {
		print <<STOP;

UPGRADES COMPLETE
Please restart your web server and test your sites.

NOTE: If you have not already done so, please consult
docs/gotcha.txt for possible upgrade complications.

STOP
	}
}




#-----------------------------------------
# checkVersion($versionNumber)
#-----------------------------------------
# Version number must be 6.2.0 or greater
# in order to be upgraded by this utility.
#-----------------------------------------
sub checkVersion {
	$_[0] =~ /(\d+)\.(\d+)\.(\d+)/; 
	my $goal = 6;
	my $feature = 2;
	my $fix = 0;
        if ($1 > $goal) {
        	return 1;
        } elsif ($1 == $goal) {
        	if ($2 > $feature) {
                	return 1;
                } elsif ($2 == $feature) {
                	if ($3 >= $fix) {
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

#-----------------------------------------
sub fatalError {
	print <<STOP;

The upgrade process failed and has stopped so you can either restore
from backup, or attempt to fix the problem and continue.

STOP
	exit;
}


#-----------------------------------------
sub _parseDSN {
    my($dsn, $args) = @_;
    my($var, $val, $hash);
    $hash = {};

    if (!defined($dsn)) {
        return;
    }

    $dsn =~ s/^dbi:(\w*?)(?:\((.*?)\))?://i
                        or '' =~ /()/; # ensure $1 etc are empty if match fails
    $hash->{driver} = $1;

    while (length($dsn)) {
        if ($dsn =~ /([^:;]*)[:;](.*)/) {
            $val = $1;
            $dsn = $2;
        } else {
            $val = $dsn;
            $dsn = '';
        }
        if ($val =~ /([^=]*)=(.*)/) {
            $var = $1;
            $val = $2;
            if ($var eq 'hostname'  ||  $var eq 'host') {
                $hash->{'host'} = $val;
            } elsif ($var eq 'db'  ||  $var eq 'dbname') {
                $hash->{'database'} = $val;
            } else {
                $hash->{$var} = $val;
            }
        } else {
            foreach $var (@$args) {
                if (!defined($hash->{$var})) {
                    $hash->{$var} = $val;
                    last;
                }
            }
        }

     }
     return $hash;
}
