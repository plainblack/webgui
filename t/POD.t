#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2005 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

# ---- BEGIN DO NOT EDIT ----
use strict;
use lib '../lib';
use Getopt::Long;
use Pod::Coverage;
use File::Find;
use WebGUI::Session;
# ---- END DO NOT EDIT ----


use Test::More;

initialize();  # this line is required

my $moduleCount = 0;
find(\&countModules, "../lib/WebGUI");
diag("Planning on running $moduleCount tests\n");
plan tests => $moduleCount;
find(\&checkPod, "../lib/WebGUI");

cleanup(); # this line is required

sub countModules {
	my $filename = $_;
	return unless $filename =~ m/\.pm$/;
	$moduleCount++;
}

sub checkPod {
	my $filename = $File::Find::dir."/".$_;
	return unless $filename =~ m/\.pm$/;
	my $package = $filename;
	$package =~ s/^\.\.\/lib\/(.*)\.pm$/$1/;
	$package =~ s/\//::/g;
	my $pc = Pod::Coverage->new(package=>$package);
	print $package.":".$pc->coverage.$pc->why_unrated."\n";
	#ok($pc->coverage, $package);
}


# ---- DO NOT EDIT BELOW THIS LINE -----

sub initialize {
	$|=1; # disable output buffering
	my $configFile;
	GetOptions(
        	'configFile=s'=>\$configFile
	);
	exit 1 unless ($configFile);
	WebGUI::Session::open("..",$configFile);
}

sub cleanup {
	WebGUI::Session::close();
}

