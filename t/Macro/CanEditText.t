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
use WebGUI::Macro::CanEditText;
use Data::Dumper;

my $session = WebGUI::Test->session;

use Test::More; # increment this value for each test you create

my $homeAsset = WebGUI::Test->asset;
my ($asset, $group, @users) = setupTest($session, $homeAsset);

my @testSets = (
	{
		comment => 'Visitor sees nothing',
		userId => 1,
		text => q!I am an editor!,
		asset => $asset,
		output => '',
	},
	{
		comment => 'Admin sees text',
		userId => 3,
		text => q!I am an editor!,
		asset => $asset,
		output => 'I am an editor',
	},
	{
		comment => 'Random user sees nothing',
		userId => $users[0]->userId,
		text => q!I am an editor!,
		asset => $asset,
		output => '',
	},
	{
		comment => 'General Content Manager sees nothing',
		userId => $users[1]->userId,
		text => q!I am an editor!,
		asset => $asset,
		output => '',
	},
	{
		comment => 'Member of group to edit this asset sees text',
		userId => $users[2]->userId,
		text => q!I am an editor!,
		asset => $asset,
		output => 'I am an editor',
	},
);

my $numTests = scalar @testSets + 1;

plan tests => $numTests;

is(
	WebGUI::Macro::CanEditText::process($session,''),
	'',
	q!Call with no default session asset returns ''!,
);

foreach my $testSet (@testSets) {
	$session->user({userId=>$testSet->{userId}});
	$session->asset($testSet->{asset});
	my $output = WebGUI::Macro::CanEditText::process($session, $testSet->{text});
	is($output, $testSet->{output}, $testSet->{comment});
}

sub setupTest {
	my ($session, $defaultNode) = @_;
	$session->user({userId=>3});
	my $editGroup = WebGUI::Group->new($session, "new");
	my $cm = WebGUI::Group->find($session, "Content Managers");
	$cm->addGroups([$editGroup->getId]);
	##Create an asset with specific editing privileges
	my $properties = {
		title => 'CanEditText test template',
		className => 'WebGUI::Asset::Wobject::Article',
		url => '/home/canedittext-test',
		description => 'This is a test article for viewing privileges',
		id => 'CanEditTextTestAsset01',
		groupIdEdit => $editGroup->getId(),
	};
	my $asset = WebGUI::Test->asset->addChild($properties, $properties->{id});
	my @users = map { WebGUI::User->new($session, "new") } 0..2;
	##User 1 is a content manager
	$users[1]->addToGroups([$cm->getId]);
	##User 2 is a member of a content manager sub-group
	$users[2]->addToGroups([$editGroup->getId]);
    addToCleanup($editGroup, @users);
	return ($asset, $editGroup, @users);
}
