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

# Write a little about what this script tests.
# 
#

use FindBin;
use strict;
use lib "$FindBin::Bin/lib";
use Test::More;
use Test::Deep;
use WebGUI::Test; # Must use this before any other WebGUI modules
use WebGUI::Test::Mechanize;
use WebGUI::Session;

#----------------------------------------------------------------------------
# Init
my $session         = WebGUI::Test->session;


#----------------------------------------------------------------------------
# Tests

#----------------------------------------------------------------------------
# Edit some settings up in here

my $mech = WebGUI::Test::Mechanize->new( config => WebGUI::Test->file );
$mech->get_ok( '/' );
$mech->session->user({ userId => 3 });

my %newSettings = (
    # Test some normal settings
    companyName => 'Shawshank Penetentiary',
    companyEmail => 'warden@shawshank.justice.gov',

    # Test some Auth settings
    facebookAuthEnabled => 1,
    ldapConnection => 'SOME_RANDOM_ID',
    twitterEnabled => 1,
    webguiPasswordLength => 9_001,

    # Test some Account settings
    overrideAbleToBeFriend => 1,
    inboxInviteUserSubject => 'Your incarceration adventure begins here!',
);

$mech->get_ok( '/?op=editSettings' );
$mech->submit_form_ok({
        fields => \%newSettings,
    },
    "Settings edited"
);

my $testSettings = $session->db->buildHashRef("select * from settings", [], {noOrder => 1});
cmp_deeply(
    $testSettings,
    superhashof( \%newSettings ),
    "Settings are set",
);

diag $mech->content;
diag explain $testSettings;

done_testing;

#vim:ft=perl
