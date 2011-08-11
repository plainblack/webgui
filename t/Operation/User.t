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

# This tests the operation of Authentication
# 
#

use FindBin;
use strict;
use lib "$FindBin::Bin/../lib";
use Test::More;
use Test::Deep;
use Exception::Class;

use WebGUI::Test; # Must use this before any other WebGUI modules
use WebGUI::Session;
use WebGUI::User;
use WebGUI::Operation::User;

#----------------------------------------------------------------------------
# Init
my $session         = WebGUI::Test->session;
$session->user({ userId => 3 });

my $andy = WebGUI::User->new($session, "new");
WebGUI::Test->addToCleanup($andy);
$andy->username("andydufresne");

#----------------------------------------------------------------------------
# Tests

plan tests => 10;        # Increment this number for each test you create

#----------------------------------------------------------------------------


#######################################################################
#
# www_editUserSave
#
#######################################################################

tie my %profile_info, "Tie::IxHash", (
    firstName       => "Andy",
    lastName        => "Dufresne",
    homeAddress     => "123 Shank Ave.",
    homeCity        => "Shawshank",
    homeState       => "PA",
    homeZip         => "11223",
    homeCountry     => "US",
    homePhone       => "111-111-1111",
    email           => 'andy@shawshank.com'
);  

$session->request->setup_body({
    uid             => $andy->getId,
    username        => $andy->username,
    webguiCsrfToken => $session->scratch->get('webguiCsrfToken'),
    %profile_info
});
$session->request->method('POST');

WebGUI::Operation::User::www_editUserSave($session);

$andy = WebGUI::User->new($session,$andy->getId);

#Test that the address was saved to the profile
cmp_bag(
    [ map { $andy->profileField($_) } keys %profile_info ],
    [ values %profile_info ],
    'Profile fields were saved'
);

#Test that the addressBook was created
my $bookId = $session->db->quickScalar(
    q{ select addressBookId from addressBook where userId=? },
    [$andy->getId]
);

ok( ($bookId ne ""), "Address Book was created");

my $book   = WebGUI::Shop::AddressBook->new($session,$bookId);

my @addresses = @{ $book->getAddresses() };

is(scalar(@addresses), 1 , "One address was created in the address book");

my $address = $addresses[0];

tie my %address_info, "Tie::IxHash", (
    firstName       => $address->get("firstName"),
    lastName        => $address->get("lastName"),
    homeAddress     => $address->get("address1"),
    homeCity        => $address->get("city"),
    homeState       => $address->get("state"),
    homeZip         => $address->get("code"),
    homeCountry     => $address->get("country"),
    homePhone       => $address->get("phoneNumber"),
    email           => $address->get("email")
);

#Test that the address was saved properly to shop
cmp_bag(
    [ values %profile_info ],
    [ values %address_info ],
    'Shop address was has the right information'
);

#Test that the address is returned as the profile address
my $profileAddress = $book->getProfileAddress;
is($profileAddress->getId, $address->getId, "Profile linked properly to address");

#Test that the address is the default address
my $defaultAddress = $book->getDefaultAddress;
is(
    $defaultAddress->getId,
    $address->getId,
    "Profile address properly set to default address when created"
);


#Test updates to existing addresses
%profile_info = (
    firstName       => "Andy",
    lastName        => "Dufresne",
    homeAddress     => "123 Seaside Ave.",
    homeCity        => "Zihuatanejo",
    homeState       => "Guerrero",
    homeZip         => "40880",
    homeCountry     => "MX",
    homePhone       => "222-222-2222",
    email           => 'andy@freeman.com'
);

$session->request->setup_body({
    uid             => $andy->getId,
    username        => $andy->username,
    webguiCsrfToken => $session->scratch->get('webguiCsrfToken'),
    %profile_info
});
$session->request->method('POST');
WebGUI::Operation::User::www_editUserSave($session);

$andy = WebGUI::User->new($session,$andy->getId);

#Test that the address was saved to the profile
cmp_bag (
    [ map { $andy->profileField($_) } keys %profile_info ],
    [ values %profile_info ],
    'Profile fields were updated'
);

#Test that there is still only one address book and one address
my @bookIds = $session->db->quickArray(
    q{ select addressBookId from addressBook where userId=? },
    [$andy->getId]
);

is( scalar(@bookIds), 1, "Only one address book exists after update" );

$bookId     = $bookIds[0];
$book       = WebGUI::Shop::AddressBook->new($session,$bookId);
@addresses  = @{ $book->getAddresses() };

is( scalar(@addresses), 1 , "Only one address exists after update");

my $address = $addresses[0];

%address_info = (
    firstName       => $address->get("firstName"),
    lastName        => $address->get("lastName"),
    homeAddress     => $address->get("address1"),
    homeCity        => $address->get("city"),
    homeState       => $address->get("state"),
    homeZip         => $address->get("code"),
    homeCountry     => $address->get("country"),
    homePhone       => $address->get("phoneNumber"),
    email           => $address->get("email")
);

#Test that the address was saved properly to shop
cmp_bag(
    [ values %profile_info ],
    [ values %address_info ],
    'Shop address was has the right information'
);
