#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2007 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use FindBin;
use strict;
use lib "$FindBin::Bin/lib";

use WebGUI::Test;
use File::Find;
use WebGUI::Session;
use Test::More;

plan skip_all => 'set TEST_SYNTAX to enable this test' unless $ENV{TEST_SYNTAX};

my @modules;
my $wgLib = WebGUI::Test->lib;
#diag("Checking modules in $wgLib");
File::Find::find( \&getWebGUIModules, $wgLib);

my $numTests = scalar @modules;

plan tests => $numTests;

#diag("Planning on $numTests tests");

foreach my $package (@modules) {
	my $command = "$^X -I$wgLib -wc $package 2>&1";
	my $output = `$command`;
	is($?, 0, "syntax check for $package");
}

#----------------------------------------
sub getWebGUIModules {
	push( @modules, $File::Find::name ) if /\.pm$/;
}
