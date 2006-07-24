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
use WebGUI::Macro_Config;
use Data::Dumper;

use Test::More; # increment this value for each test you create

my $session = WebGUI::Test->session;

unless ($session->config->get('macros')->{'GroupAdd'}) {
	Macro_Config::insert_macro($session, 'GroupAdd', 'GroupAdd');
}

my $homeAsset = WebGUI::Asset->getDefault($session);
my ($groups, $users) = setupTest($session);

##Add more Asset configurations here.
my @testSets = (
	{
		comment => 'Empty macro call returns null string',
		macroText => q!^GroupAdd();!,
		groupName => '',
		text => '',
		template => '',
		empty => 1,
		userId => $users->[2]->userId,
	},
	{
		comment => 'Empty group returns null string',
		macroText => q!^GroupAdd("%s","%s");!,
		groupName => '',
		text => 'Join up',
		template => '',
		empty => 1,
		userId => $users->[2]->userId,
	},
	{
		comment => 'Empty text returns null string',
		macroText => q!^GroupAdd("%s","%s");!,
		groupName => $groups->[0]->name,
		text => '',
		template => '',
		empty => 1,
		userId => $users->[2]->userId,
	},
	{
		comment => 'Visitor sees empty string with valid group and text',
		macroText => q!^GroupAdd("%s","%s");!,
		groupName => $groups->[0]->name(),
		text => 'Join up!',
		template => '',
		empty => 1,
		userId => 1,
	},
	{
		comment => 'Non-existant group returns null string',
		macroText => q!^GroupAdd("%s","%s");!,
		groupName => "Dudes of the day",
		text => 'Join up!',
		template => '',
		empty => 1,
		userId => $users->[2]->userId,
	},
);

my $numTests = 0;

foreach my $testSet (@testSets) {
	$numTests += 1 + ($testSet->{empty} == 0);
}

plan tests => $numTests;

foreach my $testSet (@testSets) {
	$session->user({ userId => $testSet->{userId} });
	my $output = sprintf $testSet->{macroText},
		$testSet->{groupName}, $testSet->{text}, $testSet->{template};
	WebGUI::Macro::process($session, \$output);
	if ($testSet->{empty}) {
		is($output, '', $testSet->{comment});
	}
	else {
	}
}

sub setupTest {
	my ($session) = @_;
	my @groups;
	##Two groups, one with Group Add and one without
	$groups[0] = WebGUI::Group->new($session, "new");
	$groups[0]->name('AutoAdd Group');
	$groups[0]->autoAdd(1);
	$groups[1] = WebGUI::Group->new($session, "new");
	$groups[1]->name('Regular Old Group');
	$groups[1]->autoAdd(0);

	##Three users.  One in each group and one with no group membership
	my @users = map { WebGUI::User->new($session, "new") } 0..2;
	$users[0]->addToGroups([$groups[0]->getId]);
	$users[1]->addToGroups([$groups[1]->getId]);

	return \@groups, \@users;
}

#END { ##Clean-up after yourself, always
#	foreach my $testGroup (@{ $groups }, ) {
#		$testGroup->delete if (defined $testGroup and ref $testGroup eq 'WebGUI::Group');
#	}
#	foreach my $dude (@{ $users }, ) {
#		$dude->delete if (defined $dude and ref $dude eq 'WebGUI::User');
#	}
#}
