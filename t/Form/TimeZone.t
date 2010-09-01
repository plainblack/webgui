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
use WebGUI::Form::TimeZone;
use WebGUI::Session;

#The goal of this test is to verify that Text form elements work

use Test::More; # increment this value for each test you create

my $session = WebGUI::Test->session;

# put your tests here

plan tests => 2;

my $zone;

$zone = WebGUI::Form::TimeZone->new($session, {
    value => 'America/Los Angeles',
});
is ($zone->get('value'), 'America/Los_Angeles', 'new replaces time zones with spaces with underscores in the value');

$zone = WebGUI::Form::TimeZone->new($session, {
    defaultValue => 'America/New York',
});
is ($zone->get('value'), 'America/New_York', 'new replaces time zones with spaces with underscores in the defaultValue');
