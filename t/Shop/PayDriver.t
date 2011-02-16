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
use Data::Dumper;
use JSON;
use HTML::Form;

use WebGUI::Test; # Must use this before any other WebGUI modules
use WebGUI::Session;
use WebGUI::Shop::Cart;
use WebGUI::Shop::Credit;
use WebGUI::Shop::PayDriver;
use Clone;
use WebGUI::User;
use WebGUI::Test::Mechanize;

#----------------------------------------------------------------------------
# Init
my $session = WebGUI::Test->session;

my $e;

#######################################################################
#
# create
#
#######################################################################

my $driver;

# Test incorrect for parameters

eval { $driver = WebGUI::Shop::PayDriver->new(); };
$e = Exception::Class->caught();
isa_ok      ($e, 'WebGUI::Error::InvalidParam', 'new takes exception to not giving it a session object');
cmp_deeply  (
    $e,
    methods(
        error => 'Must provide a session variable',
    ),
    'new takes exception to not giving it a session object',
);

# Test functionality

my $options = {
    label           => 'Fast and harmless',
    enabled         => 1,
    groupToUse      => 3,
};

$driver = WebGUI::Shop::PayDriver->new( $session, Clone::clone($options) );

isa_ok  ($driver, 'WebGUI::Shop::PayDriver', 'new creates WebGUI::Shop::PayDriver object');
like($driver->getId, $session->id->getValidator, 'driver id is a valid GUID');

$driver->write;
my $dbData = $session->db->quickHashRef('select * from paymentGateway where paymentGatewayId=?', [ $driver->getId ]);

cmp_deeply  (
    $dbData,
    {
        paymentGatewayId    => $driver->getId,
        className           => ref $driver,
        options             => q|{"groupToUse":3,"label":"Fast and harmless","enabled":1}|,
    },
    'Correct data written to the db',
);



#######################################################################
#
# session
#
#######################################################################

isa_ok      ($driver->session,  'WebGUI::Session',          'session method returns a session object');
is          ($session->getId,   $driver->session->getId,    'session method returns OUR session object');

#######################################################################
#
# paymentGatewayId, getId
#
#######################################################################

like        ($driver->paymentGatewayId, $session->id->getValidator, 'got a valid GUID for paymentGatewayId');
is          ($driver->getId,            $driver->paymentGatewayId,  'getId returns the same thing as paymentGatewayId');

#######################################################################
#
# className
#
#######################################################################

is          ($driver->className, ref $driver, 'className property set correctly');

#######################################################################
#
# getName
#
#######################################################################

eval { WebGUI::Shop::PayDriver->getName(); };
$e = Exception::Class->caught();
isa_ok      ($e, 'WebGUI::Error::InvalidParam', 'getName requires a session object passed to it');
cmp_deeply  (
    $e,
    methods(
        error => 'Must provide a session variable',
    ),
    'getName requires a session object passed to it',
);

is (WebGUI::Shop::PayDriver->getName($session), 'Payment Driver', 'getName returns the human readable name of this driver');

#######################################################################
#
# method checks
#
#######################################################################

can_ok $driver, qw/get set update write getName className label enabled paymentGatewayId groupToUse/;

#######################################################################
#
# default label
#
#######################################################################

$driver->label('');
is $driver->label, $driver->getName($session), 'empty label replaced with plugin name';
$driver->label('untitled');
is $driver->label, $driver->getName($session), 'label=untitled replaced with plugin name';
$driver->label('uNtItLeD');
is $driver->label, $driver->getName($session), '...regardless of case';
$driver->label('Fast and harmless');

#######################################################################
#
# get
#
#######################################################################

use Data::Dumper;

cmp_deeply(
    $driver->get,
    {
        %{ $options },
        paymentGatewayId => ignore(),
    },
    'get works like the options method with no param passed'
);
is          ($driver->get('label'), 'Fast and harmless', 'get the label entry from the options');

my $optionsCopy = $driver->get;
$optionsCopy->{label} = 'And now for something completely different';
isnt(
    $driver->get('label'),
    'And now for something completely different', 
    'hashref returned by get() is a copy of the internal hashref'
);

#######################################################################
#
# getCart
#
#######################################################################

my $cart = $driver->getCart;
WebGUI::Test->addToCleanup($cart);
isa_ok      ($cart, 'WebGUI::Shop::Cart', 'getCart returns an instantiated WebGUI::Shop::Cart object');

#######################################################################
#
# getEditForm
#
#######################################################################

my $form = $driver->getEditForm;

isa_ok      ($form, 'WebGUI::FormBuilder', 'getEditForm returns an FormBuilder object');

my $html = $form->toHtml;

##Any URL is fine, really
my @forms = HTML::Form->parse($html, 'http://www.webgui.org');
is          (scalar @forms, 1, 'getEditForm generates just 1 form');

