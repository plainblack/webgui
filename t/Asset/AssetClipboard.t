#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2007 Plain Black Corporation.
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

##The goal of this test is to check the creation and purging of
##versions.

use WebGUI::Test;
use WebGUI::Session;
use WebGUI::Utility;
use WebGUI::Asset;
use WebGUI::VersionTag;

use Test::More; # increment this value for each test you create
plan tests => 5;

my $session = WebGUI::Test->session;
$session->user({userId => 3});
my $root = WebGUI::Asset->getRoot($session);
my $versionTag = WebGUI::VersionTag->getWorking($session);
$versionTag->set({name=>"Asset Clipboard test"});

my $snippet = $root->addChild({
    url => 'testSnippet',
    title => 'snippet',
    menuTitle => 'snippetMenuTitle',
    className => 'WebGUI::Asset::Snippet',
    snippet   => 'A snippet of text',
});

my $snippetAssetId = $snippet->getId;

$versionTag->commit;

sleep 2;

my $duplicatedSnippet = $snippet->duplicate;

is($duplicatedSnippet->get('title'), 'snippet',        'duplicated snippet has correct title');
isnt($duplicatedSnippet->getId,      $snippetAssetId,  'duplicated snippet does not have same assetId as original');
is($snippet->getId,                  $snippetAssetId,  'original snippet has correct id');

is($snippet->getParent->getId,           $root->getId, 'original snippet is a child of root');
is($duplicatedSnippet->getParent->getId, $root->getId, 'duplicated snippet is also a child of root');

my $newVersionTag = WebGUI::VersionTag->getWorking($session);
$newVersionTag->commit;

END {
    foreach my $tag($versionTag, $newVersionTag) {
        if (defined $tag and ref $tag eq 'WebGUI::VersionTag') {
            $tag->rollback;
        }
    }
}
