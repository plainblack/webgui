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
use WebGUI::Macro::GroupAdd;
use Data::Dumper;

use Test::More; # increment this value for each test you create
use HTML::TokeParser;
use JSON qw/from_json/;

my $session = WebGUI::Test->session;

my $homeAsset = WebGUI::Test->asset;
my ($template, $groups, $users) = setupTest($session, $homeAsset);

my @testSets = (
	{
		comment => 'Empty macro call returns null string',
		groupName => '',
		text => '',
		template => '',
		empty => 1,
		userId => $users->[2]->userId,
	},
	{
		comment => 'Empty group returns null string',
		groupName => '',
		text => 'Join up',
		template => '',
		empty => 1,
		userId => $users->[2]->userId,
	},
	{
		comment => 'Empty text returns null string',
		groupName => $groups->[0]->name,
		text => '',
		template => '',
		empty => 1,
		userId => $users->[2]->userId,
	},
	{
		comment => 'Visitor sees empty string with valid group and text',
		groupName => $groups->[0]->name(),
		text => 'Join up!',
		template => '',
		empty => 1,
		userId => 1,
	},
	{
		comment => 'Non-existant group returns null string',
		groupName => "Dudes of the day",
		text => 'Join up!',
		template => '',
		empty => 1,
		userId => $users->[2]->userId,
	},
	{
		comment => 'Group without autoAdd returns null string',
		groupName => $groups->[1]->name,
		text => 'Join up!',
		template => '',
		empty => 1,
		userId => $users->[2]->userId,
	},
	{
		comment => 'Existing member of group sees empty string',
		groupName => $groups->[0]->name,
		text => 'Join up!',
		template => '',
		empty => 1,
		userId => $users->[0]->userId,
	},
	{
		comment => 'Non-member of group sees text and link',
		groupName => $groups->[0]->name,
		groupId => $groups->[0]->getId,
		text => 'Join up!',
		template => '',
		empty => 0,
		userId => $users->[2]->userId,
		parser => \&simpleHTMLParser,
	},
	{
		comment => 'Member of different group sees text and link',
		groupName => $groups->[0]->name,
		groupId => $groups->[0]->getId,
		text => 'Join up!',
		template => '',
		empty => 0,
		userId => $users->[1]->userId,
		parser => \&simpleHTMLParser,
	},
	{
		comment => 'Custom template check',
		groupName => $groups->[0]->name,
		groupId => $groups->[0]->getId,
		text => 'Join up!',
		template => $template->get('url'),
		empty => 0,
		userId => $users->[1]->userId,
		parser => \&simpleTextParser,
	},
);

my $numTests = 0;
foreach my $testSet (@testSets) {
	$numTests += 1 + ($testSet->{empty} == 0);
}

plan tests => $numTests;

foreach my $testSet (@testSets) {
	$session->user({ userId => $testSet->{userId} });
	my $output = WebGUI::Macro::GroupAdd::process($session,
		$testSet->{groupName}, $testSet->{text}, $testSet->{template});
	if ($testSet->{empty}) {
		is($output, '', $testSet->{comment});
	}
	else {
		my ($url, $text) = $testSet->{parser}->($output);
		is($text, $testSet->{text}, 'TEXT: '.$testSet->{comment});
		my $expectedUrl = $session->url->page('op=autoAddToGroup;groupId='.$testSet->{groupId});
		is($url, $expectedUrl, 'URL: '.$testSet->{comment});
	}
}

sub setupTest {
	my ($session, $defaultNode) = @_;
	my @groups;
	##Two groups, one with Group Add and one without
	$groups[0] = WebGUI::Group->new($session, "new");
	$groups[0]->name('AutoAdd Group');
	$groups[0]->autoAdd(1);
	$groups[1] = WebGUI::Group->new($session, "new");
	$groups[1]->name('Regular Old Group');
	$groups[1]->autoAdd(0);
    addToCleanup(@groups);

	##Three users.  One in each group and one with no group membership
	my @users = map { WebGUI::User->new($session, "new") } 0..2;
	$users[0]->addToGroups([$groups[0]->getId]);
	$users[1]->addToGroups([$groups[1]->getId]);
    addToCleanup(@users);

	my $properties = {
		title     => 'GroupAdd test template',
		className => 'WebGUI::Asset::Template',
		url       => 'groupadd-test',
		namespace => 'Macro/GroupAdd',
		template  => qq|{"HREF":"<tmpl_var group.url>",\n"LABEL":"<tmpl_var group.text>"}|,
		#            '1234567890123456789012'
		id        => 'GroupAdd001100Template',
        usePacked => 1,
	};
	my $asset = $defaultNode->addChild($properties, $properties->{id});

	return $asset, \@groups, \@users;
}

sub simpleHTMLParser {
	my ($text) = @_;
	my $p = HTML::TokeParser->new(\$text);

	my $token = $p->get_tag("a");
	my $url = $token->[1]{href} || "-";
	my $label = $p->get_trimmed_text("/a");

	return ($url, $label);
}

sub simpleTextParser {
	my ($text) = @_;

    my $json_data = from_json($text);
    my ($url, $label) = @{ $json_data }{qw/HREF LABEL/};

	return ($url, $label);
}
