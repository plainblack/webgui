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
use WebGUI::Macro::PageTitle;
use WebGUI::Session;
use Data::Dumper;

use Test::More; # increment this value for each test you create

my $session = WebGUI::Test->session;

plan tests => 2;

my $homeAsset = WebGUI::Asset->getDefault($session);

##Make the homeAsset the default asset in the session.
$session->asset($homeAsset);

my $output = WebGUI::Macro::PageTitle::process($session);
is($output, $homeAsset->get('title'), 'fetching title for site default asset');

# Create a new snippet and set it's title then check it against the macros output
my $snippetTitle = "Roy's Incredible Snippet of Mystery and Intrique";
my $snippet = $homeAsset->addChild({
                        className=>"WebGUI::Asset::Snippet",
                        title=>$snippetTitle,
                        menuTitle=>"Test Snippet",
                        groupIdView=>7,
                        groupIdEdit=>3,
                        });
$session->asset($snippet);
my $macroOutput = WebGUI::Macro::PageTitle::process($session);
is($macroOutput, $snippet->get('title'), "testing title returned from localy created asset with known title");
