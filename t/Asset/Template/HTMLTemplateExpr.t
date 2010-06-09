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
use lib "$FindBin::Bin/../../lib";
use HTML::TokeParser;

use WebGUI::Test;
use WebGUI::Session;
use WebGUI::Asset;
use WebGUI::VersionTag;
use WebGUI;

use Test::More;

my $num_tests = 3;
plan tests => 2 + $num_tests;
 
my $session = WebGUI::Test->session;
 
# put your tests here
WebGUI::Test->originalConfig('templateParsers');

my $module = use_ok('HTML::Template::Expr');
my $plugin = use_ok('WebGUI::Asset::Template::HTMLTemplateExpr');

SKIP: {
    skip "HTML::Template::Expr or plugin not loaded", $num_tests unless $plugin;

    $session->config->set('templateParsers', ['WebGUI::Asset::Template::HTMLTemplate', 'WebGUI::Asset::Template::HTMLTemplateExpr',] );
    my ($versionTag, $template) = setup_assets($session);
    WebGUI::Test->addToCleanup($versionTag);
    my $templateOutput = $template->process({ "foo.bar" => "baz", "number.value" => 2 });
    my $companyName = $session->config->get('companyName');
    like($templateOutput, qr/NAME=$companyName/, "session variable with underscores");
    like($templateOutput, qr/FOOBAR=baz/, "explicit variable with dots");
    like($templateOutput, qr/EQN=4/, "explicit variable with dots in expr");
}

sub setup_assets {
	my $session = shift;
	my $importNode = WebGUI::Asset->getImportNode($session);
	my $versionTag = WebGUI::VersionTag->getWorking($session);
	$versionTag->set({name=>"HTMLTemplateExpr test"});
	my $properties = {
		title => 'HTML Template Expr test',
		className => 'WebGUI::Asset::Template',
		url => 'dotted',
		parser => 'WebGUI::Asset::Template::HTMLTemplateExpr',
		id => 'htmltemplateexpr000001',
		#     '1234567890123456789012'
		template => q!NAME=<tmpl_var session_setting_companyName>\nFOOBAR=<tmpl_var name="foo_bar">\nEQN=<tmpl_var EXPR="2+number_value">!,
	};
	my $template = $importNode->addChild($properties, $properties->{id});
	$versionTag->commit;
	return ($versionTag, $template);
}
