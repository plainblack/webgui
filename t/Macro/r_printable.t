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
use WebGUI::Macro::r_printable;
use WebGUI::Session;
use WebGUI::International;
use Data::Dumper;

use Test::More; # increment this value for each test you create
use HTML::TokeParser;

my $session = WebGUI::Test->session;

my $homeAsset = WebGUI::Test->asset;
$session->asset($homeAsset);
my $template = setupTest($session, $homeAsset);

my $i18n = WebGUI::International->new($session, 'Macro_r_printable');

my @testSets = (
	{
		comment => 'Linkonly test',
		text => 'linkonly',
		styleId => '',
		template => '',
		output => $session->url->page('op=makePrintable').';',
	},
	{
		comment => 'Empty macro call returns i18n label and url',
		text => '',
		styleId => '',
		template => '',
		output => \&simpleHTMLParser,
	},
	{
		comment => 'Text passed in shows up as a label',
		text => 'Print me!',
		styleId => '',
		template => '',
		output => \&simpleHTMLParser,
	},
	{
		comment => 'Custom styleId shows up in url',
		text => '',
		styleId => 'dddd0000DDDDAAAA--____',
		template => '',
		output => \&simpleHTMLParser,
	},
	{
		comment => 'Custom styleId and text',
		text => 'Print this?',
		styleId => 'dddd0000DDDDAAAA--____',
		template => '',
		output => \&simpleHTMLParser,
	},
	{
		comment => 'Custom template',
		text => '',
		styleId => '',
		template => $template->get('url'),
		output => \&simpleTextParser,
	},
	{
		comment => 'Custom text, styleId, template',
		text => 'Remove all the stupid graphics',
		styleId => 'absurdely-Long-AssetId',
		template => $template->get('url'),
		output => \&simpleTextParser,
	},
);

my $numTests = 0;

foreach my $testSet (@testSets) {
	$numTests += 1 + (ref $testSet->{output} eq 'CODE');
}

plan tests => $numTests;

foreach my $testSet (@testSets) {
	my $output =  WebGUI::Macro::r_printable::process($session, $testSet->{text}, $testSet->{styleId}, $testSet->{template});
	if (ref $testSet->{output} eq 'CODE') {
		my ($url, $text) = $testSet->{output}->($output);

		my $expectedText = $testSet->{text} ? $testSet->{text} : $i18n->get(53);
		is($text, $expectedText, 'TEXT: '.$testSet->{comment});

		my $expectedUrl = $session->url->page('op=makePrintable').';';
		if ($testSet->{styleId}) {
			$expectedUrl = $session->url->append($expectedUrl, 'styleId='.$testSet->{styleId});
		}
		is($url, $expectedUrl, 'URL: '.$testSet->{comment});
	}
	else {
		is($output, $testSet->{output}, $testSet->{comment});
	}
}

sub setupTest {
	my ($session, $defaultNode) = @_;

	my $properties = {
		title => 'printable test template',
		className => 'WebGUI::Asset::Template',
		url => 'printable-test',
		namespace => 'Macro/r_printable',
		template => "HREF=<tmpl_var printable.url>\nLABEL=<tmpl_var printable.text>",
		#     '1234567890123456789012'
		id => 'printable01100Template',
        usePacked => 1,
	};
	my $asset = $defaultNode->addChild($properties, $properties->{id});

	return $asset;
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
