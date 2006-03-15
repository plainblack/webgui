#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2006 Plain Black Corporation.
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

use WebGUI::User;
use WebGUI::Group;
use Test::More tests => 39; # increment this value for each test you create
use Test::Deep;

my $session = WebGUI::Test->session;

my $g = WebGUI::Group->new($session, "new");

diag("Object creation and defaults");
is (ref $g, "WebGUI::Group", "Group object creation");
my $gid = $g->getId;
isnt ($gid, "new", "Group assigned new groupId, not new");
is (length($gid), 22, "GroupId is proper length");
is ($g->name(), 'New Group', 'Default name');
is ($g->expireOffset(), 314496000, 'Default karma threshold');
is ($g->karmaThreshold(), 1_000_000_000, 'Default karma threshold');
is ($g->expireNotifyOffset(), -14, 'Default expire notify offset time');
is ($g->deleteOffset(), 14, 'Default delete offset time');
is ($g->expireNotify(), 0, 'Default expire notify time');
is ($g->databaseLinkId(), 0, 'Default databaseLinkId');
is ($g->dbCacheTimeout(), 3600, 'Default external database cache timeout');
is ($g->dateCreated(), $g->lastUpdated(), 'lastUpdated = create time');
is_deeply ($g->getGroupsIn(), [3], 'Admin group added by default to this group');
is_deeply ($g->getGroupsFor(), [], 'Group not added to any other group');
is_deeply ($g->getUsers(), [], 'No users added by default');
is ($g->autoAdd(), 0, 'auto Add is off by default');
is ($g->autoDelete(), 0, 'auto Delete is off by default');
is ($g->isEditable(), 1, 'isEditable is on by default');
is ($g->showInForms(), 1, 'show in forms is on by default');

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

cmp_bag($gC->getGroupsFor(), [$gA->getId], 'Group A contains Group C');
cmp_bag($gA->getGroupsIn(),  [$gC->getId, 3], 'Group C is a member of Group A, cached');
cmp_bag($gB->getGroupsIn(1), [$gC->getId, $gA->getId, 3], 'Group C is in Group B, recursively, cached result');
cmp_bag($gB->getGroupsIn(),  [$gA->getId, 3], 'Group A is in Group B, cached result');

END {
	(defined $gA and ref $gA eq 'WebGUI::Group') and $gA->delete;
	(defined $gB and ref $gB eq 'WebGUI::Group') and $gB->delete;
	(defined $gC and ref $gC eq 'WebGUI::Group') and $gC->delete;
	(defined $g2 and ref $g2 eq 'WebGUI::Group') and $g2->delete;
	(defined $g  and ref $g  eq 'WebGUI::Group') and $g->delete;
}
