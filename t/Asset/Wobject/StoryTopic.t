# vim:syntax=perl
#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2009 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#------------------------------------------------------------------

# Write a little about what this script tests.
# 
#

use strict;
use Test::More;
use Test::Deep;
use Data::Dumper;

use WebGUI::Test; # Must use this before any other WebGUI modules
use WebGUI::Session;
use WebGUI::Text;

#----------------------------------------------------------------------------
# Init
my $session         = WebGUI::Test->session;

#----------------------------------------------------------------------------
# Tests

plan tests => 21;

#----------------------------------------------------------------------------
# put your tests here

my $class  = 'WebGUI::Asset::Wobject::StoryTopic';

my $archive    = WebGUI::Test->asset->addChild({className => 'WebGUI::Asset::Wobject::StoryArchive', title => 'My Stories', url => '/home/mystories'});

my $now = time();
my $nowFolder = $archive->getFolder($now);

my $yesterday = $now-24*3600;
my $newFolder = $archive->getFolder($yesterday);

my $creationDateSth = $session->db->prepare('update asset set creationDate=? where assetId=?');

my $pastStory = $newFolder->addChild({ className => 'WebGUI::Asset::Story', title => "Yesterday is history", keywords => 'andy,norton'});
$creationDateSth->execute([$yesterday, $pastStory->getId]);
$pastStory->requestAutoCommit;
$pastStory = $pastStory->cloneFromDb;

my @staff       = qw/norton hadley mert trout/;
my @inmates     = qw/bogs red brooks andy heywood tommy jake skeet/;
my @characters  = (@staff, @inmates, );

my @stories = ();
my $storyHandler = {};

STORY: foreach my $name (@characters) {
    my $namedStory = $nowFolder->addChild({ className => 'WebGUI::Asset::Story', title => $name, keywords => $name, } );
    $creationDateSth->execute([$now, $namedStory->getId]);
    $namedStory->requestAutoCommit;
    $storyHandler->{$name} = $namedStory->cloneFromDb;
}

$storyHandler->{bogs}->update({subtitle => 'drinking his food through a straw'});

my $topic = WebGUI::Test->asset->addChild({
    className   => 'WebGUI::Asset::Wobject::StoryTopic',
    title       => 'Popular inmates in Shawshank Prison',
    keywords    => join(',', @inmates),
    description => 'News from Shawshank',
});

isa_ok($topic, 'WebGUI::Asset::Wobject::StoryTopic', 'made a Story Topic');
$topic->update({
    storiesPer   => 6,
    storiesShort => 3,
});

$topic = $topic->cloneFromDb;

################################################################
#
#  viewTemplateVariables
#
################################################################

# When it's okay that the variables we get will have extra keys and
# values beyond what we're checking for, we'll use this function.
sub cmp_variable_loop {
    my ($got, $expected, $name) = @_;
    local $Test::Builder::Level = $Test::Builder::Level + 1;
    my $sg = @$got;
    my $se = @$expected;
    unless (@$got == @$expected) {
        fail($name);
        diag(<<EOM);
Arrayrefs are not the same length.
   got : $sg
expect : $se
EOM
        return 0;
    }

    my $failed;
    for my $i (0..$#$got) {
        my $g = $got->[$i];
        my $e = $expected->[$i];
        my ($ok, $stack) = Test::Deep::cmp_details($g, superhashof($e));
        unless ($ok) {
            unless ($failed) {
                fail($name);
                $failed = 1;
            }
            diag(Test::Deep::deep_diag($stack));
        }
    }
    return $failed ? 0 : pass($name);
}

my $templateVars;
$templateVars = $topic->viewTemplateVariables();

cmp_deeply(
    $templateVars,
    superhashof({
        rssUrl      => $topic->getRssFeedUrl,
        atomUrl     => $topic->getAtomFeedUrl,
        description => 'News from Shawshank',
    }),
    'viewTemplateVars: RSS and Atom feed template variables'
);
cmp_variable_loop(
    $templateVars->{story_loop},
    [
        {
            title        => 'red',
            url          => $session->url->append($topic->getUrl, 'func=viewStory;assetId='.$storyHandler->{'red'}->getId),
            creationDate => $now,
        },
        {
            title        => 'brooks',
            url          => $session->url->append($topic->getUrl, 'func=viewStory;assetId='.$storyHandler->{'brooks'}->getId),
            creationDate => $now,
        },
    ],
    'viewTemplateVars has right number and contents in the story_loop'
);

