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
use lib '../lib';
use File::Find;
use Getopt::Long;

my $configFile;
my $help;
my $verbose;

GetOptions(
	'verbose'=>\$verbose,
	'configFile=s'=>\$configFile,
	'help'=>\$help
	);

if ($help || !$configFile) {
	print <<STOP;

	perl $0 --configFile

	--configFile		The config file of the WebGUI site you'll use
				to test the codebase. Note that you should not
				use a production config file as some tests may
				be destructive.

	--verbose		Turns on additional output.

STOP
	exit;
}

my $verboseFlag = "-v" if ($verbose);
system("WEBGUI_LIB=../lib WEBGUI_CONFIG=../etc/".$configFile." prove ".$verboseFlag." -r ../t");



