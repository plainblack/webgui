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

use FindBin;
use strict;
use lib "$FindBin::Bin/../../lib";
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

my $tests = 11;
plan tests => 1 + $tests;

#----------------------------------------------------------------------------
# put your tests here

my $class  = 'WebGUI::Asset::Wobject::StoryTopic';
my $loaded = use_ok($class);

my $versionTag = WebGUI::VersionTag->getWorking($session);

my $archive    = WebGUI::Asset->getDefault($session)->addChild({className => 'WebGUI::Asset::Wobject::StoryArchive', title => 'My Stories', url => '/home/mystories'});

my $now = time();
my $nowFolder = $archive->getFolder($now);

my $yesterday = $now-24*3600;
my $newFolder = $archive->getFolder($yesterday);

my $creationDateSth = $session->db->prepare('update asset set creationDate=? where assetId=?');

my $pastStory = $newFolder->addChild({ className => 'WebGUI::Asset::Story', title => "Yesterday is history", keywords => 'andy norton'});
$creationDateSth->execute([$yesterday, $pastStory->getId]);

my @staff       = qw/norton hadley mert trout/;
my @inmates     = qw/bogs red brooks andy heywood tommy jake skeet/;
my @characters  = (@staff, @inmates, );
my $storiesToMake = 16;

my @stories = ();
my $storyHandler = {};

STORY: foreach my $name (@characters) {
    my $namedStory = $nowFolder->addChild({ className => 'WebGUI::Asset::Story', title => $name, keywords => $name, } );
    $storyHandler->{$name} = $namedStory;
    $creationDateSth->execute([$now, $namedStory->getId]);
}

$storyHandler->{bogs}->update({subtitle => 'drinking his food through a straw'});

my $topic;

SKIP: {

    skip "Unable to load module $class", $tests unless $loaded;

$topic = WebGUI::Asset->getDefault($session)->addChild({ className => 'WebGUI::Asset::Wobject::StoryTopic', title => 'Popular inmates in Shawshank Prison', keywords => join(' ', @inmates)});

isa_ok($topic, 'WebGUI::Asset::Wobject::StoryTopic', 'made a Story Topic');
$topic->update({
    storiesPer   => 6,
    storiesShort => 3,
});

################################################################
#
#  viewTemplateVariables
#
################################################################

my $templateVars;
$templateVars = $topic->viewTemplateVariables();
cmp_deeply(
    $templateVars->{story_loop},
    [
        {
            title        => 'bogs',
            url          => $session->url->append($topic->getUrl, 'func=viewStory;assetId='.$storyHandler->{'bogs'}->getId),
            creationDate => $now,
        },
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
    ! exists $templateVars->{topStoryTitle}
 && ! exists $templateVars->{topStoryUrl}
 && ! exists $templateVars->{topStoryCreationDate}
 && ! exists $templateVars->{topStorySubtitle},
    'topStory variables not present unless in standalone mode'
);
ok(! $templateVars->{standAlone}, 'viewTemplateVars: not in standalone mode');

$topic->{_standAlone} = 1;
$templateVars = $topic->viewTemplateVariables();
cmp_deeply(
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
    'viewTemplateVars has right number and contents in the story_loop in standalone mode'
);

is($templateVars->{topStoryTitle}, 'bogs', 'viewTemplateVars in standalone mode, title');
is(
    $templateVars->{topStorySubtitle},
    'drinking his food through a straw',
    'viewTemplateVars in standalone mode, subtitle'
);
is(
    $templateVars->{topStoryUrl},
    $session->url->append($topic->getUrl, 'func=viewStory;assetId='.$storyHandler->{'bogs'}->getId),
    'viewTemplateVars in standalone mode, url'
);
is($templateVars->{topStoryCreationDate}, $now, 'viewTemplateVars in standalone mode, title');
ok($templateVars->{standAlone}, 'viewTemplateVars: in standalone mode');

$topic->update({
    storiesShort => 20,
});

$topic->{_standAlone} = 0;

$templateVars = $topic->viewTemplateVariables;
my @topicInmates = map { $_->{title} } @{ $templateVars->{story_loop} };
cmp_deeply(
    \@topicInmates,
    [@inmates, 'Yesterday is history'], #extra for pastStory
    'viewTemplateVariables: is only finding things with its keywords'
);

}

#----------------------------------------------------------------------------
# Cleanup
END {
    $archive->purge if $archive;
    $topic->purge   if $topic;
    if ($versionTag) {
        $versionTag->rollback;
    }
}
