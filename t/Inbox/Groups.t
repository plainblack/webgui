#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2009 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#------------------------------------------------------------------

# This script tests the creation, sending, and queuing of mail messages

use strict;
use warnings;

use FindBin;
use lib "$FindBin::Bin/../lib";

use WebGUI::Test;
use WebGUI::Session;

use WebGUI::Inbox;
use WebGUI::User;

use Test::More;

use Data::Dumper;

$| = 1;

#----------------------------------------------------------------------------

# Create two users; add both to a group; send mail from one to the group;
# make sure the other gets it; remove the second user from the group;
# make sure the second user still has the mail message.
# Send a message from Bill to Fred.
# Concerns bug #11594

my $session         = WebGUI::Test->session;

my $userFred = WebGUI::User->create($session);
WebGUI::Test->usersToDelete($userFred);
$userFred->username('fred');
$userFred->profileField('receiveInboxEmailNotifications', 0);

my $userBill = WebGUI::User->create($session);
WebGUI::Test->usersToDelete($userBill);
$userBill->username('bill');
$userBill->profileField('receiveInboxEmailNotifications', 0);

my $group = WebGUI::Group->new($session, 'new');
WebGUI::Test->groupsToDelete($group);
$group->addUsers([$userFred->userId, $userBill->userId]);

my $inbox = WebGUI::Inbox->new($session);
isa_ok($inbox, 'WebGUI::Inbox');

is($inbox->getUnreadMessageCount($userFred->userId), 0, '0 messages according to getUnreadMessageCount');

my $message = $inbox->addMessage({
    message => 'The quick brown dog jumped over the lazy fox',
    groupId => $group->getId,    # to group
    sentBy  => $userBill->userId,
}, {
    no_email => 1, 
});

ok(defined($message), 'Message sent to user in group');
WebGUI::Test->addToCleanup($message);
isa_ok($message, 'WebGUI::Inbox::Message');

my $messageId = $message->getId;
ok($messageId, 'messageId retrieved');

my $messageList;
my $message_cnt;

$messageList = $inbox->getMessagesForUser($userFred);
$message_cnt = scalar(@{$messageList});
is($message_cnt,  1, '... 1 messages according to getMessagesForUser');

is($inbox->getUnreadMessageCount($userFred->userId), 1, '... 1 messages according to getUnreadMessageCount');

$group->deleteUsers([ $userFred->userId ]);

ok((! grep $_ eq $userFred->userId, @{ $group->getAllUsers() } ), 'User removed from group');
ok((! grep $_ eq $group->getId, @{ $userFred->getGroupIdsRecursive } ), 'User removed from group');

warn "group->getAllUsers: " .  Dumper $group->getAllUsers();
warn "getGroupIdsRecursive: " . Dumper $userFred->getGroupIdsRecursive;
warn "user->getGroups: " . Dumper $userFred->getGroups;

eval{    $userFred->session->stow->delete("gotGroupsForUser"); }; # blow the cache

$messageList = $inbox->getMessagesForUser($userFred);
$message_cnt = scalar(@{$messageList});
is($message_cnt,  1, '... still 1 messages according to getMessagesForUser');

# warn $messageList->[0]->getStatus; # 'Pending'

is(eval { $messageList->[0]->getId } || '', $messageId, '... getMessagesForUser able to get message with messageId matching the message sent');
is($inbox->getUnreadMessageCount($userFred->userId), 1, '... still 1 messages according to getUnreadMessageCount');

$message->delete($userFred->userId);

is(scalar(@{ $inbox->getMessagesForUser($userFred) }),  0, 'Message deleted:  User has no undeleted messages');

#----------------------------------------------------------------------------

done_testing();

