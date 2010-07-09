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
use WebGUI::Test::Maker::Permission;
use WebGUI::Session;
use WebGUI::Storage;
use WebGUI::User;
use WebGUI::Group;
use WebGUI::Asset::Story;

use Test::More; # increment this value for each test you create
use Test::Deep;
use Data::Dumper;

#TODO: This script tests certain aspects of WebGUI::Storage and it should not

my $session = WebGUI::Test->session;

my $story = 'placeholder for Test::Maker::Permission';
my $wgBday = WebGUI::Test->webguiBirthday;

my $canPostGroup = WebGUI::Group->new($session, 'new');
my $postUser     = WebGUI::User->create($session);
$canPostGroup->addUsers([$postUser->userId]);
my $archiveOwner = WebGUI::User->create($session);
my $reader       = WebGUI::User->create($session);
$postUser->username('Can Post User');
$reader->username('Average Reader');
$archiveOwner->username('Archive Owner');
WebGUI::Test->addToCleanup($canPostGroup);
WebGUI::Test->addToCleanup($postUser, $archiveOwner, $reader);

my $canEditMaker = WebGUI::Test::Maker::Permission->new();
$canEditMaker->prepare({
    object   => $story,
    session  => $session,
    method   => 'canEdit',
    pass     => [3, $postUser, $archiveOwner ],
    fail     => [1, $reader                  ],
});


my $defaultNode = WebGUI::Asset->getDefault($session);
my $archive     = $defaultNode->addChild({
    className   => 'WebGUI::Asset::Wobject::StoryArchive',
    title       => 'Test Archive',
                   #1234567890123456789012
    assetId     => 'TestStoryArchiveAsset1',
    groupToPost => $canPostGroup->getId,
    ownerUserId => $archiveOwner->userId,
});
my $topic       = $defaultNode->addChild({
    className => 'WebGUI::Asset::Wobject::StoryTopic',
    title     => 'Test Topic',
                 #1234567890123456789012
    assetId   => 'TestStoryTopicAsset123',
    keywords  => 'tango,yankee',
});
my $archiveTag  = WebGUI::VersionTag->getWorking($session);
$archiveTag->commit;
WebGUI::Test->addToCleanup($archiveTag);
foreach my $asset ($archive, $topic) {
    $asset = $asset->cloneFromDb;
}

my $storage1 = WebGUI::Storage->create($session);
my $storage2 = WebGUI::Storage->create($session);
WebGUI::Test->addToCleanup($storage1, $storage2);

############################################################
#
# PLAN
#
############################################################

my $tests = 45;
plan tests => $tests
            + $canEditMaker->plan
            ;

############################################################
#
# validParent
#
############################################################

ok(! WebGUI::Asset::Story->validParent($session), 'validParent: no session asset');
$session->asset($defaultNode);
ok(! WebGUI::Asset::Story->validParent($session), 'validParent: wrong type of asset');
$session->asset(WebGUI::Asset->getRoot($session));
ok(! WebGUI::Asset::Story->validParent($session), 'validParent: Any old folder is not valid');
$session->asset($archive);
ok(  WebGUI::Asset::Story->validParent($session), 'validParent: StoryArchive is valid');
my $todayFolder = $archive->getFolder();
$session->asset($todayFolder);
ok(  WebGUI::Asset::Story->validParent($session), 'validParent: Folder below story archive is valid');

############################################################
#
# Make a new one.  Test defaults
#
############################################################

$story = $archive->addChild({
    className => 'WebGUI::Asset::Story',
    title     => 'Story 1',
    subtitle  => 'The story of a CMS',
    byline    => 'JT Smith',
    story     => 'WebGUI was originally called Web Done Right.',
});

isa_ok($story, 'WebGUI::Asset::Story', 'Created a Story asset');
is($story->photo,   '[]', 'by default, photos is an empty JSON array');
is($story->isHidden, 1, 'by default, stories are hidden');
$story->update({isHidden => 0});
is($story->isHidden, 1, 'stories cannot be set to not be hidden');
is($story->state,    'published', 'Story is published');
$story->requestAutoCommit;

{
    ##Version control does not alter the current object's status, fetch an updated copy from the
    ##db.
    my $storyDB = $story->cloneFromDb;
    is($storyDB->status,   'approved',  'Story is approved');
}


############################################################
#
# getArchive
#
############################################################

is($story->getArchive->getId, $archive->getId, 'getArchive gets the parent archive for the Story');

############################################################
#
# getContainer
#
############################################################

is($story->getContainer->getId, $archive->getId, 'getContainer gets the parent archive for the Story');

############################################################
#
# canEdit
#
############################################################

$canEditMaker->{_tests}->[0]->{object} = $story;

$canEditMaker->run();

############################################################
#
# Photo JSON
#
############################################################

my $photoData = $story->getPhotoData();
cmp_deeply(
    $photoData, [],
    'getPhotoData: returns an empty array ref with no JSON data'
);

$story->setPhotoData([
    {
        byLine  => 'Andrew Dufresne',
        caption => 'Shawshank Prison',
    },
]);

is($story->photo, q|[{"caption":"Shawshank Prison","byLine":"Andrew Dufresne"}]|, 'setPhotoData: set JSON in the photo property');

$photoData = $story->getPhotoData();
$photoData->[0]->{caption}="My cell";

cmp_deeply(
    $story->getPhotoData,
    [
        {
            byLine  => 'Andrew Dufresne',
            caption => 'Shawshank Prison',
        },
    ],
    'getPhotoData does not return an unsafe reference'
);

$story->setPhotoData();
cmp_deeply(
    $story->getPhotoData, [],
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
    'getCrumbTrail: with topic set'
);

$story->topic('');

