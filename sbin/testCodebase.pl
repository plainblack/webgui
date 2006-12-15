#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2006 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

$|=1;

use strict;
use FindBin;
use lib "$FindBin::Bin/../t/lib";
use File::Spec qw[];
use Getopt::Long;

my $configFile;
my $help;
my $verbose;
my $perlBase;
my $noLongTests;

GetOptions(
	'verbose'=>\$verbose,
	'configFile=s'=>\$configFile,
	'perl-base=s'=>\$perlBase,
	'noLongTests'=>\$noLongTests,
	'help'=>\$help,
	);

my $helpmsg=<<STOP;

	perl $0 --configFile

	--configFile		The config file of the WebGUI site you'll use
				to test the codebase. Note that you should not
				use a production config file as some tests may
				be destructive.

	--verbose		Turns on additional output.

	--perl-base		The path of the perl installation you want to 
				use. Defaults to the perl installation in your
				PATH.

	--noLongTests		Prevent long tests from being run

STOP

my $verboseFlag = "-v" if ($verbose);

$perlBase .= '/bin/' if ($perlBase);

##Defaults to command-line switch
$configFile ||= $ENV{WEBGUI_CONFIG};

if (! -e $configFile) {
	##Probably given the name of the config file with no path,
	##attempt to prepend the path to it.
	$configFile = File::Spec->canonpath($FindBin::Bin.'/../etc/'.$configFile);
}

die "Unable to use $configFile as a WebGUI config file\n"
	unless(-e $configFile and -f _);

my $prefix = "WEBGUI_CONFIG=".$configFile;

##Run all tests unless explicitly forbidden
$prefix .= " CODE_COP=1" unless $noLongTests;

print(join ' ', $prefix, $perlBase."prove", $verboseFlag, '-r ../t'); print "\n";
system(join ' ', $prefix, $perlBase."prove", $verboseFlag, '-r ../t');

