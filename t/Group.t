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
use Test::More tests => 8; # increment this value for each test you create

my $session = WebGUI::Test->session;

my $g = WebGUI::Group->new($session, "new");

diag("Object creation and defaults");
is( ref $g, "WebGUI::Group", "Group object creation");
my $gid = $g->getId;
isnt( $gid, "new", "Group assigned new groupId, not new");
is( length($gid), 22, "GroupId is proper length");

is ($g->name('**TestGroup**'), '**TestGroup**', 'Set name');
is ($g->name(), '**TestGroup**', 'Get name via accessor');
is ($g->get('groupName'), '**TestGroup**', 'Get name via generic accessor');

my $g2 = WebGUI::Group->find($session, '**TestGroup**');
my $skipFindGroup = is(ref $g2, 'WebGUI::Group', 'find returns a group');

SKIP: {
	skip('find did not return a WebGUI::Group object', !$skipFindGroup);
	is( $g->getId, $g2->getId, 'find returns correct group');
}

undef $g2;
$g->delete();

my $matchingGroups = $session->db->quickArray("select groupId from groups where groupId=".$session->db->quote($gid));

is ( $matchingGroups, 0, 'group was removed');

