#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2007 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use FindBin;
use strict;
use lib "$FindBin::Bin/lib";

use WebGUI::Test;
use WebGUI::Session;
use WebGUI::Utility;
use WebGUI::Cache;

use WebGUI::User;
use WebGUI::ProfileField;

use Test::More tests => 121; # increment this value for each test you create
use Test::Deep;

my $session = WebGUI::Test->session;

my $testCache = WebGUI::Cache->new($session, 'myTestKey');
$testCache->flush;

my $numberOfUsers = $session->db->quickScalar('select count(*) from users');

my $user;
my $lastUpdate;

#Let's try to create a new user and make sure we get an object back
my $userCreationTime = time();
ok(defined ($user = WebGUI::User->new($session,"new")), 'new("new") -- object reference is defined');

#New does not return undef if something breaks, so we'll see if the _profile hash was set.
ok(scalar %{$user->{_profile}} > 0, 'new("new") -- profile property contains at least one key');  

#Let's assign a username
$user->username("bill_lumberg");
$lastUpdate = time();
is($user->username, "bill_lumberg", 'username() method');
cmp_ok(abs($user->lastUpdated-$lastUpdate), '<=', 1, 'lastUpdated() -- username change');

#Let's check the UID and make sure it's sane
ok($user->userId =~ m/[A-Za-z0-9\-\_]{22}/, 'userId() returns sane value');

#Let's make sure the user was added to the correct groups;
foreach my $groupId (2,7) {
	ok($user->isInGroup($groupId), "User added to group $groupId by default");
}

#Let's check the status method
$user->status('Active');
$lastUpdate = time();
is($user->status, "Active", 'status("Active")');
cmp_ok(abs($user->lastUpdated-$lastUpdate), '<=', 1, 'lastUpdated() -- status change');

$user->status('Selfdestructed');
is($user->status, "Selfdestructed", 'status("Selfdestructed")');

$user->status('Deactivated');
is($user->status, "Deactivated", 'status("Deactivated")');

################################################################
#
# profileField
#
################################################################

#Let's get/set a profile field
$user->profileField("firstName", "Bill");
$lastUpdate = time();
is($user->profileField("firstName"), "Bill", 'profileField() get/set');
cmp_ok(abs($user->lastUpdated-$lastUpdate), '<=', 1, 'lastUpdated() -- profileField');

#Fetching a non-existant profile field returns undef
is($user->profileField('notAProfileField'), undef, 'getting non-existant profile fields returns undef');

##Check for valid profileField access, even if it is not cached in the user object.
my $newProfileField = WebGUI::ProfileField->create($session, 'testField', {dataDefault => 'this is a test'});
is($user->profileField('testField'), undef, 'getting profile fields not cached in the user object returns undef');

################################################################
#
# authMethods
#
################################################################

#Let's check the auth methods

#Default should be WebGUI
is($user->authMethod, "WebGUI", 'authMethod() -- default value is WebGUI');

#Try changing to LDAP
$lastUpdate = time();
$user->authMethod("LDAP");
is($user->authMethod, "LDAP", 'authMethod() -- set to LDAP');
$user->authMethod("WebGUI");
is($user->authMethod, "WebGUI", 'authMethod() -- set back to WebGUI');
cmp_ok(abs($user->lastUpdated-$lastUpdate), '<=', 1, 'lastUpdated() -- authmethod change');

#See if date created is correct
is($user->dateCreated, $userCreationTime, 'dateCreated()');

################################################################
#
# get/set karma
#
################################################################

my $oldKarma = $user->karma;
$user->karma('69');
$user->karma('69', 'wonder man');
is($user->karma, $oldKarma, 'karma() -- requires amount, source and description');
$user->karma('69', 'peter gibbons', 'test karma');
is($user->karma, $oldKarma+69, 'karma() -- get/set add amount');

my ($source, $description) = $session->db->quickArray("select source, description from karmaLog where userId=?",[$user->userId]);

is($source, 'peter gibbons', 'karma() -- get/set source');
is($description, 'test karma', 'karma() -- get/set description');

$oldKarma = $user->karma;
$user->karma('-69', 'peter gibbons', 'lumberg took test karma away');
is($user->karma, $oldKarma-69, 'karma() -- get/set subtract amount');

