#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2009 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use strict;
use FindBin qw($Bin);
use lib "$FindBin::Bin/lib";

use File::Find;
use Pod::Checker;
use Test::More;
use WebGUI::Test;

my (@modules, @failedModules);
my $wgLib = WebGUI::Test->lib;
File::Find::find( \&getWebGUIModules, $wgLib);

plan tests => scalar(@modules);

#note("Planning on ".scalar(@modules)." tests");

my %options;
$options{-warnings} = 0; # report only errors for now
foreach my $module (@modules) {
	my $result = podchecker($module, \*STDOUT, %options);
	SKIP: {
		skip("(No POD in $module)", 1) if ($result == -1);
		is($result, 0, "POD syntax for $module");
		if ($result > 0) {
			push(@failedModules, $module);
		}
	}
}

my $numFailedModules = scalar(@failedModules);
if ($numFailedModules) {
	print "\n# The folling modules have bad POD syntax:\n";
	foreach my $module (@failedModules) {
		print "# - $module\n";
	}
	print "# Summary: $numFailedModules module".
		($numFailedModules == 1 ? '' : 's')." failed\n\n";
}

#----------------------------------------
sub getWebGUIModules {
	push( @modules, $File::Find::name ) if /\.pm$/;
}
