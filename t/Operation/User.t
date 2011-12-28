# vim:syntax=perl
#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2012 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#------------------------------------------------------------------

# Test the User operation

use strict;
use WebGUI::Test; # Must use this before any other WebGUI modules
use WebGUI::Session;
use WebGUI::Test::Mechanize;
use WebGUI::User;
use WebGUI::Operation::User;
use Test::More;
use Test::Deep;

#----------------------------------------------------------------------------
# Init
my $session         = WebGUI::Test->session;
$session->user({ userId => 3 });

#----------------------------------------------------------------------------
# Tests

#----------------------------------------------------------------------------
# Create a new user
my $mech = WebGUI::Test::Mechanize->new( config => WebGUI::Test->file );
$mech->get_ok( '/' );
$mech->session->user({userId => 3});

$mech->get_ok( '?op=editUser;uid=new' );
my %fields = (
            username    => 'AndrewDufresne',
            email       => 'andy@shawshank.doj.gov',
            alias       => 'Randall Stevens',
            status      => 'Active',
        );
$mech->submit_form_ok({
        fields => {
            %fields,
            'authWebGUI.identifier' => 'zihuatanejo',
            groupsToAdd => '12',
        },
    },
    "Add a new user",
);

ok( my $user = WebGUI::User->newByUsername( $session, 'AndrewDufresne' ), "user exists" );
WebGUI::Test->addToCleanup( $user );
is( $user->get('email'), $fields{email}, 'checking email' );
is( $user->get('alias'), $fields{alias}, '... alias' );
is( $user->status, $fields{status}, '... status' );
ok( $user->isInGroup( 12 ), '... added to group 12' );
my $auth = WebGUI::Auth::WebGUI->new( $session, $user );
is( $auth->get('identifier'), $auth->hashPassword('zihuatanejo'), "password was set correctly" );

# Edit an existing user
$mech->get_ok( '?op=editUser;uid=' . $user->getId );
%fields = (
    username    => "EllisRedding",
    email       => 'red@shawshank.doj.gov',
    alias       => 'Red',
    status      => 'Active',
);
$mech->submit_form_ok({
        fields  => {
            %fields,
            'authWebGUI.identifier' => 'rehabilitated',
            groupsToDelete => '12',
        },
    },
    "Edit an existing user",
);

ok( my $user = WebGUI::User->newByUsername( $mech->session, 'EllisRedding' ), "user exists" );
is( $user->get('email'), $fields{email}, '... checking email' );
is( $user->get('alias'), $fields{alias}, '... checking alias' );
is( $user->status, $fields{status}, '... checking status' );
ok( not ($user->isInGroup( 12 )), '.. checking group deletion' );
$auth = WebGUI::Auth::WebGUI->new( $session, $user );
is( $auth->get('identifier'), $auth->hashPassword('rehabilitated'), "password was set correctly" );

#######################################################################
#
# Address testing in the profile
#
#######################################################################

my $andy = WebGUI::User->new($session, "new");
WebGUI::Test->addToCleanup($andy);
$andy->username("andydufresne");

$mech->get_ok( '?op=editUser;uid=' . $andy->getId );

my %profile_info = (
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
$mech->submit_form_ok({
        fields  => {
            %profile_info,
        },
    },
    "Edit an existing user for address testing",
);

$andy = WebGUI::User->new($session,$andy->getId);

#Test that the address was saved to the profile
cmp_bag(
    [ map { $andy->get($_) } keys %profile_info ],
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
ok ($address->get('isProfile'), '... and it is a profile address');

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
    'Shop address has the right information'
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
$mech->get_ok( '?op=editUser;uid=' . $andy->getId );
$mech->submit_form_ok({
        fields  => {
            %profile_info,
        },
    },
    "Update existing address info",
);


$andy = WebGUI::User->new($session,$andy->getId);

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
    'Shop address has the right information'
);

done_testing;
