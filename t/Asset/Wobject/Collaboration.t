#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2009 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

# XXX I (chrisn) started this file to test the features I added to the
# Collaboration / Post system for 7.5, but didn't have the time available to me
# to do a full test suite for the Collaboration Wobject. This means that this
# test suite is *largely incomplete* and should be finished. What is here *is*
# the following:
#
#
# 1. The basic framework for a test suite for the Collaboration Wobject.
# Includes setup, cleanup, boilerplate, etc. Basically the really boring,
# repetitive parts of the test that you don't want to write yourself.
# 2. The tests for the features I've implemented; namely, the groupToEditPost
# functionality.

use FindBin;
use strict;
use lib "$FindBin::Bin/../../lib";
use WebGUI::Test;
use WebGUI::Session;
use WebGUI::User;
use WebGUI::Group;
use WebGUI::Asset::Wobject::Collaboration;
use WebGUI::Asset::Post;
use WebGUI::Asset::Wobject::Layout;
use Data::Dumper;
use Test::More tests => 10; # increment this value for each test you create

my $session = WebGUI::Test->session;

# Do our work in the import node
my $node = WebGUI::Asset->getImportNode($session);

# grab a named version tag
my $versionTag = WebGUI::VersionTag->getWorking($session);
$versionTag->set({name => 'Collaboration => groupToEditPost test'});

# place the collab system under a layout to ensure we're using the inherited groupIdEdit value
my $layout  = $node->addChild({className => 'WebGUI::Asset::Wobject::Layout'});

# set the layout as the current asset for the same reason
$session->asset($layout);

# finally, add the collab
my $collab  = $layout->addChild({
    className => 'WebGUI::Asset::Wobject::Collaboration',
    url       => 'collab',
});

# Test for a sane object type
isa_ok($collab, 'WebGUI::Asset::Wobject::Collaboration');

# Verify that the groupToEdit field exists
ok(defined $collab->get('groupToEditPost'), 'groupToEditPost field is defined');

# Verify sane defaults
cmp_ok($collab->get('groupToEditPost'), 'eq', $collab->get('groupIdEdit'), 'groupToEditPost defaults to groupIdEdit correctly');
is($collab->get('itemsPerFeed'), 25, 'itemsPerFeed is set to the default');

# finally, add the post to the collaboration system
my $props = {
    className   => 'WebGUI::Asset::Post::Thread',
    content     => 'hello, world!',
};
my $post = $collab->addChild($props,
        undef,
        undef,
        {
            skipAutoCommitWorkflows => 1,
        });

# Test for a sane object type
isa_ok($post, 'WebGUI::Asset::Post::Thread');

$props = {
    className   => 'WebGUI::Asset::Post::Thread',
    content     => 'jello, world!',
};
$post = $collab->addChild($props,
        undef,
        undef,
        {
            skipAutoCommitWorkflows => 1,
        });

my $rssitems = $collab->getRssFeedItems();
is(scalar @{ $rssitems }, 2, 'rssitems set to number of posts added');

note "AssetAspect tests";
is($collab->getRssFeedUrl,  '/collab?func=viewRss',  'getRssFeedUrl');
is($collab->getRdfFeedUrl,  '/collab?func=viewRdf',  'getRdfFeedUrl');
is($collab->getAtomFeedUrl, '/collab?func=viewAtom', 'getAtomFeedUrl');

TODO: {
    local $TODO = "Tests to make later";
    ok(0, 'A whole lot more work to do here');
}

END {
    # Clean up after thyself
    $versionTag->rollback();
}
