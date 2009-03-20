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
use Data::Dumper;

my $tests = 1;
plan tests => 27
            + $tests
            ;

#TODO: This script tests certain aspects of WebGUI::Storage and it should not

my $session = WebGUI::Test->session;

my $class  = 'WebGUI::Asset::Story';
my $loaded = use_ok($class);
my $story;
my $wgBday = WebGUI::Test->webguiBirthday;

my $defaultNode = WebGUI::Asset->getDefault($session);
my $archive     = $defaultNode->addChild({
    className => 'WebGUI::Asset::Wobject::StoryArchive',
    title     => 'Test Archive',
                 #1234567890123456789012
    assetId   => 'TestStoryArchiveAsset1',
});
my $topic       = $defaultNode->addChild({
    className => 'WebGUI::Asset::Wobject::StoryTopic',
    title     => 'Test Topic',
                 #1234567890123456789012
    assetId   => 'TestStoryTopicAsset123',
    keywords  => 'tango yankee',
});
my $archiveTag  = WebGUI::VersionTag->getWorking($session);
$archiveTag->commit;


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
is($story->get('isHidden'), 1, 'by default, stories are hidden');
$story->update({isHidden => 0});
is($story->get('isHidden'), 1, 'stories cannot be set to not be hidden');
is($story->get('state'),    'published', 'Story is published');

{
    ##Version control does not alter the current object's status, fetch an updated copy from the
    ##db.
    my $storyDB = WebGUI::Asset->newByUrl($session, $story->getUrl);
    is($storyDB->get('status'),   'approved',  'Story is approved');
}


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

############################################################
#
# formatDuration
#
############################################################

is($story->formatDuration(time() - (24*3600+15)), '1 Day(s)', 'formatDuration, 1 day');
is($story->formatDuration(time() - (48*3600+15)), '2 Day(s)', 'formatDuration, 2 day');
like($story->formatDuration($wgBday), qr{Year.s.}, 'formatDuration: a long time ago');
is($story->formatDuration(time() - (3600+5)), '1 Hour(s)', 'formatDuration: 1 hour');
is($story->formatDuration(time() - (60+5)),   '1 Minute(s)', 'formatDuration: 1 minute');
is($story->formatDuration(time() - (7200+120)), '2 Hour(s), 2 Minute(s)', 'formatDuration: 2 hours, 2 minutes');

############################################################
#
# getCrumbTrail
#
############################################################

cmp_deeply(
    $story->getCrumbTrail,
    [
        {
            title => $archive->getTitle,
            url   => $archive->getUrl,
        },
        {
            title => $story->getTitle,
            url   => $story->getUrl,
        },
    ],
    'getCrumbTrail: with no topic set'
);

$story->topic($topic);

cmp_deeply(
    $story->getCrumbTrail,
    [
        {
            title => $archive->getTitle,
            url   => $archive->getUrl,
        },
        {
            title => $topic->getTitle,
            url   => $topic->getUrl,
        },
        {
            title => $story->getTitle,
            url   => $story->getUrl,
        },
    ],
    'getCrumbTrail: with no topic set'
);

$story->topic('');

############################################################
#
# viewTemplateVariables
#
############################################################

$story->update({
    highlights => "one\ntwo\nthree",
    keywords   => "foxtrot tango whiskey",
});
is($story->get('highlights'), "one\ntwo\nthree", 'highlights set correctly for template var check');
my $viewVariables = $story->viewTemplateVariables;
#diag Dumper $viewVariables;
cmp_deeply(
    $viewVariables->{highlights_loop},
    [
        { highlight => "one", },
        { highlight => "two", },
        { highlight => "three", },
    ],
    'viewTemplateVariables: highlights_loop is okay'
);

cmp_bag(
    $viewVariables->{keyword_loop},
    [
        { keyword => "foxtrot", url => '/home/test-archive?func=view;keywords=foxtrot', },
        { keyword => "tango",   url => '/home/test-archive?func=view;keywords=tango', },
        { keyword => "whiskey", url => '/home/test-archive?func=view;keywords=whiskey', },
    ],
    'viewTemplateVariables: keywords_loop is okay'
);

is ($viewVariables->{updatedTimeEpoch}, $story->get('revisionDate'), 'viewTemplateVariables: updatedTimeEpoch');

}

END {
    $story->purge   if $story;
    $archive->purge if $archive;
    $topic->purge   if $topic;
    $archiveTag->rollback;
    WebGUI::VersionTag->getWorking($session)->rollback;
}
