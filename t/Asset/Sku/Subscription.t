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

use FindBin;
use strict;
use lib "$FindBin::Bin/../../lib";
use Test::More;
use Test::Deep;
use WebGUI::Test; # Must use this before any other WebGUI modules
use WebGUI::Session;
use WebGUI::Asset;
use WebGUI::Asset::Sku::Subscription;

#----------------------------------------------------------------------------
# Init
my $session         = WebGUI::Test->session;


#----------------------------------------------------------------------------
# Tests

plan tests => 4;        # Increment this number for each test you create

#----------------------------------------------------------------------------
# put your tests here
my $root  = WebGUI::Asset->getRoot($session);
my $group = WebGUI::Group->new($session, 'new');
WebGUI::Test->addToCleanup($group);
my $user  = WebGUI::User->create($session);
WebGUI::Test->addToCleanup($user);

my $sku = $root->addChild({
        className => "WebGUI::Asset::Sku::Subscription",
        title     => "Test Subscription",
        price     => 50.00,
        recurringSubscription => 0,
        subscriptionGroup     => $group->getId,
        duration              => 'Monthly',
        });
my $versionTag = WebGUI::VersionTag->getWorking($session);
WebGUI::Test->addToCleanup($versionTag);
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
