#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2009 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use FindBin;
use strict;
use lib "$FindBin::Bin/../lib";

use WebGUI::Test;
use WebGUI::Session;
use WebGUI::Macro::FormParam;

use Test::More; # increment this value for each test you create
use Test::MockObject;
use WebGUI::Form_Checking;

my $session = WebGUI::Test->session;

my @testSets = (
	{
		key => 'FormParam1',
		testValue => 'a',
		expected  => 'EQUAL',
		comment   => 'scalar data, alpha',
		dataType  => 'SCALAR'
	},
	{
		key => 'FormParam2',
		testValue => 100,
		expected  => 'EQUAL',
		comment   => 'scalar data, numeric',
		dataType  => 'SCALAR'
	},
	{
		key => 'FormParam3',
		testValue => [qw/a b c/],
		expected  => "a",
		comment   => 'array data, alpha',
		dataType  => 'SCALAR'
	},
	{
		key => 'FormParam4',
		testValue => [qw/b c a/],
		expected  => "b",
		comment   => 'array data, alpha, non-alpha order',
		dataType  => 'SCALAR'
	},
);

my $numTests = scalar @testSets;

$numTests += 1; ##testBlock has no name collisions
$numTests += 3; ##TODO block

plan tests => $numTests;

WebGUI::Form_Checking::auto_check($session, \@testSets);

TODO: {
	local $TODO = "Tests to write later";
	ok(0, "What will this do with a non-existant form param?");
	ok(0, "Also try null");
	ok(0, "Also try undef");
}