#Let's test referringAffiliate
$lastUpdate = time();
$user->referringAffiliate(10);
is($user->referringAffiliate, '10', 'referringAffiliate() -- get/set');
cmp_ok(abs($user->lastUpdated-$lastUpdate), '<=', 1, 'lastUpdated() -- referringAffiliate');

#Let's try adding this user to some groups.  Note, users are auto-added to 2 and 7 on creation
my @groups = qw|6 4|;
$user->addToGroups(\@groups);

my $result;
($result) = $session->db->quickArray("select count(*) from groupings where groupId=? and userId=?", [6, $user->userId]);
ok($result, 'addToGroups() -- added to first test group');

($result) = $session->db->quickArray("select count(*) from groupings where groupId=? and userId=?", [4, $user->userId]);
ok($result, 'addToGroups() -- added to second test group');

#Let's delete this user from our test groups
$user->deleteFromGroups(\@groups);

($result) = $session->db->quickArray("select count(*) from groupings where groupId=? and userId=?", [6, $user->userId]);
is($result, '0', 'deleteFromGroups() -- removed from first test group');

($result) = $session->db->quickArray("select count(*) from groupings where groupId=? and userId=?", [4, $user->userId]);
is($result, '0', 'deleteFromGroups() -- removed from second test group');

#Let's delete this user
my $userId = $user->userId;
$user->delete;

my ($count) = $session->db->quickArray("select count(*) from users where userId=?",[$userId]);
is($count, '0', 'delete() -- users table');

($count) = $session->db->quickArray("select count(*) from userProfileData where userId=?",[$userId]);
is($count, '0', 'delete() -- userProfileData table');

($count) = $session->db->quickArray("select count(*) from inbox where userId=?",[$userId]);
is($count, '0', 'delete() -- inbox table'); 

#Let's test new with an override uid
$user = WebGUI::User->new($session, "new", "ROYSUNIQUEUSERID000001");
is($user->userId, "ROYSUNIQUEUSERID000001", 'new() -- override user id');
$user->delete;

#Let's test new to retrieve an existing user
$user = WebGUI::User->new($session,3);
is($user->username, "Admin", 'new() -- retrieve existing user');
$user = "";

#Let's test new to retrieve default user visitor with no params passed in
$user = WebGUI::User->new($session);
is($user->userId, '1', 'new() -- returns visitor with no args');
$user = "";

#Let's test new to retrieve a non-existing user
$user = WebGUI::User->new($session, 'xxYYxxYYxxYYxxYYxxYYxx');
isa_ok($user, 'WebGUI::User', 'non-existant ID returns valid user object');
$user = "";

$user = WebGUI::User->new($session, "new", "ROYSUNIQUEUSERID000002");
is($user->userId, "ROYSUNIQUEUSERID000002", 'new() -- override user id');
$user->authMethod("LDAP");
is($user->authMethod, "LDAP", 'authMethod() -- set to LDAP');

ok(WebGUI::User->validUserId($session, 1), 'Visitor has a valid userId');
ok(WebGUI::User->validUserId($session, 3), 'Admin has a valid userId');
ok(!WebGUI::User->validUserId($session, 'eeee'), 'random illegal Id #1');
ok(!WebGUI::User->validUserId($session, 37), 'random illegal Id #2');

$user->delete;

#identifier() and uncache()
SKIP: {
  skip("identifier() -- deprecated",1);
  ok(undef, "identifier()");
}

SKIP: {
  skip("uncache() -- Don't know how to test uncache()",1);
  ok(undef, "uncache");
}

my $cm = WebGUI::Group->new($session, 4);
is( $cm->name, "Content Managers", "content manager name check");
is( $cm->getId, 4, "content manager groupId check");

my $admin = WebGUI::User->new($session, 3);
is($admin->profileField('uiLevel'), 9, 'Admin default uiLevel = 9');
my $visitor = WebGUI::User->new($session, 1);
is($visitor->profileField('uiLevel'), 5, 'Visitor gets the default uiLevel of 5');

$session->db->write('update userSession set lastIP=? where sessionId=?',['192.168.0.101', $session->getId]);

my ($result) = $session->db->quickArray('select lastIP,sessionId from userSession where sessionId=?',[$session->getId]);
is ($result, '192.168.0.101', "userSession setup correctly");

ok (!$visitor->isInGroup($cm->getId), "Visitor is not member of group");
ok ($admin->isInGroup($cm->getId), "Admin is member of group");

my $origFilter = $cm->ipFilter;

