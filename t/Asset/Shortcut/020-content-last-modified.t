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
WebGUI::Test->addToCleanup($versionTag);
# Make a snippet to shortcut
my $now = time();
my $snippet = $node->addChild({
            className       => "WebGUI::Asset::Snippet",
           },
           undef, $now-50);

my $shortcut = $node->addChild({
                className           => "WebGUI::Asset::Shortcut",
                shortcutToAssetId   => $snippet->getId,
           },
           undef, $now-10);
$versionTag->commit;
$session->db->write(q|update assetData set lastModified=? where assetId=?|,[WebGUI::Test->webguiBirthday, $snippet->getId]);
foreach my $asset ($snippet, $shortcut) {
    $asset = $asset->cloneFromDb;
}


#----------------------------------------------------------------------------
# Tests
plan tests => 2;

is( $shortcut->getContentLastModified, $now-10, "getContentLastModified: returns date of shortcut since it has a newer revision date.");

$snippet->update({snippet => 'updated', }, $now-5);

diag $snippet->get('lastModified');
diag $snippet->getContentLastModified;
$shortcut = $shortcut->cloneFromDb; ##Wipe the cached version of the shortcut.

is( $shortcut->getContentLastModified, $snippet->get('lastModified'), "returns lastModified when shortcutted asset has a more recent date");


