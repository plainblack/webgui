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

use WebGUI::Test;
use WebGUI::Session;
use WebGUI::Macro::LastModified;

use Test::More; # increment this value for each test you create

my $session = WebGUI::Test->session;

my $homeAsset = WebGUI::Asset->getDefault($session);

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

$numTests += 2; #For the use_ok, default asset, and revisionDate=0

plan tests => $numTests;

my $versionTag = WebGUI::VersionTag->getWorking($session);
addToCleanup($versionTag);

my $output = WebGUI::Macro::LastModified::process($session);
is($output, '', "Macro returns '' if no asset is defined");

##Make the homeAsset the default asset in the session.
$session->asset($homeAsset);

foreach my $testSet (@testSets) {
	my $output = WebGUI::Macro::LastModified::process($session, $testSet->{label}, $testSet->{format});
	is($output, $testSet->{output}, $testSet->{comment});
}

$versionTag->set({name=>"Adding assets for LastModified macro tests"});

my $root = WebGUI::Asset->getRoot($session);
my %properties_A = (
		className   => 'WebGUI::Asset',
		title       => 'Asset A',
		url         => 'asset-a',
		ownerUserId => 3,
		groupIdView => 7,
		groupIdEdit => 3,
		id          => 'RootA-----------------',
		#              '1234567890123456789012'
);

my $assetA = $root->addChild(\%properties_A, $properties_A{id}, 0e0);
$versionTag->commit;

##Save the original revisionDate and then rewrite it in the db to be 0
my $revDate = $session->db->quickArray('select max(revisionDate) from assetData where assetId=?', [$assetA->getId]);
$session->db->write('update assetData set revisionDate=0 where assetId=?', [$assetA->getId]);

$session->asset($assetA);
$output = WebGUI::Macro::LastModified::process($session);
my $i18n = WebGUI::International->new($session, 'Macro_LastModified');
is($output, $i18n->get('never'), 'asset with 0 revisionDate returns never modified label');

##Restore the original revisionDate, otherwise it dies during clean-up
$session->db->write('update assetData set revisionDate=? where assetId=?', [$revDate, $assetA->getId]);
