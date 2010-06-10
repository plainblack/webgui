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
use lib "$FindBin::Bin/../lib";
use Test::More;
use Test::Deep;
use WebGUI::Test; # Must use this before any other WebGUI modules
use WebGUI::Session;

#----------------------------------------------------------------------------
# Init
my $session         = WebGUI::Test->session;


#----------------------------------------------------------------------------
# Tests


my $numTests = 1;

$numTests += 2; #For the use_ok

plan tests => $numTests;

#----------------------------------------------------------------------------
# put your tests here

my $module = 'WebGUI::Inbox::Message';
my $loaded = use_ok($module);

SKIP: {

skip "Unable to load $module", $numTests-1 unless $loaded;

###############################################
#
# statusCodes
#
###############################################

my $statusCodes = WebGUI::Inbox::Message->statusCodes($session);
my $expectedCodes = {
    active    => ignore(),
    pending   => ignore(),
    completed => ignore(),
    unread    => ignore(),
    read      => ignore(),
    replied   => ignore(),
};

cmp_deeply( $statusCodes, $expectedCodes, 'statusCodes as a class method works');
undef $statusCodes;

my $tempMessage = WebGUI::Inbox::Message->create($session, {}, {no_email => 1});
$statusCodes = $tempMessage->statusCodes;
cmp_deeply( $statusCodes, $expectedCodes, 'statusCodes as an object method works');
undef $statusCodes;
$tempMessage->delete;

}

#vim:ft=perl
