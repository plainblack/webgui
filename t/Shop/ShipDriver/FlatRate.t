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
use lib "$FindBin::Bin/../../lib";
use Test::More;
use Test::Deep;
use JSON;
use HTML::Form;

use WebGUI::Test; # Must use this before any other WebGUI modules
use WebGUI::Session;

#----------------------------------------------------------------------------
# Init
my $session         = WebGUI::Test->session;

#----------------------------------------------------------------------------
# Tests

my $tests = 11;
plan tests => 1 + $tests;

#----------------------------------------------------------------------------
# put your tests here

my $loaded = use_ok('WebGUI::Shop::ShipDriver::FlatRate');

my $storage;

SKIP: {

skip 'Unable to load module WebGUI::Shop::ShipDriver::FlatRate', $tests unless $loaded;

#######################################################################
#
# definition
#
#######################################################################

my $definition;
my $e; ##Exception variable, used throughout the file

eval { $definition = WebGUI::Shop::ShipDriver::FlatRate->definition(); };
$e = Exception::Class->caught();
isa_ok($e, 'WebGUI::Error::InvalidParam', 'definition takes an exception to not giving it a session variable');
cmp_deeply(
    $e,
    methods(
        error => 'Must provide a session variable',
    ),
    'definition: requires a session variable',
);


$definition = WebGUI::Shop::ShipDriver::FlatRate->definition($session);

cmp_deeply(
    $definition,
    [ {
        name => 'Flat Rate',
        properties => {
            flatFee => {
                fieldType => 'float',
                label => ignore(),
                hoverHelp => ignore(),
                defaultValue => 0,
            },
            percentageOfPrice => {
                fieldType => 'float',
                label => ignore(),
                hoverHelp => ignore(),
                defaultValue => 0,
            },
            pricePerWeight => {
                fieldType => 'float',
                label => ignore(),
                hoverHelp => ignore(),
                defaultValue => 0,
            },
            pricePerItem => {
                fieldType => 'float',
                label => ignore(),
                hoverHelp => ignore(),
                defaultValue => 0,
            },
        }
    },
    {
        name => 'Shipper Driver',
        properties => {
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
            },
        }
    } ],
    'Definition returns an array of hashrefs',
);

#######################################################################
#
# create
#
#######################################################################

my $driver;

my $options = {
                label   => 'flat rate, ship weight, items in the cart',
                enabled => 1,
                flatFee => 1.00,
                percentageOfPrice => 5,
                pricePerWeight    => 0.5,
                pricePerItem      => 0.1,
              };

$driver = WebGUI::Shop::ShipDriver::FlatRate->create($session, $options);

isa_ok($driver, 'WebGUI::Shop::ShipDriver::FlatRate');

isa_ok($driver, 'WebGUI::Shop::ShipDriver');

#######################################################################
#
# getName
#
#######################################################################

is (WebGUI::Shop::ShipDriver::FlatRate->getName($session), 'Flat Rate', 'getName returns the human readable name of this driver');

#######################################################################
#
# getEditForm
#
#######################################################################

my $form = $driver->getEditForm;

isa_ok($form, 'WebGUI::HTMLForm', 'getEditForm returns an HTMLForm object');

my $html = $form->print;

##Any URL is fine, really
my @forms = HTML::Form->parse($html, 'http://www.webgui.org');
is (scalar @forms, 1, 'getEditForm generates just 1 form');

my @inputs = $forms[0]->inputs;
is (scalar @inputs, 11, 'getEditForm: the form has 11 controls');

my @interestingFeatures;
foreach my $input (@inputs) {
    my $name = $input->name;
    my $type = $input->type;
    push @interestingFeatures, { name => $name, type => $type };
}

cmp_deeply(
    \@interestingFeatures,
    [
        {
            name => undef,
            type => 'submit',
        },
        {
            name => 'driverId',
            type => 'hidden',
        },
        {
            name => 'shop',
            type => 'hidden',
        },
        {
            name => 'method',
            type => 'hidden',
        },
        {
            name => 'do',
            type => 'hidden',
        },
        {
            name => 'label',
            type => 'text',
        },
        {
            name => 'enabled',
            type => 'radio',
        },
        {
            name => 'flatFee',
            type => 'text',
        },
        {
            name => 'percentageOfPrice',
            type => 'text',
        },
        {
            name => 'pricePerWeight',
            type => 'text',
        },
        {
            name => 'pricePerItem',
            type => 'text',
        },
    ],
    'getEditForm made the correct form with all the elements'

);

#######################################################################
#
# delete
#
#######################################################################

$driver->delete;

my $count = $session->db->quickScalar('select count(*) from shipper where shipperId=?',[$driver->getId]);
is($count, 0, 'delete deleted the object');

undef $driver;

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
