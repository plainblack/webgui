#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2009 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

# The goal of this test is to test the makeShortcut method and www_makeShortcut
# pages

use FindBin;
use strict;
use lib "$FindBin::Bin/../../../../lib";

use Scalar::Util;
use WebGUI::Test;
use WebGUI::Session;
use Test::More; 
use Test::Deep;
use WebGUI::Asset::File::GalleryFile::Photo;

#----------------------------------------------------------------------------
# Init
my $session         = WebGUI::Test->session;
my $node            = WebGUI::Asset->getImportNode($session);
my $versionTag      = WebGUI::VersionTag->getWorking($session);
$versionTag->set({name=>"Photo Test"});
WebGUI::Test->addToCleanup($versionTag);
my $otherParent
    = $node->addChild({
        className           => "WebGUI::Asset::Wobject::Layout",
    });
my $gallery
    = $node->addChild({
        className           => "WebGUI::Asset::Wobject::Gallery",
        imageResolutions    => "1600x1200\n1024x768\n800x600\n640x480",
    });
my $album
    = $gallery->addChild({
        className           => "WebGUI::Asset::Wobject::GalleryAlbum",
    },
    undef,
    undef,
    {
        skipAutoCommitWorkflows => 1,
    });

my $photo
    = $album->addChild({
        className           => "WebGUI::Asset::File::GalleryFile::Photo",
        userDefined1        => "ORIGINAL",
    },
    undef,
    undef,
    {
        skipAutoCommitWorkflows => 1,
    });

$versionTag->commit;

#----------------------------------------------------------------------------
# Tests
plan tests => 10;

#----------------------------------------------------------------------------
# makeShortcut argument checking
ok(
    !eval{ $photo->makeShortcut(); 1 },
    "Photo->makeShortcut requires at least one argument",
);

ok(
    !eval{ $photo->makeShortcut("", ""); 1},
    "Photo->makeShortcut fails if second argument is not hash reference",
);

ok(
    !eval{ $photo->makeShortcut(""); 1},
    "Photo->makeShortcut fails if given parent cannot be instanciated",
);

#----------------------------------------------------------------------------
# makeShortcut returns a reference to the new Shortcut asset
my $shortcut;
ok(
    eval{ $shortcut = $photo->makeShortcut($otherParent->getId); 1},
    "Photo->makeShortcut succeeds when valid assetId is given",
);

is(
    Scalar::Util::blessed($shortcut), "WebGUI::Asset::Shortcut",
    "Photo->makeShortcut returns a WebGUI::Shortcut asset",
);

is(
    $shortcut->getShortcutOriginal->getId, $photo->getId,
    "Photo->makeShortcut makes a shortcut to the correct asset",
);

#----------------------------------------------------------------------------
# makeShortcut creates the appropriate overrides
my $overrides   = {
   userDefined1         => "OVERRIDDEN", 
};
ok(
    eval{ $shortcut = $photo->makeShortcut($otherParent->getId, $overrides); 1},
    "Photo->makeShortcut succeeds when valid assetId is given",
);

is(
    Scalar::Util::blessed($shortcut), "WebGUI::Asset::Shortcut",
    "Photo->makeShortcut returns a WebGUI::Shortcut asset",
);

is(
    $shortcut->getShortcutOriginal->getId, $photo->getId,
    "Photo->makeShortcut makes a shortcut to the correct asset",
);

my %shortcutOverrides   = $shortcut->getOverrides;
cmp_deeply(
    { map({ $_ => $shortcutOverrides{overrides}->{$_}->{newValue} } keys %{ $overrides }) },
    $overrides,
    "Photo->makeShortcut makes a shortcut with the correct overrides",
);

#----------------------------------------------------------------------------
# www_makeShortcut is only available to those who can edit the photo

#----------------------------------------------------------------------------
# www_makeShortcut

#vim:ft=perl
