# vim:syntax=perl
#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2008 Plain Black Corporation.
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

my $tests = 4;
plan tests => 1 + $tests;

#----------------------------------------------------------------------------
# put your tests here

my $loaded = use_ok('WebGUI::Shop::ShipDriver');

my $storage;

SKIP: {

skip 'Unable to load module WebGUI::Shop::ShipDriver', $tests unless $loaded;

#######################################################################
#
# definition
#
#######################################################################

my $definition = WebGUI::Shop::ShipDriver->definition($session);

cmp_deeply(
    $definition,
    [ {
        name => 'Shipper Driver',
        fields => {
            label => {
                fieldType => 'text',
                label => ignore(),
                hoverHelp => ignore(),
                defaultValue => undef,
            },
            enabled => {
                fieldType => 'yesNo',
                label => ignore(),
                hoverHelp => ignore(),
                defaultValue => 1,
            }
        }
    } ],
    ,
    'Definition returns an array of hashrefs',
);

$definition = WebGUI::Shop::ShipDriver->definition($session, [ { name => 'Red' }]);

cmp_deeply(
    $definition,
    [
        {
            name => 'Red',
        },
        {
            name => 'Shipper Driver',
            fields => ignore(),
        }
    ],
    ,
    'New data is appended correctly',
);

#######################################################################
#
# new
#
#######################################################################

my $driver;

eval { $driver = WebGUI::Shop::ShipDriver->create($session); };
like ($@, qr/You must pass a hashref of options to create a new ShipDriver object/, 'create croaks without a hashref of options');

eval { $driver = WebGUI::Shop::ShipDriver->create($session, {}); };
like ($@, qr/You must pass a hashref of options to create a new ShipDriver object/, 'create croaks with an empty hashref of options');

#isa_ok($driver, 'WebGUI::Shop::ShipDriver');
#
#isa_ok($driver->session, 'WebGUI::Session', 'session method returns a session object');
#
#is($session->getId, $driver->session->getId, 'session method returns OUR session object');

#######################################################################
#
# getName
#
#######################################################################

#######################################################################
#
# getEditForm
#
#######################################################################

#######################################################################
#
# calculate
#
#######################################################################

}

#----------------------------------------------------------------------------
# Cleanup
END {
}