$cm->ipFilter('192.168.0.0/24');

is( $cm->ipFilter, "192.168.0.0/24", "ipFilter assignment to local net, 192.168.0.0/24");

ok ($visitor->isInGroup($cm->getId), "Visitor is allowed in via IP");

$session->db->write('update userSession set lastIP=? where sessionId=?',['193.168.0.101', $session->getId]);

$cm->clearCaches;

ok (!$visitor->isInGroup($cm->getId), "Visitor is not allowed in via IP");

##Restore original filter
$cm->ipFilter(defined $origFilter ? $origFilter : '');

##Test for group membership
$user = WebGUI::User->new($session, "new");
ok($user->isInGroup(7), "addToGroups: New user is in group 7(Everyone)");
ok(!$user->isInGroup(1),  "New user not in group 1 (Visitors)");

$user->addToGroups([3]);

ok($user->isInGroup(3), "addToGroups: New user is in group 3(Admin)");
ok($user->isInGroup(11), "New user is in group 11(Secondary Admins)");
ok($user->isInGroup(12), "New user is in group 12(Turn On Admin)");
ok($user->isInGroup(13), "New user is in group 13(Export Managers)");
ok($user->isInGroup(14), "New user is in group 14(Product Managers)");

$user->deleteFromGroups([3]);
ok(!$user->isInGroup(3), "deleteFromGroups: New user is not in group 3(Admin)");
ok(!$user->isInGroup(11), "New user not in group 11 (Secondary Admins)");
ok(!$user->isInGroup(12), "New user not in group 12 (Turn On Admin)");
ok(!$user->isInGroup(13), "New user not in group 13 (Export Managers)");
ok(!$user->isInGroup(14), "New user not in group 14 (Product Managers)");

ok(!$user->isInGroup(), "isInGroup, default group is 3");

$user->delete;

ok($visitor->isInGroup(1),  "Visitor is a member of group Visitor");
ok($visitor->isInGroup(7),  "Visitor is a member of group Everyone");
ok(!$visitor->isInGroup(2), "Visitor is a not member of group 2 (Registered Users)");

##remove Visitor from those groups, and make sure we can add him back in.
WebGUI::Group->new($session, '1')->deleteUsers([1]);
($result) = $session->db->quickArray("select count(*) from groupings where groupId=? and userId=?", [1, $user->userId]);
is($result, 0, 'deleteFromGroups() -- Visitor removed from Visitor group');
WebGUI::Group->new($session, '7')->deleteUsers([1]);
($result) = $session->db->quickArray("select count(*) from groupings where groupId=? and userId=?", [7, $user->userId]);
is($result, 0, 'deleteFromGroups() -- Visitor removed from Everyone group');

ok($visitor->isInGroup(1), "isInGroup: Visitor is in group Visitor, hardcoded");
ok($visitor->isInGroup(7), "isInGroup: Everyone is in group Everyone, hardcoded");

##Test for group membership in a non-existant group
ok(! $visitor->isInGroup('nonExistantGroup'), 'isInGroup: Checking for membership in a non-existant group');

##Add Visitor back to those groups
WebGUI::Group->new($session, '1')->addUsers([1]);
WebGUI::Group->new($session, '7')->addUsers([1]);

ok($visitor->isInGroup(1), "Visitor added back to group Visitor");
ok($visitor->isInGroup(7), "Visitor added back to group Everyone");

################################################################
#
# canUseAdminMode
#
################################################################

my $dude = WebGUI::User->new($session, "new");

ok(!$dude->canUseAdminMode, 'canUseAdminMode: newly created users cannot');

$dude->addToGroups([12]);

ok($dude->isInGroup(12), 'user successfully added to group 12');

ok($dude->canUseAdminMode, 'canUseAdminMode: with no subnets set, user canUseAdminMode');

$dude->deleteFromGroups([12]);

##Spoof the IP address to test subnet level access control to adminMode
my $origEnvHash = $session->env->{_env};
my %newEnv = ( REMOTE_ADDR => '192.168.0.2' );
$session->env->{_env} = \%newEnv;
$session->config->set('adminModeSubnets', ['192.168.0.0/24']);

ok(!$dude->isInGroup(12), 'user is not in group 12');
ok(!$dude->canUseAdminMode, 'canUseAdminMode: just being in the subnet does not allow adminMode access');

$dude->addToGroups([12]);

