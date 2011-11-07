#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2009 Plain Black Corporation.
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

use WebGUI::User;
use WebGUI::Group;

use Test::More;
use Test::Deep;

my @scratchTests = (
			{
				scratch => 'foo=bar',
				comment => 'wrong name and value',
				expect  => 0,
			},
			{
				scratch => 'name=Dan',
				comment => 'wrong value',
				expect  => 0,
			},
			{
				scratch => 'airport=Tom',
				comment => 'wrong name',
				expect  => 0,
			},
			{
				scratch => 'name=Tom',
				comment => 'right name and value',
				expect  => 1,
			},
			{
				scratch => 'airport=PDX',
				comment => 'right name and value',
				expect  => 1,
			},
);

my @ipTests = (
			{
				ip => '194.168.0.2',
				comment => 'good IP address',
				expect  => 1,
			},
			{
				ip => '10.0.0.2',
				comment => 'bad IP address',
				expect  => 0,
			},
			{
				ip => '194.168.0.128',
				comment => 'another good IP address',
				expect  => 1,
			},
			{
				ip => '172.17.10.20',
				comment => 'another bad IP address',
				expect  => 0,
			},
);


my $session = WebGUI::Test->session;
$session->cache->remove('myTestKey');
WebGUI::Test->addToCleanup(sub { $session->cache->remove('myTestKey'); });

foreach my $gid ('new', '') {
	my $g = WebGUI::Group->new($session, $gid);

	##Check defaults
	is (ref $g, "WebGUI::Group", "Group object creation");
	isnt ($g->getId, "new", "Group assigned new groupId, not new");
	is ($g->name(), 'New Group', 'Default name');
	is ($g->expireOffset(), 314496000, 'Default expireOffset');
	is ($g->karmaThreshold(), 1_000_000_000, 'Default karma threshold');
	is ($g->expireNotifyOffset(), -14, 'Default expire notify offset time');
	is ($g->deleteOffset(), 14, 'Default delete offset time');
	is ($g->expireNotify(), 0, 'Default expire notify time');
	is ($g->databaseLinkId(), 0, 'Default databaseLinkId');
	is ($g->groupCacheTimeout(), 3600, 'Default external database cache timeout');
	is ($g->dateCreated(), $g->lastUpdated(), 'lastUpdated = create time');
	is ($g->autoAdd(), 0, 'auto Add is off by default');
	is ($g->autoDelete(), 0, 'auto Delete is off by default');
	is ($g->isEditable(), 1, 'isEditable is on by default');
	is ($g->showInForms(), 1, 'show in forms is on by default');
	is ($g->isAdHocMailGroup(), 0, 'is adHoc group is off by default');

	$g->delete;
}

is(WebGUI::Group->new($session, 'neverAGroupId'), undef, 'calling new with a non-existant groupId returns undef');

my $g = WebGUI::Group->new($session, "new");

$g->description('I am really a montage');
is($g->description(), 'I am really a montage', 'description set and get correctly');

$g->expireNotifyMessage('Outta the tub');
is($g->expireNotifyMessage(), 'Outta the tub', 'expire notify message set and get correctly');

$g->expireNotifyOffset(-7);
is($g->expireNotifyOffset(), -7, 'expireNotifyOffset set and get correctly');

$g->expireOffset(3600);
is($g->expireOffset(), 3600, 'expireOffset set and get correctly');

$g->autoAdd(2);
is($g->autoAdd(), 2, 'autoAdd set and get correctly');

$g->autoDelete(1);
is($g->autoDelete(), 1, 'autoDelete set and get correctly');

$g->deleteOffset(-28);
is($g->deleteOffset(), -28, 'deleteOffset set and get correctly');

$g->expireNotify(7);
is($g->expireNotify(), 7, 'expireNotify set and get correctly');

$g->isEditable(0);
is($g->isEditable(), 0, 'isEditable set and get correctly');

$g->showInForms(0);
is($g->showInForms(), 0, 'showInForms set and get correctly');

