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
use Test::More tests => 4; # increment this value for each test you create

my $session = WebGUI::Test->session;

my $g = WebGUI::Group->new($session, "new");

diag("Object creation and defaults");
is( ref $g, "WebGUI::Group", "Group object creation");
isnt( $g->getId, "new", "Group assigned new groupId, not new");
is( length($g->getId), 22, "GroupId is proper length");

my $gid = $g->getId;

$g->delete();

my $matchingGroups = $session->db->quickArray("select groupId from groups where groupId=".$session->db->quote($gid));

is ( $matchingGroups, 0, 'group was removed');

