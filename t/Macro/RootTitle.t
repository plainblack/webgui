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
use WebGUI::Macro::RootTitle;
use WebGUI::Session;
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

#my $versionTag = WebGUI::VersionTag->getWorking($session);
#$versionTag->set({name=>"Adding assets for RootTitle tests"});

my $root = WebGUI::Asset->getRoot($session);
my %properties_A = (
		className => 'WebGUI::Asset::Snippet',
		title     => 'Asset A',
		url       => 'asset-a',
		snippet   => 'root A',
		#            '1234567890123456789012'
		id        => 'RootA-----------------',
);

my $versionA = WebGUI::VersionTag->getWorking($session);
$versionA->set({name=>"Adding asset A"});
my $assetA = $root->addChild(\%properties_A, $properties_A{id});
$versionA->commit;

my %properties_B = (
		className => 'WebGUI::Asset::Snippet',
		title     => 'Asset B',
		url       => 'asset-b',
		snippet   => 'Asset B',
		#            '1234567890123456789012'
		id        => 'RootA-AssetB----------',
);

my $versionB = WebGUI::VersionTag->getWorking($session);
$versionB->set({name=>"Adding asset B"});
my $assetB = $assetA->addChild(\%properties_B, $properties_B{id});
$versionB->commit;

my %properties_Z = (
		className => 'WebGUI::Asset::Snippet',
		title     => 'Asset Z',
		url       => 'asset-z',
		snippet   => 'root Z',
		#            '1234567890123456789012'
		id        => 'RootZ-----------------',
);
my $versionZ = WebGUI::VersionTag->getWorking($session);
$versionZ->set({name=>"Adding asset Z"});
my $assetZ = $root->addChild(\%properties_Z, $properties_Z{id});
$versionZ->commit;

my %properties_Y = (
		className => 'WebGUI::Asset::Snippet',
		title     => 'Asset Y',
		url       => 'asset-y',
		snippet   => 'Asset Y',
		#            '1234567890123456789012'
		id        => 'RootZ-AssetY----------',
);
my $versionY = WebGUI::VersionTag->getWorking($session);
$versionY->set({name=>"Adding asset Y"});
my $assetY = $assetZ->addChild(\%properties_Y, $properties_Y{id});
$versionY->commit;

my %properties_X = (
		className => 'WebGUI::Asset::Snippet',
		title     => 'Asset X',
		url       => 'asset-x',
		snippet   => 'Asset X',
		#            '1234567890123456789012'
		id        => 'RootZ-AssetX----------',
);
my $versionX = WebGUI::VersionTag->getWorking($session);
$versionX->set({name=>"Adding asset X"});
my $assetX = $assetZ->addChild(\%properties_X, $properties_X{id});
$versionX->commit;

#$versionTag->commit;

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
);

plan tests => scalar @testSets;

foreach my $testSet (@testSets) {
	$session->asset($testSet->{asset});
	my $output =  WebGUI::Macro::RootTitle::process($session);
	is($output, $testSet->{title}, $testSet->{comment});
}

END { ##Clean-up after yourself, always
#	if (defined $versionTag and ref $versionTag eq 'WebGUI::VersionTag') {
#		$versionTag->rollback;
#	}

	foreach my $vTag ($versionB, $versionA, $versionX, $versionY, $versionZ) {
		if (defined $vTag and ref $vTag eq 'WebGUI::VersionTag') {
			$vTag->rollback;
		}
	}
}
