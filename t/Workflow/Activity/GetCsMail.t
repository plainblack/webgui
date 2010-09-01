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

use strict;
use Test::More;
use WebGUI::Test; # Must use this before any other WebGUI modules
use WebGUI::Test::MockAsset;
use WebGUI::Session;
use WebGUI::Exception;
use Test::MockObject;
use Test::MockObject::Extends;

#----------------------------------------------------------------------------
# Init
my $session         = WebGUI::Test->session;


#----------------------------------------------------------------------------
# Tests

plan tests => 4;        # Increment this number for each test you create

my $sendmock = Test::MockObject->new( {} );
$sendmock->set_isa('WebGUI::Mail::Send');
$sendmock->set_true('addText', 'send');
local *WebGUI::Mail::Send::create;
$sendmock->fake_module('WebGUI::Mail::Send',
    create => sub { return $sendmock },
);

my $getmock = Test::MockObject->new( {} );
$getmock->set_isa('WebGUI::Mail::Get');
# false for now.  use set_series later to add list of messages.
$getmock->set_false('getNextMessage');
$getmock->set_true('disconnect');
local *WebGUI::Mail::Get::connect;
$getmock->fake_module('WebGUI::Mail::Get',
    connect => sub { return $getmock },
);

my $activity = Test::MockObject::Extends->new( 'WebGUI::Workflow::Activity::GetCsMail' );
$activity->set_always('session', $session);
$activity->set_always('getTTL', 60);
$activity->set_always('COMPLETE', 'complete');
my $parentAsset;
$activity->mock('addPost', sub { $parentAsset = $_[1] } );

my $cs_id    = 'MAILCS________________';
my $post_id  = 'MAILCSPOST____________';
my $cs2_id   = 'OTHERCS_______________';
my $post2_id = 'OTHERCSPOST___________';

my $csmock = Test::MockObject->new({
    getMail => 1,
    postGroupId => 7,
    allowReplies => 1,
});
$csmock->set_isa('WebGUI::Asset::Wobject::Collaboration');
$csmock->mock('get', sub {
    my $self = shift;
    if (@_) {
        return $self->{$_[0]};
    }
    return $self;
});
$csmock->set_always('getId', $cs_id);

my $postmock = Test::MockObject->new( {} );
$postmock->set_isa('WebGUI::Asset::Post::Thread', 'WebGUI::Asset::Post');
$postmock->set_always('getThread', $postmock);
$postmock->set_always('getParent', $csmock);
$postmock->set_always('getId', $post_id);

my $cs2mock = Test::MockObject->new({});
$cs2mock->set_isa('WebGUI::Asset::Wobject::Collaboration');
$cs2mock->set_always('getId', $cs2_id);

my $post2mock = Test::MockObject->new( {} );
$post2mock->set_isa('WebGUI::Asset::Post::Thread', 'WebGUI::Asset::Post');
$post2mock->set_always('getThread', $post2mock);
$post2mock->set_always('getParent', $cs2mock);
$post2mock->set_always('getId', $post2_id);

{
    $getmock->set_series('getNextMessage', {
        from => 'admin@localhost',
        parts => ['parts'],
        subject => 'Subject',
        messageId => 'Message Id',
    });
    $activity->execute($csmock);
    is $parentAsset->getId, $cs_id, 'add as new thread to current cs if not reply';
}

{
    # simulate asset not found
    WebGUI::Test::MockAsset->mock_id($post2_id, sub { WebGUI::Error::ObjectNotFound->throw });
    $getmock->set_series('getNextMessage', {
        from => 'admin@localhost',
        parts => ['parts'],
        subject => 'Subject',
        messageId => 'Message Id',
        inReplyTo => 'cs-' . $post2_id . '@',
    });
    $activity->execute($csmock);
    is $parentAsset->getId, $cs_id, 'add as new thread to current cs if reply to nonexistant post';
    WebGUI::Test::MockAsset->unmock_id($post2_id);
}

{
    WebGUI::Test::MockAsset->mock_id($post2_id, $post2mock);
    $getmock->set_series('getNextMessage', {
        from => 'admin@localhost',
        parts => ['parts'],
        subject => 'Subject',
        messageId => 'Message Id',
        inReplyTo => 'cs-' . $post2_id . '@',
    });
    $activity->execute($csmock);
    is $parentAsset->getId, $cs_id, 'add as new thread to current cs if reply to post in another CS';
    WebGUI::Test::MockAsset->unmock_id($post2_id);
}

{
    WebGUI::Test::MockAsset->mock_id($post_id, $postmock);
    $getmock->set_series('getNextMessage', {
        from => 'admin@localhost',
        parts => ['parts'],
        subject => 'Subject',
        messageId => 'Message Id',
        inReplyTo => 'cs-' . $post_id . '@',
    });
    $activity->execute($csmock);
    is $parentAsset->getId, $post_id, 'add as reply to post if reply to post in current CS';
    WebGUI::Test::MockAsset->unmock_id($post_id);
}

#vim:ft=perl
