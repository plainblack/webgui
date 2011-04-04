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
use HTML::TokeParser;
use WebGUI::Macro::EditableToggle;
use Data::Dumper;

use Test::More; # increment this value for each test you create

my $session = WebGUI::Test->session;

my $homeAsset = WebGUI::Asset->getDefault($session);
my ($versionTag, $asset, @users) = setupTest($session, $homeAsset);

my $i18n = WebGUI::International->new($session,'Macro_EditableToggle');

my @testSets = (
	{
		comment     => 'Visitor sees nothing, admin off, home asset',
		userId      => 1,
		adminStatus => 'off',
		asset       => $homeAsset,
		onText      => '',
		offText     => '',
		template    => q!!,
		output      => '',
	},
	{
		comment     => 'Visitor sees nothing, admin on, home asset',
		userId      => 1,
		adminStatus => 'on',
		asset       => $homeAsset,
		onText      => '',
		offText     => '',
		template    => q!!,
		output      => '',
	},
	{
		comment     => 'Admin sees off text, home asset',
		userId      => 3,
		adminStatus => 'off',
		asset       => $homeAsset,
		onText      => '',
		offText     => '',
		template    => q!!,
		output      => \&simpleHTMLParser,
	},
	{
		comment     => 'Admin sees on text, home asset',
		userId      => 3,
		adminStatus => 'on',
		asset       => $homeAsset,
		onText      => '',
		offText     => '',
		template    => q!!,
		output      => \&simpleHTMLParser,
	},
	{
		comment => 'Admin sees off text, custom asset',
		userId => 3,
		adminStatus => 'off',
		asset => $asset,
		onText => '',
		offText => '',
		template => q!!,
		output => \&simpleHTMLParser,
	},
	{
		comment => 'Admin sees on text, custom asset',
		userId => 3,
		adminStatus => 'on',
		asset => $asset,
		onText => '',
		offText => '',
		template => q!!,
		output => \&simpleHTMLParser,
	},
	{
		comment => 'user 0 sees nothing, admin off, custom asset',
		userId => $users[0]->userId,
		adminStatus => 'off',
		asset => $asset,
		onText => '',
		offText => '',
		template => q!!,
		output => '',
	},
	{
		comment => 'user 0 sees nothing, admin on, custom asset',
		userId => $users[0]->userId,
		adminStatus => 'on',
		asset => $asset,
		onText => '',
		offText => '',
		template => q!!,
		output => '',
	},
	{
		comment => 'user 1 sees nothing, admin off, custom asset',
		userId => $users[1]->userId,
		adminStatus => 'off',
		asset => $asset,
		onText => '',
		offText => '',
		template => q!!,
		output => '',
	},
	{
		comment => 'user 1 sees nothing, admin on, custom asset',
		userId => $users[1]->userId,
		adminStatus => 'on',
		asset => $asset,
		onText => '',
		offText => '',
		template => q!!,
		output => '',
	},
	{
		comment => 'user 2 sees on text, admin off, custom asset',
		userId => $users[2]->userId,
		adminStatus => 'off',
		asset => $asset,
		onText => '',
		offText => '',
		template => q!!,
		output => \&simpleHTMLParser,
	},
	{
		comment => 'user 2 sees off text, admin on, custom asset',
		userId => $users[2]->userId,
		adminStatus => 'on',
		asset => $asset,
		onText => '',
		offText => '',
		template => q!!,
		output => \&simpleHTMLParser,
	},
	{
		comment => 'user 2 sees on text, admin off, custom asset and text',
		userId => $users[2]->userId,
		adminStatus => 'off',
		asset => $asset,
		onText => 'Admin powers... Activate!',
		offText => 'Chillin, dude',
		template => q!!,
		output => \&simpleHTMLParser,
	},
	{
		comment => 'user 2 sees off text, admin on, custom asset and text',
		userId => $users[2]->userId,
		adminStatus => 'on',
		asset => $asset,
		onText => 'Admin powers... Activate!',
		offText => 'Chillin, dude',
		template => q!!,
		output => \&simpleHTMLParser,
	},
	{
		comment => 'user 2 sees off text, admin on, custom asset, text, template',
		userId => $users[2]->userId,
		adminStatus => 'on',
		asset => $asset,
		onText => 'Admin powers... Activate!',
		offText => 'Chillin, dude',
		template => $asset->get('url'),
		output => \&simpleTextParser,
	},
);

my $numTests = 0;
foreach my $testSet (@testSets) {
	$numTests += 1 + (ref $testSet->{output} eq 'CODE');
}

$numTests += 1; ##Empty session Asset plus use_ok

plan tests => $numTests;

is(
	WebGUI::Macro::EditableToggle::process($session,'on','off',''),
	'',
	q!Call with no default session asset returns ''!,
);

foreach my $testSet (@testSets) {
	$session->user({userId=>$testSet->{userId}});
	$session->asset($testSet->{asset});
	if ($testSet->{adminStatus} eq 'off') {
		$session->var->switchAdminOff();
		$testSet->{label} = $testSet->{onText} || $i18n->get(516);
		$testSet->{url} = $session->url->page('op=switchOnAdmin'),
	}
	elsif ($testSet->{adminStatus} eq 'on') {
		$session->var->switchAdminOn();
		$testSet->{label} = $testSet->{offText} || $i18n->get(517);
		$testSet->{url} = $session->url->page('op=switchOffAdmin'),
	}
	else {
		BAIL_OUT('Unknown admin status selected');
	}
	my $output = WebGUI::Macro::EditableToggle::process($session,
		$testSet->{onText}, $testSet->{offText}, $testSet->{template});
	if (ref $testSet->{output} eq 'CODE') {
		my ($url, $label) = $testSet->{output}->($output);
		is($label, $testSet->{label}, $testSet->{comment}.", label");
		is($url,   $testSet->{url},   $testSet->{comment}.", url");
	}
	else {
		is($output, $testSet->{output}, $testSet->{comment});
	}
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

sub setupTest {
	my ($session, $defaultNode) = @_;
	$session->user({userId=>3});
	my $editGroup = WebGUI::Group->new($session, "new");
	my $tao = WebGUI::Group->find($session, "Turn Admin On");
	##Create an asset with specific editing privileges
	my $versionTag = WebGUI::VersionTag->getWorking($session);
	$versionTag->set({name=>"EditableToggle test"});
	my $properties = {
		title => 'EditableToggle test template',
		className => 'WebGUI::Asset::Template',
		parser    => 'WebGUI::Asset::Template::HTMLTemplate',
		url => 'editabletoggle-test',
		namespace => 'Macro/EditableToggle',
		template => "HREF=<tmpl_var toggle.url>\nLABEL=<tmpl_var toggle.text>",
		groupIdEdit => $editGroup->getId(),
		#     '1234567890123456789012'
		id => 'EditableToggleTemplate',
        usePacked => 1,
	};
	my $asset = $defaultNode->addChild($properties, $properties->{id});
	$versionTag->commit;
	my @users = map { WebGUI::User->new($session, "new") } 0..2;
	##User 1 is an editor
	$users[1]->addToGroups([$editGroup->getId]);
	##User 2 is an editor AND can turn on Admin
	$users[2]->addToGroups([$editGroup->getId, $tao->getId]);
    addToCleanup($versionTag, $editGroup, @users);
	return ($versionTag, $asset, @users);
}
