package WebGUI::Shop::Tax;

use strict;

use Class::InsideOut qw{ :std };
use WebGUI::Text;
use WebGUI::Storage;
use WebGUI::Exception::Shop;
use WebGUI::Shop::Cart;
use WebGUI::Shop::CartItem;
use List::Util qw{sum};

=head1 NAME

Package WebGUI::Shop::Tax

=head1 DESCRIPTION

This package manages tax information, and calculates taxes on a shopping cart.  It isn't a classic object
in that the only data it contains is a WebGUI::Session object, but it does provide several methods for
handling the information in the tax tables.

Taxes are accumulated through increasingly specific geographic information.  For example, you can
specify the sales tax for a whole country, then the additional sales tax for a state in the country,
all the way down to a single code inside of a city.

=head1 SYNOPSIS

 use WebGUI::Shop::Tax;

 my $tax = WebGUI::Shop::Tax->new($session);

=head1 METHODS

These subroutines are available from this package:

=cut

readonly session => my %session;

#-------------------------------------------------------------------

=head2 add ( [$params] )

Add tax information to the table.  Returns the taxId of the newly created tax information.  

=head3 $params

A hash ref of the geographic and rate information.  The country and taxRate parameters
must have defined values.

=head4 country

The country this tax information applies to.

=head4 state

The state this tax information applies to.  state and country together are unique.

=head4 city

The ciy this tax information applies to.  Cities are unique with state and country information.

=head4 code

The postal code this tax information applies to.  codes are unique with state and country information.

=head4 taxRate

This is the tax rate for the location, as specified by the geographical
fields country, state, city and/or code.  The tax rate is stored as
a percentage, like 5.5 .

=cut

sub add {
    my $self   = shift;
    my $params = shift;

    WebGUI::Error::InvalidParam->throw(error => 'Must pass in a hashref of params')
        unless ref($params) eq 'HASH';
    WebGUI::Error::InvalidParam->throw(error => "Missing required information.", param => 'country')
        unless exists($params->{country}) and $params->{country};
    WebGUI::Error::InvalidParam->throw(error => "Missing required information.", param => 'taxRate')
        unless exists($params->{taxRate}) and defined $params->{taxRate};

    $params->{taxId} = 'new';
    my $id = $self->session->db->setRow('tax', 'taxId', $params);
    return $id;
}

#-------------------------------------------------------------------

=head2 calculate ( $cart )

Calculate the tax for the contents of the cart.  The tax rate is calculated off
of the shipping address stored in the cart.  If an item in the cart has an alternate
address, that is used instead.  Finally, if the item in the cart has a Sku with a tax
rate override, that rate overrides all. Returns 0 if no shipping address has been attached to the cart yet.

=cut

sub calculate {
    my $self = shift;
    my $cart = shift;
    WebGUI::Error::InvalidParam->throw(error => 'Must pass in a WebGUI::Shop::Cart object')
        unless ref($cart) eq 'WebGUI::Shop::Cart';
    my $book = $cart->getAddressBook;
    return 0 if $cart->get('shippingAddressId') eq "";
    my $address = $book->getAddress($cart->get('shippingAddressId'));
    my $tax = 0;
    foreach my $item (@{ $cart->getItems }) {
        my $sku = $item->getSku;
        my $unitPrice = $sku->getPrice;
        my $quantity  = $item->get('quantity');
        ##Check for an item specific shipping address
        my $itemAddress;
        if (defined $item->get('shippingAddressId')) {
            $itemAddress = $book->getAddress($item->get('shippingAddressId'));
        }
        else {
            $itemAddress = $address;
        }
        my $taxables  = $self->getTaxRates($itemAddress);
        ##Check for a SKU specific tax override rate
        my $skuTaxRate = $sku->getTaxRate();
        my $itemTax;
        if (defined $skuTaxRate) {
            $itemTax = $skuTaxRate;
        }
        else {
            $itemTax = sum(@{$taxables});
        }
        $itemTax /= 100;
        $tax += $unitPrice * $quantity * $itemTax;
    }
    return $tax;
}

#-------------------------------------------------------------------

=head2 canEdit ( [ $user ] )

Determine whether or not the current user can perform commerce functions

=head3 $user

An optional WebGUI::User object to check for permission to do commerce functions.  If
this is not used, it uses the current session user object.

=cut

sub canEdit {
    my $self   = shift;
    my $user   = shift || $self->session->user;
    return $user->isInGroup( $self->session->get('groupIdAdminCommerce'));
}

#-------------------------------------------------------------------

=head2 delete ( [$params] )

Deletes data from the tax table by taxId.

=head3 $params

A hashref containing the taxId of the data to delete from the table.

=head4 taxId

The taxId of the data to delete from the table.

=cut

sub delete {
    my $self   = shift;
    my $params = shift;
    WebGUI::Error::InvalidParam->throw(error => 'Must pass in a hashref of params')
        unless ref($params) eq 'HASH';
    WebGUI::Error::InvalidParam->throw(error => "Hash ref must contain a taxId key with a defined value")
        unless exists($params->{taxId}) and defined $params->{taxId};
    $self->session->db->write('delete from tax where taxId=?', [$params->{taxId}]);
    return;
}

#-------------------------------------------------------------------

=head2 exportTaxData ( )

