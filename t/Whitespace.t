#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2005 Plain Black Corporation.
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
use Test::More tests => 1; # increment this value for each test you create
use WebGUI::Test;

my (@modules, @failedModules);
my $wgLib = WebGUI::Test->lib;
File::Find::find( \&getWebGUIModules, $wgLib);

my $numFailedModules = checkModules();
is($numFailedModules, 0, "No erroneous whitespace in or before POD");

if ($numFailedModules) {
	print "\n# The folling modules have erroneous whitespace in or before POD:\n";
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

sub checkModules {
	foreach my $module (@modules) {
		open(FILE, "< $module") or die "Can't open file $module";
		my @content = <FILE>;
		close FILE;

		if (checkContent(\@content)) {
			push(@failedModules, $module);
		}
	}
	return scalar(@failedModules);
}

sub checkContent {
	my $content = shift;
	my @content = @{$content};

	my $badEnd = 0;
	foreach my $line (@content) {
		my $isPodWord = ($line =~ m/^=/);
		return 1 if ($isPodWord && $badEnd);
		$badEnd = ($line =~ m/[ \t]$/);
	}

	return 0;
}

