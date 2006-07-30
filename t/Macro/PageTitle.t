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
use WebGUI::Session;
use Data::Dumper;

use Test::More; # increment this value for each test you create

my $session = WebGUI::Test->session;

my $numTests = 2;
$numTests += 1; #For the use_ok

plan tests => $numTests;

my $macro = 'WebGUI::Macro::PageTitle';
my $loaded = use_ok($macro);

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

SKIP: {

skip "Unable to load $macro", $numTests-1 unless $loaded;

##Make the homeAsset the default asset in the session.
$session->asset($homeAsset);

my $output = WebGUI::Macro::PageTitle::process($session);
is($output, $homeAsset->get('title'), 'fetching title for site default asset');

$session->asset($snippet);
my $macroOutput = WebGUI::Macro::PageTitle::process($session);
is($macroOutput, $snippet->get('title'), "testing title returned from localy created asset with known title");

}

END {
	$versionTag->rollback;
}