my @inputs = $forms[0]->inputs;
is          (scalar @inputs, 10, 'getEditForm: the form has 10 controls');

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
            name    => 'submit',
            type    => 'submit',
        },
        {
            name    => 'shop',
            type    => 'hidden',
        },
        {
            name    => 'method',
            type    => 'hidden',
        },
        {
            name    => 'do',
            type    => 'hidden',
        },
        {
            name    => 'paymentGatewayId',
            type    => 'hidden',
        },
        {
            name    => 'className',
            type    => 'hidden',
        },
        {
            name    => 'label',
            type    => 'text',
        },
        {
            name    => 'enabled',
            type    => 'radio',
        },
        {
            name    => 'groupToUse',
            type    => 'option',
        },
        {
            name    => '__groupToUse_isIn',
            type    => 'hidden',
        },
    ],
    'getEditForm made the correct form with all the elements'

);

# Try to add a new PayDriver
my $mech = WebGUI::Test::Mechanize->new( config => WebGUI::Test->file );
$mech->get_ok( '/' );
$mech->session->user({userId => 3});

# Get to the management screen
$mech->get_ok( '?shop=pay;method=manage' );

# Click the Add Payment button
$mech->form_with_fields( 'className', 'add' );
$mech->select( 'className' => 'WebGUI::Shop::PayDriver::Cash' );
$mech->click_ok( 'add' );

# Fill in the form
$mech->submit_form_ok({
        fields => {
            label => 'Authority Scrip',
            enabled => '1',
        },
    },
    "add a new gateway",
);

# Payment method added!
$mech->content_contains( 'Authority Scrip', 'new label shows up in manage screen' );

# Find our new payment gateway
my $paydriverId;
for my $row ( @{ $session->db->buildArrayRefOfHashRefs( 'SELECT * FROM paymentGateway' ) } ) {
    my $options = JSON->new->decode( $row->{options} );
    if ( $options->{label} eq 'Authority Scrip' ) {
        $paydriverId = $row->{paymentGatewayId};
    }
}
ok( my $paydriver = WebGUI::Shop::PayDriver->new( $mech->session, $paydriverId ), 'paydriver can be instanced' );
WebGUI::Test::addToCleanup( $paydriver );
is( $paydriver->label, 'Authority Scrip', 'label set correctly' );
ok( $paydriver->enabled, 'driver is enabled' );

# Edit an existing PayDriver
# Find the right form and click the Edit button
my $formNumber = 1;
for my $form ( $mech->forms ) {
    if ( $form->value( 'do' ) eq 'edit' && $form->value( 'paymentGatewayId' ) eq $paydriverId ) {
        last;
    }
    $formNumber++;
}
$mech->submit_form_ok({
        form_number => $formNumber,
    }, 'click edit button',
);

# Fill in the form
$mech->submit_form_ok({
        fields => {
            label   => 'Free Luna Dollars',
            enabled => 1,
        },
    },
    "edit an existing method",
);

# Payment method edited!
$mech->content_contains( 'Free Luna Dollars', 'new label shows up in manage screen' );
diag( $mech->content );
ok( my $paydriver = WebGUI::Shop::PayDriver->new( $mech->session, $paydriverId ), 'paydriver can be instanced' );
is( $paydriver->label, 'Free Luna Dollars', 'label set correctly' );
ok( $paydriver->enabled, 'driver is enabled' );

#######################################################################
#
# new
#
#######################################################################

my $oldDriver;

eval { $oldDriver = WebGUI::Shop::PayDriver->new(); };
$e = Exception::Class->caught();
isa_ok      ($e, 'WebGUI::Error::InvalidParam', 'new takes exception to not giving it a session object');
cmp_deeply  (
    $e,
    methods(
        error => 'Must provide a session variable',
    ),
    'new takes exception to not giving it a session object',
);

eval { $oldDriver = WebGUI::Shop::PayDriver->new($session); };
$e = Exception::Class->caught();
isa_ok      ($e, 'WebGUI::Error::InvalidParam', 'new takes exception to not giving it a paymentGatewayId');
cmp_deeply  (
    $e,
    methods(
        error => 'Must provide a paymentGatewayId',
    ),
    'new takes exception to not giving it a paymentGatewayId',
);

eval { $oldDriver = WebGUI::Shop::PayDriver->new($session, 'notEverAnId'); };
$e = Exception::Class->caught();
isa_ok      ($e, 'WebGUI::Error::ObjectNotFound', 'new croaks unless the requested paymentGatewayId object exists in the db');
cmp_deeply  (
    $e,
    methods(
        error => 'paymentGatewayId not found in db',
        id    => 'notEverAnId',
    ),
    'new croaks unless the requested paymentGatewayId object exists in the db',
);

my $driverCopy = WebGUI::Shop::PayDriver->new($session, $driver->getId);

is          ($driver->getId,           $driverCopy->getId,     'same id');
is          ($driver->className,       $driverCopy->className, 'same className');
cmp_deeply  ($driver->get,             $driverCopy->get,       'same properties');

TODO: {
    local $TODO = 'tests for new';
    ok(0, 'Test broken options in the db');
}

