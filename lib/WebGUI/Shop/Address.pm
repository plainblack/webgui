package WebGUI::Shop::Address;

=head1 LEGAL

 -------------------------------------------------------------------
  WebGUI is Copyright 2001-2009 Plain Black Corporation.
 -------------------------------------------------------------------
  Please read the legal notices (docs/legal.txt) and the license
  (docs/license.txt) that came with this distribution before using
  this software.
 -------------------------------------------------------------------
  http://www.plainblack.com                     info@plainblack.com
 -------------------------------------------------------------------

=cut

use strict;
use Class::InsideOut qw{ :std };
use WebGUI::Exception::Shop;

=head1 NAME

Package WebGUI::Shop::Address

=head1 DESCRIPTION

An address is used to track shipping or payment addresses in the commerce system.  Because of
object caching in the AddressBook, addresses should never, ever be accessed directly.

=head1 SYNOPSIS

 use WebGUI::Shop::Address;

 my $address = WebGUI::Shop::Address->new($addressBook, $addressId);

=head1 METHODS

These subroutines are available from this package:

=cut

readonly addressBook => my %addressBook;
private properties => my %properties;

#-------------------------------------------------------------------

=head2 addressBook ( )

Returns a reference to the Address Book.

=cut

#-------------------------------------------------------------------

=head2 create ( addressBook, address)

Constructor. Adds an address to an address book. Returns a reference to the address.

=head3 addressBook

A reference to a WebGUI::Shop::AddressBook object.

=head3 address

A hash reference containing the properties to set in the address.

=cut

sub create {
    my ($class, $book, $addressData) = @_;
    unless (defined $book && $book->isa("WebGUI::Shop::AddressBook")) {
        WebGUI::Error::InvalidObject->throw(expected=>"WebGUI::Shop::AddressBook", got=>(ref $book), error=>"Need an address book.", param=>$book);
    }
    unless (defined $addressData && ref $addressData eq "HASH") {
        WebGUI::Error::InvalidParam->throw(param=>$addressData, error=>"Need a hash reference.");
    }
    my $id = $book->session->db->setRow("address","addressId", {addressId=>"new", addressBookId=>$book->getId});
    my $address = $class->new($book, $id);
    $address->update($addressData);
    return $address;
}

#-------------------------------------------------------------------

=head2 delete ( )

Removes this address from the book.

=cut

sub delete {
    my $self = shift;
    $self->addressBook->session->db->deleteRow("address","addressId",$self->getId);
    undef $self;
    return undef;
}

#-------------------------------------------------------------------

=head2 get ( [ property ] )

Returns a duplicated hash reference of this object’s data.

=head3 property

Any field − returns the value of a field rather than the hash reference.

=cut

sub get {
    my ($self, $name) = @_;
    if (defined $name) {
        return $properties{id $self}{$name};
    }
    my %copyOfHashRef = %{$properties{id $self}};
    return \%copyOfHashRef;
}

#-------------------------------------------------------------------

=head2 getHtmlFormatted ()

Returns an HTML formatted address for display.

=cut

sub getHtmlFormatted {
    my $self = shift;
    my $address = $self->get("firstName"). " " .$self->get("lastName") . "<br />";
    $address .= $self->get("organization") . "<br />" if ($self->get("organization") ne "");
    $address .= $self->get("address1") . "<br />";
    $address .= $self->get("address2") . "<br />" if ($self->get("address2") ne "");
    $address .= $self->get("address3") . "<br />" if ($self->get("address3") ne "");
    $address .= $self->get("city") . ", ";
    $address .= $self->get("state") . " " if ($self->get("state") ne "");
    $address .= $self->get("code") if ($self->get("code") ne "");
    $address .= '<br />' . $self->get("country");
    $address .= '<br />'.$self->get("phoneNumber") if ($self->get("phoneNumber") ne "");
    $address .= '<br /><a href="mailto:'.$self->get("email").'">'.$self->get("email").'</a>' if ($self->get("email") ne "");
    return $address;
}

#-------------------------------------------------------------------

=head2 getId () 

Returns the unique id of this item.

=cut

sub getId {
    my $self = shift;
    return $self->get("addressId");
}


#-------------------------------------------------------------------

=head2 new ( addressBook, addressId )

Constructor.  Instanciates an existing address from the database based upon addressId.

=head3 addressBook

A reference to a WebGUI::Shop::AdressBook object.

=head3 addressId

The unique id of the address to instanciate.

=cut

sub new {
    my ($class, $book, $addressId) = @_;
    unless (defined $book && $book->isa("WebGUI::Shop::AddressBook")) {
        WebGUI::Error::InvalidObject->throw(expected=>"WebGUI::Shop::AddressBook", got=>(ref $book), error=>"Need an address book.");
    }
    unless (defined $addressId) {
        WebGUI::Error::InvalidParam->throw(error=>"Need an addressId.", param=>$addressId);
    }
    my $address = $book->session->db->quickHashRef('select * from address where addressId=?', [$addressId]);
    if ($address->{addressId} eq "") {
        WebGUI::Error::ObjectNotFound->throw(error=>"Address not found.", id=>$addressId);
    }
    if ($address->{addressBookId} ne $book->getId) {
        WebGUI::Error::ObjectNotFound->throw(error=>"Address not in this address book.", id=>$addressId);
    }
    my $self = register $class;
    my $id        = id $self;
    $addressBook{ $id }   = $book;
    $properties{ $id } = $address;
    return $self;
}


#-------------------------------------------------------------------

=head2 update ( properties )

Sets properties of the address.

=head3 properties

A hash reference that contains one or more of the following:

=head4 label

A human readable label like "home" or "work".

=head4 firstName

The first name of the company or person to address this to.

=head4 lastName

The last name of the company or person to address this to.

=head4 address1

The street name and number.

=head4 address2

Suite number or other addressing information.

=head4 address3

Care of info or other addressing information.

=head4 city

The city that this address is in.

=head4 state

The state or province that this address is in.

=head4 code 

The postal code or zip code that this address is in.

=head4 country

The country that this address is in.

=head4 phoneNumber

A telephone number for this address. It is required by some shippers.

=head4 email

An email address for this user.

=head4 organization

The organization or company that this user is a part of.

=head4 addressBookId

The address book that this address belongs to.

=cut

sub update {
    my ($self, $newProperties) = @_;
    my $id = id $self;
    foreach my $field (qw(addressBookId email organization address1 address2 address3 state code city label firstName lastName country phoneNumber)) {
        $properties{$id}{$field} = (exists $newProperties->{$field}) ? $newProperties->{$field} : $properties{$id}{$field};
    }
    $self->addressBook->session->db->setRow("address","addressId",$properties{$id});
}


1;
