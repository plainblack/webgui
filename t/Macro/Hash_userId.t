#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2009 Plain Black Corporation.
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
use WebGUI::Session;
use WebGUI::Macro::Hash_userId;
use Data::Dumper;

my $session = WebGUI::Test->session;

use Test::More; # increment this value for each test you create

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
	my $output = WebGUI::Macro::Hash_userId::process($session);
	is($output, $testSet->{userId}, 'testing '.$testSet->{comment});
}