$g->dbQuery('select userId from someOtherDatabase');
is($g->dbQuery(), 'select userId from someOtherDatabase', 'dbQuery set and get correctly');

$g->isAdHocMailGroup(1); 
is($g->isAdHocMailGroup(),  1, 'isAdHocMailGroup set and get correctly');

$g->databaseLinkId('newDbLinkId'); 
is($g->databaseLinkId(),  'newDbLinkId', 'databaseLinkId set and get correctly');
$g->databaseLinkId(0); 
is($g->databaseLinkId(),  0,             'databaseLinkId set and get correctly (0)');

################################################################
#
# options for new
#
################################################################

my $optionGroup = WebGUI::Group->new($session, 'new', undef, 'noAdmin');
my $getGroupsIn = $optionGroup->getGroupsIn();
cmp_deeply($getGroupsIn, [], 'new: noAdmin prevents the admin group from being added to this group');
$optionGroup->delete;

my $gid = $g->getId;
is (length($gid), 22, "GroupId is proper length");

{
    # our invalid db query from earlier is going to error, keep it quiet
    local $SIG{__WARN__} = sub {};
    is_deeply ($g->getGroupsIn(), [3], 'Admin group added by default to this group');
    is_deeply ($g->getGroupsFor(), [], 'Group not added to any other group');
    is_deeply ($g->getUsers(), [], 'No users added by default');
    is_deeply ($g->getAllUsers(), [3], 'No users added by default in any method');
}

my $gname = '**TestGroup**';
is ($g->name($gname), $gname, 'Set name');
is ($g->name(), $gname, 'Get name via accessor');
is ($g->get('groupName'), $gname, 'Get name via generic accessor');

my $g2 = WebGUI::Group->find($session, $gname);
my $skipFindGroup = is(ref $g2, 'WebGUI::Group', 'find returns a group');

SKIP: {
	skip('find did not return a WebGUI::Group object', !$skipFindGroup);
	is( $g->getId, $g2->getId, 'find returns correct group');
}
undef $g2;

$g2 = WebGUI::Group->find($session, 'Non existant group name');
is(ref $g2, 'WebGUI::Group', 'find with non-existant group name returns a group');
is($g2->getId, undef, 'find with non-existant group name returns a group with undefined ID');


delete $g->{_group};
ok( !exists $g->{_group}, 'deleted group property hash');
is( $g->name, $gname, 'group name restored after ->get through ->name');
ok( exists $g->{_group}, 'group property hash restored');

$g->delete();

my $matchingGroups = $session->db->quickArray("select groupId from groups where groupId=?",[$gid]);

is ( $matchingGroups, 0, 'group was removed');

my $gA = WebGUI::Group->new($session, "new");
my $gB = WebGUI::Group->new($session, "new");
$gA->name('Group A');
$gB->name('Group B');
ok( ($gA->name eq 'Group A' and $gB->name eq 'Group B'), 'object name assignment, multiple objects');
WebGUI::Test->addToCleanup($gA, $gB);

$gB->addGroups([$gA->getId]);

cmp_bag($gB->getGroupsIn(1), [$gA->getId, 3], 'Group A is in Group B, recursively');
cmp_bag($gB->getGroupsIn(),  [$gA->getId, 3], 'Group A is in Group B');
cmp_bag($gA->getGroupsFor(), [$gB->getId], 'Group B contains Group A');
cmp_bag($gA->getGroupsIn(),  [3], 'Admin added to group A automatically');

$gA->addGroups([$gB->getId]);
cmp_bag($gA->getGroupsIn(), [3], 'Not allowed to create recursive group loops');

$gA->addGroups([1]);
cmp_bag($gA->getGroupsIn(), [3], 'Not allowed to add group Visitor to a group');

$gA->addGroups([$gA->getId]);
cmp_bag($gA->getGroupsIn(), [3], 'Not allowed to add myself to my group');

