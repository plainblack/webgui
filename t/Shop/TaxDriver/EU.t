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

use FindBin;
use strict;
use lib "$FindBin::Bin/../../lib";
use Test::More;
use Test::Deep;
use Test::MockObject::Extends;
use Exception::Class;
use Data::Dumper;

use WebGUI::Test; # Must use this before any other WebGUI modules
use WebGUI::Session;
use WebGUI::Text;
use WebGUI::Shop::Cart;
use WebGUI::Shop::AddressBook;

#----------------------------------------------------------------------------
# Init
my $session         = WebGUI::Test->session;

my $taxUser     = WebGUI::User->new( $session, 'new' );
$taxUser->username( 'Tex Evasion' );
WebGUI::Test->usersToDelete($taxUser);

my $sku  = WebGUI::Asset->getRoot($session)->addChild( {
    className => 'WebGUI::Asset::Sku::Donation',
    title     => 'Taxable donation',
    defaultPrice => 100.00,
} );

my $cart;

#----------------------------------------------------------------------------
# Tests

my $tests = 58;
plan tests => 1 + $tests;

#----------------------------------------------------------------------------
# put your tests here

my $loaded = use_ok('WebGUI::Shop::TaxDriver::EU');

SKIP: {

    skip 'Unable to load module WebGUI::Shop::TaxDriver::EU', $tests unless $loaded;

    #######################################################################
    #
    # new
    #
    #######################################################################

    my $taxer = WebGUI::Shop::TaxDriver::EU->new($session);

    isa_ok($taxer, 'WebGUI::Shop::TaxDriver::EU');

    isa_ok($taxer->session, 'WebGUI::Session', 'session method returns a session object');

    is($session->getId, $taxer->session->getId, 'session method returns OUR session object');

    #######################################################################
    #
    # className
    #
    #######################################################################

    is( $taxer->className, 'WebGUI::Shop::TaxDriver::EU', 'className returns correct class name' );

    #######################################################################
    #
    # getConfigurationScreen
    #
    #######################################################################

    #### TODO: Figure out how to test this.

    #######################################################################
    #
    # getCountryCode
    #
    #######################################################################

    is( $taxer->getCountryCode( 'Netherlands' ), 'NL', 'getCountryCode returns correct code for country inside EU.' );
    is( $taxer->getCountryCode( 'United States' ), undef, 'getCountryCode returns undef for countries outside EU.' );

    #######################################################################
    #
    # getCountryName
    #
    #######################################################################

    is( $taxer->getCountryName( 'NL' ), 'Netherlands', 'getCountryName returns correct name for country code within EU.' );
    is( $taxer->getCountryName( 'US' ), undef, 'getCountryName returns undef for county codes outside EU.' );

    #######################################################################
    #
    # addVATNumber
    #
    #######################################################################

    $session->user( {userId=>$taxUser->userId} );

    # Mock the Validation module
    my $validator = Test::MockObject::Extends->new( Business::Tax::VAT::Validation->new );
    local *Business::Tax::VAT::Validation::new;
    $validator->fake_new( 'Business::Tax::VAT::Validation' );

    my $testVAT_NL  = 'NL123456789B12';
    my $testVAT_BE  = 'BE0123456789';
    my $noServiceVAT= 'NotGonnaWork';
    my $invalidVAT  = 'ByNoMeansAllowed';
    my $visitorUser = WebGUI::User->new( $session, 1 );

    eval { $taxer->addVATNumber };
    my $e = Exception::Class->caught();
    isa_ok( $e, 'WebGUI::Error::InvalidParam', 'A VAT number is required' );
    is( $e, 'A VAT number is required', 'addVATNumber returns correct message for missing VAT number' );

    eval { $taxer->addVATNumber( $testVAT_NL, 'NotAUserObject' ) };
    $e = Exception::Class->caught();
    isa_ok( $e, 'WebGUI::Error::InvalidParam', 'Second argument must be a user object' );
    is( $e, 'The second argument must be an instanciated WebGUI::User object', 'addVATNumber returns correct message when user object is of wrong type' );

    eval { $taxer->addVATNumber( $testVAT_NL, $visitorUser ) };
    $e = Exception::Class->caught();
    isa_ok( $e, 'WebGUI::Error::InvalidParam', 'User may not be visitor' );
    is( $e, 'Visitor cannot add VAT numbers', 'addVATNumber returns correct message when user is visitor' );

    #----- invalid vat number
    $validator->set_always( 'check', 0 );
    $validator->set_always( 'get_last_error_code', 1 );
    my $response = $taxer->addVATNumber( $invalidVAT, $taxUser );
    is( $response, 'The entered VAT number is invalid.', 'Invalid VAT numbers return an error message' );

    #----- service unavailable 
    $validator->set_always( 'check', 0 );
    $validator->set_always( 'get_last_error_code', 17 );
    my $response = $taxer->addVATNumber( $noServiceVAT, $taxUser );
    ok( $response =~ m{^Number validation is currently not available.}, 'When VIES is down a message is returned' );

    my $workflows = WebGUI::Workflow::Instance->getAllInstances( $session );
    my ($workflow) = grep { $_->get('parameters')->{ vatNumber } eq $noServiceVAT } @{ $workflows };
    ok( defined $workflow , 'A recheck workflow has been fired' );

    #----- valid number
    $validator->set_always( 'check', 1 );
    $validator->set_always( 'get_last_error_code', undef );
    my $response = $taxer->addVATNumber( $testVAT_NL, $taxUser );
    ok( !defined $response , 'Valid VAT numbers return undef.' );

    # Add another number for later testing purposes.
    my $responseBE = $taxer->addVATNumber( $testVAT_BE, $taxUser );


    #######################################################################
    #
    # getVATNumbers
    #
    #######################################################################

    my $expectNL = {
        userId           => $taxUser->userId,
        countryCode      => 'NL',
        vatNumber        => $testVAT_NL,
        viesValidated    => 1,
        viesErrorCode    => undef,
        approved         => 0,
    };
    my $expectBE = {
        userId           => $taxUser->userId,
        countryCode      => 'BE',
        vatNumber        => $testVAT_BE,
        approved         => 0,
        viesErrorCode    => undef,
        viesValidated    => 1,
    };

    my $vatNumbers = $taxer->getVATNumbers( undef, $taxUser );
    cmp_bag( $vatNumbers, [ $expectNL, $expectBE ], 'VAT Numbers are correctly returned by getVATNumbers' );

    $vatNumbers = $taxer->getVATNumbers( 'BE', $taxUser );
    cmp_bag( $vatNumbers, [ $expectBE ], 'getVATNumbers filters on country code when one is passed' );

    #######################################################################
    #
    # deleteVATNumber
    #
    #######################################################################

    $taxer->deleteVATNumber( $testVAT_BE, $taxUser );
    $vatNumbers = $taxer->getVATNumbers( undef, $taxUser );
    cmp_bag( $vatNumbers, [ $expectNL ], 'deleteVATNumber deletes number' );
    
    $taxer->deleteVATNumber( $testVAT_NL, $taxUser );    
    #######################################################################
    #
    # addGroupRate
    #
    #######################################################################

    eval { $taxer->addGroup };
    $e = Exception::Class->caught();
    isa_ok( $e, 'WebGUI::Error::InvalidParam', 'addGroup requires a group name' );
    is( $e, 'A group name is required', 'addGroup returns correct message for omitted group name' );

    eval { $taxer->addGroup( 'Dummy' ) };
    $e = Exception::Class->caught();
    isa_ok( $e, 'WebGUI::Error::InvalidParam', 'addGroup requires a tax rate' );
    is( $e, 'Group rate must be within 0 and 100', 'addGroup returns correct message on omitted tax rate' );

    eval { $taxer->addGroup( 'Dummy', -1 ) };
    $e = Exception::Class->caught();
    isa_ok( $e, 'WebGUI::Error::InvalidParam', 'addGroup: tax rate cannot be < 0' );
    is( $e, 'Group rate must be within 0 and 100', 'addGroup returns correct message on tax rate < 0' );

    eval { $taxer->addGroup( 'Dummy', 101 ) };
    $e = Exception::Class->caught();
    isa_ok( $e, 'WebGUI::Error::InvalidParam', 'addGroup: tax rate cannot be > 100' );
    is( $e, 'Group rate must be within 0 and 100', 'addGroup returns correct message on tax rate > 100' );

    my $id0 = eval { $taxer->addGroup( 'Group0', 0 ) };
    $e = Exception::Class->caught();
    ok( !$e, 'addGroup: 0% is a valid group rate' );

    my $id100 = eval { $taxer->addGroup( 'Group100', 100 ) };
    $e = Exception::Class->caught();
    ok( !$e, 'addGroup: 100% is a valid group rate' );

    my $id50_5 = eval { $taxer->addGroup( 'Group50.5', 50.5 ) };
    $e = Exception::Class->caught();
    ok( !$e, 'addGroup: floats are a valid group rate' );

    my $taxGroups    = $taxer->get( 'taxGroups' );
    my $expectGroups = [
        {
            name    => 'Group0',
            rate    => 0,
            id      => $id0,
        },
        {
            name    => 'Group100',
            rate    => 100,
            id      => $id100,
        },
        {
            name    => 'Group50.5',
            rate    => 50.5,
            id      => $id50_5,
        },
    ];
    cmp_bag( $taxGroups, $expectGroups, 'addGroup saves correctly' );


    #######################################################################
    #
    # getGroupRate 
    #
    #######################################################################

    ok( $taxer->getGroupRate( $id0    ) == 0
            && $taxer->getGroupRate( $id100  ) == 100
            && $taxer->getGroupRate( $id50_5 ) == 50.5,
        'getGroup rate gets correct rates'
    );

    #######################################################################
    #
    # getTaxRate
    #
    #######################################################################

    $taxer->update( { 'automaticViesApproval' => 1 } );
    my $book = WebGUI::Shop::AddressBook->create($session);

    # setup address in EU but not in residential country of merchant
    my $beAddress = $book->addAddress({
        label => 'BE',
        city  => 'Antwerpen',
        country => 'Belgium',
    });

    # setup address in residential country of merchant 
    my $nlAddress = $book->addAddress({
        label => 'NL',
        city  => 'Delft',
        country => 'Netherlands',
    });

    # setup address outside EU
    my $usAddress = $book->addAddress({
        label => 'outside eu',
        city => 'New Amsterdam',
        country => 'US',
    });

    eval { $taxer->getTaxRate(); };
    $e = Exception::Class->caught();
    isa_ok($e, 'WebGUI::Error::InvalidParam', 'getTaxRate: error handling for not sending a sku');
    is($e->error, 'Must pass in a WebGUI::Asset::Sku object', 'getTaxRate: error handling for not sending a sku');

    # Set defaultTaxGroup and residential country
    $taxer->update( { defaultGroup => $id50_5, shopCountry => 'NL' } );

    # Check default tax group
    is( $taxer->getTaxRate( $sku ), 50.5, 'getTaxRate returns default tax group when no address is given and sku has no tax group set');

    # Check case when no address is given
    $sku->setTaxConfiguration( 'WebGUI::Shop::TaxDriver::EU', { taxGroup => $id100 } );
    is( $taxer->getTaxRate( $sku ), 100, 'getTaxRate returns tax group set by sku when no address is given');

    # Address outside EU
    is( $taxer->getTaxRate( $sku, $usAddress ), 0, 'getTaxRate: shipping addresses outside EU are tax exempt' );
    
    # Addresses inside EU
    is( $taxer->getTaxRate( $sku, $beAddress ), 100, 'getTaxRate: shipping addresses inside EU w/o VAT number pay tax' );
    is( $taxer->getTaxRate( $sku, $nlAddress ), 100, 'getTaxRate: shipping addresses in country of merchant w/o VAT number pay tax' );

    # Add VAT numbers
    $taxer->addVATNumber( $testVAT_NL, $taxUser, 1);
    $taxer->addVATNumber( $testVAT_BE, $taxUser, 1);

    is( $taxer->getTaxRate( $sku, $beAddress ), 0, 
        'getTaxRate: shipping addresses inside EU but other country than merchant w/ VAT number are tax exempt.' 
    );
    is( $taxer->getTaxRate( $sku, $nlAddress ), 100, 'getTaxRate: shipping addresses in country of merchant w/ VAT number pay tax' );

    #######################################################################
    #
    # appendCartItemVars
    #
    #######################################################################

    eval { $taxer->appendCartItemVars };
    my $e = Exception::Class->caught();
    isa_ok( $e, 'WebGUI::Error::InvalidParam', 'appendCartItemVars requires a hash ref.' );
    is( $e, 'Must supply a hash ref', 'appendCartItemVars returns correct message for missing hash ref' );

    eval { $taxer->appendCartItemVars( {}, 'NotAUserObject' ) };
    $e = Exception::Class->caught();
    isa_ok( $e, 'WebGUI::Error::InvalidObject', 'appendCartItemVars: Second argument must be a cart item object' );
    cmp_deeply( $e,  methods(
        error    => 'Must pass a cart item',
        expected => 'WebGUI::Shop::CartItem',
        got      => '',
    ), 'appendCartItemVars returns correct error for missing CartItem' );
    

    $cart = WebGUI::Shop::Cart->newBySession( $session );

    my $item = $cart->addItem( $sku );
    $item->setQuantity( 2 );
    $item->update( { shippingAddressId => $nlAddress->getId } );

    my $cartItemVars = { must => 'be kept' };
    $taxer->appendCartItemVars( $cartItemVars, $item );
    cmp_deeply( $cartItemVars, {
        pricePlusTax            => '200.00',
        extendedPricePlusTax    => '400.00',
        taxRate                 => '100',
        taxAmount               => '100.00',
        VATNumber               => $testVAT_NL,
        must                    => 'be kept',
    }, 'appendCartItemVars returns correct data for address in shopy country.' );

    $item->update( { shippingAddressId => $beAddress->getId } );
    $cartItemVars = { must => 'be kept' };
    $taxer->appendCartItemVars( $cartItemVars, $item );
    cmp_deeply( $cartItemVars, {
        pricePlusTax            => '100.00',
        extendedPricePlusTax    => '200.00',
        taxRate                 => '0',
        taxAmount               => '0.00',
        VATNumber               => $testVAT_BE,
        must                    => 'be kept',
    }, 'appendCartItemVars returns correct data for address in otrher country in EU.' );
    
    $item->update( { shippingAddressId => $usAddress->getId } );
    $cartItemVars = { must => 'be kept' };
    $taxer->appendCartItemVars( $cartItemVars, $item );
    cmp_deeply( $cartItemVars, {
        pricePlusTax            => '100.00',
        extendedPricePlusTax    => '200.00',
        taxRate                 => '0',
        taxAmount               => '0.00',
        must                    => 'be kept',
    }, 'appendCartItemVars returns correct data for address outside EU.' );

    #######################################################################
    #
    # getTransactionTaxData
    #
    #######################################################################

    my $details = $taxer->getTransactionTaxData( $sku, $usAddress );
    cmp_deeply( $details, {
        className   => 'WebGUI::Shop::TaxDriver::EU',
        outsideEU   => 1,
    }, 'getTransactionTaxData returns correct hashref for addresses outside EU' );

    $details = $taxer->getTransactionTaxData( $sku, $beAddress );
    cmp_deeply( $details, {
        className       => 'WebGUI::Shop::TaxDriver::EU',
        useVATNumber    => 1,
        VATNumber       => $testVAT_BE,
    }, 'getTransactionTaxData returns correct hashref for addresses inside EU but not shop country w/ VAT number' );

    $details = $taxer->getTransactionTaxData( $sku, $nlAddress );
    cmp_deeply( $details, {
        className       => 'WebGUI::Shop::TaxDriver::EU',
        useVATNumber    => 1,
        VATNumber       => $testVAT_NL,
    }, 'getTransactionTaxData returns correct hashref for addresses in shop country w/ VAT number' );
    
    $taxer->deleteVATNumber( $testVAT_NL );

    $details = $taxer->getTransactionTaxData( $sku, $nlAddress );
    cmp_deeply( $details, {
        className       => 'WebGUI::Shop::TaxDriver::EU',
        useVATNumber    => 0,
    }, 'getTransactionTaxData returns correct hashref for addresses in EU w/o VAT number' );

    #######################################################################
    #
    # deleteGroup
    #
    #######################################################################

    eval { $taxer->deleteGroup };
    $e = Exception::Class->caught();
    isa_ok( $e, 'WebGUI::Error::InvalidParam', 'addGroup requires a group id' );
    is( $e, 'A group id is required', 'addGroup returns correct message for missing group id' );

    $taxer->deleteGroup( $id50_5 );

    $taxGroups = $taxer->get( 'taxGroups' );
    cmp_bag( $taxGroups, [
        {
            name    => 'Group0',
            rate    => 0,
            id      => $id0,
        },
        {
            name    => 'Group100',
            rate    => 100,
            id      => $id100,
        },
    ], 'deleteGroup deletes correctly' );
}

#----------------------------------------------------------------------------
# Cleanup
END {
    $session->db->write('delete from tax_eu_vatNumbers');
    $cart->delete;
    $session->db->write('delete from cart');
    $session->db->write('delete from addressBook');
    $session->db->write('delete from address');
    $session->db->write('delete from taxDriver where className=?', [ 'WebGUI::Shop::TaxDriver::EU' ]);
 
    $sku->purge;
}