#######################################################################
#
# update, get
#
#######################################################################

my $newOptions = {
    label           => 'Yet another label',
    enabled         => 0,
    groupToUse      => 4,
};

$driver->update($newOptions);
my $storedJson = $session->db->quickScalar('select options from paymentGateway where paymentGatewayId=?', [
    $driver->getId,
]);
cmp_deeply(
    $newOptions,
    from_json($storedJson),
    'update() actually stores data',
);

is( $driver->get('groupToUse'),     4,          '... updates object, group');
is( $driver->get('enabled'),        0,          '... updates object, enabled');
is( $driver->get('label'),          'Yet another label', '... updates object, label');

$newOptions->{label} = 'Safe reference';
is( $driver->get('label'),          'Yet another label', '... safe reference check');

my $storedOptions = $driver->get();
$storedOptions->{label} = 'Safe reference';
is( $driver->get('label'),          'Yet another label', 'get: safe reference check');

#######################################################################
#
# canUse
#
#######################################################################
$options = $driver->get();
$options->{enabled} = 1;
$driver->update($options);

$session->user({userId => 3});
ok( $driver->canUse, 'canUse: session->user is used if no argument is passed');
ok(!$driver->canUse({userId => 1}), 'canUse: userId explicit works, visitor cannot use this driver');

$options = $driver->get();
$options->{enabled} = 0;
$driver->update($options);
ok( !$driver->get('enabled'), 'driver is disabled');
ok( !$driver->canUse({userId => 3}), '... driver cannot be used');

TODO: {
    local $TODO = 'tests for canUse';
    ok(0, 'Test other users and groups');
}

#######################################################################
#
# appendCartVariables
#
#######################################################################

my $node    = WebGUI::Test->asset;
my $widget  = $node->addChild({
    className          => 'WebGUI::Asset::Sku::Product',
    title              => 'Test product for cart template variables in the Product',
    isShippingRequired => 1,
});
my $blue_widget  = $widget->setCollateral('variantsJSON', 'variantId', 'new',
    {
        shortdesc => 'Blue widget',   price     => 5.00,
        varSku    => 'blue-widget',  weight    => 1.0,
        quantity  => 9999,
    }
);

my $credited_user = WebGUI::User->create($session);
$session->user({user => $credited_user});

my $cart = WebGUI::Shop::Cart->newBySession($session);
WebGUI::Test->addToCleanup($cart, $credited_user);
my $addressBook = $cart->getAddressBook;
my $workAddress = $addressBook->addAddress({
    label => 'work',
    organization => 'Plain Black Corporation',
    address1 => '1360 Regent St. #145',
    city => 'Madison', state => 'WI', code => '53715',
    country => 'United States',
});
$cart->update({
    billingAddressId  => $workAddress->getId,
    shippingAddressId => $workAddress->getId,
});

$widget->addToCart($widget->getCollateral('variantsJSON', 'variantId', $blue_widget));

my $cart_variables = {};
$driver->appendCartVariables($cart_variables);

cmp_deeply(
    $cart_variables,
    {
        taxes                 => ignore(),
        shippableItemsInCart  => 1,
        totalPrice            => '5.00',
        inShopCreditDeduction => ignore(),
        inShopCreditAvailable => ignore(),
        subtotal              => '5.00',
        shipping              => ignore(),

    },
    'appendCartVariables: checking shippableItemsInCart and totalPrice & subtotal formatting'
);

my $credit = WebGUI::Shop::Credit->new($session, $credited_user->userId);
$credit->adjust('1', 'credit for testing');
$cart_variables = {};
$driver->appendCartVariables($cart_variables);
cmp_deeply(
    $cart_variables,
    {
        taxes                 => ignore(),
        shippableItemsInCart  => 1,
        subtotal              => '5.00',
        inShopCreditDeduction => '-1.00',
        inShopCreditAvailable => '1.00',
        totalPrice            => '4.00',
        shipping              => ignore(),

    },
    '... checking credit display'
);


#######################################################################
#
# delete
#
#######################################################################

$driver->delete;

my $count = $session->db->quickScalar('select count(*) from paymentGateway where paymentGatewayId=?', [
    $driver->paymentGatewayId
]);

is ($count, 0, 'delete deleted the object');

undef $driver;

#######################################################################
#
# processPropertiesFromFormPost
#
#######################################################################

$session->request->setup_body({
    label      => 'form processed driver',
    enabled    => 1,
    groupToUse => 7,
});

my $form_driver = WebGUI::Shop::PayDriver->new($session, {});
WebGUI::Test->addToCleanup($form_driver);

$form_driver->processPropertiesFromFormPost;

cmp_deeply(
    $form_driver->get(),
    {
        label            => 'form processed driver',
        enabled          => 1,
        groupToUse       => 7,
        paymentGatewayId => $form_driver->paymentGatewayId,
    },
    'form contents processed.  Missing form properties inherit defaults'
);

done_testing;
