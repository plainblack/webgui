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

# Tests the transaction backend for the shop.
# 
#

use FindBin;
use strict;
use lib "$FindBin::Bin/../lib";
use Test::More;
use Test::Deep;
use WebGUI::Test; # Must use this before any other WebGUI modules
use WebGUI::Test::MockAsset;
use WebGUI::Session;
use WebGUI::Shop::Transaction;
use WebGUI::Inbox;
use Clone qw/clone/;

#----------------------------------------------------------------------------
# Init
my $session         = WebGUI::Test->session;


#----------------------------------------------------------------------------
# Tests

plan tests => 77;        # Increment this number for each test you create

#----------------------------------------------------------------------------
# put your tests here

my $transaction = WebGUI::Shop::Transaction->create($session,{
    amount              => 40,
    shippingAddressId   => 'xxx1',
    shippingAddressName => 'abc',
    shippingAddress1    => 'def',
    shippingAddress2    => 'hij',
    shippingAddress3    => 'lmn',
    shippingCity        => 'opq',
    shippingState       => 'wxy',
    shippingCountry     => 'z',
    shippingCode        => '53333',
    shippingPhoneNumber => '123456',
    shippingDriverId    => 'xxx2',
    shippingDriverLabel => 'foo',
    shippingPrice       => 5,
    paymentAddressId    => 'xxx3',
    paymentAddressName  => 'abc1',
    paymentAddress1     => 'def1',
    paymentAddress2     => 'hij1',
    paymentAddress3     => 'lmn1',
    paymentCity         => 'opq1',
    paymentState        => 'wxy1',
    paymentCountry      => 'z1',
    paymentCode         => '66666',
    paymentPhoneNumber  => '908765',
    paymentDriverId     => 'xxx4',
    paymentDriverLabel  => 'kkk',
    taxes               => 7,
    });
addToCleanup($transaction);

# objects work
isa_ok($transaction, "WebGUI::Shop::Transaction");
isa_ok($transaction->session, "WebGUI::Session");


# basic transaction properties
is($transaction->get("amount"), 40, "set and get amount");
is($transaction->get("shippingAddressId"), 'xxx1', "set and get shipping address id");
is($transaction->get("shippingAddressName"), 'abc', "set and get shipping address name");
is($transaction->get("shippingAddress1"), 'def', "set and get shipping address 1");
is($transaction->get("shippingAddress2"), 'hij', "set and get shipping address 2");
is($transaction->get("shippingAddress3"), 'lmn', "set and get shipping address 3");
is($transaction->get("shippingCity"), 'opq', "set and get shipping city");
is($transaction->get("shippingState"), 'wxy', "set and get shipping state");
is($transaction->get("shippingCountry"), 'z', "set and get shipping country");
is($transaction->get("shippingCode"), '53333', "set and get shipping code");
is($transaction->get("shippingPhoneNumber"), '123456', "set and get shipping phone number");
is($transaction->get("shippingDriverId"), 'xxx2', "set and get shipping driver id");
is($transaction->get("shippingDriverLabel"), 'foo', "set and get shipping driver label");
is($transaction->get("shippingPrice"), 5, "set and get shipping price");
is($transaction->get("paymentAddressId"), 'xxx3', "set and get payment address id");
is($transaction->get("paymentAddressName"), 'abc1', "set and get payment address name");
is($transaction->get("paymentAddress1"), 'def1', "set and get payment address 1");
is($transaction->get("paymentAddress2"), 'hij1', "set and get payment address 2");
is($transaction->get("paymentAddress3"), 'lmn1', "set and get payment address 3");
is($transaction->get("paymentCity"), 'opq1', "set and get payment city");
is($transaction->get("paymentState"), 'wxy1', "set and get payment state");
is($transaction->get("paymentCountry"), 'z1', "set and get payment country");
is($transaction->get("paymentCode"), '66666', "set and get payment code");
is($transaction->get("paymentPhoneNumber"), '908765', "set and get payment phone number");
is($transaction->get("paymentDriverId"), 'xxx4', "set and get payment driver id");
is($transaction->get("paymentDriverLabel"), 'kkk', "set and get payment driver label");
is($transaction->get("taxes"), 7, "set and get taxes");


