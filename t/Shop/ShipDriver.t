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
use HTML::Form;

use WebGUI::Test; # Must use this before any other WebGUI modules
use WebGUI::Session;

#----------------------------------------------------------------------------
# Init
my $session         = WebGUI::Test->session;

#----------------------------------------------------------------------------
# Tests

my $tests = 42;
plan tests => 1 + $tests;

#----------------------------------------------------------------------------
# put your tests here

my $e;

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
$e = Exception::Class->caught();
isa_ok($e, 'WebGUI::Error::InvalidParam', 'definition takes an exception to not giving it a session variable');
cmp_deeply(
    $e,
    methods(
        error => 'Must provide a session variable',
    ),
    'definition: requires a session variable',
);

$definition = WebGUI::Shop::ShipDriver->definition($session);

cmp_deeply(
    $definition,
    [ {
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
            properties => ignore(),
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

eval { $driver = WebGUI::Shop::ShipDriver->create(); };
$e = Exception::Class->caught();
isa_ok($e, 'WebGUI::Error::InvalidParam', 'create takes exception to not giving it a session object');
cmp_deeply(
    $e,
    methods(
        error => 'Must provide a session variable',
    ),
    'create takes exception to not giving it a session object',
);

eval { $driver = WebGUI::Shop::ShipDriver->create($session); };
$e = Exception::Class->caught();
isa_ok($e, 'WebGUI::Error::InvalidParam', 'create takes exception to not giving it a hashref of options');
cmp_deeply(
    $e,
    methods(
        error => 'Must provide a hashref of options',
    ),
    'create takes exception to not giving it a hashref of options',
);


eval { $driver = WebGUI::Shop::ShipDriver->create($session, {}); };
$e = Exception::Class->caught();
isa_ok($e, 'WebGUI::Error::InvalidParam', 'create takes exception to not giving it an empty hashref of options');
cmp_deeply(
    $e,
    methods(
        error => 'Must provide a hashref of options',
    ),
    'create takes exception to not giving it an empty hashref of options',
);

my $options = {
                label   => 'Slow and dangerous',
                enabled => 1,
              };
$driver = WebGUI::Shop::ShipDriver->create( $session, $options );

isa_ok($driver, 'WebGUI::Shop::ShipDriver');

isa_ok($driver->session, 'WebGUI::Session', 'session method returns a session object');

is($session->getId, $driver->session->getId, 'session method returns OUR session object');

like($driver->shipperId, $session->id->getValidator, 'got a valid GUID for shipperId');
is($driver->getId,       $driver->shipperId,         'getId returns the same thing as shipperId');

is($driver->className, ref $driver, 'className property set correctly');

cmp_deeply($driver->options, $options, 'options accessor works');

my $dbData = $session->db->quickHashRef('select * from shipper where shipperId=?',[$driver->shipperId]);
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

is (WebGUI::Shop::ShipDriver->getName($session), 'Shipper Driver', 'getName returns the human readable name of this driver');

#######################################################################
#
# get
#
#######################################################################

cmp_deeply($driver->get, $driver->options, 'get works like the options method with no param passed');
is($driver->get('enabled'), 1, 'get the enabled entry from the options');
is($driver->get('label'),   'Slow and dangerous', 'get the label entry from the options');

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
is (scalar @inputs, 5, 'getEditForm: the form has 5 controls');

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
            name => 'shipperId',
            type => 'hidden',
        },
        {
            name => 'className',
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
    ],
    'getEditForm made the correct form with all the elements'

);


#######################################################################
#
# new
#
#######################################################################

my $oldDriver;

eval { $oldDriver = WebGUI::Shop::ShipDriver->new(); };
$e = Exception::Class->caught();
isa_ok($e, 'WebGUI::Error::InvalidParam', 'new takes exception to not giving it a session object');
cmp_deeply(
    $e,
    methods(
        error => 'Must provide a session variable',
    ),
    'new takes exception to not giving it a session object',
);

eval { $oldDriver = WebGUI::Shop::ShipDriver->new($session); };
$e = Exception::Class->caught();
isa_ok($e, 'WebGUI::Error::InvalidParam', 'new takes exception to not giving it a shipperId');
cmp_deeply(
    $e,
    methods(
        error => 'Must provide a shipperId',
    ),
    'new takes exception to not giving it a shipperId',
);

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

my $driverCopy = WebGUI::Shop::ShipDriver->new($session, $driver->shipperId);

is($driver->getId,           $driverCopy->getId,     'same id');
is($driver->className,       $driverCopy->className, 'same className');
cmp_deeply($driver->options, $driverCopy->options,   'same options');

my $brokenDriver = WebGUI::Shop::ShipDriver->create($session, {label=>'to be broken', enabled=>'0'});
$session->db->write('update shipper set options=NULL where shipperId=?',[$brokenDriver->getId]);

eval { $oldDriver = WebGUI::Shop::ShipDriver->new($session, $brokenDriver->getId); };
$e = Exception::Class->caught();
isa_ok($e, 'WebGUI::Error::InvalidParam', 'new croaks if the options column in the db is null');
cmp_deeply(
    $e,
    methods(
        error => re('Options property for \S{22} was broken in the db'),
        param => undef,
    ),
    'new croaks if the options column in the db is null',
);

$session->db->write(q{update shipper set options='' where shipperId=?},[$brokenDriver->getId]);

eval { $oldDriver = WebGUI::Shop::ShipDriver->new($session, $brokenDriver->getId); };
$e = Exception::Class->caught();
isa_ok($e, 'WebGUI::Error::InvalidParam', 'new croaks if the options column in the db is empty string');
cmp_deeply(
    $e,
    methods(
        error => re('Options property for \S{22} was broken in the db'),
        param => '',
    ),
    'new croaks if the options column in the db is empty string',
);


#######################################################################
#
# calculate
#
#######################################################################

eval { $driver->calculate; };
like ($@, qr/^You must override the calculate method/, 'calculate croaks to force overriding it in the child classes');

#######################################################################
#
# set
#
#######################################################################

eval { $driver->set(); };
$e = Exception::Class->caught();
isa_ok($e, 'WebGUI::Error::InvalidParam', 'set takes exception to not giving it a hashref of options');
cmp_deeply(
    $e,
    methods(
        error => 'set was not sent a hashref of options to store in the database',
    ),
    'set takes exception to not giving it a hashref of options',
);

#######################################################################
#
# delete
#
#######################################################################

#$driver->delete;
#
#my $count = $session->db->quickScalar('select count(*) from shipper where shipperId=?',[$driver->shipperId]);
#is($count, 0, 'delete deleted the object');
#
#undef $driver;


}

#----------------------------------------------------------------------------
# Cleanup
END {
    #$session->db->write('delete from shipper');
}
