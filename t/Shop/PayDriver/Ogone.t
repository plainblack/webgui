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

plan tests => 45;

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

# Test functionality
my $signature = '-----BEGIN PKCS7-----
MIIHPwYJKoZIhvcNAQcEoIIHMDCCBywCAQExggE0MIIB
MAIBADCBmDCBkjELMAkGA1UEBhMCVVMxCzAJBgNVBAgT
AkNBMRYwFAYDVQQHEw1Nb3VudGFpbiBWaWV3MRQwEgYD
VQQKEwtQYXlQYWwgSW5jLjEVMBMGA1UECxQMc3RhZ2Ux
X2NlcnRzMRMwEQYDVQQDFApzdGFnZTFfYXBpMRwwGgYJ
KoZIhvcNAQkBFg1yZUBwYXlwYWwuY29tAgEAMA0GCSqG
SIb3DQEBAQUABIGAiJLqJ8905lNbvKoa715KsOJtSOGy
4d6fEKV7+S8KU8E/RK0SFmMgGPRpmXdzx9MXCU43/tXj
lyuyOeZQUBaAIaWoNpfZmBUYIvJVh4W+bDH6JUkugelp
CaTjxXOx/F1qj79D9z06AK+N3yW1fM41fM7X9Q1Bc12g
THjJUKXcIIcxCzAJBgUrDgMCGgUAMIGkBgkqhkiG9w0B
BwEwFAYIKoZIhvcNAwcECOsHG9QOvcJFgIGAwmbN5Acd
cnCH0ZTnsSOq5GtXeQf0j2jCBCg6y7b4ZXQwgdqUC/7x
eb0yicuiRVuRB9WLr/0rGFuSYENpKVUqWYjnlg3TsxLP
IxDCp6lfFqsrclppyZ9CP+xim7y0qKqZZufJG8HgCHxk
3BPD6LqByjQjDVpqKKmCNJ1HlwXGN+SgggOWMIIDkjCC
AvugAwIBAgIBADANBgkqhkiG9w0BAQQFADCBkzELMAkG
A1UEBhMCVVMxCzAJBgNVBAgTAkNBMREwDwYDVQQHEwhT
YW4gSm9zZTEPMA0GA1UEChMGUGF5UGFsMRwwGgYDVQQL
ExNTeXN0ZW1zIEVuZ2luZWVyaW5nMRMwEQYDVQQDEwpT
b3V2aWsgRGFzMSAwHgYJKoZIhvcNAQkBFhFzb3VkYXNA
cGF5cGFsLmNvbTAeFw0wNDA1MjExODE4NTBaFw0wNDA2
MjAxODE4NTBaMIGTMQswCQYDVQQGEwJVUzELMAkGA1UE
CBMCQ0ExETAPBgNVBAcTCFNhbiBKb3NlMQ8wDQYDVQQK
EwZQYXlQYWwxHDAaBgNVBAsTE1N5c3RlbXMgRW5naW5l
ZXJpbmcxEzARBgNVBAMTClNvdXZpayBEYXMxIDAeBgkq
hkiG9w0BCQEWEXNvdWRhc0BwYXlwYWwuY29tMIGfMA0G
CSqGSIb3DQEBAQUAA4GNADCBiQKBgQDatyhVzmVe+kCN
tOSNS+c7p9pNHlFGbGtIWgIAKSOVlaTk4JD/UAvQzYnn
eWPUk+Xb5ShTx8YRDEtRtecy/PwSIIrtS2sC8RrmjZxU
uNRqPB6y1ahGwGcNd/wOIy3FekGE/ctX7oG6/Voz/E2Z
EyJaPm7KwYiDQYz7kWJ6eB+kDwIDAQABo4HzMIHwMB0G
A1UdDgQWBBQx23WZRMmnADSXDr+P7uxORBdDuzCBwAYD
VR0jBIG4MIG1gBQx23WZRMmnADSXDr+P7uxORBdDu6GB
maSBljCBkzELMAkGA1UEBhMCVVMxCzAJBgNVBAgTAkNB
MREwDwYDVQQHEwhTYW4gSm9zZTEPMA0GA1UEChMGUGF5
UGFsMRwwGgYDVQQLExNTeXN0ZW1zIEVuZ2luZWVyaW5n
MRMwEQYDVQQDEwpTb3V2aWsgRGFzMSAwHgYJKoZIhvcN
AQkBFhFzb3VkYXNAcGF5cGFsLmNvbYIBADAMBgNVHRME
BTADAQH/MA0GCSqGSIb3DQEBBAUAA4GBAIBlMsXVnxYe
ZtVTG3rsVYePdkMs+0WdRd+prTK4ZBcAkCyNk9jCq5dy
VziCi4ZCleMqR5Y0NH1+BQAf8vxxcb4Z7p0rryXGb96f
ZfkSYd99a4qGKW3aSIsc2kpaC/ezQg8vuD6JSo6VhJIb
Zn0oWajvkHNMENOwN/Ym5stvAxtnMYIBnzCCAZsCAQEw
gZkwgZMxCzAJBgNVBAYTAlVTMQswCQYDVQQIEwJDQTER
MA8GA1UEBxMIU2FuIEpvc2UxDzANBgNVBAoTBlBheVBh
bDEcMBoGA1UECxMTU3lzdGVtcyBFbmdpbmVlcmluZzET
MBEGA1UEAxMKU291dmlrIERhczEgMB4GCSqGSIb3DQEJ
ARYRc291ZGFzQHBheXBhbC5jb20CAQAwCQYFKw4DAhoF
AKBdMBgGCSqGSIb3DQEJAzELBgkqhkiG9w0BBwEwHAYJ
KoZIhvcNAQkFMQ8XDTA0MDUyNjE5MTgxNFowIwYJKoZI
hvcNAQkEMRYEFI2w1oe5qvHYB0w9Z/ntkRcDqLlhMA0G
CSqGSIb3DQEBAQUABIGAimA3r6ZXmyynFGF5cOj6E1Hq
Ebtelq2tg4HroAHZLWoQ3kc/7IM0LCuWZmgtD5739NSS
0+tOFSdH68sxKsdooR3MFTbdzWhtej5fPKRa6BfHGPjI
9R9NoAQBmaeUuOiPSeVTzXDOKDbZB0sJtmWNeueTD9D0
BOu+vkC1g+HRToc=
-----END PKCS7-----';