############################################################
#
# getRssData
#
############################################################

can_ok($story, 'getRssData');

cmp_deeply(
    $story->getRssData,
    {
        title       => 'Story 1',
        description => 'WebGUI was originally called Web Done Right.',
        'link'      => all(re('^'.$session->url->getSiteURL),re('story-1$')),
        guid        => re('story-1$'),
        author      => 'JT Smith',
        date        => $story->lastModified,
        pubDate     => $session->datetime->epochToMail($story->creationDate),
    },
    'getRssData: returns correct data'
);

$story->update({headline  => 'WebGUI, Web Done Right'});

is($story->getRssData->{title}, 'WebGUI, Web Done Right', '... headline preferred over title if present');

############################################################
#
# viewTemplateVariables
#
############################################################

$story->update({
    highlights => "one\ntwo\nthree",
    keywords   => "foxtrot,tango,whiskey",
});
is($story->highlights, "one\ntwo\nthree", 'highlights set correctly for template var check');

$storage1->addFileFromFilesystem(WebGUI::Test->getTestCollateralPath('gooey.jpg'));
$storage2->addFileFromFilesystem(WebGUI::Test->getTestCollateralPath('lamp.jpg'));

$story->setPhotoData([
    {
        storageId => $storage1->getId,
        caption   => 'Mascot for a popular CMS',
        byLine    => 'Darcy Gibson',
        alt       => 'Gooey',
        title     => 'Mascot',
        url       => 'http://www.webgui.org',
    },
    {
        storageId => $storage2->getId,
        caption   => 'The Lamp',
        byLine    => 'Aladdin',
        alt       => 'Lamp',
        title     => '',
        url       => 'http://www.lamp.com',
    },
]);


my $viewVariables = $story->viewTemplateVariables;
#note explain $viewVariables;
cmp_deeply(
    $viewVariables->{highlights_loop},
    [
        { highlight => "one", },
        { highlight => "two", },
        { highlight => "three", },
    ],
    'viewTemplateVariables: highlights_loop is okay'
);

is($viewVariables->{title},    'Story 1',                '... title is okay');
is($viewVariables->{headline}, 'WebGUI, Web Done Right', '... headline is okay');

cmp_bag(
    $viewVariables->{keyword_loop},
    [
        { keyword => "foxtrot", url => '/home/test-archive?func=view;keyword=foxtrot', },
        { keyword => "tango",   url => '/home/test-archive?func=view;keyword=tango', },
        { keyword => "whiskey", url => '/home/test-archive?func=view;keyword=whiskey', },
    ],
    'viewTemplateVariables: keywords_loop is okay'
);

is ($viewVariables->{updatedTimeEpoch}, $story->revisionDate, 'viewTemplateVariables: updatedTimeEpoch');

cmp_deeply(
    $viewVariables->{photo_loop},
    [
        {
            imageUrl     => re('gooey.jpg'),
            imageCaption => 'Mascot for a popular CMS',
            imageByline  => 'Darcy Gibson',
            imageAlt     => 'Gooey',
            imageTitle   => 'Mascot',
            imageLink    => 'http://www.webgui.org',
        },
        {
            imageUrl     => re('lamp.jpg'),
            imageCaption => 'The Lamp',
            imageByline  => 'Aladdin',
            imageAlt     => 'Lamp',
            imageTitle   => '',
            imageLink    => 'http://www.lamp.com',
        },
    ],
    'viewTemplateVariables: photo_loop is okay'
);

ok(! $viewVariables->{singlePhoto}, 'viewVariables: singlePhoto: there is more than 1');
ok(  $viewVariables->{hasPhotos},   'viewVariables: hasPhotos: it has photos');

##Simulate someone deleting the file stored in the storage object.
$storage2->deleteFile('lamp.jpg');
$viewVariables = $story->viewTemplateVariables;

cmp_deeply(
    $viewVariables->{photo_loop},
    [
        {
            imageUrl     => re('gooey.jpg'),
            imageCaption => 'Mascot for a popular CMS',
            imageByline  => 'Darcy Gibson',
            imageAlt     => 'Gooey',
            imageTitle   => 'Mascot',
            imageLink    => 'http://www.webgui.org',
        },
    ],
    'viewTemplateVariables: photo_loop: if the storage has no files, it is not shown'
);

ok($viewVariables->{singlePhoto}, 'viewVariables: singlePhoto: there is just 1');
ok($viewVariables->{hasPhotos},   'viewVariables: hasPhotos: it has photos');

############################################################
#
# duplicatePhotoData
#
############################################################

$photoData = $story->getPhotoData;
$photoData->[0]->{storageId} = re('^[A-Za-z0-9_-]{22}$');
$photoData->[1]->{storageId} = re('^[A-Za-z0-9_-]{22}$');
my $newPhotoData = $story->duplicatePhotoData;

cmp_deeply(
    $newPhotoData,
    $photoData,
    'duplicatePhotoData: checking JSON data minus storage locations'
);

isnt($newPhotoData->[0]->{storageId}, $photoData->[0]->{storageId}, '... and storage 0 is duplicated');
isnt($newPhotoData->[1]->{storageId}, $photoData->[1]->{storageId}, '... and storage 1 is duplicated');

WebGUI::Test->addToCleanup( map { ( 'WebGUI::Storage' => $_->{storageId} ) } @{ $newPhotoData } );

############################################################
#
# exportAssetData
#
############################################################

my $exportData = $story->exportAssetData;
isa_ok($exportData, 'HASH', 'exportAssetData');

cmp_bag(
    $exportData->{storage},
    [
        $storage1->getId,
        $storage2->getId,
    ],
    '...asset package data has the storage locations in it'
);

#vim:ft=perl
