#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2005 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

$|=1;

use strict;
use lib '../..';
use Getopt::Long;

my $configFile;
my $help;

GetOptions(
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

STOP
	exit;
}

opendir(DIR,"../t");
my @files = readdir(DIR);
closedir(DIR);

chdir("../t");
my $someTestFailed = 0;
my @failedModules;
foreach my $file (@files) {
	next unless $file =~ m/^(.*?)\.t$/;
	my $testType = $1;
	$testType =~ s/_/ /g;
	print "Running $testType tests...\n";
	unless (system("$^X $file --configFile=$configFile")) {
		print "All $testType tests were successful.\n";
	} else {
		push(@failedModules,$testType);
		$someTestFailed++;
		print "----------------------------\n";
		print "Some $testType tests failed!\n";
		print "----------------------------\n";
		sleep(2);
	}
	print "\n";
}
if ($someTestFailed) {
	print "\n\n";
	print "---------------------------------------\n";
	print " $someTestFailed test modules experienced failures:\n";
	print "\t".join("\n\t",@failedModules)."\n";
	print "---------------------------------------\n";
	print "\n\n";
}
exit $someTestFailed;

