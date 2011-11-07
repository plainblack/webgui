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

use FindBin;
use strict;
use lib "$FindBin::Bin/../lib";
use Test::More;
use WebGUI::Test; # Must use this before any other WebGUI modules
use WebGUI::Session;

use WebGUI::Group;

#----------------------------------------------------------------------------
# Init
my $session1         = WebGUI::Test->session;
my $session2         = WebGUI::Test->newSession;

#----------------------------------------------------------------------------
# Tests
### Updates by DRT test that group membership is restricted by user session
### ...specifically for Visitors to have separate scratch group memberships

plan tests => 14;        # Increment this number for each test you create

my $group = WebGUI::Group->new($session1, 'new');
WebGUI::Test->addToCleanup($group);
$group->scratchFilter("itchy=test_value");
is( $group->scratchFilter(), "itchy=test_value",'Group->scratchFilter is properly set and retrieved');
$group->groupCacheTimeout(0);
is( $group->groupCacheTimeout(), 0, 'set groupCacheTimeout to 0');

$session1->user({userId => 1});
$session2->user({userId => 1});

### Test group membership before scratch is set
### NOTE: test hasScratchUser first, because isInGroup sets stow & cache
is ($group->hasScratchUser($session1->user->getId,$session1->user->session->getId), 0, 'Group->hasScratchUser correctly returns 0 for Visitor 1 before scratch is set');
is ($group->hasScratchUser($session2->user->getId,$session2->user->session->getId), 0, 'Group->hasScratchUser correctly returns 0 for Visitor 2 before scratch is set');
ok( !$session1->user->isInGroup($group->getId), 'user1->isInGroup correctly returns 0 before scratch is set');
ok( !$session2->user->isInGroup($group->getId), 'user2->isInGroup correctly returns 0 before scratch is set');

### Test group membership after scratch is set
### Clear stow, which is volatile, to simulate new page view
$session1->stow->deleteAll;
$session2->stow->deleteAll;
$session1->scratch->set('itchy', 'test_value');
is ($group->hasScratchUser($session1->user->getId,$session1->user->session->getId), 1, 'Group->hasScratchUser correctly returns 1 for Visitor 1 after scratch for Visitor 1 is set');
is ($group->hasScratchUser($session2->user->getId,$session2->user->session->getId), 0, 'Group->hasScratchUser correctly returns 0 for Visitor 2 after scratch for Visitor 1 is set');
ok( $session1->user->isInGroup($group->getId), 'user1->isInGroup correctly returns 1 after scratch for Visitor 1 is set');
ok( !$session2->user->isInGroup($group->getId), 'user2->isInGroup correctly returns 0 after scratch for Visitor 1 is set');

### Test group membership after scratch is deleted
### Clear stow, which is volatile, to simulate new page view
$session1->stow->deleteAll;
$session2->stow->deleteAll;
$session1->scratch->delete('itchy');
is ($group->hasScratchUser($session1->user->getId,$session1->user->session->getId), 0, 'Group->hasScratchUser for Visitor 1 correctly returns 0 after clearing scratch for Visitor 1');
is ($group->hasScratchUser($session2->user->getId,$session2->user->session->getId), 0, 'Group->hasScratchUser for Visitor 2 correctly returns 0 after clearing scratch for Visitor 1');
ok( !$session1->user->isInGroup($group->getId), 'user1->isInGroup correctly returns 0 after scratch for Visitor 1 is deleted');
ok( !$session2->user->isInGroup($group->getId), 'user2->isInGroup correctly returns 0 after scratch for Visitor 1 is deleted');