ok(
    exists $templateVars->{topStory}
 && exists $templateVars->{topStoryTitle}
 && exists $templateVars->{topStoryUrl}
 && exists $templateVars->{topStoryCreationDate}
 && exists $templateVars->{topStorySubtitle},
    'topStory variables present in standalone mode'
);
ok(! $templateVars->{standAlone}, 'viewTemplateVars: not in standalone mode');

$topic->{_standAlone} = 1;
$templateVars = $topic->viewTemplateVariables();
cmp_variable_loop(
    $templateVars->{story_loop},
    [
        {
            title        => 'red',
            url          => $session->url->append($topic->getUrl, 'func=viewStory;assetId='.$storyHandler->{'red'}->getId),
            creationDate => $now,
        },
        {
            title        => 'brooks',
            url          => $session->url->append($topic->getUrl, 'func=viewStory;assetId='.$storyHandler->{'brooks'}->getId),
            creationDate => $now,
        },
        {
            title        => 'andy',
            url          => $session->url->append($topic->getUrl, 'func=viewStory;assetId='.$storyHandler->{'andy'}->getId),
            creationDate => $now,
        },
        {
            title        => 'heywood',
            url          => $session->url->append($topic->getUrl, 'func=viewStory;assetId='.$storyHandler->{'heywood'}->getId),
            creationDate => $now,
        },
        {
            title        => 'tommy',
            url          => $session->url->append($topic->getUrl, 'func=viewStory;assetId='.$storyHandler->{'tommy'}->getId),
            creationDate => $now,
        },
    ],
    'viewTemplateVars has right number and contents in the story_loop in standalone mode.  Top story not present in story_loop'
);

cmp_deeply($templateVars->{topStory}, superhashof({
    title        => 'bogs',
    subtitle     => 'drinking his food through a straw',
    creationDate => $now,
}));


is($templateVars->{topStoryTitle}, 'bogs', '... topStoryTitle');
is(
    $templateVars->{topStorySubtitle},
    'drinking his food through a straw',
    '... topStorySubtitle'
);
is(
    $templateVars->{topStoryUrl},
    $session->url->append($topic->getUrl, 'func=viewStory;assetId='.$storyHandler->{'bogs'}->getId),
    '... topStoryUrl'
);
is($templateVars->{topStoryCreationDate}, $now, '... topStoryCreationDate');
ok($templateVars->{standAlone}, '... standAlone mode=1');

my $storage = WebGUI::Storage->create($session);
WebGUI::Test->addToCleanup($storage);
$storyHandler->{bogs}->setPhotoData([{
    caption   => "Octopus seen at the scene of Mrs. Dufresne's murder.",
    byLine    => 'Elmo Blatch',
    alt       => 'The suspect',
}]);

$templateVars = $topic->viewTemplateVariables();
ok(
    ! exists $templateVars->{topStoryImageUrl}
 && ! exists $templateVars->{topStoryImageByLine}
 && ! exists $templateVars->{topStoryImageAlt}
 && ! exists $templateVars->{topStoryImageCaption},
    '... no photo template variables, since there is no storage location'
);
my $bogsData = $storyHandler->{bogs}->getPhotoData();
$bogsData->[0]->{storageId} = $storage->getId;
$storyHandler->{bogs}->setPhotoData($bogsData);
$templateVars = $topic->viewTemplateVariables();
ok(
    ! exists $templateVars->{topStoryImageUrl}
 && ! exists $templateVars->{topStoryImageByLine}
 && ! exists $templateVars->{topStoryImageAlt}
 && ! exists $templateVars->{topStoryImageCaption},
    '... no photo template variables, since there is no file in the storage location'
);

$storage->addFileFromFilesystem(WebGUI::Test->getTestCollateralPath('gooey.jpg'));
$templateVars = $topic->viewTemplateVariables();
cmp_deeply(
    [ @{ $templateVars }{qw/topStoryImageUrl topStoryImageByline topStoryImageAlt topStoryImageCaption/} ],
    [
       $storage->getUrl('gooey.jpg'), 
       'Elmo Blatch',
       'The suspect',
       "Octopus seen at the scene of Mrs. Dufresne's murder.",
    ],
    '... photo template variables set'
);

