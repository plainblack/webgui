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
use HTML::TokeParser;
use Data::Dumper;
use WebGUI::Macro::AdminToggle;

use Test::More; # increment this value for each test you create

my $session = WebGUI::Test->session;

my $template = addTemplate();

my $homeAsset = WebGUI::Test->asset;
$session->asset($homeAsset);

my $i18n = WebGUI::International->new($session,'Macro_AdminToggle');

my @testSets = (
	{
		comment => 'Visitor sees nothing',
		userId => 1,
		adminStatus => 'off',
		onText => q!!,
		template => q!!,
		output => '',
	},
	{
		comment => 'Admin sees onText, default call',
		userId => 3,
		adminStatus => 'off',
		onText => '',
		template => q!!,
		url => $session->url->append($homeAsset->getUrl(),'op=admin'),
		output => \&simpleHTMLParser,
	},
	{
		comment => 'Admin sees onText, custom text',
		userId => 3,
		adminStatus => 'off',
		onText => 'Admin powers... Activate!',
		template => q!!,
		url => $session->url->append($homeAsset->getUrl(),'op=admin'),
		output => \&simpleHTMLParser,
	},
	{
		comment => 'Admin sees onText, custom text and template',
		userId => 3,
		adminStatus => 'off',
		onText => 'Admin powers... Activate!',
		template => $template->get('url'),
		url => $session->url->append($homeAsset->getUrl(),'op=admin'),
		output => \&simpleTextParser,
	},
);

my $numTests = 0;
foreach my $testSet (@testSets) {
	$numTests += 1 + (ref $testSet->{output} eq 'CODE');
}

plan tests => $numTests + 1; ##conditional module load and TODO at end

foreach my $testSet (@testSets) {
	$session->user({userId=>$testSet->{userId}});
        $testSet->{label} = $testSet->{onText} || $i18n->get(516);
	my $output = WebGUI::Macro::AdminToggle::process( $session,
		$testSet->{onText}, $testSet->{template} );
	if (ref $testSet->{output} eq 'CODE') {
		my ($url, $label) = $testSet->{output}->($output);
		is($label, $testSet->{label}, $testSet->{comment}.", label");
		is($url,   $testSet->{url},   $testSet->{comment}.", url");
	}
	else {
		is($output, $testSet->{output}, $testSet->{comment});
	}
}

TODO: {
	local $TODO = 'Tests to make later';
	ok(0, 'Run tests with a user other than Admin');
}

sub addTemplate {
	$session->user({userId=>3});
	my $importNode = WebGUI::Test->asset;
	my $properties = {
		title => 'AdminToggle test template',
		className => 'WebGUI::Asset::Template',
		url => 'admintoggle-test',
		namespace => 'Macro/AdminToggle',
		template => "HREF=<tmpl_var toggle_url>\nLABEL=<tmpl_var toggle_text>",
		id => 'AdminToggleTemplate--Z',
        usePacked => 0,
	};
	my $template = $importNode->addChild($properties, $properties->{id});
	return $template;
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

	my ($url)   = $text =~ /HREF=(.+?)\s/;
	my ($label) = $text =~ /LABEL=(.+?)\Z/;

	return ($url, $label);
}
