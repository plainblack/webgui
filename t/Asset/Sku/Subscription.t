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
# This tests WebGUI::Asset::Sku::Donation

use strict;
use Test::More;
use Test::Deep;
use WebGUI::Test; # Must use this before any other WebGUI modules
use WebGUI::Test::Mechanize;
use WebGUI::Session;
use WebGUI::Asset;
use WebGUI::Asset::Sku::Subscription;

#----------------------------------------------------------------------------
# Init
my $session         = WebGUI::Test->session;

my $group = WebGUI::Group->new($session, 'new');
WebGUI::Test->addToCleanup($group);
my $user  = WebGUI::User->create($session);
WebGUI::Test->addToCleanup($user);


#----------------------------------------------------------------------------
# Tests

plan tests => 16;        # Increment this number for each test you create

#----------------------------------------------------------------------------
# put your tests here
my $sku = WebGUI::Test->asset(
        className => "WebGUI::Asset::Sku::Subscription",
        title     => "Test Subscription",
        price     => 50.00,
        recurringSubscription => 0,
        subscriptionGroup     => $group->getId,
        duration              => 'Monthly',
        );
isa_ok($sku, "WebGUI::Asset::Sku::Subscription");

is($sku->getPrice, 50.00, "Price should be 50.00");

$sku->apply($user->userId);

cmp_deeply(
    $group->userGroupExpireDate($user->getId)-time(),
    num($sku->getExpirationOffset, 5),
    "apply: sets user's group expiration offset correctly"
);

$sku->apply($user->userId);

cmp_deeply(
    $group->userGroupExpireDate($user->getId)-time(),
    num(2*$sku->getExpirationOffset, 10),
    "... increments user's expiration offset when the subscription is non-recurring and they are already a group member"
);

#----------------------------------------------------------------------------
# www_createSubscriptionBatch
my $mech = WebGUI::Test::Mechanize->new( config => WebGUI::Test->file );
$mech->get_ok( '/' );
$mech->session->user({ userId => 3 });
$mech->get_ok( $sku->getUrl( 'func=createSubscriptionCodeBatch' ) );
$mech->submit_form_ok( {
    fields => {
        noc => 2,
        codeLength => 20,
        expires => 60 * 60 * 24 * 14, # 14 days
        name => "Paycheck",
        description => "Sign up to get your paycheck!",
    },
}, 'generate subscription codes' );

my $batches = $session->db->buildArrayRefOfHashRefs(
    "SELECT * FROM Subscription_codeBatch WHERE subscriptionId=?",
    [ $sku->getId ],
);
cmp_deeply( $batches,
    [
        {
            name => "Paycheck",
            description => "Sign up to get your paycheck!",
            expirationDate => ignore(),
            dateCreated => ignore(),
            subscriptionId => $sku->getId,
            batchId => ignore(),
        },
    ],
    "code batch got created",
);

my $codes = $session->db->buildArrayRefOfHashRefs(
    "SELECT * FROM Subscription_code WHERE batchId=?",
    [ $batches->[0]->{batchId} ],
);
cmp_deeply( $codes,
    [
        {
            code => ignore(),
            batchId => $batches->[0]->{batchId},
            status  => 'Unused',
            dateUsed => 0,
            usedBy => 0,
        },
        {
            code => ignore(),
            batchId => $batches->[0]->{batchId},
            status  => 'Unused',
            dateUsed => 0,
            usedBy => 0,
        },
    ],
    "codes got created",
);


#----------------------------------------------------------------------------
# www_listSubscriptionCodeBatches
my $mech = WebGUI::Test::Mechanize->new( config => WebGUI::Test->file );
$mech->get_ok( '/' );
$mech->session->user({ userId => 3 });

# Add another code for the selection
$session->db->setRow( 'Subscription_codeBatch', 'batchId', {
    batchId         => 'new',
    name            => "Fired!",
    description     => "Sign up to get fired!",
    subscriptionId  => $sku->getId,
    expirationDate  => 3600 * 24 * 7,
    dateCreated     => time+1500,
});

$mech->get_ok( $sku->getUrl( 'func=listSubscriptionCodeBatches' ) );
$mech->text_contains( "Sign up to get your paycheck!" );
$mech->text_contains( "Sign up to get fired!" );
$mech->submit_form_ok( {
    fields => {
        selection => "dc",
        dcStart => time+1000,
        dcStop => time+2000,
    },
}, 'limit subscription code batches' );
$mech->content_lacks( "Sign up to get your paycheck!" );
$mech->text_contains( "Sign up to get fired!" );