Creates a tab deliniated file containing all the information from
the tax table.  Returns a temporary WebGUI::Storage object containing
the file.  The file will be named "siteTaxData.csv".

=cut

sub exportTaxData {
    my $self = shift;
    my $taxIterator = $self->getItems;
    my @columns = grep { $_ ne 'taxId' } $taxIterator->getColumnNames;
    my $taxData = WebGUI::Text::joinCSV(@columns) . "\n";
    while (my $taxRow = $taxIterator->hashRef() ) {
        my @taxData = @{ $taxRow }{@columns};
        foreach my $column (@taxData) {
            $column =~ tr/,/|/;  ##Convert to the alternation syntax for the text file
        }
        $taxData .= WebGUI::Text::joinCSV(@taxData) . "\n";
    }
    my $storage = WebGUI::Storage->createTemp($self->session);
    $storage->addFileFromScalar('siteTaxData.csv', $taxData);
    return $storage;
}

#-------------------------------------------------------------------

=head2 getItems ( )

Returns a WebGUI::SQL::Result object for accessing all of the data in the tax table.  This
is a convenience method for listing and/or exporting tax data.

=cut

sub getItems {
    my $self = shift;
    my $result = $self->session->db->read('select * from tax');
    return $result;
}

#-------------------------------------------------------------------

=head2 getTaxRates ( $address )

Given a WebGUI::Shop::Address object, return all rates associated with the address as an arrayRef.

=cut

sub getTaxRates {
    my $self = shift;
    my $address = shift;
    WebGUI::Error::InvalidObject->throw(error => 'Need an address.', expected=>'WebGUI::Shop::Address', got=>(ref $address))
        unless ref($address) eq 'WebGUI::Shop::Address';
    my $country = $address->get('country');
    my $state   = $address->get('state');
    my $city    = $address->get('city');
    my $code    = $address->get('code');
    my $result = $self->session->db->buildArrayRef(
    q{
        select taxRate from tax where find_in_set(?, country)
        and (state='' or find_in_set(?, state))
        and (city=''  or find_in_set(?, city))
        and (code=''  or find_in_set(?, code))
    },
    [ $country, $state, $city, $code, ]);
    return $result;
}

#-------------------------------------------------------------------

=head2 importTaxData ( $filePath )

Import tax information from the specified file in CSV format.  The
first line of the file should contain the name of the columns, in
any order.  The first line may not contain comments in it, or
before it.

The following lines will contain tax information.  Blank
lines and anything following a '#' sign will be ignored from
the second line of the file, on to the end.

Returns 1 if the import has taken place.  This is to help you know
if old data has been deleted and new has been inserted.

=cut

sub importTaxData {
    my $self     = shift;
    my $filePath = shift;
    WebGUI::Error::InvalidParam->throw(error => q{Must provide the path to a file})
        unless $filePath;
    WebGUI::Error::InvalidFile->throw(error => qq{File could not be found}, brokenFile => $filePath)
        unless -e $filePath;
    WebGUI::Error::InvalidFile->throw(error => qq{File is not readable}, brokenFile => $filePath)
        unless -r $filePath;
    open my $table, '<', $filePath or
        WebGUI::Error->throw(error => qq{Unable to open $filePath for reading: $!\n});
    my $headers;
    $headers = <$table>;
    chomp $headers;
    my @headers = WebGUI::Text::splitCSV($headers);
    WebGUI::Error::InvalidFile->throw(error => qq{Bad header found in the CSV file}, brokenFile => $filePath)
        unless (join(q{-}, sort @headers) eq 'city-code-country-state-taxRate')
           and (scalar @headers == 5);
    my @taxData = ();
    my $line = 1;
    while (my $taxRow = <$table>) {
        chomp $taxRow;
        $taxRow =~ s/\s*#.+$//;
        next unless $taxRow;
        local $_;
        my @taxRow = map { tr/|/,/; $_; } WebGUI::Text::splitCSV($taxRow);
        WebGUI::Error::InvalidFile->throw(error => qq{Error found in the CSV file}, brokenFile => $filePath, brokenLine => $line)
            unless scalar @taxRow == 5;
        push @taxData, [ @taxRow ];
    }
    ##Okay, if we got this far, then the data looks fine.
    return unless scalar @taxData;
    $self->session->db->beginTransaction;
    $self->session->db->write('delete from tax');
    foreach my $taxRow (@taxData) {
        my %taxRow;
        @taxRow{ @headers } = @{ $taxRow }; ##Must correspond 1:1, or else...
        $self->add(\%taxRow);
    }
    $self->session->db->commit;
    return 1;
}

#-------------------------------------------------------------------

=head2 new ( $session )

Constructor for the WebGUI::Shop::Tax.  Returns a WebGUI::Shop::Tax object.

=cut

sub new {
    my $class   = shift;
    my $session = shift;
    my $self    = {};
    bless $self, $class;
    register $self;
    $session{ id $self } = $session;
    return $self;
}

#-------------------------------------------------------------------

=head2 session (  )

Accessor for the session object.  Returns the session object.

=cut

#-------------------------------------------------------------------

=head2 www_view (  )

User interface to manage taxes.  Provides a list of current taxes, and forms for adding
new tax info, exporting and importing sets of taxes, and deleting individual tax data.

=cut

sub www_view {
    my $self = shift;
    return $self->session->privileges->insufficient
        unless $self->canEdit;
    return '';
}

1;
