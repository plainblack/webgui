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
use Moose;
use WebGUI::Definition;

property label => (
    noFormPost => 1,
    default    => '',
);

property firstName => (
    noFormPost => 1,
    default    => '',
);

property lastName => (
    noFormPost => 1,
    default    => '',
);

property address1 => (
    noFormPost => 1,
    default    => '',
);

property address2 => (
    noFormPost => 1,
    default    => '',
);

property address3 => (
    noFormPost => 1,
    default    => '',
);

property city => (
    noFormPost => 1,
    default    => '',
);

property state => (
    noFormPost => 1,
    default    => '',
);

property code => (
    noFormPost => 1,
    default    => '',
);

property country => (
    noFormPost => 1,
    default    => '',
);

property phoneNumber => (
    noFormPost => 1,
    default    => '',
);

property email => (
    noFormPost => 1,
    default    => '',
);

property organization => (
    noFormPost => 1,
    default    => '',
);

property "addressBookId" => (
    noFormPost => 1,
    required   => 1,
);

property "isProfile" => (
    noFormPost => 1,
    required   => 0,
    default    => 0,
);

has [ qw/addressId addressBook/] => (
    is => 'ro',
    required => 1,
);

use Scalar::Util qw/blessed/;
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

#-------------------------------------------------------------------

=head2 new ( $book, $addressId )

Constructor.  Instanciates an address based upon an addressId.

=head2 new ( $book, $properties )

Constructor.  Builds a new, default address.

=head2 new ( $properties )

Constructor.  Builds a new, default address book object in Moose style with default properties set by $properties. This does not
persist them to the database automatically.  This needs to be done via $self->write.

=head3 $addressBook

A reference to an addressBook object

=head3 $addressId

The unique id of an address to instanciate.

=head3 $properties

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

=head4 isProfile

Whether or not this address is linked to the user profile.  Defaults to 0

=cut


around BUILDARGS => sub {
    my $orig  = shift;
    my $class = shift;
    if (ref $_[0] eq 'HASH') {
        my $properties = $_[0];
        my $book = $properties->{addressBook};
        if (! (blessed $book && $book->isa('WebGUI::Shop::AddressBook')) ) {
            WebGUI::Error::InvalidObject->throw(expected=>"WebGUI::Shop::AddressBook", got=>(ref $book), error=>"Need an address book.", param=>$book);
        }
        my ($addressId)              = $class->_init($book);
        $properties->{addressId}     = $addressId;
        $properties->{addressBookId} = $book->addressBookId;
        $properties->{addressBook}   = $book;
        return $class->$orig($properties);
    }
    my $book = shift;
    if (! (blessed $book && $book->isa('WebGUI::Shop::AddressBook')) ) {
        WebGUI::Error::InvalidObject->throw(expected=>"WebGUI::Shop::AddressBook", got=>(ref $book), error=>"Need an address book.", param=>$book);
    }
    my $argument2 = shift;
    if (!defined $argument2) {
        my ($addressId)              = $class->_init($book);
        my $properties = {};
        $properties->{addressId}     = $addressId;
        $properties->{addressBookId} = $book->addressBookId;
        $properties->{addressBook}   = $book;
        return $class->$orig($properties);
    }
    elsif (ref $argument2 eq 'HASH') {
        my $properties = $argument2;
        my ($addressId)              = $class->_init($book);
        $properties->{addressId}     = $addressId;
        $properties->{addressBookId} = $book->addressBookId;
        $properties->{addressBook}   = $book;
        return $class->$orig($properties);
    }
    ##Look up one in the db
    my $address = $book->session->db->quickHashRef("select * from address where addressId=?", [$argument2]);
    if ($address->{addressId} eq "") {
        WebGUI::Error::ObjectNotFound->throw(error=>"Address not found.", id=>$argument2);
    }
    if ($address->{addressBookId} ne $book->getId) {
        WebGUI::Error::ObjectNotFound->throw(error=>"Address not in this address book.", id=>$argument2);
    }
    $address->{addressBook} = $book;
    return $class->$orig($address);
};

#-------------------------------------------------------------------

=head2 _init ( session )

Builds a stub of object information in the database, and returns the newly created
addressId, and the creationDate fields so the object can be initialized correctly.

=cut

sub _init {
    my $class     = shift;
    my $book      = shift;
    my $session   = $book->session;
    my $addressId = $session->id->generate;
    $session->db->write('insert into address (addressId, addressBookId) values (?,?)', [$addressId, $book->getId]);
    return ($addressId);
}

#-------------------------------------------------------------------

=head2 addressBook ( )

Returns a reference to the Address Book.

=cut

#-------------------------------------------------------------------

=head2 create ( book )

Deprecated, left as a stub for existing code.  Use L<new> instead.

=head3 book

A reference to an address book.

=cut

sub create {
    my ($class, $book) = @_;
    return $class->new($book);
}

#-------------------------------------------------------------------

=head2 delete ( )

Removes this address from the book.

=cut

sub delete {
    my $self = shift;
    $self->addressBook->session->db->deleteRow("address","addressId",$self->getId);
    return undef;
}

#-------------------------------------------------------------------

=head2 getHtmlFormatted ()

Returns an HTML formatted address for display.

=cut

sub getHtmlFormatted {
    my $self = shift;
    my $address = $self->firstName. " " .$self->lastName . "<br />";
    $address .= $self->organization . "<br />" if ($self->organization ne "");
    $address .= $self->address1 . "<br />";
    $address .= $self->address2 . "<br />" if ($self->address2 ne "");
    $address .= $self->address3 . "<br />" if ($self->address3 ne "");
    $address .= $self->city . ", ";
    $address .= $self->state . " " if ($self->state ne "");
    $address .= $self->code if ($self->code ne "");
    $address .= '<br />' . $self->country;
    $address .= '<br />'.$self->phoneNumber if ($self->phoneNumber ne "");
    $address .= '<br /><a href="mailto:'.$self->email.'">'.$self->email.'</a>' if ($self->email ne "");
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

=head2 write ( )

Store the object's properties to the db.

=cut

sub write {
    my ($self) = @_;
    my $properties = $self->get();
    my $book = delete $properties->{addressBook};
    $book->session->db->setRow("address","addressId",$properties);
}

1;
