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
use WebGUI::Macro::PageTitle;
use Data::Dumper;

use Test::More;
use Test::MockObject;

my $session = WebGUI::Test->session;

my $numTests = 7;

plan tests => $numTests;

my $homeAsset = WebGUI::Asset->getDefault($session);

my $versionTag = WebGUI::VersionTag->getWorking($session);
$versionTag->set({name=>"PageTitle macro test"});

# Create a new snippet and set it's title then check it against the macros output
my $snippetTitle = "Roy's Incredible Snippet of Mystery and Intrique";
my $snippet = $homeAsset->addChild({
                        className=>"WebGUI::Asset::Snippet",
                        title=>$snippetTitle,
                        menuTitle=>"Test Snippet",
                        groupIdView=>7,
                        groupIdEdit=>3,
                        });

$versionTag->commit;
addToCleanup($versionTag);

is(
	WebGUI::Macro::PageTitle::process($session),
	undef,
	q!Call with no default session asset returns undef!,
);

##Make the homeAsset the default asset in the session.
$session->asset($homeAsset);

my $output = WebGUI::Macro::PageTitle::process($session);
is($output, $homeAsset->get('title'), 'fetching title for site default asset');

$session->asset($snippet);
my $macroOutput = WebGUI::Macro::PageTitle::process($session);
is($macroOutput, $snippet->get('title'), "testing title returned from localy created asset with known title");

my $request = $session->request;
$request->setup_param({op => 0, func => 0});
$output = WebGUI::Macro::PageTitle::process($session);
is($output, $session->asset->get('title'), 'fetching title for session asset, no func or op');

my $urlizedTitle = sprintf q!<a href="%s">%s</a>!,
	$session->asset->getUrl,
	$session->asset->get('title');

$request->setup_param({op => 1, func => 0});
$output = WebGUI::Macro::PageTitle::process($session);
is($output, $urlizedTitle, 'fetching urlized title via an operation');

$request->setup_param({op => 0, func => 1});
$output = WebGUI::Macro::PageTitle::process($session);
is($output, $urlizedTitle, 'fetching urlized title via a function');

$request->setup_param({op => 1, func => 1});
$output = WebGUI::Macro::PageTitle::process($session);
is($output, $urlizedTitle, 'fetching urlized title via an operation and function');
