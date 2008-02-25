package WebGUI::Shop::Cart;

use strict;

use Class::InsideOut qw{ :std };
use Carp qw(croak);
use WebGUI::Shop::CartItems;

=head1 NAME

Package WebGUI::Shop::Cart

=head1 DESCRIPTION

The cart is the glue that holds a user's order together until they're ready to check out.

=head1 SYNOPSIS

 use WebGUI::Shop::Cart;

 my $cart = WebGUI::Shop::Cart->new($session);

=head1 METHODS

These subroutines are available from this package:

=cut

readonly session => my %session;
public properties => my %properties;

#-------------------------------------------------------------------

=head2 addItem ( item, [ quantity ])

Adds an item to the cart. Returns the number of items now in the cart.

=head3 item

A reference to a subclass of WebGUI::Asset::Sku.

=head3 quantity

The number of items configured this way. Defaults to 1. 

=cut

sub addItem {
    my ($self, $item, $quantity) = @_;
    croak "Need a SKU item." unless (defined $item && $item->isa("WebGUI::Asset::Sku"));
    $quantity ||= 1;
    croak "Too many items of that type in cart." if ($quantity > $item->getMaxAlowedInCart);
    my $item = WebGUI::Shop::CartItem->create(
        $self->session, 
        $self->getId,
        $item,
        $quantity,
        );
    return $item;
}

#-------------------------------------------------------------------

=head2 create ( session )

Constructor. Creates a new cart object if there’s not one already attached to the current session object. Otherwise just instanciates the existing one.  Returns a reference to the object.

=head3 session

A reference to the current session.

=cut

sub create {
    my ($class, $session) = @_;
    croak "Need a session." unless (defined $session && $session->isa("WebGUI::Session"));
    my $cartId = $session->db->quickScalar("select cartId from cart where sessionId=?",[$session->getId]);
    return $class->new($session, $cartId) if (defined $cartId);
    my $cartId = $session->id->generate;
    $session->db->write('insert into cart (cartId, sessionId) values (?,?)', [$cartId, $session->getId]);
    bless my $self, $class;
    register $self;
    my $id        = id $self;
    $session{ $id }   = $session;
    $properties{ $id } = {cartId=>$cartId, sessionId=>$session->getId};
    return $self;
}

#-------------------------------------------------------------------

=head2 delete ()

Deletes this cart and all cartItems contained in it.

=cut

sub delete {
    my ($self) = @_;
    $self->empty;
    $self->session->db->write("delete from cart where cartId=?",[$self->getId]);
}

#-------------------------------------------------------------------

=head2 empty ()

Removes all items from this cart.

=cut

sub empty {
    my ($self) = @_;
    foreach my $item = (@{$self->getItems}) {
        $item->delete;
    } 
}

#-------------------------------------------------------------------

=head2 get ( [ property ] )

Returns a duplicated hash reference of this object’s data.

=head3 property

Any field − returns the value of a field rather than the hash reference.

=cut

sub get {
    my ($self, $property) = @_;
    if (defined $property) {
        return $self->{_properties}{$propertyName};
    }
    my %copyOfHashRef = $properties{id $self};
    return \%copyOfHashRef;
}

#-------------------------------------------------------------------

=head2 getId ()

Returns the unique id for this cart.

=cut

sub getId {
    my ($self) = @_;
    return $self->get("cartId");
}

#-------------------------------------------------------------------

=head2 getItems ( )

Returns an array reference of WebGUI::Asset::Sku objects that are in the cart.

=cut

sub getItems {
    my ($self) = @_;
    my @itemsObjects = ();
    my $items = $self->session->db->read("select assetId from cartItems where cartId=?",[$self->getId]);
    while (my ($assetId) = $items->array) {
        push(@itemsObjects, WebGUI::Shop::CartItems->new($self->session, $assetId));
    }
    return \@itemsObjects;
}

#-------------------------------------------------------------------

=head2 new ( session, cartId )

Constructor.  Instanciates a cart based upon a cartId.

=head3 session

A reference to the current session.

=head3 cartId

The unique id of a cart to instanciate.

=cut

sub new {
    my ($class, $session, $cartId) = @_;
    croak "Need a session" unless (defined $session && $session->isa("WebGUI::Session");
    croak "Need a cartId" unless defined $cartId;
    my $cart = $session->db->quickHashRef('select * from cart where cartId=?', [$cartId]);
    croak "No cart with id of $cartId" if ($cart->{cartId} eq "");
    bless my $self, $class;
    register $self;
    my $id        = id $self;
    $session{ $id }   = $session;
    $properties{ $id } = $cart;
    return $self;
}

#-------------------------------------------------------------------

=head2 update ( properties )

Sets properties in the cart.

=head3 properties

A hash reference that contains one of the following:

=head4 couponId

The unique id for a coupon used in this cart.

=head4 shippingAddressId

The unique id for a shipping address attached to this cart.

=cut

sub update {
    my ($self, $properties) = @_;
    my $id = id $self;
    $properties{$id}{couponId} = $properties->{couponId} || $self->properties->{couponId};
    $properties{$id}{shippingAddressId} = $properties->{shippingAddressId} || $self->properties->{shippingAddressId};
    $self->session->db->setRow("cart","cartId",$self->properties);
}


1;
