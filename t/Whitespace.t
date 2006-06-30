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

#---------------------------------------------------------------------
# Note: this test checks for non-empty lines before POD commands
# which are not detected by podchecker, but are causing problems
# for pod2html (might be a bug in the latter). This results in badly
# formatted and invalid API documentation.
#---------------------------------------------------------------------
sub checkContent {
	my $content = shift;
	my @content = @{$content};

	my $podAllowed = 0;
	foreach my $line (@content) {
		chomp $line;
		my $isPodWord = ($line =~ m/^=/);
		if ($isPodWord && !$podAllowed) {
			diag $line;
			return 1;
		}
		# POD is allowed on next line if current line is empty
		$podAllowed = ($line eq '');
	}

	return 0;
}

