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
use WebGUI::Test::Maker::Permission;
use WebGUI::Session;
use WebGUI::Text;

################################################################
#
#  setup session, users and groups for this test
#
################################################################

my $session         = WebGUI::Test->session;

my $staff = WebGUI::Group->new($session, 'new');
$staff->name('Reporting Staff');

my $reporter = WebGUI::User->new($session, 'new');
$reporter->username('reporter');
my $editor   = WebGUI::User->new($session, 'new');
$editor->username('editor');
my $reader   = WebGUI::User->new($session, 'new');
$reader->username('reader');
$staff->addUsers([$reporter->userId]);

my $archive = 'placeholder for Test::Maker::Permission';

my $canPostMaker = WebGUI::Test::Maker::Permission->new();
$canPostMaker->prepare({
    object   => $archive,
    session  => $session,
    method   => 'canPostStories',
    pass     => [3, $editor, $reporter ],
    fail     => [1, $reader            ],
});

my $tests = 1;
plan tests => 2
            + $tests
            + $canPostMaker->plan
            ;

#----------------------------------------------------------------------------
# put your tests here

my $class  = 'WebGUI::Asset::Wobject::StoryArchive';
my $loaded = use_ok($class);

my $storage;

SKIP: {

skip "Unable to load module $class", $tests unless $loaded;

$archive = WebGUI::Asset->getDefault($session)->addChild({className => $class});

isa_ok($archive, 'WebGUI::Asset::Wobject::StoryArchive', 'created StoryArchive');

################################################################
#
#  canPostStories
#
################################################################

$archive->update({
    ownerUserId => $editor->userId,
    groupToPost => $staff->getId,
});

is($archive->get('groupToPost'), $staff->getId, 'set Staff group to post to Story Archive');

$canPostMaker->{_tests}->[0]->{object} = $archive;

$canPostMaker->run();

}

#----------------------------------------------------------------------------
# Cleanup
END {
    if (defined $archive and ref $archive eq $class) {
        $archive->purge;
    }
    WebGUI::VersionTag->getWorking($session)->rollback;
    foreach my $user ($editor, $reporter, $reader) {
        $user->delete if defined $user;
    }
    foreach my $group ($staff) {
        $group->delete if defined $group;
    }
}
