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
use JSON;
use WebGUI::Test; # Must use this before any other WebGUI modules
use WebGUI::Session;

#----------------------------------------------------------------------------
# Init
my $session         = WebGUI::Test->session;

#----------------------------------------------------------------------------
# Tests

my $tests = 18;
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

my $definition;

eval { $definition = WebGUI::Shop::ShipDriver->definition(); };
like ($@, qr/^Definition requires a session object/, 'definition croaks without a session object');

$definition = WebGUI::Shop::ShipDriver->definition($session);

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
# create
#
#######################################################################

my $driver;

eval { $driver = WebGUI::Shop::ShipDriver->create($session); };
like ($@, qr/You must pass a hashref of options to create a new ShipDriver object/, 'create croaks without a hashref of options');

eval { $driver = WebGUI::Shop::ShipDriver->create($session, {}); };
like ($@, qr/You must pass a hashref of options to create a new ShipDriver object/, 'create croaks with an empty hashref of options');

my $options = {
                label   => 'Slow and dangerous',
                enabled => 1,
              };
$driver = WebGUI::Shop::ShipDriver->create( $session, $options);

isa_ok($driver, 'WebGUI::Shop::ShipDriver');

isa_ok($driver->session, 'WebGUI::Session', 'session method returns a session object');

is($session->getId, $driver->session->getId, 'session method returns OUR session object');

like($driver->shipperId, $session->id->getValidator, 'got a valid GUID for shipperId');
is($driver->getId,       $driver->shipperId,         'getId returns the same thing as shipperId');

is($driver->className, ref $driver, 'className property set correctly');

cmp_deeply($driver->options, $options, 'options accessor works');

my $dbData = $session->db->quickHashRef('select * from shipper limit 1');
cmp_deeply(
    $dbData,
    {
        shipperId => $driver->shipperId,
        className => ref($driver),
        options   => q|{"label":"Slow and dangerous","enabled":1}|,
    },
    'Correct data written to the db',
);

#######################################################################
#
# getName
#
#######################################################################

is ($driver->getName, 'Shipper Driver', 'getName returns the human readable name of this driver');

#######################################################################
#
# getEditForm
#
#######################################################################

#######################################################################
#
# delete
#
#######################################################################

$driver->delete;

my $count = $session->db->quickScalar('select count(*) from shipper where shipperId=?',[$driver->shipperId]);
is($count, 0, 'delete deleted the object');

undef $driver;

#######################################################################
#
# new
#
#######################################################################

my $oldDriver;

eval { $oldDriver = WebGUI::Shop::ShipDriver->new(); };
like ($@, qr/^new requires a session object/, 'new croaks without a session object');

eval { $oldDriver = WebGUI::Shop::ShipDriver->new($session); };
like ($@, qr/^new requires a shipperId/, 'new croaks without a shipperId');

eval { $oldDriver = WebGUI::Shop::ShipDriver->new($session, 'notEverAnId'); };
like ($@, qr/^The requested shipperId does not exist in the db/, 'new croaks unless the requested shipperId object exists in the db');

#######################################################################
#
# calculate
#
#######################################################################

}

#----------------------------------------------------------------------------
# Cleanup
END {
    $session->db->write('delete from shipper');
}
