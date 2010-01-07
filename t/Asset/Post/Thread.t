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
use lib "$FindBin::Bin/../../lib";
use WebGUI::Test;
use WebGUI::Session;
use Test::More tests => 5; # increment this value for each test you create
use Test::MockObject::Extends;
use WebGUI::Asset::Wobject::Collaboration;
use WebGUI::Asset::Post::Thread;

my $session = WebGUI::Test->session;

# Do our work in the import node
my $node = WebGUI::Asset->getImportNode($session);

# Grab a named version tag
my $versionTag = WebGUI::VersionTag->getWorking($session);
$versionTag->set({name=>"Collab setup"});
addToCleanup($versionTag);

# Need to create a Collaboration system in which the post lives.
my @addArgs = ( undef, undef, { skipAutoCommitWorkflows => 1, skipNotification => 1 } );
my $collab = $node->addChild({className => 'WebGUI::Asset::Wobject::Collaboration', editTimeout => '1'}, @addArgs);


# finally, add the post to the collaboration system
my $props = {
    className   => 'WebGUI::Asset::Post::Thread',
    content     => 'hello, world!',
    ownerUserId => 1,
};

my $thread = $collab->addChild($props, @addArgs);

$versionTag->commit();

my $uncommittedThread = $collab->addChild($props, @addArgs);

# Test for a sane object type
isa_ok($thread, 'WebGUI::Asset::Post::Thread');

my $env = $session->env;
$env    = Test::MockObject::Extends->new($env);

my %mockEnv = (
    REMOTE_ADDR          => '192.168.0.2',
);

$env->mock('get', sub { return $mockEnv{$_[1]}});

$session->user({userId => 3});
$thread->rate(1);
$thread->trash;
is($thread->get('threadRating'), 0, 'trash does not die, and updates the threadRating to 0');

unlike $thread->getDirectLinkUrl, qr/\?pn=\d+/, 'threads do not need pagination url query fragments';
unlike $uncommittedThread->getDirectLinkUrl, qr/\?pn=\d+/, 'uncommitted threads, too';
like $uncommittedThread->getDirectLinkUrl, qr/\?revision=\d+/, 'uncommitted threads do have a revision query param';

# vim: syntax=perl filetype=perl
