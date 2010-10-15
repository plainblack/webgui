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

use strict;
use Test::More;
use Test::Deep;
use JSON;
use HTML::Form;

use WebGUI::Test; # Must use this before any other WebGUI modules
use WebGUI::Session;
use WebGUI::Shop::ShipDriver;
use Clone;

#----------------------------------------------------------------------------
# Init
my $session         = WebGUI::Test->session;

#----------------------------------------------------------------------------
# Tests

plan tests => 32;

#----------------------------------------------------------------------------
# put your tests here

my $e;

#######################################################################
#
# new
#
#######################################################################

my $driver;

eval { $driver = WebGUI::Shop::ShipDriver->new(); };
$e = Exception::Class->caught();
isa_ok($e, 'WebGUI::Error::InvalidParam', 'new takes exception to not giving it a session object');
cmp_deeply(
    $e,
    methods(
        error => 'Must provide a session variable',
    ),
    'new takes exception to not giving it a session object',
);

eval { $driver = WebGUI::Shop::ShipDriver->new($session); };
$e = Exception::Class->caught();
isa_ok($e, 'WebGUI::Error::InvalidParam', 'new takes exception to not giving it a hashref of options');
cmp_deeply(
    $e,
    methods(
        error => 'Must provide a shipperId',
    ),
    'new takes exception to not giving it a shipperId',
);

my $options = {
                label      => 'Slow and dangerous',
                enabled    => 1,
                groupToUse => 7,
              };

$driver = WebGUI::Shop::ShipDriver->new( $session, Clone::clone($options) );
$driver->write;
WebGUI::Test->addToCleanup($driver);

isa_ok($driver, 'WebGUI::Shop::ShipDriver');

isa_ok($driver->session, 'WebGUI::Session', 'session method returns a session object');

is($session->getId, $driver->session->getId, 'session method returns OUR session object');

like($driver->getId, $session->id->getValidator, 'got a valid GUID for shipperId');

cmp_deeply($driver->get, { %{$options}, shipperId=>ignore()} , 'get works');

my $dbData = $session->db->quickHashRef('select * from shipper where shipperId=?',[$driver->getId]);
cmp_deeply(
    $dbData,
    {
        shipperId => $driver->getId,
        className => ref($driver),
        options   => q|{"groupToUse":7,"label":"Slow and dangerous","enabled":1}|,
    },
    'Correct data written to the db',
);

#######################################################################
#
# getName
#
#######################################################################

is (WebGUI::Shop::ShipDriver->getName($session), 'Shipping Driver', 'getName returns the human readable name of this driver');

#######################################################################
#
# get
#
#######################################################################

is($driver->get('enabled'), 1, 'get the enabled entry from the options');
is($driver->get('label'),   'Slow and dangerous', 'get the label entry from the options');
my $optionsCopy = $driver->get();
$optionsCopy->{label} = 'fast and furious';
is($driver->get('label'), 'Slow and dangerous', 'get returns a safe copy of the options');

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
is (scalar @inputs, 10, 'getEditForm: the form has 10 controls');

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
            name => 'webguiCsrfToken',
            type => 'hidden',
        },
        {
            name => undef,
            type => 'submit',
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
            name => 'driverId',
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
            name => 'groupToUse',
            type => 'option',
        },
        {
            name => '__groupToUse_isIn',
            type => 'hidden',
        },
    ],
    'getEditForm made the correct form with all the elements'

);


#######################################################################
#
# new
#
#######################################################################

my $oldDriver;

eval { $oldDriver = WebGUI::Shop::ShipDriver->new($session, 'notEverAnId'); };
$e = Exception::Class->caught();
isa_ok($e, 'WebGUI::Error::ObjectNotFound', 'new croaks unless the requested shipperId object exists in the db');
cmp_deeply(
    $e,
    methods(
        error => 'shipperId not found in db',
        id    => 'notEverAnId',
    ),
    'new croaks unless the requested shipperId object exists in the db',
);

my $driverCopy = WebGUI::Shop::ShipDriver->new($session, $driver->getId);

is($driver->getId,       $driverCopy->getId, 'same id');
is(ref $driver,          ref $driverCopy,    'same className');
cmp_deeply($driver->get, $driverCopy->get,   'same options');

#######################################################################
#
# calculate
#
#######################################################################

eval { $driver->calculate; };
like ($@, qr/^You must override the calculate method/, 'calculate croaks to force overriding it in the child classes');

#######################################################################
#
# update, get
#
#######################################################################

isa_ok( $driver->get(), 'HASH', 'get returns a hashref if called with no param');

is($driver->get('groupToUse'), 7, '... default group is 7');

$options = $driver->get();
$options->{groupToUse} = 3;

is($driver->get('groupToUse'), 7, '... get returns a safe hashref');

$driver->update($options);
is($driver->get('groupToUse'), 3, '... update groupToUse to 3');

#######################################################################
#
# canUse
#
#######################################################################

$session->user({userId => 1});
ok(! $driver->canUse, 'canUse, Visitor cannot use this driver since it is set to Admin');
$session->user({userId => 3});
ok(  $driver->canUse, '... Admin can use this driver');

$options = $driver->get();
$options->{groupToUse} = 7;
$session->user({userId => 1});
ok(! $driver->canUse, '... reset to group Everyone, and Visitor can use it');

#######################################################################
#
# delete
#
#######################################################################

my $driverId = $driver->getId;
$driver->delete;

my $count = $session->db->quickScalar('select count(*) from shipper where shipperId=?',[$driverId]);
is($count, 0, 'delete deleted the object');

undef $driver;
