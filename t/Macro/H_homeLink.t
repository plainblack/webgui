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
use HTML::TokeParser;
use Data::Dumper;

use Test::More; # increment this value for each test you create

my $session = WebGUI::Test->session;

unless ($session->config->get('macros')->{'H_homeLink'}) {
	Macro_Config::insert_macro($session, 'H', 'H_homeLink');
}

my ($versionTag, $template) = addTemplate();

my $homeAsset = WebGUI::Asset->getDefault($session);

my $i18n = WebGUI::International->new($session,'Macro_H_homeLink');

my @testSets = (
	{
		macroText => q!^H("%s");!,
		label => q!linkonly!,
		template => q!!,
		output => $homeAsset->getUrl(),
		comment => 'linkonly argument',
	},
	{
		macroText => q!^H();!,
		label => $i18n->get(47),
		template => q!!,
		url => $homeAsset->getUrl(),
		output => \&simpleHTMLParser,
		comment => 'default macro call',
	},
	{
		macroText => q!^H("%s");!,
		label => q!Hi, want to go home?!,
		template => q!!,
		url => $homeAsset->getUrl(),
		output => \&simpleHTMLParser,
		comment => 'custom label',
	},
	{
		macroText => q!^H("%s","%s");!,
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

plan tests => $numTests;

foreach my $testSet (@testSets) {
	my $output = sprintf $testSet->{macroText}, $testSet->{label}, $testSet->{template};
	WebGUI::Macro::process($session, \$output);
	if (ref $testSet->{output} eq 'CODE') {
		my ($url, $label) = $testSet->{output}->($output);
		is($label, $testSet->{label}, $testSet->{comment}.", label");
		is($url,   $testSet->{url},   $testSet->{comment}.", url");
	}
	else {
		is($output, $testSet->{output}, $testSet->{comment});
	}
}

sub addTemplate {
	$session->user({userId=>3});
	my $importNode = WebGUI::Asset->getImportNode($session);
	my $versionTag = WebGUI::VersionTag->getWorking($session);
	$versionTag->set({name=>"H_homeLink test"});
	my $properties = {
		title => 'H_homeLink test template',
		className => 'WebGUI::Asset::Template',
		url => 'h_homelink-test',
		namespace => 'Macro/H_homeLink',
		template => "HREF=<tmpl_var homeLink.url>\nLABEL=<tmpl_var homeLink.text>",
		id => 'testTemplateH_HomeLink'
	};
	my $template = $importNode->addChild($properties, $properties->{id});
	$versionTag->commit;
	return ($versionTag, $template);
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

	my ($url)   = $text =~ /^HREF=(.+)$/m;
	my ($label) = $text =~ /^LABEL=(.+)$/m;

	return ($url, $label);
}

END {
	if (defined $versionTag and ref $versionTag eq 'WebGUI::VersionTag') {
		$versionTag->rollback;
	}
}
