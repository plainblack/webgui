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

use strict;
use Test::More;
use Test::Deep;
use WebGUI::Test; # Must use this before any other WebGUI modules
use WebGUI::Session;
use JSON;
use HTML::Form;
use WebGUI::Shop::PayDriver::Ogone;

#----------------------------------------------------------------------------
# Init
my $session         = WebGUI::Test->session;


#----------------------------------------------------------------------------
# Tests

plan tests => 12;

#----------------------------------------------------------------------------
# figure out if the test can actually run

my $e;

#######################################################################
#
# new
#
#######################################################################

my $driver;

# Test incorrect for parameters

my $options = {
    label           => 'Fast and harmless',
    enabled         => 1,
    groupToUse      => 3,
    currency        => 'EUR',
};

$driver = WebGUI::Shop::PayDriver::Ogone->new( $session, $options );
WebGUI::Test->addToCleanup($driver);
$driver->write;

isa_ok  ($driver, 'WebGUI::Shop::PayDriver::Ogone', 'new creates WebGUI::Shop::PayDriver object');
like($driver->getId, $session->id->getValidator, 'driver id is a valid GUID');

my $dbData = $session->db->quickHashRef('select * from paymentGateway where paymentGatewayId=?', [ $driver->getId ]);

cmp_deeply  (
    $dbData,
    {
        paymentGatewayId    => $driver->getId,
        className           => ref $driver,
        options             => ignore()
    },
    'Correct data written to the db',
);
my $paymentGatewayOptions = from_json($dbData->{'options'});
cmp_deeply (
    $paymentGatewayOptions,
    {
        groupToUse        => 3,
        label             => 'Fast and harmless',
        enabled           => 1,
        currency          => 'EUR',
        pspid             => '',
        summaryTemplateId => 'jysVZeUR0Bx2NfrKs5sulg',
        useTestMode       => 1,
        locale            => 'en_US',
        shaSecret         => undef,
        postbackSecret    => undef,
    },
    'Correct options are written to the db'

);

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

is (WebGUI::Shop::PayDriver::Ogone->getName($session), 'Ogone', 'getName returns the human readable name of this driver');

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

isa_ok      ($form, 'WebGUI::FormBuilder', 'getEditForm returns an HTMLForm object');

my $html = $form->toHtml;

##Any URL is fine, really
my @forms = HTML::Form->parse($html, 'http://www.webgui.org');
is          (scalar @forms, 1, 'getEditForm generates just 1 form');

my @inputs = $forms[0]->inputs;
is          (scalar @inputs, 17, 'getEditForm: the form has 18 controls');

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
            name    => 'send',
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
        {
            name    => 'pspid',
            type    => 'text',
        },
        {
            name    => 'shaSecret',
            type    => 'password',
        },
        {
            name    => 'postbackSecret',
            type    => 'password',
        },
        {
            name    => 'locale',
            type    => 'text',
        },
        {
            name    => 'currency',
            type    => 'text',
        },
        {
            name    => 'useTestMode',
            type    => 'radio',
        },
        {
            name    => 'summaryTemplateId',
            type    => 'option',
        },
    ],
    'getEditForm made the correct form with all the elements'

);

#vim:ft=perl
