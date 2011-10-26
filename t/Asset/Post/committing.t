#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2009 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

## Test that committing a post works, and doesn't affect the parent thread.

use strict;
use Test::More;
use WebGUI::Test;
use WebGUI::Session;
use WebGUI::Asset::Wobject::Collaboration;
use WebGUI::Asset::Post;
use WebGUI::Asset::Post::Thread;

my $session = WebGUI::Test->session;

# Do our work in the import node
my $node = WebGUI::Asset->getImportNode($session);

# Grab a named version tag
my $versionTag = WebGUI::VersionTag->getWorking($session);
$versionTag->set({name=>"Collab setup"});
my $addArgs = { skipAutoCommitWorkflows => 1, skipNotification => 1 };

my $collab = $node->addChild(
    {
        className => 'WebGUI::Asset::Wobject::Collaboration',
        title     => 'Test Collaboration',
    },
);

# finally, add posts and threads to the collaboration system

my $first_thread = $collab->addChild(
    {
        className   => 'WebGUI::Asset::Post::Thread',
        title       => 'Test Thread',
    },
    undef, undef, $addArgs,
);
$first_thread->setSkipNotification;

##Thread 1, Post 1 => t1p1
my $t1p1 = $first_thread->addChild(
    {
        className   => 'WebGUI::Asset::Post',
        title       => 'Test Post',
    },
    undef, undef, $addArgs,
);
$t1p1->setSkipNotification;

$versionTag->commit();
WebGUI::Test->addToCleanup($versionTag);

foreach my $asset ($collab, $t1p1, $first_thread, ) {
    $asset = $asset->cloneFromDb;
}

is $collab->getChildCount, 1, 'collab has correct number of children';
is $first_thread->status, 'approved', 'thread is approved';
is $t1p1->status, 'approved', 'post is approved';

done_testing;

#vim:ft=perl
