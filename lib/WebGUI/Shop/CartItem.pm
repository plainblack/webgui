package WebGUI::Shop::CartItem;

use strict;
use Class::InsideOut qw{ :std };
use Carp qw(croak);
use JSON;
use WebGUI::Asset;

=head1 NAME

Package WebGUI::Shop::CartItem

=head1 DESCRIPTION

A cart item is a manager of a WebGUI::Asset::Sku class that is put into a user's cart.

=head1 SYNOPSIS

 use WebGUI::Shop::CartItem;

 my $item = WebGUI::Shop::CartItem->new($session, $cartId, $assetId);

=head1 METHODS

These subroutines are available from this package:

=cut

readonly cart => my %cart;
private properties => my %properties;

#-------------------------------------------------------------------

=head2 cart ( )

Returns a reference to the cart.

=cut

#-------------------------------------------------------------------

=head2 create ( cart, item)

Constructor. Adds an item to the cart. Returns a reference to the item.

=head3 cart

A reference to WebGUI::Shop::Cart object.

=head3 item

A reference to a subclass of WebGUI::Asset::Sku.

=cut

sub create {
    my ($class, $cart, $sku) = @_;
    croak "Need a cart." unless (defined $cart && $cart->isa("WebGUI::Shop::Cart"));
    croak "Need a SKU item." unless (defined $sku && $sku->isa("WebGUI::Asset::Sku"));
    my $itemId = $cart->session->id->generate;
    $cart->session->db->write('insert into cartItems (quantity, cartId, assetId, itemId) values (1,?,?,?)', [$cart->getId, $sku->getId, $itemId]);
    my $self = $class->new($cart, $itemId);
    $self->update({asset=>$sku});
    return $self;
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
        if ($name eq "options") {
            my $options = $properties{id $self}{$name};
            if ($options eq "") {
                return {};
            }
            else {
                return JSON::from_json($properties{id $self}{$name});
            }
        }
        return $properties{id $self}{$name};
    }
    my %copyOfHashRef = $properties{id $self};
    return \%copyOfHashRef;
}

#-------------------------------------------------------------------

=head2 getId () 

Returns the unique id of this item.

=cut

sub getId {
    my $self = shift;
    return $self->get("itemId");
}


#-------------------------------------------------------------------

=head2 getSku ( )

Returns an instanciated WebGUI::Asset::Sku object for this cart item.

=cut

sub getSku {
    my ($self) = @_;
    my $asset = WebGUI::Asset->newByDynamicClass($self->cart->session, $self->get("assetId"));
    $asset->applyOptions($self->get("options"));
    return $asset;
}


#-------------------------------------------------------------------

=head2 incrementQuantity ( [ quantity ] )

Increments quantity of item by one. Returns the quantity of this item in the cart.

=head3 quantity

If specified may increment quantity by more than one. Specify a negative number to decrement quantity. If the quantity ever reaches 0 or lower, the item will be removed from the cart.

=cut

sub incrementQuantity {
    my ($self, $quantity) = @_;
    $quantity ||= 1;
    my $id = id $self;
    if ($self->get("quantity") + $quantity > $self->getSku->getMaxAllowedInCart) {
        croak "Cannot have that many in cart.";
    }
    if ($self->get("quantity") + $quantity <= 0) {
        return $self->remove;
    }
    $properties{$id}{quantity} += $quantity;
    $self->cart->session->db->setRow("cartItems","itemId", $properties{$id});
    return $properties{$id}{quantity};
}


#-------------------------------------------------------------------

=head2 new ( session, cart, itemId )

Constructor.  Instanciates a cart based upon a cartId.

=head3 cart

A reference to the current cart we're working with.

=head3 itemId

The unique id of the item to instanciate.

=cut

sub new {
    my ($class, $cart, $itemId) = @_;
    croak "Need a cart" unless (defined $cart && $cart->isa("WebGUI::Shop::Cart"));
    croak "Need an itemId" unless defined $itemId;
    my $item = $cart->session->db->quickHashRef('select * from cartItems where itemId=?', [$itemId]);
    croak "No item with id of $itemId" if ($item->{itemId} eq "");
    croak "Item $itemId is not in this cart." if ($item->{cartId} ne $cart->getId);
    my $self = register $class;
    my $id        = id $self;
    $cart{ $id }   = $cart;
    $properties{ $id } = $item;
    return $self;
}

#-------------------------------------------------------------------

=head2 remove ( )

Removes this item from the cart.

=cut

sub remove {
    my $self = shift;
    $self->cart->session->db->deleteRow("cartItems","itemId",$self->getId);
    undef $self;
    return undef;
}


#-------------------------------------------------------------------

=head2 update ( properties )

Sets properties of the cart item.

=head3 properties

A hash reference that contains one of the following:

=head4 asset

This is a special meta property. It is a reference to a WebGUI::Asset::Sku subclass object. If you pass this reference it will acquire the assetId and options properties automatically.

=head4 assetId 

The assetId of the asset to add to the cart.

=head4 options

The configuration options for this asset.

=head4 shippingAddressId

The unique id for a shipping address attached to this cart.

=cut

sub update {
    my ($self, $newProperties) = @_;
    my $id = id $self;
    if (exists $newProperties->{asset}) {
        $newProperties->{options} = $newProperties->{asset}->getOptions;
        $newProperties->{assetId} = $newProperties->{asset}->getId;       
    }
    $properties{$id}{assetId} = $newProperties->{assetId} || $properties{$id}{assetId};
    if (exists $newProperties->{options} && ref($newProperties->{options}) eq "HASH") {
        $properties{$id}{options} = JSON::to_json($newProperties->{options});
    }
    $properties{$id}{shippingAddressId} = $newProperties->{shippingAddressId} || $properties{$id}{shippingAddressId};
    $self->cart->session->db->setRow("cartItems","cartId",$properties{$id});
}


1;
