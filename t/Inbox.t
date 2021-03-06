#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2012 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use strict;
use WebGUI::Test;
use WebGUI::Session;

use WebGUI::Inbox;
use WebGUI::User;

use Test::More tests => 20; # increment this value for each test you create

my $session = WebGUI::Test->session;

# get a user so we can test retrieving messages for a specific user
my $admin = WebGUI::User->new($session, 3);
WebGUI::Test->addToCleanup(sub { WebGUI::Test->cleanupAdminInbox($session); });

# Begin tests by getting an inbox object
my $inbox = WebGUI::Inbox->new($session); 
isa_ok($inbox, 'WebGUI::Inbox');
ok(defined ($inbox), 'new("new") -- object reference is defined');

########################
# create a new message #
########################
my $message_body = 'Test message';
my $new_message = {
    message => $message_body,
    groupId => 3,
    userId  => 1,
};

my $message = $inbox->addMessage($new_message,{ no_email => 1, });
WebGUI::Test->addToCleanup($message);
isa_ok($message, 'WebGUI::Inbox::Message');

ok(defined($message), 'addMessage returned a response');
ok($message->{_properties}{message} eq $message_body, 'Message body set');

my $messageId = $message->getId;
ok($messageId, 'messageId retrieved');

####################################
# get a message based on messageId #
####################################
my $messageCopy = $inbox->getMessage($messageId);
ok($messageCopy->getId == $messageId, 'getMessage returns message object');

#########################################################
# get a list (arrayref) of messages for a specific user #
#########################################################
my $messageList = $inbox->getMessagesForUser($admin);
my $message_cnt = scalar(@{$messageList});
is($message_cnt,  1, 'User only has 1 messages');
$message->setDeleted(3);
is(scalar(@{ $inbox->getMessagesForUser($admin) }),  0, 'User has no undeleted messages');
$message->delete(3);

#########################################################
#
# Check user filtering
#
#########################################################

my @senders = ();

push @senders, WebGUI::User->create($session);
push @senders, WebGUI::User->create($session);
push @senders, WebGUI::User->create($session);
WebGUI::Test->addToCleanup(@senders);
$senders[0]->username('first');
$senders[0]->profileField('firstName', 'First Only');
$senders[1]->username('last');
$senders[1]->profileField('lastName', 'Last Only');
$senders[2]->username('wholename');
$senders[2]->profileField('firstName', 'Tom');
$senders[2]->profileField('lastName', 'Jones');

$inbox->addMessage({
    message => "First message",
    userId  => 3,
    sentBy  => $senders[0]->userId,
    status  => 'unread',
},{
    no_email => 1,
});

$inbox->addMessage({
    message => "Second message",
    userId  => 3,
    sentBy  => $senders[1]->userId,
    status  => 'unread',
},{
    no_email => 1,
});

$inbox->addMessage({
    message => "Third message",
    userId  => 3,
    sentBy  => $senders[2]->userId,
    status  => 'unread',
},{
    no_email => 1,
});

$inbox->addMessage({
    message => "Fourth message",
    userId  => 3,
    sentBy  => $senders[2]->userId,
    status  => 'unread',
},{
    no_email => 1,
});

is(scalar @{ $inbox->getMessagesForUser($admin) }, 4, 'Added 3 messages by various users');
is(scalar @{ $inbox->getMessagesForUser($admin, '', '', '', 'sentBy='.$session->db->quote($senders[0]->userId)) }, 1, '1 message by sender[0]');
is(scalar @{ $inbox->getMessagesForUser($admin, '', '', '', 'sentBy='.$session->db->quote($senders[1]->userId)) }, 1, '1 message by sender[1]');
is(scalar @{ $inbox->getMessagesForUser($admin, '', '', '', 'sentBy='.$session->db->quote($senders[2]->userId)) }, 2, '2 messages by sender[2]');

is($inbox->getUnreadMessageCount($admin->userId), 4, 'getUnreadMessageCount');
my $messages = $inbox->getMessagesForUser($admin);
$messages->[0]->setRead($admin->userId);
is($inbox->getUnreadMessageCount($admin->userId), 3, '... really tracks unread messages');

is(scalar @{ $inbox->getMessagesForUser($admin) }, 4, 'Four messages in the inbox');
$inbox->deleteMessagesForUser($admin);
is(scalar @{ $inbox->getMessagesForUser($admin) }, 0, 'deleteMessagesForUser removed all messages');

my $dead_user = WebGUI::User->create($session);
WebGUI::Test->addToCleanup($dead_user);
$inbox->addMessage({
    message => "This method should be removed",
    userId  => 3,
    sentBy  => $dead_user->userId,
    status  => 'unread',
},{
    no_email => 1,
});

is(scalar @{ $inbox->getMessagesForUser($admin) }, 1, 'one message from dead_user in the inbox');
$dead_user->delete;
is(scalar @{ $inbox->getMessagesForUser($admin) }, 1, '... after deleting the user, still 1 message');
$inbox->deleteMessagesForUser($admin);
is(scalar @{ $inbox->getMessagesForUser($admin) }, 0, '... after deleteMessagesForUser, all messages gone again');

#vim:ft=perl