my $gC = WebGUI::Group->new($session, "new");
$gC->name('Group C');
$gA->addGroups([$gC->getId]);
WebGUI::Test->addToCleanup($gC);

cmp_bag($gC->getGroupsFor(), [$gA->getId], 'Group A contains Group C');
cmp_bag($gA->getGroupsIn(),  [$gC->getId, 3], 'Group C is a member of Group A, cached');
cmp_bag($gB->getGroupsIn(1), [$gC->getId, $gA->getId, 3], 'Group C is in Group B, recursively');
cmp_bag($gB->getGroupsIn(),  [$gA->getId, 3], 'Group A is in Group B');

$gC->addGroups([$gB->getId]);
cmp_bag($gC->getGroupsIn(), [3], 'Adding Group B to Group C fails, recursively');

$gA->deleteGroups([$gC->getId]);
cmp_bag($gA->getGroupsIn(),  [3], 'Group C is not a member of Group A');
cmp_bag($gB->getGroupsIn(1), [$gA->getId, 3], 'Group C is not in Group B, recursively');
cmp_bag($gC->getGroupsFor(), [], 'No groups contain Group C');

#   B       Z
#  / \     / \
# A   C	  Y   X

$gB->addGroups([$gC->getId]);

my $gX = WebGUI::Group->new($session, "new");
my $gY = WebGUI::Group->new($session, "new");
my $gZ = WebGUI::Group->new($session, "new");
$gX->name('Group X');
$gY->name('Group Y');
$gZ->name('Group Z');
WebGUI::Test->addToCleanup($gX, $gY, $gZ);

$gZ->addGroups([$gX->getId, $gY->getId]);

#      B
#	  / \
#	 A   C
#    |
#    Z
#   / \
#  X   Y

$gA->addGroups([$gZ->getId]);
cmp_bag($gB->getGroupsIn(1), [$gA->getId, $gC->getId, $gZ->getId, $gY->getId, $gX->getId, 3], 'Add Z tree to A under B');

$gX->addGroups([$gA->getId]);
cmp_bag($gX->getGroupsIn(), [3], 'Not able to add B tree under Z tree under X');

$gZ->addGroups([$gX->getId]);
cmp_bag($gZ->getGroupsIn(), [$gX->getId, $gY->getId, 3], 'Not able to add a group when it is already a member of a group');

cmp_bag($gX->getAllGroupsFor(), [ map {$_->getId} ($gZ, $gA, $gB) ], 'getAllGroupsFor X');
cmp_bag($gY->getAllGroupsFor(), [ map {$_->getId} ($gZ, $gA, $gB) ], 'getAllGroupsFor Y');
cmp_bag($gZ->getAllGroupsFor(), [ map {$_->getId} ($gA, $gB) ], 'getAllGroupsFor Z');

my $user = WebGUI::User->new($session, "new");
WebGUI::Test->addToCleanup($user);
$gX->userIsAdmin($user->userId, "yes");
ok(!$gX->userIsAdmin($user->userId), "userIsAdmin: User who isn't secondary admin can't be group admin");
isnt($gX->userIsAdmin($user->userId), 'yes', "userIsAdmin returns 1 or 0, not value");

my $originalSessionUserId = $session->user->userId;
$session->user({userId => 1});
is($gX->userIsAdmin, 0, 'userIsAdmin: using session user Visitor');
$session->user({userId => 3});
is($gX->userIsAdmin, 1, 'userIsAdmin: using session user Admin');
$session->user({userId => $originalSessionUserId});

$gX->userIsAdmin($user->userId, 1);
ok(!$gX->userIsAdmin($user->userId), "userIsAdmin: User must be member of group to be group admin");

my $expireOffset = $gX->expireOffset;

$user->addToGroups([$gX->getId]);
##User expire time is calculated correctly
my $expireTime = abs($gX->userGroupExpireDate($user->userId) - $expireOffset - time());
cmp_ok( $expireTime,  '<=', 1, 'userGroupExpireDate: Default expire time');
ok($user->isInGroup($gX->getId), "addToGroups: Added dude to gX");

