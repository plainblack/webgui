package WebGUI::Shop::CartItem;

use strict;

use Scalar::Util qw/blessed/;
use Moose;
use WebGUI::Definition;
property assetId => (
    is => 'rw',
    noFormPost => 1,
    default => '',
);
property configuredTitle => (
    is => 'rw',
    noFormPost => 1,
    default => '',
);
property options => (
    is         => 'rw',
    noFormPost => 1,
    default    => sub { return {}; },
    traits     => ['Hash', 'WebGUI::Definition::Meta::Property::Serialize',],
    isa        => 'WebGUI::Type::JSONHash',
    coerce     => 1,
);
property shippingAddressId => (
    is => 'rw',
    noFormPost => 1,
    default => '',
);
property quantity => (
    is => 'rw',
    noFormPost => 1,
    default => '1',
    trigger => \&_call_sku,
);
sub _call_sku {
    my ($self, $newQuantity) = @_;
}
property dateAdded => (
    is => 'ro',
    noFormPost => 1,
    default => '',
);

has [ qw/cart itemId/ ] => (
    is       => 'ro',
    required => 1,
);

has asset => (
    is      => 'rw',
    trigger => \&_mine_asset,
);

sub _mine_asset {
    my ($self, $asset) = @_;
    $self->options($asset->getOptions);
    $self->assetId($asset->getId);
    $self->configuredTitle($asset->getConfiguredTitle);
}

use JSON;
use WebGUI::Asset;
use WebGUI::Exception::Shop;

=head1 NAME

Package WebGUI::Shop::CartItem

=head1 DESCRIPTION

A cart item is a manager of a WebGUI::Asset::Sku class that is put into a user's cart.

=head1 SYNOPSIS

 use WebGUI::Shop::CartItem;

 my $item = WebGUI::Shop::CartItem->new($cart);

=head1 METHODS

These subroutines are available from this package:

=cut

around BUILDARGS => sub {
    my $orig  = shift;
    my $class = shift;
    if (ref $_[0] eq 'HASH') {
        my $properties = $_[0];
        my $cart = $properties->{cart};
        if (! (blessed $cart && $cart->isa("WebGUI::Shop::Cart"))) {
            WebGUI::Error::InvalidObject->throw(expected=>"WebGUI::Shop::Cart", got=>(ref $cart), error=>"Need a cart.");
        }
        my $sku = $properties->{sku};
        if (! (blessed $sku && $sku->isa("WebGUI::Asset::Sku"))) {
            WebGUI::Error::InvalidObject->throw(expected=>"WebGUI::Asset::Sku", got=>(ref $sku), error=>"Need a SKU item.");
        }
        my ($itemId, $dateAdded) = $class->_init($cart);
        $properties->{itemId}    = $itemId;
        $properties->{cartId}    = $cart->getId;
        $properties->{dateAdded} = $dateAdded;
        return $class->$orig($properties);
    }
    my $cart = shift;
    if (! (blessed $cart && $cart->isa("WebGUI::Shop::Cart"))) {
        WebGUI::Error::InvalidObject->throw(expected=>"WebGUI::Shop::Cart", got=>(ref $cart), error=>"Need a cart.");
    }
    my $argument2 = shift;
    if (!defined $argument2) {
        WebGUI::Error::InvalidParam->throw( param=>$argument2, error=>"Need a itemId.");
    }
    if (blessed $argument2 && $argument2->isa('WebGUI::Asset::Sku')) {
        ##Build a new one
        my ($itemId, $dateAdded) = $class->_init($cart);
        my $properties           = {};
        $properties->{itemId}    = $itemId;
        $properties->{cartId}    = $cart->getId;
        $properties->{dateAdded} = $dateAdded;
        $properties->{asset}     = $argument2;
        $properties->{cart}      = $cart;
        return $class->$orig($properties);
    }
    else {
        ##Look up one in the db
        my $item = $cart->session->db->quickHashRef("select * from cartItem where itemId=?", [$argument2]);
        if ($item->{itemId} eq "") {
            WebGUI::Error::ObjectNotFound->throw(error=>"Item not found", id=>$argument2);
        }
        if ($item->{cartId} ne $cart->getId) {
            WebGUI::Error::ObjectNotFound->throw(error=>"Item not in this cart.", id=>$argument2);
        }
        $item->{cart} = $cart;
        return $class->$orig($item);
    }
};

#-------------------------------------------------------------------