ok($dude->canUseAdminMode, 'canUseAdminMode: with no subnets set, user canUseAdminMode');

$newEnv{REMOTE_ADDR} = '10.0.0.2';

ok(!$dude->canUseAdminMode, 'canUseAdminMode: even with the right group permission, user must be in subnet if subnet is set');

##restore the original session variables
$session->env->{_env} = $origEnvHash;
$session->config->delete('adminModeSubnets');

################################################################
#
# newByEmail
#
################################################################

my $originalVisitorEmail = $visitor->profileField('email');
$visitor->profileField('email', 'visitor@localdomain');
$dude->profileField('email', 'dude@aftery2k.com');

my $clone = WebGUI::User->newByEmail($session, 'visitor@localdomain');
is($clone, undef, 'newByEmail returns undef if you look up the Visitor');

$clone = WebGUI::User->newByEmail($session, 'noone@localdomain');
is($clone, undef, 'newByEmail returns undef if email address cannot be found');

$dude->username('');

$clone = WebGUI::User->newByEmail($session, 'dude@aftery2k.com');
is($clone, undef, 'newByEmail returns undef if the user does not have a username');

$dude->username('dude');

$clone = WebGUI::User->newByEmail($session, 'dude@aftery2k.com');
isa_ok($clone, 'WebGUI::User', 'newByEmail returns a valid user object');
is($clone->username, 'dude', '... and it has the right username');

################################################################
#
# newByUsername
#
################################################################

my $useru = WebGUI::User->newByUsername($session, 'Visitor');
is($useru, undef, 'newByUsername returns undef if you look up the Visitor');

$useru = WebGUI::User->newByUsername($session, 'NotHomeRightNow');
is($useru, undef, 'newByUsername returns undef if username cannot be found');

$dude->username('');

$useru = WebGUI::User->newByUsername($session, '');
is($useru, undef, 'newByUsername returns undef if the user does not have a username');

$dude->username('dude');

$useru = WebGUI::User->newByUsername($session, 'dude');
isa_ok($useru, 'WebGUI::User', 'newByUsername returns a valid user object');
is($useru->userId, $dude->userId, '... and it is the right user object');


################################################################
#
# new, cached user profile data and overrides
#
################################################################

my $buster = WebGUI::User->new($session, "new");
is( $buster->profileField('timeZone'), 'America/Chicago', 'buster received original user profile on user creation');

my $profileField = WebGUI::ProfileField->new($session, 'timeZone');
my %originalFieldData = %{ $profileField->get() };
my %copiedFieldData = %originalFieldData;
$copiedFieldData{'dataDefault'} = "'America/Hillsboro'";
$profileField->set(\%copiedFieldData);

is($profileField->get('dataDefault'), "'America/Hillsboro'", 'default timeZone set to America/Hillsboro');

my $busterCopy = WebGUI::User->new($session, $buster->userId);
is( $busterCopy->profileField('timeZone'), 'America/Hillsboro', 'busterCopy received updated user profile because there is no username set in his cached user object');

$profileField->set(\%originalFieldData);

$buster->username('mythBuster');

my $aliasProfile = WebGUI::ProfileField->new($session, 'alias');
my %originalAliasProfile = %{ $aliasProfile->get() };
my %copiedAliasProfile = %originalAliasProfile;
$copiedAliasProfile{'dataDefault'} = "'aliasAlias'"; ##Non word characters;
$aliasProfile->set(\%copiedAliasProfile);

my $buster3 = WebGUI::User->new($session, $buster->userId);
is($buster3->profileField('alias'), 'aliasAlias', 'default alias set');

$copiedAliasProfile{'dataDefault'} = "'....^^^^....'"; ##Non word characters;
$aliasProfile->set(\%copiedAliasProfile);
$buster->uncache();

$buster3 = WebGUI::User->new($session, $buster->userId);
is($buster3->profileField('alias'), 'mythBuster', 'alias set to username since the default alias has only non-word characters');

$aliasProfile->set(\%originalAliasProfile);

my %listProfile = %copiedAliasProfile;
$listProfile{'fieldName'} = 'listProfile';
$listProfile{'dataDefault'} = "['alpha', 'delta', 'tango']";
my $listProfileField = WebGUI::ProfileField->create($session, 'listProfile', \%listProfile);

$buster->uncache;
$buster3 = WebGUI::User->new($session, $buster->userId);
is($buster3->profileField('listProfile'), 'alpha', 'profile field with default data value that is a list gives the user the first value');

