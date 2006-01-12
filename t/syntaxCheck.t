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
use File::Find;
# ---- END DO NOT EDIT ----


use Test::More; # increment this value for each test you create
my @modules;
my $wgLib = "../lib/";
diag("Checking modules in $wgLib");
File::Find::find(\&getWebGUIModules, $wgLib);

my $numTests = scalar @modules;

plan tests => $numTests;

diag("Planning on $numTests tests");

foreach my $package (@modules) {
	my $returnVal = system("export PERL5LIB=$wgLib; perl -wc $package");
	is($returnVal, 0, "syntax check for $package");
}

my $session = initialize();  # this line is required

# put your tests here

cleanup($session); # this line is required

#----------------------------------------
sub getWebGUIModules {
	push(@modules,$File::Find::name) if /\.pm$/;
}


# ---- DO NOT EDIT BELOW THIS LINE -----

sub initialize {
        $|=1; # disable output buffering
        my $configFile;
        GetOptions(
                'configFile=s'=>\$configFile
        );
        exit 1 unless ($configFile);
        my $session = WebGUI::Session->open("..",$configFile);
}

sub cleanup {
        my $session = shift;
        $session->close();
}

