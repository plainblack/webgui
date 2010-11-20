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

## The goal of this test is to test the creation and deletion of shortcut assets

use WebGUI::Test;
use WebGUI::Session;
use Test::More; 
use WebGUI::Asset::Snippet;

#----------------------------------------------------------------------------
# Init
my $session         = WebGUI::Test->session;

# Make a snippet to shortcut
my $snippet 
    = WebGUI::Test->asset(
        className       => "WebGUI::Asset::Snippet",
    );

#----------------------------------------------------------------------------
# Tests
plan tests => 3;

#----------------------------------------------------------------------------
# Test module compiles okay
# plan tests => 1
use_ok("WebGUI::Asset::Shortcut"); 

#----------------------------------------------------------------------------
# Test creating a shortcut to snippet
# plan tests => 2
my $shortcut
    = WebGUI::Test->asset(
        className           => "WebGUI::Asset::Shortcut",
        shortcutToAssetId   => $snippet->getId,
    );

isa_ok(
    $shortcut, "WebGUI::Asset::Shortcut",
);

isa_ok( 
    $shortcut, "WebGUI::Asset",
);

#----------------------------------------------------------------------------
# Test deleting a shortcut
# plan tests => 
TODO: {
   local $TODO = "Test deleting a shortcut."; 
}


