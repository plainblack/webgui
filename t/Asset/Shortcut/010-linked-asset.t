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

## The goal of this test is to test the link between the asset and its shortcut
# and that changes to the asset are propagated to the shortcut

use Scalar::Util qw( blessed );
use WebGUI::Test;
use WebGUI::Session;
use Test::More; 
use WebGUI::Asset::Shortcut;
use WebGUI::Asset::Snippet;

#----------------------------------------------------------------------------
# Init
my $session         = WebGUI::Test->session;
my $node            = WebGUI::Asset->getImportNode($session);
my $versionTag      = WebGUI::VersionTag->getWorking($session);
$versionTag->set({name=>"Shortcut Test"});
addToCleanup;

# Make a snippet to shortcut
my $snippet 
    = $node->addChild({
        className       => "WebGUI::Asset::Snippet",
    });

my $shortcut
    = $node->addChild({
        className           => "WebGUI::Asset::Shortcut",
        shortcutToAssetId   => $snippet->getId,
    });


#----------------------------------------------------------------------------
# Tests
plan tests => 9;

#----------------------------------------------------------------------------
# Test shortcut's link to original asset
my $original = $shortcut->getShortcut;

ok(
    defined $original,
    "Original asset is defined",
);

is(
    Scalar::Util::blessed($original), Scalar::Util::blessed($snippet),
    "Original asset class is correct",
);

is(
    $original->getId, $snippet->getId,
    "Original assetId is correct"
);

#----------------------------------------------------------------------------
# Test trashing snippet trashes shortcut also
$snippet->trash;
$shortcut   = WebGUI::Asset->newById($session, $shortcut->getId);

ok(
    defined $shortcut,
    "Trash Linked Asset: Shortcut is defined",
);

like(
    $shortcut->get("state"), qr/^trash/,
    "Trash Linked Asset: Shortcut state is trash",
);

ok(
    grep({ $_->getId eq $shortcut->getId } @{ $snippet->getAssetsInTrash }),
    "Trash Linked Asset: Shortcut is in trash",
);

#----------------------------------------------------------------------------
# Test restoring snippet restores shortcut also
$snippet->publish;
$shortcut   = WebGUI::Asset->newByDynamicClass($session, $shortcut->getId);

ok( 
    defined $shortcut,
    "Restore Linked Asset: Shortcut is defined",
);

ok(
    !grep({ $_->getId eq $shortcut->getId } @{ $snippet->getAssetsInTrash }),
    "Restore Linked Asset: Shortcut is not in trash",
);

#----------------------------------------------------------------------------
# Test purging snippet purges shortcut also
$snippet->purge;
$shortcut   = WebGUI::Asset->newByDynamicClass($session, $shortcut->getId);

ok( 
    !defined $shortcut,
    "Purge Linked Asset: Shortcut is not defined",
);