$gX->userIsAdmin($user->userId, 1);
ok($gX->userIsAdmin($user->userId), "userIsAdmin: Dude set to be group admin for gX");

sleep 5;
$expireTime = time() + $expireOffset - $gX->userGroupExpireDate($user->userId) ;

$gX->addUsers([$user->userId]);
ok( ($expireTime < 7 && $expireTime > 0), 'userGroupExpireDate: Default expire time ages');
my $expireTime = abs($gX->userGroupExpireDate($user->userId) - $expireOffset - time());
cmp_ok(  $expireTime, '<=', 1, 'adding exising user to group resets expire date');
ok($gX->userIsAdmin($user->userId), "userIsAdmin: adding existing user to group does not change group admin status");

##undef and the empty string will return the set value because they're
##interpreted as the empty string.
is($gX->userIsAdmin($user->userId, ''), 1, "userIsAdmin: empty string returns status");
is($gX->userIsAdmin($user->userId, undef), 1, "userIsAdmin: undef returns status");

##Now we'll try various settings and see how they work with userIsAdmin.
$gX->userIsAdmin($user->userId, 0);
ok(!$gX->userIsAdmin($user->userId), "userIsAdmin: trying 0 as value");
$gX->userIsAdmin($user->userId, '0E0');
ok(!$gX->userIsAdmin($user->userId), "userIsAdmin: trying '0E0'(string) as value");
$gX->userIsAdmin($user->userId, 0E0);
ok(!$gX->userIsAdmin($user->userId), "userIsAdmin: trying 0E0 as value");

$user->delete;

##Build a group of users and add them to various groups to test fetching users

################################################################
#
# addUser
#
################################################################

my @crowd = map { WebGUI::User->new($session, "new") } 0..7;
WebGUI::Test->addToCleanup(@crowd);
my @mob;
foreach my $idx (0..2) {
	$mob[$idx] = WebGUI::User->new($session, "new");
	$mob[$idx]->username("mob$idx");
}
WebGUI::Test->addToCleanup(@mob);

my @bUsers = map { $_->userId } @crowd[0,1];
my @aUsers = map { $_->userId } @crowd[2,3];
my @cUsers = map { $_->userId } @crowd[4,5];
my @zUsers = map { $_->userId } @crowd[6,7];

$gB->addUsers([ @bUsers ]);
$gA->addUsers([ @aUsers ]);
$gC->addUsers([ @cUsers ]);
$gZ->addUsers([ @zUsers ]);

cmp_bag($gB->getUsers, [@bUsers], 'users in group B');
cmp_bag($gA->getUsers, [@aUsers], 'users in group A');
cmp_bag($gC->getUsers, [@cUsers], 'users in group C');
cmp_bag($gZ->getUsers, [@zUsers], 'users in group Z');

cmp_bag($gB->getAllUsers(), [@bUsers, @aUsers, @cUsers, @zUsers, 3], 'users in group B, recursively');
cmp_bag($gA->getAllUsers(), [@aUsers, @zUsers, 3], 'users in group A, recursively');
cmp_bag($gC->getAllUsers(), [@cUsers, 3], 'users in group C, recursively');
cmp_bag($gZ->getAllUsers(), [@zUsers, 3], 'users in group Z, recursively');

##User and Group specific addUser tests

my $visitorUser = WebGUI::User->new($session, 1);

my $everyoneGroup = WebGUI::Group->new($session, 7);
my $everyUsers = $everyoneGroup->getUsers();
$everyoneGroup->addUsers([$visitorUser->userId]);
cmp_bag($everyUsers, $everyoneGroup->getUsers(), 'addUsers will not add a user to a group they already belong to');

##Check expire time override on addUsers

