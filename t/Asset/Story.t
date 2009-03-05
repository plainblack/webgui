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
use lib "$FindBin::Bin/../lib";

use WebGUI::Test;
use WebGUI::Session;
use WebGUI::Storage;

use Test::More; # increment this value for each test you create
use Test::Deep;

my $tests = 1;
plan tests => 13
            + $tests
            ;

#TODO: This script tests certain aspects of WebGUI::Storage and it should not

my $session = WebGUI::Test->session;

my $class  = 'WebGUI::Asset::Story';
my $loaded = use_ok($class);
my $story;

my $defaultNode = WebGUI::Asset->getDefault($session);
my $archive     = $defaultNode->addChild({
    className => 'WebGUI::Asset::Wobject::StoryArchive',
    title     => 'Test Archive',
                 #1234567890123456789012
    assetId   => 'TestStoryArchiveAsset1',
});

SKIP: {

skip "Unable to load module $class", $tests unless $loaded;

############################################################
#
# validParent
#
############################################################

ok(! WebGUI::Asset::Story->validParent($session), 'validParent: no session asset');
$session->asset($defaultNode);
ok(! WebGUI::Asset::Story->validParent($session), 'validParent: wrong type of asset');
$session->asset($archive);
ok(  WebGUI::Asset::Story->validParent($session), 'validParent: StoryArchive is valid');

############################################################
#
# Make a new one.  Test defaults
#
############################################################

$story = $archive->addChild({
    className => 'WebGUI::Asset::Story',
    title     => 'Story 1',
});

isa_ok($story, 'WebGUI::Asset::Story', 'Created a Story asset');
is($story->get('storageId'), '', 'by default, there is no storageId');
is($story->get('photo'),   '{}', 'by default, photos is an empty JSON hash');
is($story->get('isHidden'), 1, 'by default, photos are hidden');
$story->update({isHidden => 0});
is($story->get('isHidden'), 1, 'photos cannot be set to not be hidden');

############################################################
#
# getArchive
#
############################################################

is($story->getArchive->getId, $archive->getId, 'getArchive gets the parent archive for the Story');

############################################################
#
# Photo JSON
#
############################################################

my $photoData = $story->getPhotoData();
cmp_deeply(
    $photoData, {},
    'getPhotoData: returns an empty hash with no JSON data'
);

$story->setPhotoData({
    filename1 => {
        byLine  => 'Andrew Dufresne',
        caption => 'Shawshank Prison',
    },
});

is($story->get('photo'), q|{"filename1":{"caption":"Shawshank Prison","byLine":"Andrew Dufresne"}}|, 'setPhotoData: set JSON in the photo property');

$photoData = $story->getPhotoData();
$photoData->{filename1}->{caption}="My cell";

cmp_deeply(
    $story->getPhotoData,
    {
        filename1 => {
            byLine  => 'Andrew Dufresne',
            caption => 'Shawshank Prison',
        },
    },
    'getPhotoData does not return an unsafe reference'
);

$story->setPhotoData();
cmp_deeply(
    $story->getPhotoData, {},
    'setPhotoData: wipes the stored data if nothing is passed'
);

}

END {
    $story->purge   if $story;
    $archive->purge if $archive;
    WebGUI::VersionTag->getWorking($session)->rollback;
}
