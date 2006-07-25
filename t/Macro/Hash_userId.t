#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2006 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

##The goal of this test is to make sure the Hash_userId macro works.

use FindBin;
use strict;
use lib "$FindBin::Bin/../lib";

use WebGUI::Test;
use WebGUI::Macro;
use WebGUI::Session;
use Data::Dumper;
use WebGUI::Macro_Config;

my $session = WebGUI::Test->session;

use Test::More; # increment this value for each test you create

my @added_macros = ();
push @added_macros, WebGUI::Macro_Config::enable_macro($session, '#', 'Hash_userId');

my @testSets = (
	{
	userId => 1,
	comment => q!Visitor!,
	},
	{
	userId => 3,
	comment => q!Admin!,
	},
);

my $numTests = scalar @testSets;

plan tests => $numTests;

foreach my $testSet (@testSets) {
	$session->user({userId => $testSet->{userId}});
	my $output = "^#;";
	WebGUI::Macro::process($session, \$output);
	is($output, $testSet->{userId}, 'testing '.$testSet->{comment});
}

END {
	foreach my $macro (@added_macros) {
		next unless $macro;
		$session->config->deleteFromHash("macros", $macro);
	}
}