my $expireOverrideGroup = WebGUI::Group->new($session, 'new');
WebGUI::Test->addToCleanup($expireOverrideGroup);
$expireOverrideGroup->expireOffset('50');
my $expireOverrideUser = WebGUI::User->create($session);
WebGUI::Test->addToCleanup($expireOverrideUser);
$expireOverrideGroup->addUsers([$expireOverrideUser->userId], '5000');
my $expirationDate = $session->db->quickScalar('select expireDate from groupings where userId=?', [$expireOverrideUser->userId]);
cmp_ok($expirationDate-time(), '>', 50, 'checking expire offset override on addUsers');

################################################################
#
# getDatabaseUsers & hasDatabaseUsers
#
################################################################

$session->db->dbh->do('DROP TABLE IF EXISTS myUserTable');
WebGUI::Test->addToCleanup(SQL => 'DROP TABLE IF EXISTS myUserTable');
$session->db->dbh->do(q!CREATE TABLE myUserTable (userId CHAR(22) binary NOT NULL default '', PRIMARY KEY(userId)) TYPE=InnoDB!);

my $sth = $session->db->prepare('INSERT INTO myUserTable VALUES(?)');
foreach my $mob (@mob) {
	$sth->execute([ $mob->userId ]);
}

ok( !$mob[0]->isInGroup($gY->getId), 'mob[0] is not in group Z');

my $mobUsers = $session->db->buildArrayRef('select userId from myUserTable');

cmp_bag($mobUsers, [map {$_->userId} @mob], 'verify SQL table built correctly');

is( $gY->databaseLinkId, 0, "Group Y's databaseLinkId is set to WebGUI");
$gY->dbQuery(q!select userId from myUserTable!);
is( $session->stow->get('isInGroup'), undef, 'setting dbQuery clears cached isInGroup');

is( $mob[0]->isInGroup($gY->getId), 1, 'mob[0] is in group Y after setting dbQuery');
is( $mob[0]->isInGroup($gZ->getId), 1, 'mob[0] isInGroup Z');

ok( $mob[0]->userId ~~ $gY->getAllUsers, 'mob[0] in list of group Y users');
ok( ! ($mob[0]->userId ~~ $gZ->getUsers), 'mob[0] not in list of group Z users');

ok( $mob[0]->userId ~~ $gZ->getAllUsers, 'mob[0] in list of group Z users, recursively');

$gY->clearCaches;

my @mobIds = map { $_->userId } @mob;

cmp_bag(
	$gY->getDatabaseUsers(),
	\@mobIds,
	'all mob users in list of group Y users from database'
);

$session->db->write('delete from myUserTable where userId=?',[$mob[0]->getId]);
my $inDb = $session->db->quickScalar("select count(*) from myUserTable where userId=?",[$mob[0]->getId]);
ok ( !$inDb, 'mob[0] no longer in myUserTable');
$session->cache->remove("isInGroup");                                #Delete stow so we get a good test

is_deeply(
	[ (map { $gY->hasDatabaseUser($_->getId) }  @mob) ],
	[0, 1, 1],
	'mob users 1,2 found in list of group Y users from database'
);

##Karma tests

my $gK = WebGUI::Group->new($session, "new");
$gK->name('Group K');
$gC->addGroups([$gK->getId]);
WebGUI::Test->addToCleanup($gK);

#      B
#     / \
#    A   C
#    |   |
#    Z   K
#   / \
#  X   Y

$gK->karmaThreshold(5);

my @chameleons =  ();
foreach my $idx (0..3) {
	$chameleons[$idx] = WebGUI::User->new($session, "new");
	$chameleons[$idx]->username("chameleon$idx");
}
WebGUI::Test->addToCleanup(@chameleons);

foreach my $idx (0..3) {
	$chameleons[$idx]->karma(5*$idx, 'testCode', 'testable karma, dude');
}

is_deeply(
	[ (map { $_->karma() }  @chameleons) ],
	[0, 5, 10, 15],
	'karma level checks'
);

my $defaultKarmaSetting = $session->setting->get('useKarma');

$session->setting->set('useKarma', 0);

is_deeply(
	[ (map { $_->isInGroup($gK->getId) }  @chameleons) ],
	[0, 0, 0, 0],
	'karma disabled in settings, no users in group'
);