$topic->update({
    storiesShort => 20,
});

$topic->{_standAlone} = 0;

$templateVars    = $topic->viewTemplateVariables;
my @topicInmates = map { $_->{title} } @{ $templateVars->{story_loop} };
unshift @topicInmates, $templateVars->{topStoryTitle};
cmp_deeply(
    \@topicInmates,
    [@inmates, 'Yesterday is history'], #extra for pastStory
    'viewTemplateVariables: is only finding things with its keywords'
);

$session->scratch->set('isExporting', 1);
$topic->update({
    storiesShort => 3,
});
$templateVars = $topic->viewTemplateVariables;
cmp_variable_loop(
    $templateVars->{story_loop},
    [
        {
            title        => 'red',
            url          => $storyHandler->{'red'}->getUrl,
            creationDate => $now,
        },
        {
            title        => 'brooks',
            url          => $storyHandler->{'brooks'}->getUrl,
            creationDate => $now,
        },
    ],
    '... export mode, URLs are the regular story URLs'
);
cmp_deeply(
    $templateVars,
    superhashof({
        rssUrl  => $topic->getStaticRssFeedUrl,
        atomUrl => $topic->getStaticAtomFeedUrl,
    }),
    '... export mode, RSS and Atom feed template variables show the static url'
);
$session->scratch->delete('isExporting');

################################################################
#
#  getRssFeedItems
#
################################################################

$topic->update({
    storiesPer   => 3,
});
cmp_deeply(
    $topic->getRssFeedItems(),
    [
        {
            title => 'bogs',
            description => ignore(),
            'link'      => ignore(),
            date        => ignore(),
            author      => ignore(),
            guid        => ignore(),
            pubDate     => ignore(),
        },
        {
            title => 'red',
            description => ignore(),
            'link'      => ignore(),
            date        => ignore(),
            author      => ignore(),
            guid        => ignore(),
            pubDate     => ignore(),
        },
        {
            title => 'brooks',
            description => ignore(),
            'link'      => ignore(),
            date        => ignore(),
            author      => ignore(),
            guid        => ignore(),
            pubDate     => ignore(),
        },
    ],
    'rssFeedItems'
);

################################################################
# Sort Order
################################################################

$pastStory->update( { title => "aaaay was history but isn't any more" } );
$pastStory->requestAutoCommit;
$pastStory = $pastStory->cloneFromDb;

$topic->update({ storiesPer   => 4, storiesShort => 4, }); # storiesPer is used when _standAlone is true, storiesShort otherwise
$topic->{_standAlone} = 0;
$topic->update( { storySortOrder => 'Alphabetically' } );

$templateVars = $topic->viewTemplateVariables();

cmp_variable_loop(
    [
        {
            title        => $templateVars->{topStoryTitle},
            url          => $templateVars->{topStoryUrl},
            creationDate => $templateVars->{topStoryCreationDate},
        },
        @{ $templateVars->{story_loop} },
    ],
    [
        {
            title        => "aaaay was history but isn't any more",
            url          => ignore(),
            creationDate => $yesterday,
        },
        {
            title        => 'andy',
            url          => ignore(),
            creationDate => $now,
        },
        {
            title        => 'bogs',
            url          => ignore(),
            creationDate => $now,
        },
        {
            title        => 'brooks',
            url          => ignore(),
            creationDate => $now,
        },
    ],
    'viewTemplateVars has right number and contents in the story_loop in sort order Alphabetically mode'
);

################################################################
# Regression -- Empty StoryTopics shouldn't blow up
################################################################

my $emptyarchive    = WebGUI::Test->asset->addChild({
    className => 'WebGUI::Asset::Wobject::StoryTopic', 
    title => 'Why Do Good Things Happen To Bad People', 
    url => '/home/badstories', 
    keywords => 'aksjhgkja asgjhshs assajshhsg5',
});

$emptyarchive->{_standAlone} = 1;  
ok(eval { $emptyarchive->viewTemplateVariables() }, "viewTemplateVariables with _standAlone = 1 doesn't throw an error");