$transaction->update({
    isSuccessful        => 1,
    transactionCode     => 'yyy',
    statusCode          => 'jd31',
    statusMessage       => 'was a success',
});
 
is($transaction->get("isSuccessful"), 1,"update and get isSuccessful");
is($transaction->get("transactionCode"), 'yyy',"update and get transaction code");
is($transaction->get("statusCode"), 'jd31',"update and get status code");
is($transaction->get("statusMessage"), 'was a success',"update and get status message");
is($transaction->get('taxes'), 7, 'update does not modify things it was not sent');

# make sure new() works
my $tcopy = WebGUI::Shop::Transaction->new($session, $transaction->getId);

isa_ok($tcopy, "WebGUI::Shop::Transaction");
is($tcopy->getId, $transaction->getId, "is it the same object");


# basic item properties
my $item = $transaction->addItem({
    assetId                 => 'a',
    configuredTitle         => 'b',
    options                 => {color=>'blue'},
    shippingAddressId       => 'c',
    shippingName            => 'd',
    shippingAddress1        => 'e',
    shippingAddress2        => 'f',
    shippingAddress3        => 'g',
    shippingCity            => 'h',
    shippingState           => 'i',
    shippingCountry         => 'j',
    shippingCode            => 'k',
    shippingPhoneNumber     => 'l',
    quantity                => 5,
    price                   => 33, 
    taxRate                 => 19,
});

isa_ok($item, "WebGUI::Shop::TransactionItem");
isa_ok($item->transaction, "WebGUI::Shop::Transaction");

is($item->get("assetId"), 'a', "set and get asset id");
is($item->get("configuredTitle"), 'b', "set and get configured title");
cmp_deeply($item->get("options"), {color=>'blue'}, "set and get options");
is($item->get("shippingAddressId"), 'c', "set and get shipping address id");
is($item->get("shippingName"), 'd', "set and get shipping name");
is($item->get("shippingAddress1"), 'e', "set and get shipping address 1");
is($item->get("shippingAddress2"), 'f', "set and get shipping address 2");
is($item->get("shippingAddress3"), 'g', "set and get shipping address 3");
is($item->get("shippingCity"), 'h', "set and get shipping city");
is($item->get("shippingState"), 'i', "set and get shipping state");
is($item->get("shippingCountry"), 'j', "set and get shipping country");
is($item->get("shippingCode"), 'k', "set and get shipping code");
is($item->get("shippingPhoneNumber"), 'l', "set and get shipping phone number");
is($item->get("quantity"), 5, "set and get quantity");
is($item->get("price"), 33,  "set and get price");
is($item->get('taxRate'), 19, 'set and get taxRate' );

$item->update({
    shippingTrackingNumber  => 'adfs',
    orderStatus          => 'BackOrdered',
});

is($item->get("shippingTrackingNumber"), 'adfs', "update and get shipping tracking number");
is($item->get("orderStatus"), 'BackOrdered', "update and get shipping status");

# make sure new() works
my $icopy = $transaction->getItem($item->getId);
isa_ok($icopy, "WebGUI::Shop::TransactionItem");
is($icopy->getId, $item->getId, "items are the same");

# get items
is(scalar @{$transaction->getItems}, 1, "can retrieve items");

# delete
$item->delete;
is(scalar @{$transaction->getItems}, 0, "can delete items");

#######################################################################
#
# www_getTransactionsAsJson
#
#######################################################################

