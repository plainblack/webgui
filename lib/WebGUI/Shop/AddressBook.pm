package WebGUI::Shop::AddressBook;

use strict;

use Class::InsideOut qw{ :std };
use WebGUI::Asset::Template;
use WebGUI::Exception::Shop;
use WebGUI::International;
use WebGUI::Shop::Address;

=head1 NAME

Package WebGUI::Shop::AddressBook;

=head1 DESCRIPTION

Managing addresses for commerce.

=head1 SYNOPSIS

 use WebGUI::Shop::AddressBook;

 my $book = WebGUI::Shop::AddressBook->new($session);

=head1 METHODS

These subroutines are available from this package:

=cut

readonly session => my %session;
private properties => my %properties;
private error => my %error;

#-------------------------------------------------------------------

=head2 addAddress ( address )

Adds an address to the address book.

=head2 address

A hash reference containing address information.

=cut

sub addAddress {
    my ($self, $address) = @_;
    my $addressObj = WebGUI::Shop::Address->create( $self, $address);
    return $addressObj;
}

#-------------------------------------------------------------------

=head2 convertToUser ( userId )

Converts a session based address book to be owned by a user. If the user already has an address book then the address book will be merged with this one. 

=head3 userId

The userId to own this address book.

=cut

sub convertToUser {
    my ($self, $userId) = @_;
    $self->update({userId=>$userId});
    my $other = $self->session->db->read("select addressBookId from addressBook where addressBookId<>? and userId=?", [$self->getId, $userId]);
    while (my ($id) = $other->array) {
        my $book = __PACKAGE__->new($self->session, $id);
        foreach my $address (@{$book->getAddresses}) {
            $address->update({addressBookId=>$self->getId});
        }
        $book->delete;
    }    
}


#-------------------------------------------------------------------

=head2 create ( session )

Constructor. Creates a new address book for this user if they don't have one. If the user is not logged in creates an address book attached to the session if there isn't one for the session. In any case returns a reference to the address book.

=head3 session

A reference to the current session.

=cut

sub create {
    my ($class, $session) = @_;
    unless (defined $session && $session->isa("WebGUI::Session")) {
        WebGUI::Error::InvalidObject->throw(expected=>"WebGUI::Session", got=>(ref $session), error=>"Need a session.");
    }
    # check to see if we're dealing with a registered user or just a visitor
    if ($session->user->userId ne "1") {  
        # check to see if this user or his session already has an address book
        my $addressBookId = "";
        my @ids = $session->db->buildArray("select addressBookId from addressBook where userId=? or sessionId=?",[$session->user->userId, $session->getId]);
        if (scalar(@ids) > 0) {
            # how are we looking
            my $book = $class->new($session, $ids[0]);
            if ($book->get("userId") eq "" || scalar(@ids) > 1) {
                # it's attached to the session or we have too many
                $book->convertToUser($session->user->userId);
            }
            # it's ours
            return $book;
        }
        else {
            # nope create one for the user
            my $id = $session->db->setRow("addressBook", "addressBookId", {addressBookId=>"new", userId=>$session->user->userId}); 
            return $class->new($session, $id);
        }
    }
    else {
        # check to see if this session already has an address book
        my $addressBookId = $session->db->quickScalar("select addressBookId from addressBook where sessionId=?",[$session->getId]);
        if ($addressBookId eq "") {
            # nope, create one for the session
            $addressBookId = $session->db->setRow("addressBook", "addressBookId", {addressBookId=>"new", sessionId=>$session->getId}); 
        }
        return $class->new($session, $addressBookId);
    }
}

#-------------------------------------------------------------------

=head2 delete ()

Deletes this address book and all addresses contained in it.

=cut

sub delete {
    my ($self) = @_;
    foreach my $address (@{$self->addresses}) {
        $address->delete;
    } 
    $self->session->db->write("delete from addressBook where addressBookId=?",[$self->getId]);
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

=head2 getId ()

Returns the unique id for this cart.

=cut

sub getId {
    my ($self) = @_;
    return $self->get("addressBookId");
}

#-------------------------------------------------------------------

=head2 getAddresses ( )

Returns an array reference of address objects that are in this book.

=cut

sub getAddresses {
    my ($self) = @_;
    my @addressObjects = ();
    my $addresses = $self->session->db->read("select addressId from addresses where addressBookId=?",[$self->getId]);
    while (my ($addressId) = $addresses->array) {
        push(@addressObjects, WebGUI::Shop::Address->new($self, $addressId));
    }
    return \@addressObjects;
}

#-------------------------------------------------------------------

=head2 new ( session, addressBookId )

Constructor.  Instanciates a cart based upon a addressBookId.

=head3 session

A reference to the current session.

=head3 addressBookId

The unique id of an address book to instanciate.

=cut

sub new {
    my ($class, $session, $addressBookId) = @_;
    unless (defined $session && $session->isa("WebGUI::Session")) {
        WebGUI::Error::InvalidObject->throw(expected=>"WebGUI::Session", got=>(ref $session), error=>"Need a session.");
    }
    unless (defined $addressBookId) {
        WebGUI::Error::InvalidParam->throw(error=>"Need an addressBookId.");
    }
    my $addressBook = $session->db->quickHashRef('select * from addressBook where addressBookId=?', [$addressBookId]);
    if ($addressBook->{addressBookId} eq "") {
        WebGUI::Error::ObjectNotFound->throw(error=>"No such address book.", id=>$addressBookId);
    }
    my $self = register $class;
    my $id        = id $self;
    $session{ $id }   = $session;
    $properties{ $id } = $addressBook;
    return $self;
}

#-------------------------------------------------------------------

=head2 update ( properties )

Sets properties in the addressBook

=head3 properties

A hash reference that contains one of the following:

=head4 lastShipId

The last addressId used for shipping.

=head4 lastPayId

The last addressId used for payment.

=head4 userId

Assign the user that owns this address book.

=head4

Assign the session that owns this adress book. Will automatically be set to "" if a user owns it.

=cut

sub update {
    my ($self, $newProperties) = @_;
    my $id = id $self;
    $properties{$id}{lastShipId} = $newProperties->{lastShipId} || $properties{$id}{lastShipId};
    $properties{$id}{lastPayId} = $newProperties->{lastPayId} || $properties{$id}{lastPayId};
    $properties{$id}{userId} = (exists $newProperties->{userId}) ? $newProperties->{userId} : $properties{$id}{userId};
    $properties{$id}{sessionId} = (exists $newProperties->{sessionId}) ? $newProperties->{sessionId} : $properties{$id}{sessionId};
    if ($properties{$id}{userId} ne "") {
        $properties{$id}{sessionId} = "";
    }
    $self->session->db->setRow("addressBook","addressBookId",$properties{$id});
}


1;

