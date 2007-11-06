#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2006 Plain Black Corporation.
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
use Data::Dumper;
use Test::More tests => 3; # increment this value for each test you create

my $session = WebGUI::Test->session;

# Do our work in the import node
my $node = WebGUI::Asset->getImportNode($session);

# Grab a named version tag
#my $versionTag = WebGUI::VersionTag->getWorking($session);
#$versionTag->set({name => 'Collaboration Test'});

my $collab = $node->addChild({className => 'WebGUI::Asset::Wobject::Collaboration', editTimeout => '1'});
#$versionTag->commit();

# Test for a sane object type
isa_ok($collab, 'WebGUI::Asset::Wobject::Collaboration');

# Verify that the groupToEdit field exists
ok(defined $collab->get('groupToEditPost'), 'groupToEditPost field is defined');

# Verify sane defaults
cmp_ok($collab->get('groupToEditPost'), 'eq', $collab->get('groupIdEdit'), 'groupToEditPost defaults to groupIdEdit correctly');

TODO: {
    local $TODO = "Tests to make later";
    ok(0, 'A whole lot more work to do here');
}

END {
    # Clean up after thyself
    $collab->purge();
    #$versionTag->rollback();
}
# vim: syntax=perl filetype=perl
