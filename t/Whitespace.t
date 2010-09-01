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

use File::Find;
use Test::More;
use WebGUI::Test;

my (@modules, @failedModules);
my $wgLib = WebGUI::Test->lib;
File::Find::find( \&getWebGUIModules, $wgLib);

plan tests => scalar(@modules);

foreach my $module (@modules) {
	open(FILE, "< $module") or die "Can't open file $module";
	my @content = <FILE>;
	close FILE;

	my $lineNumber = checkContent(\@content);
	is($lineNumber, 0, "Whitespace test for $module");

	if ($lineNumber > 0) {
		push(@failedModules, $module);
		diag("Failed on $module, near line $lineNumber");
	}
}
my $numFailedModules = scalar(@failedModules);

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
	if ($File::Find::name =~ m#/(?:Help|i18n)/?$#) {
		$File::Find::prune=1;
		return;
	}
	push( @modules, $File::Find::name ) if /\.pm$/;
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

	my $podAllowed = 1;
	my $lineNumber = 1;
	foreach my $line (@content) {
		chomp $line;
		my $isPodWord = ($line =~ m/^=/);
		if ($isPodWord && !$podAllowed) {
			return $lineNumber;
		}
		# POD is allowed on next line if current line is empty
		$podAllowed = ($line eq '');
		$lineNumber++;
	}

	return 0;
}