$session->user({userId=>3});
my $json = WebGUI::Shop::Transaction->www_getTransactionsAsJson($session);
ok($json, 'www_getTransactionsAsJson returned something');
is($session->http->getMimeType, 'application/json', 'MIME type set to application/json');
my $jsonTransactions = JSON::from_json($json);
cmp_deeply(
    $jsonTransactions,
    {
        sort            => undef,
        startIndex      => 0,
        totalRecords    => 1,
        recordsReturned => 1,
        dir             => 'desc',
        records         => array_each({
            orderNumber=>ignore,
            transactionId=>ignore,
            transactionCode=>ignore,
            paymentDriverLabel=>ignore,
            dateOfPurchase=>ignore,
            username=>ignore,
            amount=>ignore,
            isSuccessful=>ignore,
            statusCode=>ignore,
            statusMessage=>ignore,
        }),
    },
    'Check major elements of transaction JSON',
);

TODO: {
    local $TODO = 'More getTransactionsAsJson tests';
    ok(0, 'test group privileges to this method');
    ok(0, 'test startIndex variable');
    ok(0, 'test results form variable');
    ok(0, 'test keywords');
}

#######################################################################
#
# sendNotification
#
#######################################################################

my $shopUser   = WebGUI::User->create($session);
$shopUser->username('shopUser');
my $shopGroup  = WebGUI::Group->new($session, 'new');
my $shopAdmin  = WebGUI::User->create($session);
$shopUser->username('shopAdmin');
$shopGroup->addUsers([$shopAdmin->getId]);
addToCleanup($shopUser, $shopAdmin, $shopGroup);
$session->setting->set('shopSaleNotificationGroupId', $shopGroup->getId);
$session->user({userId => $shopUser->getId});

my $trans = WebGUI::Shop::Transaction->create($session, {});
ok($trans->can('sendNotifications'), 'sendNotifications: valid method for transactions');
addToCleanup($trans);

##Disable sending email
my $sendmock = Test::MockObject->new( {} );
$sendmock->set_isa('WebGUI::Mail::Send');
$sendmock->set_true('addText', 'send', 'addHeaderField', 'addHtml', 'queue', 'addFooter');
local *WebGUI::Mail::Send::create;
$sendmock->fake_module('WebGUI::Mail::Send',
    create => sub { return $sendmock },
);

                 #1234567890123456789012#
my $templateId = 'SHOP_NOTIFICATION_____';

my $templateMock = WebGUI::Test::MockAsset->new('WebGUI::Asset::Template');
$templateMock->mock_id($templateId);
my @templateVars;
$templateMock->mock('process', sub { push @templateVars, clone $_[1]; } );

$session->setting->set('shopReceiptEmailTemplateId', $templateId);

{
    $trans->sendNotifications;
    is(@templateVars, 2, '... called template->process twice');
    my $inbox = WebGUI::Inbox->new($session);
    my $userMessages  = $inbox->getMessagesForUser($shopUser);
    my $adminMessages = $inbox->getMessagesForUser($shopAdmin);
    is(@{ $userMessages },  1, '... sent one message to shop user');
    is(@{ $adminMessages }, 1, '... sent one message to shop admin, via shopSaleNotificationGroupId');
    like($userMessages->[0]->get('subject'),  qr/^Receipt for Order #/,  '... subject for user email okay');
    like($adminMessages->[0]->get('subject'), qr/^A sale has been made/, '... subject for admin email okay');
    like($templateVars[0]->{viewDetailUrl}, qr/shop=transaction;method=viewMy;/, '... viewDetailUrl okay for user');
    like($templateVars[1]->{viewDetailUrl}, qr/shop=transaction;method=view;/  , '... viewDetailUrl okay for admin');
}

#######################################################################
#
# delete
#
#######################################################################

$transaction->delete;
is($session->db->quickScalar("select count(*) from transaction     where transactionId=?",[$transaction->getId]),
   0, "delete: deleted transaction");
is($session->db->quickScalar("select count(*) from transactionItem where transactionId=?",[$transaction->getId]),
   0, "... deleted transactionItems associated with this transaction");


