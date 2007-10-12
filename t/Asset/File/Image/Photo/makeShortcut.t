#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2007 Plain Black Corporation.
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

use Scalar::Util qw( blessed );
use WebGUI::Test;
use WebGUI::Session;
use Test::More; 
use WebGUI::Test::Maker::HTML;
use WebGUI::Asset::File::Image::Photo;

#----------------------------------------------------------------------------
# Init
my $session         = WebGUI::Test->session;
my $node            = WebGUI::Asset->getImportNode($session);
my $versionTag      = WebGUI::VersionTag->getWorking($session);
$versionTag->set({name=>"Photo Test"});
my $maker           = WebGUI::Test::Maker::HTML->new;
my $otherParent
    = $node->addChild({
        className           => "WebGUI::Asset::Wobject::Layout",
    });
my $photo
    = $node->addChild({
        className           => "WebGUI::Asset::File::Image::Photo",
        userDefined1        => "ORIGINAL",
    });

#----------------------------------------------------------------------------
# Cleanup
END {
    $versionTag->rollback();
}

#----------------------------------------------------------------------------
# Tests
plan tests => 0;

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
    blessed $shortcut, "WebGUI::Asset::Shortcut",
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
    blessed $shortcut, "WebGUI::Asset::Shortcut",
    "Photo->makeShortcut returns a WebGUI::Shortcut asset",
);

is(
    $shortcut->getShortcutOriginal->getId, $photo->getId,
    "Photo->makeShortcut makes a shortcut to the correct asset",
);

is_deeply(
    {$shortcut->getShortcutOverrides}, $overrides,
    "Photo->makeShortcut makes a shortcut with the correct overrides",
);

#----------------------------------------------------------------------------
# www_makeShortcut is only available to those who can edit the photo
$maker->prepare({
    object      => $photo,
    method      => "www_makeShortcut",
    userId      => 1,
    test_privilege  => "insufficient",
});
$maker->run;

#----------------------------------------------------------------------------
# www_makeShortcut 
