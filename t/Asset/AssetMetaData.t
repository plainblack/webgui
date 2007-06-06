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

##The goal of this test is to check the creation and purging of
##versions.

use WebGUI::Test;
use WebGUI::Session;
use WebGUI::Utility;
use WebGUI::Asset;
use WebGUI::VersionTag;

use Test::More; # increment this value for each test you create
use Test::Deep;
plan tests => 6;

my $session = WebGUI::Test->session;
$session->user({userId => 3});
my $root = WebGUI::Asset->getRoot($session);
my $versionTag = WebGUI::VersionTag->getWorking($session);
$versionTag->set({name=>"Asset Package test"});

my $folder = $root->addChild({
    url   => 'testFolder',
    title => 'folder',
    menuTitle => 'folderMenuTitle',
    className => 'WebGUI::Asset::Wobject::Folder',
    isPackage => 1,
});

my $snippet = $folder->addChild({
    url => 'testSnippet',
    title => 'snippet',
    menuTitle => 'snippetMenuTitle',
    className => 'WebGUI::Asset::Snippet',
    snippet   => 'A snippet of text',
});

$versionTag->commit;

##Note that there is no MetaData field master class.  New fields can be added
##from _ANY_ asset, and be available to all assets.

cmp_deeply({}, $snippet->getMetaDataFields, 'snippet has no metadata fields');
cmp_deeply({}, $folder->getMetaDataFields,  'folder has no metadata fields');

$snippet->addMetaDataField('new', 'searchEngine', '', 'Search Engine preference', 'text');

my @snipKeys;
my @foldKeys;

@snipKeys = keys %{ $snippet->getMetaDataFields };
@foldKeys = keys %{ $folder->getMetaDataFields };
is(scalar @snipKeys, 1, 'Only 1 meta data field available');
cmp_deeply( \@snipKeys, \@foldKeys, 'Snippet and Folder have access to the same meta data');

my $seMetaData = $snippet->getMetaDataFields()->{$snipKeys[0]};

$folder->addMetaDataField('new', 'color', '', 'Favorite Color', 'radioList', "Blue\nRed\nWhite\nYellow\nGreen");

@snipKeys = keys %{ $snippet->getMetaDataFields };
@foldKeys = keys %{ $folder->getMetaDataFields };
is(scalar @foldKeys, 2, 'Two meta data fields available');
cmp_deeply( \@snipKeys, \@foldKeys, 'Snippet and Folder have access to the same meta data fields');

END {
    foreach my $metaDataFieldId (keys %{ $snippet->getMetaDataFields }) {
        $snippet->deleteMetaDataField($metaDataFieldId);
    }

    foreach my $tag($versionTag) {
        if (defined $tag and ref $tag eq 'WebGUI::VersionTag') {
            $tag->rollback;
        }
    }

}