is_deeply(
	[ (map { $gK->hasKarmaUser($_->getId) }  @chameleons) ],
	[0, 0, 0, 0],
	'karma disabled in settings, group K has no users via karma threshold'
);

$session->setting->set('useKarma', 1);
$gK->clearCaches; ##Clear cache since previous data is wrong

is_deeply(
	[ (map { $_->isInGroup($gK->getId) }  @chameleons) ],
	[0, 1, 1, 1],
	'chameleons 1, 2 and 3 are in group K via karma threshold'
);

is_deeply(
	[ (map { $gK->hasKarmaUser($_->getId) }  @chameleons) ],
	[0, 1, 1, 1],
	'group K has chameleons 1, 2 and 3 via karma threshold'
);

cmp_bag(
	$gK->getKarmaUsers,
	[ (map { $_->userId() }  @chameleons[1..3]) ],
	'chameleons 1, 2 and 3 are group K karma users'
);

$session->setting->set('useKarma', $defaultKarmaSetting);

##Scratch tests

my $gS = WebGUI::Group->new($session, "new");
$gS->name('Group S');
$gC->addGroups([$gS->getId]);
WebGUI::Test->addToCleanup($gS);

#        B
#    	/ \
#      A   C
#      |   | \
#      Z   K  S
#     / \
#    X   Y


$gS->scratchFilter('name=Tom;airport=PDX');
is ($gS->scratchFilter(), 'name=Tom;airport=PDX', 'checking retrieval of scratchFilter');

my @itchies =  ();
my @sessionBank = ();

foreach my $idx (0..$#scratchTests) {
	##Create a new session
	$sessionBank[$idx] = WebGUI::Session->open(WebGUI::Test->file);

	##Create a new user and make this session's default user that user
	$itchies[$idx] = WebGUI::User->new($sessionBank[$idx], "new");
	$sessionBank[$idx]->user({user => $itchies[$idx]});

	##Name this user for convenience
	$itchies[$idx]->username("itchy$idx");

	##Assign this user to this test to be fetched later
	$scratchTests[$idx]->{user} = $itchies[$idx];

	##Set scratch in the session for this user
	my @scratchData = split /;/, $scratchTests[$idx]->{scratch};
	foreach my $item (@scratchData) {
		my ($name, $value) = split /=/, $item;
		$sessionBank[$idx]->scratch->set($name, $value);
	}
}
WebGUI::Test->addToCleanup(@itchies);
WebGUI::Test->addToCleanup(@sessionBank);

#isInGroup test
foreach my $scratchTest (@scratchTests) {
    is($scratchTest->{user}->isInGroup($gS->getId), $scratchTest->{expect}, $scratchTest->{comment});
}

$session->cache->remove("isInGroup");

#hasScratchUser test
foreach my $idx (0..$#scratchTests) {
    my $scratchTest = $scratchTests[$idx];
    my $sessionId   = $sessionBank[$idx]->getId;
	is($gS->hasScratchUser($scratchTest->{user}->getId, $sessionId), $scratchTest->{expect}, $scratchTest->{comment}." - hasScratchUser");
}


cmp_bag(
	$gS->getScratchUsers,
	[ (map { $_->{user}->userId() }  grep { $_->{expect} } @scratchTests) ],
	'getScratchUsers'
);

cmp_bag(
	$gS->getAllUsers,
	[ ( (map { $_->{user}->userId() }  grep { $_->{expect} } @scratchTests), 3) ],
	'getAllUsers for group with scratch'
);

