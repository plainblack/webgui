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

use Test::More; # increment this value for each test you create

my $session = WebGUI::Test->session;

my ($template) = addTemplate();

my $homeAsset = WebGUI::Test->asset;
$session->setting->set( 'defaultPage', $homeAsset->getId );

my $i18n = WebGUI::International->new($session,'Macro_H_homeLink');

my @testSets = (
	{
		label => q!linkonly!,
		template => q!!,
		output => $homeAsset->getUrl(),
		comment => 'linkonly argument',
	},
	{
		label => q!!,
		template => q!!,
		url => $homeAsset->getUrl(),
		output => \&simpleHTMLParser,
		comment => 'default macro call',
	},
	{
		label => q!Hi, want to go home?!,
		template => q!!,
		url => $homeAsset->getUrl(),
		output => \&simpleHTMLParser,
		comment => 'custom label',
	},
	{
		label => q!Custom label!,
		template => q!H_homeLink-test!,
		url => $homeAsset->getUrl(),
		output => \&simpleTextParser,
		comment => 'custom template',
	},
);

my $numTests = 0;
foreach my $testSet (@testSets) {
	$numTests += 1 + (ref $testSet->{output} eq 'CODE');
}

$numTests += 1; #For the use_ok

plan tests => $numTests;

my $macro = 'WebGUI::Macro::H_homeLink';
my $loaded = use_ok($macro);

SKIP: {

skip "Unable to load $macro", $numTests-1 unless $loaded;

foreach my $testSet (@testSets) {
	my $output = WebGUI::Macro::H_homeLink::process($session, $testSet->{label}, $testSet->{template});
	$testSet->{label} ||= $i18n->get(47);
	if (ref $testSet->{output} eq 'CODE') {
		my ($url, $label) = $testSet->{output}->($output);
		is($label, $testSet->{label}, $testSet->{comment}.", label");
		is($url,   $testSet->{url},   $testSet->{comment}.", url");
	}
	else {
		is($output, $testSet->{output}, $testSet->{comment});
	}
}

}

sub addTemplate {
	$session->user({userId=>3});
	my $importNode = WebGUI::Test->asset;
	my $properties = {
		title => 'H_homeLink test template',
		className => 'WebGUI::Asset::Template',
		parser    => 'WebGUI::Asset::Template::HTMLTemplate',
		url => 'h_homelink-test',
		namespace => 'Macro/H_homeLink',
		template => "HREF=<tmpl_var homeLink.url>\nLABEL=<tmpl_var homeLink.text>",
		id => 'testTemplateH_HomeLink',
        usePacked => 1,
	};
	my $template = $importNode->addChild($properties, $properties->{id});
	return ($template);
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
#vim:ft=perl
