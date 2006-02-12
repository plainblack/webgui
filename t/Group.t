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
use Test::More tests => 27; # increment this value for each test you create

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
is( $g->name, $gname, 'group name restored after ->get');
ok( exists $g->{_group}, 'group property hash restored');

$g->delete();

my $matchingGroups = $session->db->quickArray("select groupId from groups where groupId=".$session->db->quote($gid));

is ( $matchingGroups, 0, 'group was removed');

