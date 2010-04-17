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
use Test::More tests => 15; # increment this value for each test you create
use Test::MockObject::Extends;
use Test::Exception;
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
my $collab = $node->addChild({
        className      => 'WebGUI::Asset::Wobject::Collaboration',
        editTimeout    => '1',
        threadsPerPage => 3,
    },
    @addArgs);


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

note 'getThreadLinkUrl';
unlike $thread->getThreadLinkUrl, qr/\?pn=\d+/, 'threads do not need pagination url query fragments';
unlike $uncommittedThread->getThreadLinkUrl, qr/\?pn=\d+/, 'uncommitted threads, too';
like $uncommittedThread->getThreadLinkUrl, qr/\?revision=\d+/, 'uncommitted threads do have a revision query param';
$collab->update({threadsPerPage => 0, postsPerPage => 0,});
lives_ok { $uncommittedThread->getThreadLinkUrl } '... works when pagination set to 0';
$collab->update({threadsPerPage => 3, postsPerPage => 10,});

note 'getCSLinkUrl';
my @newThreads;
my $threadCount = 15;
while ($threadCount--) {
    push @newThreads, $collab->addChild($props, @addArgs);
}
my $versionTag2 = WebGUI::VersionTag->getWorking($session);
$versionTag2->commit;

my $csUrl = $collab->get('url');
like $newThreads[-1]->getCSLinkUrl, qr/^$csUrl/, 'getCsLinkUrl returns URL of the parent CS with no gateway';
like $newThreads[-1]->getCSLinkUrl, qr/\?pn=1/, '... and has the right page number';
like $newThreads[-1]->getCSLinkUrl, qr/\?pn=1;sortBy=lineage;sortOrder=desc/, 'and has the right sort parameters';
like $newThreads[-2]->getCSLinkUrl, qr/\?pn=1/, '... second to last has right page number';
like $newThreads[-3]->getCSLinkUrl, qr/\?pn=1/, '... and third to last';
like $newThreads[-4]->getCSLinkUrl, qr/\?pn=2/, '... and fourth to last';
$thread->restore();
like $thread->getCSLinkUrl, qr/\?pn=6/, 'checking 2nd thread on another page';

$newThreads[0]->archive;
$newThreads[1]->archive;
$newThreads[2]->archive;
like $thread->getCSLinkUrl, qr/\?pn=5/, 'checking thread on another page, with archived threads';

$collab->update({threadsPerPage => 0, postsPerPage => 0,});
lives_ok { $uncommittedThread->getCSLinkUrl } '... works when pagination set to 0';

# vim: syntax=perl filetype=perl