my $options = {
    label           => 'Fast and harmless',
    enabled         => 1,
    groupToUse      => 3,
    vendorId        => 'oqapi',
    signature       => $signature,
    currency        => 'EUR',
    useSandbox      => '0',
    emailMessage    => 'Thank you very very much'
};

$driver = WebGUI::Shop::PayDriver::Ogone->new( $session, $options );
WebGUI::Test->addToCleanup($driver);

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
        "groupToUse"        => 3,
        "label"             => 'Fast and harmless',
        "enabled"           => 1,
        "vendorId"          => 'oqapi',
        "signature"         => $signature,
        "currency"          => 'EUR',
        "useSandbox"        => '0',
        "emailMessage"      => 'Thank you very very much'
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
WebGUI::Test->addToCleanup($cart);

#######################################################################
#
# getEditForm
#
#######################################################################

my $form = $driver->getEditForm;

isa_ok      ($form, 'WebGUI::HTMLForm', 'getEditForm returns an HTMLForm object');

my $html = $form->print;

##Any URL is fine, really
my @forms = HTML::Form->parse($html, 'http://www.webgui.org');
is          (scalar @forms, 1, 'getEditForm generates just 1 form');

my @inputs = $forms[0]->inputs;
is          (scalar @inputs, 18, 'getEditForm: the form has 18 controls');

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
            name    => 'webguiCsrfToken',
            type    => 'hidden',
        },
        {
            name    => undef,
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
