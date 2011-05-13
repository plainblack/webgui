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
my $session         = WebGUI::Test->session;


#----------------------------------------------------------------------------
# Tests

plan tests => 5;        # Increment this number for each test you create

my $group = WebGUI::Group->new($session, 'new');
WebGUI::Test->addToCleanup($group);
$group->scratchFilter("itchy=test_value");
is( $group->scratchFilter(), "itchy=test_value",'Group->scratchFilter is properly set and retrieved');
$group->groupCacheTimeout(0);
is( $group->groupCacheTimeout(), 0, 'set groupCacheTimeout to 0');

$session->user({userId => 1});
ok( !$session->user->isInGroup($group->getId), 'Visitor is NOT in the group BEFORE scratch value is set'); 
$session->scratch->set('itchy', 'test_value');
is ($group->hasScratchUser($session->user->getId), 1, 'Group->hasScratchUser correctly returns 1 immediately after scratch is set');

##Simulate another page view by clearing stow, which is volatile
$session->stow->deleteAll;
$session->scratch->delete('itchy');
is ($group->hasScratchUser($session->user->getId), 0, 'after clearing scratch, user is not in the group any longer');
