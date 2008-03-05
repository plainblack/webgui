package WebGUI::Shop::Tax;

use strict;

use Class::InsideOut qw{ :std };
use WebGUI::Text;
use WebGUI::Storage;
use WebGUI::Exception::Shop;
use WebGUI::Shop::Cart;
use WebGUI::Shop::CartItem;
use WebGUI::Shop::AddressBook;
use WebGUI::Shop::Address;
use List::Util qw{sum};

=head1 NAME

Package WebGUI::Shop::Tax

=head1 DESCRIPTION

This package manages tax information, and calculates taxes on a shopping cart.  It isn't a classic object
in that the only data it contains is a WebGUI::Session object, but it does provide several methods for
handling the information in the tax tables.

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

A hash ref of the geographic and rate information.  All parameters are required and
must have defined values.

=head4 field

field denotes what kind of location the tax information is for.  This should
be country, state, or code.  The combination of field and value is unique
in the database.

=head4 value

value is the value of the field to be added.  For example, appropriate values
for a field of country might be China, United States, Mexico.  If the field
is state, it could be British Colombia, Oregon or Maine.

=head4 taxRate

This is the tax rate for the location, as specified by field and value.  The tax rate is stored
as a percentage, like 5.5 .

=cut

sub add {
    my $self   = shift;
    my $params = shift;
    my $id = $self->session->id->generate();

    WebGUI::Error::InvalidParam->throw(error => 'Must pass in a hashref of params')
        unless ref($params) eq 'HASH';
    foreach my $key (qw/field value taxRate/) {
        WebGUI::Error::InvalidParam->throw(error => "Hash ref must contain a $key key with a defined value")
            unless exists($params->{$key}) and defined $params->{$key};
    }
    $self->session->db->write('insert into tax (taxId, field, value, taxRate) VALUES (?,?,?,?)', [$id, @{ $params }{qw[ field value taxRate ]}]);
    return $id;
}

#-------------------------------------------------------------------

=head2 calculate ( $cart )

Calculate the tax for the contents of the cart.

=cut

sub calculate {
    my $self = shift;
    my $cart = shift;
    WebGUI::Error::InvalidParam->throw(error => 'Must pass in a WebGUI::Shop::Cart object')
        unless ref($cart) eq 'WebGUI::Shop::Cart';
    my $book = WebGUI::Shop::AddressBook->create($self->session);
    my $address = WebGUI::Shop::Address->new($book, $cart->get('shippingAddressId'));
    my $tax = 0;
    foreach my $item (@{ $cart->getItems }) {
        my $sku = $item->getSku;
        my $unitPrice = $sku->getPrice;
        my $quantity  = $item->get('quantity');
        my $taxables  = $self->getTaxRates($address);
        use Data::Dumper;
        warn Dumper $taxables;
        my $itemTax   = sum(@{$taxables}) / 100;  ##Form a percentage
        warn "unitPrice: $unitPrice\n";
        warn "quantity : $quantity\n";
        warn "itemTax  : $itemTax\n";
        $tax += $unitPrice * $quantity * $itemTax;
    }
    return $tax;
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
    my @columns = qw{ field value taxRate };
    my $taxData = WebGUI::Text::joinCSV(@columns) . "\n";
    while (my $taxRow = $taxIterator->hashRef() ) {
        my @taxData = @{ $taxRow }{@columns};
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
    my $result = $self->session->db->buildArrayRef(
    q{
        select taxRate from tax where
           (field='state'   and value=?)
        OR (field='country' and value=?)
        OR (field='code'    and value=?)
    },
    [$address->get('state'), $address->get('country'), $address->get('code')]);
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
        unless (join(q{-}, sort @headers) eq 'field-taxRate-value')
           and (scalar @headers == 3);
    my @taxData = ();
    my $line = 1;
    while (my $taxRow = <$table>) {
        chomp $taxRow;
        $taxRow =~ s/\s*#.+$//;
        next unless $taxRow;
        my @taxRow = WebGUI::Text::splitCSV($taxRow);
        WebGUI::Error::InvalidFile->throw(error => qq{Error found in the CSV file}, brokenFile => $filePath, brokenLine => $line)
            unless scalar @taxRow == 3;
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

1;