{  ##Add scope to force cleanup

    note "Checking for user Visitor session leak with scratch";

    my $remoteSession = WebGUI::Test->newSession;
    $remoteSession->user({userId => 1});
    $remoteSession->scratch->set('remote','nok');

    my $localScratchGroup = WebGUI::Group->new($session, 'new');
    $localScratchGroup->name("Local IP Group");
    $localScratchGroup->scratchFilter('local=ok');

    ok !$remoteSession->user->isInGroup($localScratchGroup->getId), 'Remote Visitor fails to be in the scratch group';

    my $localSession = WebGUI::Test->newSession;
    WebGUI::Test->addToCleanup($localScratchGroup, $remoteSession, $localSession);
    $localSession->user({userId => 1});
    $localSession->scratch->set('local','ok');
    $localScratchGroup->clearCaches;

    ok $localSession->user->isInGroup($localScratchGroup->getId), 'Local Visitor is in the scratch group';

    $remoteSession->stow->delete('isInGroup');
    ok !$remoteSession->user->isInGroup($localScratchGroup->getId), 'Remote Visitor is not in the scratch group, even though a different Visitor passed';

}

@sessionBank = ();
my @tcps =  ();

foreach my $idx (0..$#ipTests) {
	my $ip = $ipTests[$idx]->{ip};

	##Create a new session
	$sessionBank[$idx] = WebGUI::Test->newSession;

	##Set the ip to be used by the session for this user
	$sessionBank[$idx]->request->env->{REMOTE_ADDR} = $ip;

	##Create a new user and make this session's default user that user
	$tcps[$idx] = WebGUI::User->new($sessionBank[$idx], "new");
	$sessionBank[$idx]->user({user => $tcps[$idx]});

	##Name this user for convenience
	$tcps[$idx]->username("tcp$idx");

    ##Assign this user and session to this test to be fetched later
    $ipTests[$idx]->{user}    = $tcps[$idx];
    $ipTests[$idx]->{session} = $sessionBank[$idx];
}
WebGUI::Test->addToCleanup(@tcps);

my $gI = WebGUI::Group->new($session, "new");
WebGUI::Test->addToCleanup($gI);
$gI->name('Group I');
$gI->ipFilter('194.168.0.0/24');

cmp_bag(
	$gI->getIpUsers,
	[ (map { $_->{user}->userId() }  grep { $_->{expect} } @ipTests) ],
	'getIpUsers'
);

cmp_bag(
	$gI->getAllUsers,
	[ ( (map { $_->{user}->userId() }  grep { $_->{expect} } @ipTests), 3) ],
	'getUsers for group with IP filter'
);

is_deeply(
	[ (map { $gI->hasIpUser($_->{user}->getId, $_->{session}->getId) }  @ipTests) ],
	[ (map { $_->{expect} } @ipTests) ],
	'hasIpUsers for group with IP filter'
);

foreach my $ipTest (@ipTests) {
	is($ipTest->{user}->isInGroup($gI->getId), $ipTest->{expect}, $ipTest->{comment});
}

{  ##Add scope to force cleanup

    note "Checking for user Visitor session leak via IP address";

    my $remoteSession = WebGUI::Test->newSession;
    $remoteSession->request->env->{REMOTE_ADDR} = '191.168.1.1';
    $remoteSession->user({userId => 1});

    my $localIpGroup = WebGUI::Group->new($session, 'new');
    $localIpGroup->name("Local IP Group");
    $localIpGroup->ipFilter('192.168.33.0/24');

    ok !$remoteSession->user->isInGroup($localIpGroup->getId), 'Remote Visitor fails to be in the group';

    my $localSession = WebGUI::Test->newSession;
    $localSession->request->env->{REMOTE_ADDR} = '192.168.33.1';
    WebGUI::Test->addToCleanup($localIpGroup, $remoteSession, $localSession);
    $localSession->user({userId => 1});
    $localIpGroup->clearCaches;

    ok $localSession->user->isInGroup($localIpGroup->getId), 'Local Visitor is in the group';

    $remoteSession->stow->delete('isInGroup');
    $localIpGroup->clearCaches;
    ok !$remoteSession->user->isInGroup($localIpGroup->getId), 'Remote Visitor is not in the group, even though a different Visitor passed';

}



##Cache check.

my $cacheDude = WebGUI::User->new($session, "new");
WebGUI::Test->addToCleanup($cacheDude);
$cacheDude->username('Cache Dude');