################################################################
#
# getGroups
#
################################################################

##Set up a group that has expired.

my $expiredGroup = WebGUI::Group->new($session, 'new');
$expiredGroup->name('Group that expires users automatically');
$expiredGroup->expireOffset(-1000);

$dude->addToGroups([$expiredGroup->getId]);

my $dudeGroups = $dude->getGroups();
cmp_bag($dudeGroups, ['12', '2', '7', $expiredGroup->getId], 'Dude belongs to Registered Users, Everyone and T.O.A');

##Group lookups are cached, so we'll clear the cache by removing Dude from T.O.A.
$dude->deleteFromGroups([12]);
$dudeGroups = $dude->getGroups(1);
cmp_bag($dudeGroups, ['2', '7'], 'Dude belongs to Registered Users, Everyone as unexpired group memberships');

################################################################
#
# acceptsPrivateMessages
#
################################################################

my $friend = WebGUI::User->new($session, 'new');
$friend->profileField('allowPrivateMessages', 'all');
is ($friend->acceptsPrivateMessages(1), 1, 'when allowPrivateMessages=all, anyone can send messages');
$friend->profileField('allowPrivateMessages', 'none');
is ($friend->acceptsPrivateMessages($friend->userId), 0, 'when allowPrivateMessages=all, no one can send messages');

TODO: {
	local $TODO = "Tests that need to be written";
    ok(0, 'Test allowPrivateMessages=friends, with various userIds');
}

################################################################
#
# getFirstName
#
################################################################

is($friend->getFirstName, undef, 'with no profile settings, getFirstName returns undef');

$friend->username('friend');
is($friend->getFirstName, 'friend', 'username is the lower priority profile setting for getFirstName');
$friend->profileField('alias', 'Friend');
is($friend->getFirstName, 'Friend', 'alias is the middle priority profile setting for getFirstName');
$friend->profileField('firstName', 'Mr');
is($friend->getFirstName, 'Mr', 'firstName is the highest priority profile setting for getFirstName');

################################################################
#
# getWholeName
#
################################################################

my $neighbor = WebGUI::User->new($session, 'new');

is($neighbor->getWholeName, undef, 'with no profile settings, getWholeName returns undef');
$neighbor->username('neighbor');
is($neighbor->getWholeName, 'neighbor', 'username is the lower priority profile setting for getWholeName');
$neighbor->profileField('alias', 'neighbor-man');
is($neighbor->getWholeName, 'neighbor-man', 'alias is the middle priority profile setting for getWholeName');

$neighbor->profileField('firstName', 'Mr');
is($neighbor->getWholeName, 'neighbor-man', 'must have firstName and lastName to override alias');
$neighbor->profileField('lastName', 'Rogers');
is($neighbor->getWholeName, 'Mr Rogers', 'If firstName and lastName are true, wholeName is the concatenation of the both');

################################################################
#
# isOnline
#
################################################################

is ($neighbor->isOnline, 0, 'neighbor is not onLine (no userSession entry)');
$session->user({user => $neighbor});
is ($neighbor->isOnline, 1, 'neighbor is onLine');
$session->db->write('update userSession set lastPageView=?',[time-599]);
is ($neighbor->isOnline, 1, 'neighbor is onLine (lastPageViews=599)');
$session->db->write('update userSession set lastPageView=?',[time-601]);
is ($neighbor->isOnline, 0, 'neighbor is not onLine (lastPageViews=601)');
$session->user({userId => 1});

END {
    foreach my $account ($user, $dude, $buster, $buster3, $neighbor, $friend) {
        (defined $account  and ref $account  eq 'WebGUI::User') and $account->delete;
    }

    (defined $expiredGroup  and ref $expiredGroup  eq 'WebGUI::Group') and $expiredGroup->delete;

    ##Note, do not delete the visitor account.  That would be really bad
    $session->config->delete('adminModeSubnets');

    $profileField->set(\%originalFieldData);
    $aliasProfile->set(\%originalAliasProfile);
    $listProfileField->delete;
    $visitor->profileField('email', $originalVisitorEmail);

    $newProfileField->delete();

	$testCache->flush;
    my $newNumberOfUsers = $session->db->quickScalar('select count(*) from users');
    is ($newNumberOfUsers, $numberOfUsers, 'no new additional users were leaked by this test');

}

