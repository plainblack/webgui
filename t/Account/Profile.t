# vim:syntax=perl
#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2009 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#------------------------------------------------------------------
# http://www.plainblack.com info@plainblack.com
#------------------------------------------------------------------

# This tests the operation of WebGUI::Account modules. You can use
# as a base to test your own modules.

use FindBin;
use strict;
use lib "$FindBin::Bin/../lib";
use Test::More;
use Test::Deep;
use Exception::Class;

use WebGUI::Test; # Must use this before any other WebGUI modules
use WebGUI::Session;

#----------------------------------------------------------------------------
# Init
my $session = WebGUI::Test->session;

my $andy = WebGUI::User->new($session, "new");
WebGUI::Test->addToCleanup($andy);
$session->user({userId => $andy->getId});

#----------------------------------------------------------------------------
# Tests

plan tests => 17; # Increment this number for each test you create

#----------------------------------------------------------------------------
# Test the creation of WebGUI::Account::Profile

# Can we load it?
use_ok( "WebGUI::Account::Profile" );

SKIP: { # Not everyone has Test::Exception yet
    eval { require Test::Exception; import Test::Exception };
    # Skip 1 test if Test::Exception couldn't be loaded
    skip 1, 'Test::Exception not found' if $@;
    throws_ok( sub { WebGUI::Account::Profile->new }, 'WebGUI::Error::InvalidObject',
        'new() throws exception without session object'
    );
};

my $profile;
ok( $profile = WebGUI::Account::Profile->new( $session ),
    "WebGUI::Account::Profile object created successfully"
);

# Test $profile->isa
isa_ok( $profile, "WebGUI::Account", 'Blessed into the right class' );

#----------------------------------------------------------------------------
# Test getUrl

is( $profile->getUrl, $session->url->page('op=account;module=;do='.$profile->method),
    'getUrl adds op, module, and do since no method has been set'
);

is( $profile->getUrl( 'foo=bar' ), $session->url->page( 'op=account;foo=bar' ),
    'getUrl adds op if passed other parameters'
);

is( $profile->getUrl( 'op=account' ), $session->url->page( 'op=account' ),
    'getUrl doesnt add op=account if already exists'
);

#######################################################################
#
# www_editSave
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

$session->request->setup_body( \%profile_info );

$profile->www_editSave;

#Reset andy to the session users since stuff has changed
$andy = $session->user;

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

$session->request->setup_body( \%profile_info );

$profile->www_editSave;

$andy = $session->user;

#Test that the address was saved to the profile
cmp_bag (
    [ map { $andy->get($_) } keys %profile_info ],
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



#vim:ft=perl
