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
use WebGUI::Macro::GroupDelete;
use Data::Dumper;

use Test::More; # increment this value for each test you create
use HTML::TokeParser;

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
		text => 'Bow out',
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
		text => 'Bow out',
		template => '',
		empty => 1,
		userId => 1,
	},
	{
		comment => 'Non-existant group returns null string',
		groupName => "Dudes of the day",
		text => 'Bow out',
		template => '',
		empty => 1,
		userId => $users->[2]->userId,
	},
	{
		comment => 'Group without autoDelete returns null string',
		groupName => $groups->[1]->name,
		text => 'Bow out',
		template => '',
		empty => 1,
		userId => $users->[2]->userId,
	},
	{
		comment => 'Non-member of group sees empty string',
		groupName => $groups->[0]->name,
		text => 'Bow out',
		template => '',
		empty => 1,
		userId => $users->[1]->userId,
	},
	{
		comment => 'Member of different group sees empty string',
		groupName => $groups->[0]->name,
		groupId => $groups->[0]->getId,
		text => 'Bow out',
		template => '',
		empty => 1,
		userId => $users->[2]->userId,
	},
	{
		comment => 'Member of group sees text and link',
		groupName => $groups->[0]->name,
		groupId => $groups->[0]->getId,
		text => 'Bow out',
		template => '',
		empty => 0,
		userId => $users->[0]->userId,
		parser => \&simpleHTMLParser,
	},
	{
		comment => 'Custom template check',
		groupName => $groups->[0]->name,
		groupId => $groups->[0]->getId,
		text => 'Bow out',
		template => $template->get('url'),
		empty => 0,
		userId => $users->[0]->userId,
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
	my $output = WebGUI::Macro::GroupDelete::process($session, 
		$testSet->{groupName}, $testSet->{text}, $testSet->{template});
	if ($testSet->{empty}) {
		is($output, '', $testSet->{comment});
	}
	else {
		my ($url, $text) = $testSet->{parser}->($output);
		is($text, $testSet->{text}, 'TEXT: '.$testSet->{comment});
		my $expectedUrl = $session->url->page('op=autoDeleteFromGroup;groupId='.$testSet->{groupId});
		is($url, $expectedUrl, 'URL: '.$testSet->{comment});
	}
}

sub setupTest {
	my ($session, $defaultNode) = @_;
	my @groups;
	##Two groups, one with Group Delete and one without
	$groups[0] = WebGUI::Group->new($session, "new");
	$groups[0]->name('AutoDelete Group');
	$groups[0]->autoDelete(1);
	$groups[1] = WebGUI::Group->new($session, "new");
	$groups[1]->name('Regular Old Group');
	$groups[1]->autoDelete(0);
    addToCleanup(@groups);

	##Three users.  One in each group and one with no group membership
	my @users = map { WebGUI::User->new($session, "new") } 0..2;
	$users[0]->addToGroups([$groups[0]->getId]);
	$users[1]->addToGroups([$groups[1]->getId]);
    addToCleanup(@users);

	my $properties = {
		title => 'GroupDelete test template',
		className => 'WebGUI::Asset::Template',
		parser    => 'WebGUI::Asset::Template::HTMLTemplate',
		url => 'groupdelete-test',
		namespace => 'Macro/GroupDelete',
		template => "HREF=<tmpl_var group.url>\nLABEL=<tmpl_var group.text>",
        usePacked => 1,
		#     '1234567890123456789012'
		id => 'GroupDelete001Template',
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

	my ($url)   = $text =~ /HREF=(.+?)(\n?LABEL|\Z)/;
	my ($label) = $text =~ /LABEL=(.+?)(\n?HREF|\Z)/;

	return ($url, $label);
}
