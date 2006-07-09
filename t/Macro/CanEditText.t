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
use WebGUI::Macro;
use WebGUI::Session;
use Data::Dumper;
use WebGUI::Macro_Config;

my $session = WebGUI::Test->session;

use Test::More; # increment this value for each test you create

unless ($session->config->get('macros')->{'CanEditText'}) {
	Macro_Config::insert_macro($session, 'CanEditText', 'CanEditText');
}

my $adminText = "^CanEditText(editor);";
my $output;

my $homeAsset = WebGUI::Asset->getDefault($session);
$session->asset($homeAsset);
my ($versionTag, $asset, $group, @users) = setupTest($session, $homeAsset);

my @testSets = (
	{
		comment => 'Visitor sees nothing',
		userId => 1,
		macroText => q!^CanEditText("%s");!,
		text => q!I am an editor!,
		asset => $asset,
		output => '',
	},
	{
		comment => 'Admin sees text',
		userId => 3,
		macroText => q!^CanEditText("%s");!,
		text => q!I am an editor!,
		asset => $asset,
		output => 'I am an editor',
	},
	{
		comment => 'Random user sees nothing',
		userId => $users[0]->userId,
		macroText => q!^CanEditText("%s");!,
		text => q!I am an editor!,
		asset => $asset,
		output => '',
	},
	{
		comment => 'General Content Manager sees nothing',
		userId => $users[1]->userId,
		macroText => q!^CanEditText("%s");!,
		text => q!I am an editor!,
		asset => $asset,
		output => '',
	},
	{
		comment => 'Member of group to edit this asset sees text',
		userId => $users[2]->userId,
		macroText => q!^CanEditText("%s");!,
		text => q!I am an editor!,
		asset => $asset,
		output => 'I am an editor',
	},
);

my $numTests = scalar @testSets;

plan tests => $numTests;

foreach my $testSet (@testSets) {
	$session->user({userId=>$testSet->{userId}});
	$session->asset($testSet->{asset});
	my $output = sprintf $testSet->{macroText}, $testSet->{text};
	WebGUI::Macro::process($session, \$output);
	is($output, $testSet->{output}, $testSet->{comment});
}


sub setupTest {
	my ($session, $defaultNode) = @_;
	$session->user({userId=>3});
	my $editGroup = WebGUI::Group->new($session, "new");
	my $cm = WebGUI::Group->find($session, "Content Managers");
	$cm->addGroups([$editGroup->getId]);
	##Create an asset with specific editing privileges
	my $versionTag = WebGUI::VersionTag->getWorking($session);
	$versionTag->set({name=>"CanEditText test"});
	my $properties = {
		title => 'CanEditText test template',
		className => 'WebGUI::Asset::Wobject::Article',
		url => '/home/CanEditText-test',
		description => 'This is a test article for viewing privileges',
		id => 'CanEditTextTestAsset01',
		groupIdEdit => $editGroup->getId(),
	};
	my $asset = $defaultNode->addChild($properties, $properties->{id});
	$versionTag->commit;
	my @users = map { WebGUI::User->new($session, "new") } 0..2;
	##User 1 is a content manager
	$users[1]->addToGroups([$cm->getId]);
	##User 2 is a member of a content manager sub-group
	$users[2]->addToGroups([$editGroup->getId]);
	return ($versionTag, $asset, $editGroup, @users);
}

END { ##Clean-up after yourself, always
	if (defined $versionTag and ref $versionTag eq 'WebGUI::VersionTag') {
		$versionTag->rollback;
	}
	foreach my $testGroup ($group) {
		$testGroup->delete if (defined $testGroup and ref $testGroup eq 'WebGUI::Group');
	}
	foreach my $dude (@users) {
		$dude->delete if (defined $dude and ref $dude eq 'WebGUI::User');
	}
}
