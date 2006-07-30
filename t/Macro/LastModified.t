#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2006 Plain Black Corporation.
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

use Test::More; # increment this value for each test you create

my $session = WebGUI::Test->session;

my $homeAsset = WebGUI::Asset->getDefault($session);

##Make the homeAsset the default asset in the session.
$session->asset($homeAsset);

my ($time) = $session->dbSlave->quickArray("SELECT max(revisionDate) FROM assetData where assetId=?",[$homeAsset->getId]);

my @testSets = (
	{
		label => q!!,
		format => q!!,
		output => $session->datetime->epochToHuman($time,'%z'),
		comment => 'checking defaults with empty args',
	},
	{
		label => q!Last modified on: !,
		format => q!!,
		output => 'Last modified on: '.$session->datetime->epochToHuman($time,'%z'),
		comment => 'checking label, empty format',
	},
	{
		label => '',
		format => q!%c %y!,
		output => $session->datetime->epochToHuman($time,'%c %y'),
		comment => 'checking format, empty label',
	},
);

my $numTests = scalar @testSets;

$numTests += 1; #For the use_ok
$numTests += 2; #For TODO tests

plan tests => $numTests;

my $macro = 'WebGUI::Macro::LastModified';
my $loaded = use_ok($macro);

SKIP: {

skip "Unable to load $macro", $numTests-1 unless $loaded;


foreach my $testSet (@testSets) {
	my $output = WebGUI::Macro::LastModified::process($session, $testSet->{label}, $testSet->{format});
	is($output, $testSet->{output}, $testSet->{comment});
}

}

TODO: {
	local $TODO = "Tests to make later";
	ok(0, 'Check label and format');
	ok(0, 'Create asset with revisionDate = 0 and check label "never"');
}