$gY->addUsers([$cacheDude->userId]);

ok( $cacheDude->isInGroup($gY->getId), "Cache dude added to group Y");
ok( $cacheDude->isInGroup($gZ->getId), "Cache dude is a member of group Z by group membership");
ok((grep $_ eq $gY->getId, @{ $cacheDude->getGroupIdsRecursive } ), 'Cache dude in Y by getGroupIdsRecursive');

ok(eval { $gY->deleteUsers([$cacheDude->userId]); 1; }, "Y deleteUsers on Cache dude");

ok((! grep $_ eq $gY->getId, @{ $cacheDude->getGroupIdsRecursive } ), 'Cache dude not in Y getGroupIdsRecursive');
ok((! grep $_ eq $cacheDude->userId, @{ $gY->getAllUsers() } ), 'Cache dude not in Y getAllUsers');

ok( !$cacheDude->isInGroup($gY->getId), "Cache dude removed from group Y by isInGroup");
ok( !$cacheDude->isInGroup($gZ->getId), "Cache dude removed from group Z too by isInGroup");

my $gCache = WebGUI::Group->new($session, "new");
WebGUI::Test->addToCleanup($gCache);

$gCache->addUsers([$cacheDude->userId]);

$gY->addGroups([$gCache->getId]);

ok( $cacheDude->isInGroup($gY->getId), "Cache dude is a member of group Y by group membership");
ok( $cacheDude->isInGroup($gZ->getId), "Cache dude is a member of group Z by group membership");
ok( $cacheDude->isInGroup($gA->getId), "Cache dude is a member of group A by group membership");
ok( $cacheDude->isInGroup($gB->getId), "Cache dude is a member of group B by group membership");

$gY->deleteGroups([$gCache->getId]);

ok( !$cacheDude->isInGroup($gY->getId), "Cache dude is not a member of group Y");
ok( !$cacheDude->isInGroup($gZ->getId), "Cache dude is not a member of group Z");
ok( !$cacheDude->isInGroup($gA->getId), "Cache dude is not a member of group A");
ok( !$cacheDude->isInGroup($gB->getId), "Cache dude is not a member of group B");

##Admin group inclusion check.

SKIP: {
	skip("need to test expiration date in groupings interacting with recursive or not", 1);
	ok(undef, "expiration date in groupings for getUser");
}

################################################################
#
# getUserList
#
################################################################

################################################################
#
# vitalGroup
#
################################################################

ok(  WebGUI::Group->vitalGroup(7), 'vitalGroup: 7');
ok(  WebGUI::Group->vitalGroup(3), '... 3');
ok(  WebGUI::Group->vitalGroup('pbgroup000000000000015'), '... pbgroup000000000000015');
ok(! WebGUI::Group->vitalGroup('27'), '... 27 is not vital');

#----------------------------------------------------------------------------
# getUsersNotIn

# Normal group
my $happyDude   = WebGUI::User->create( $session );
$happyDude->username(" Happy Dude ");
WebGUI::Test->addToCleanup( $happyDude );

$gA->addUsers([ $happyDude->getId ]);
$gB->addUsers([ $happyDude->getId ]);
cmp_deeply(
    $gA->getUsersNotIn( $gZ->getId ),
    superbagof( $happyDude->getId ),
    "get the users not in the group",
);
ok(
    !grep( { $_ eq $happyDude->getId } @{$gA->getUsersNotIn( $gB->getId )}),
    "don't get the users in both groups",
);

# Special-case Registered Users
my $regUser = WebGUI::Group->new( $session, "2" );
cmp_deeply(
    $regUser->getUsersNotIn( $gZ->getId ),
    superbagof( $happyDude->getId ),
    "registered users: get the users not in the group",
);
ok(
    !grep( { $_ eq $happyDude->getId } @{$regUser->getUsersNotIn( $gA->getId )}),
    "registered users: don't get the users in both groups",
);

done_testing;

#vim:ft=perl