=head2 _init ( cart )

Builds a stub of object information in the database, and returns the newly created
itemId, and the dateAdded fields so the object can be initialized correctly.

=head3 cart

A Cart object, to tag the item and to provide a session object.

=cut

sub _init {
    my $class     = shift;
    my $cart      = shift;
    my $session   = $cart->session;
    my $itemId    = $session->id->generate;
    my $dateAdded = WebGUI::DateTime->new($session)->toDatabase;
    $session->db->write("insert into cartItem (itemId, dateAdded, cartId) values (?,?,?)",[$itemId, $dateAdded, $cart->getId]);
    return ($itemId, $dateAdded);
}

#-------------------------------------------------------------------

=head2 adjustQuantity ( [ quantity ] )

Increments quantity of item by one. Returns the quantity of this item in the cart.

=head3 quantity

If specified may increment quantity by more than one. Specify a negative number to decrement quantity. If the quantity ever reaches 0 or lower, the item will be removed from the cart.

=cut

sub adjustQuantity {
    my ($self, $quantity) = @_;
    $quantity ||= 1;
    $self->setQuantity($quantity + $self->quantity);
    return $self->quantity;
}


#-------------------------------------------------------------------

=head2 cart ( )

Returns a reference to the cart.

=cut

#-------------------------------------------------------------------

=head2 delete ( )

Removes this item from the cart without calling $sku->onRemoveFromCart which would adjust inventory levels. See also remove().

=cut

sub delete {
    my $self = shift;
    $self->cart->session->db->deleteRow("cartItem","itemId",$self->getId);
    return undef;
}

#-------------------------------------------------------------------

=head2 getId ()

Returns the unique id of this item.

=cut

sub getId {
    my $self = shift;
    return $self->itemId;
}


#-------------------------------------------------------------------

=head2 getShippingAddress ()

Returns the WebGUI::Shop::Address object that is attached to this item for shipping.

=cut

sub getShippingAddress {
    my $self = shift;
    my $addressId = $self->shippingAddressId || $self->cart->shippingAddressId;
    return $self->cart->getAddressBook->getAddress($addressId);
}

#-------------------------------------------------------------------

=head2 getSku ( )

Returns an instanciated WebGUI::Asset::Sku object for this cart item.

=cut

sub getSku {
    my ($self) = @_;
    my $asset = eval { WebGUI::Asset->newById($self->cart->session, $self->assetId); };
    if (!Exception::Class->caught) {
        $asset->applyOptions($self->options);
    }
    return $asset;
}



#-------------------------------------------------------------------

=head2 remove ( )

Removes this item from the cart and calls $sku->onRemoveFromCart. See also delete().

=cut

sub remove {
    my $self = shift;
    my $sku = eval { $self->getSku; };
    $sku->onRemoveFromCart($self) if $sku;
    return $self->delete;
}


#-------------------------------------------------------------------

=head2 setQuantity ( quantity )

Sets quantity of this item in the cart.

=head3 quantity

The number to set the quantity to. Zero or less will remove the item from cart.

=cut

sub setQuantity {
    my ($self, $newQuantity) = @_;
    my $currentQuantity = $self->quantity;
    if ($newQuantity > $self->getSku->getMaxAllowedInCart) {
        WebGUI::Error::Shop::MaxOfItemInCartReached->throw(error=>"Cannot have that many of this item in cart.");
    }
    if ($newQuantity <= 0) {
        return $self->remove;
    }
    $self->quantity($newQuantity);
    $self->write();
    $self->getSku->onAdjustQuantityInCart($self, $newQuantity - $currentQuantity);
}

#-------------------------------------------------------------------

=head2 update ( properties )

Sets properties of the cart item.

=head3 properties

A hash reference that contains one of the following:

=head4 asset

This is a special meta property. It is a reference to a WebGUI::Asset::Sku subclass object. If you pass this reference it will acquire the assetId, configuredTitle, and options properties automatically.

=head4 assetId

The assetId of the asset to add to the cart.

=head4 options

The configuration options for this asset.

=head4 configuredTitle

The title of this product as configured.

=head4 shippingAddressId

The unique id for a shipping address attached to this cart.

=cut

sub write {
    my ($self) = @_;
    my %properties       = %{ $self->get() };
    $properties{options} = JSON->new->encode($properties{options});
    delete @properties{qw/cart asset/};
    $self->cart->session->db->setRow("cartItem","itemId",\%properties);
}


1;
