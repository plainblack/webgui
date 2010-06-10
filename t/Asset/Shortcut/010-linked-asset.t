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

my $snippet;
my $shortcut;
init();

#----------------------------------------------------------------------------
# Tests
plan tests => 11;

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
$shortcut   = $shortcut->cloneFromDb();

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
$shortcut   = $shortcut->cloneFromDb();

ok( 
    defined $shortcut,
    "Restore Linked Asset: Shortcut is defined",
);

ok(
    !grep({ $_->getId eq $shortcut->getId } @{ $snippet->getAssetsInTrash }),
    "Restore Linked Asset: Shortcut is not in trash",
);

#----------------------------------------------------------------------------
# Test purging snippet but keeping shortcut doesn't cause
# getContentLastModified to generate an error; makes sure that
# http://www.webgui.org/use/bugs/tracker/11052 stays fixed.
$session->db->beginTransaction();
$session->db->write("delete from assetData where assetId = ?",
                    [$snippet->getId]);
$session->db->write("delete from asset where assetId = ?",
                    [$snippet->getId]);
$session->db->write("delete from snippet where assetId = ?",
                    [$snippet->getId]);
$session->db->commit();

my $contentLastModified;
eval {
    $contentLastModified = $shortcut->getContentLastModified();
};

is(
    $contentLastModified, 0,
    "Purged Linked Asset: getContentLastModified returns 0 when linked asset missing",
);

# re-init so further tests will work
init();

#----------------------------------------------------------------------------
# Test purging snippet purges shortcut also, even when they're both in the trash

# This will trash both the snippet and the shortcut (or else an earlier test failed)
$snippet->trash();

$snippet->purge();
$shortcut   = $shortcut->cloneFromDb();

ok(
    !defined $shortcut,
    "Purge Linked Asset: Shortcut is purged even though it's in the trash"
);

# re-init so further tests will work
init();

#----------------------------------------------------------------------------
# Test purging snippet purges shortcut also
$snippet->purge;
$shortcut   = $shortcut->cloneFromDb();

ok( 
    !defined $shortcut,
    "Purge Linked Asset: Shortcut is not defined",
);

#----------------------------------------------------------------------------
# init a new snippet and shortcut; handy to have in a sub because we destroy
# them in some tests and need to reset them for the next round
sub init {
    my $versionTag      = WebGUI::VersionTag->getWorking($session);
    $versionTag->set({name=>"Shortcut Test"});
    WebGUI::Test->addToCleanup($versionTag);
    # Make a snippet to shortcut
    $snippet 
        = $node->addChild({
            className       => "WebGUI::Asset::Snippet",
        });

    $shortcut
        = $node->addChild({
            className           => "WebGUI::Asset::Shortcut",
            shortcutToAssetId   => $snippet->getId,
        });
}
