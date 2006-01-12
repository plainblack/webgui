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
# ---- END DO NOT EDIT ----


use Test::More;

my $session = initialize();  # this line is required

my @modules = ();
find(\&countModules, "../lib/WebGUI");
my $moduleCount = scalar(@modules);
diag("Planning on running $moduleCount tests\n");
plan tests => $moduleCount;
foreach my $package (sort @modules) {
	my $pc = Pod::Coverage->new(package=>$package);
	ok($pc->coverage, $package);
}

cleanup($session); # this line is required

sub countModules {
	my $filename = $File::Find::dir."/".$_;
	return unless $filename =~ m/\.pm$/;
	return if $filename =~ m/WebGUI\/i18n/;
	return if $filename =~ m/WebGUI\/Help/;
	my $package = $filename;
	$package =~ s/^\.\.\/lib\/(.*)\.pm$/$1/;
	$package =~ s/\//::/g;
	push(@modules,$package);
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

