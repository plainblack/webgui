#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2012 Plain Black Corporation.
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
use WebGUI::Macro::RootTitle;
use Data::Dumper;

use Test::More; # increment this value for each test you create

my $session = WebGUI::Test->session;

##Build this structure in Snippet Assets because it's easy
#         defaultRoot
#          /  |    \ 
#         /   |     \
#        /    |      \
#    A        Z      defaultHome   <=== "ROOTS"
#    |       / \
#    B      Y   X

my $versionTag = WebGUI::VersionTag->getWorking($session);
$versionTag->set({name=>"Adding assets for RootTitle tests"});
WebGUI::Test->addToCleanup($versionTag);

my $root = WebGUI::Asset->getRoot($session);
my %properties_A = (
		className   => 'WebGUI::Asset::Snippet',
		title       => 'Asset A',
		url         => 'asset-a',
		snippet     => 'root A',
		ownerUserId => 3,
		groupIdView => 7,
		groupIdEdit => 3,
		id          => 'RootA-----------------',
		#              '1234567890123456789012'
);


my $assetA = $root->addChild(\%properties_A, $properties_A{id});

my %properties_B = (
		className   => 'WebGUI::Asset::Snippet',
		title       => 'Asset B',
		url         => 'asset-b',
		snippet     => 'Asset B',
		ownerUserId => 3,
		groupIdView => 7,
		groupIdEdit => 3,
		#              '1234567890123456789012'
		id          => 'RootA-AssetB----------',
);

my $assetB = $assetA->addChild(\%properties_B, $properties_B{id});

my %properties_Z = (
		className   => 'WebGUI::Asset::Snippet',
		title       => 'Asset Z',
		url         => 'asset-z',
		snippet     => 'root Z',
		ownerUserId => 3,
		groupIdView => 7,
		groupIdEdit => 3,
		#              '1234567890123456789012'
		id          => 'RootZ-----------------',
);
my $assetZ = $root->addChild(\%properties_Z, $properties_Z{id});

my %properties_Y = (
		className   => 'WebGUI::Asset::Snippet',
		title       => 'Asset Y',
		url         => 'asset-y',
		snippet     => 'Asset Y',
		ownerUserId => 3,
		groupIdView => 7,
		groupIdEdit => 3,
		#              '1234567890123456789012'
		id          => 'RootZ-AssetY----------',
);
my $assetY = $assetZ->addChild(\%properties_Y, $properties_Y{id});

my %properties_X = (
		className   => 'WebGUI::Asset::Snippet',
		title       => 'Asset X',
		url         => 'asset-x',
		snippet     => 'Asset X',
		ownerUserId => 3,
		groupIdView => 7,
		groupIdEdit => 3,
		#              '1234567890123456789012'
		id          => 'RootZ-AssetX----------',
);
my $assetX = $assetZ->addChild(\%properties_X, $properties_X{id});

my %properties__ = (
		className   => 'WebGUI::Asset::Snippet',
		title       => 'Asset _',
		url         => 'asset-_',
		snippet     => 'Asset _',
		ownerUserId => 3,
		groupIdView => 7,
		groupIdEdit => 3,
		#              '1234567890123456789012'
		id          => 'Root_-----------------',
);
my $asset_ = $root->addChild(\%properties__, $properties__{id});

$versionTag->commit;

WebGUI::Test->addToCleanup($assetZ, $asset_);

my $origLineage = $asset_->lineage;
my $newLineage = substr $origLineage, 0, length($origLineage)-1; 
$session->db->write('update asset set lineage=? where assetId=?',[$newLineage, $asset_->getId]);

my @testSets = (
	{
		comment => q!B's root = A!,
		asset   => $assetB,
		title   => $assetA->getTitle,
	},
	{
		comment => q!A's root is itself!,
		asset   => $assetA,
		title   => $assetA->getTitle,
	},
	{
		comment => q!Z's root is itself!,
		asset   => $assetZ,
		title   => $assetZ->getTitle,
	},
	{
		comment => q!X's root = Z!,
		asset   => $assetX,
		title   => $assetZ->getTitle,
	},
	{
		comment => q!Y's root = Z!,
		asset   => $assetY,
		title   => $assetZ->getTitle,
	},
	{
		comment => q!The super root's root is itself!,
		asset   => $root,
		title   => $root->getTitle,
	},
	{
		comment => q!Unable to find root!,
		asset   => $asset_,
		title   => '',
	},
);

my $numTests = scalar @testSets; 
$numTests += 1;

plan tests => $numTests;

use WebGUI::Macro::RootTitle;

is(
	WebGUI::Macro::RootTitle::process($session),
	'',
	q!Call with no default session asset returns ''!,
);


foreach my $testSet (@testSets) {
	$session->asset($testSet->{asset});
	my $output =  WebGUI::Macro::RootTitle::process($session);
	is($output, $testSet->{title}, $testSet->{comment});
}
