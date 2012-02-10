package WebGUI::Shop::ShipDriver::FlatRate;

use strict;
use Moose;
use WebGUI::Definition::Shop;
extends qw/WebGUI::Shop::ShipDriver/;
use WebGUI::Exception;

define pluginName => ['Flat Rate','ShipDriver_FlatRate'];
property flatFee => (
            fieldType    => 'float',
            label        => ['flatFee', 'ShipDriver_FlatRate'],
            hoverHelp    => ['flatFee help', 'ShipDriver_FlatRate'],
            default      => 0,
         );
property percentageOfPrice => (
            fieldType    => 'float',
            label        => ['percentageOfPrice', 'ShipDriver_FlatRate'],
            hoverHelp    => ['percentageOfPrice help', 'ShipDriver_FlatRate'],
            default      => 0,
         );
property pricePerWeight => (
            fieldType    => 'float',
            label        => ['percentageOfWeight', 'ShipDriver_FlatRate'],
            hoverHelp    => ['percentageOfWeight help', 'ShipDriver_FlatRate'],
            default      => 0,
         );
property pricePerItem => (
            fieldType    => 'float',
            label        => ['pricePerItem', 'ShipDriver_FlatRate'],
            hoverHelp    => ['pricePerItem help', 'ShipDriver_FlatRate'],
            default      => 0,
         );

=head1 NAME

Package WebGUI::Shop::ShipDriver::FlatRate

=head1 DESCRIPTION

This Shipping driver allows for calculating shipping costs without any
tie-ins to external shippers.

=head1 SYNOPSIS

=head1 METHODS

See the master class, WebGUI::Shop::ShipDriver for information about
base methods.  These methods are customized in this class:

=cut

#-------------------------------------------------------------------

=head2 calculate ( $cart )

Returns a shipping price. Calculates the shipping price using the following formula:

    total price of shippable items * percentageOfPrice
    + total weight of shippable items * pricePerWeight
    + total quantity of shippable items * pricePerItem
    + flatFee * numberOfSeparatelyShippedItems

=head3 $cart

A WebGUI::Shop::Cart object.  The contents of the cart are analyzed to calculate
the shipping costs.  If no items in the cart require shipping, then no shipping
costs are assessed.

=cut

sub calculate {
    my ($self, $cart) = @_;
	my $cost = 0;
	my $anyShippable = 0;
    my $separatelyShipped = 0;
    my $looseBundle = 0;
	foreach my $item (@{$cart->getItems}) {
		my $sku = $item->getSku;
		if ($sku->isShippingRequired) {
            my $quantity = $item->get('quantity');
			$cost += ($quantity * $sku->getPrice * $self->percentageOfPrice / 100)  # cost by price
				   + ($quantity * $sku->getWeight * $self->pricePerWeight / 100)	# cost by weight
				   + ($quantity * $self->pricePerItem);								# cost by item
			$anyShippable = 1;
            ##Account for items which must be shipped separately, and with those that can be shipped
            ##together.
            ## Two items shipped separately    = two bundles
            ## 1 shipped separately plus 1 not = two bundles
            ## two items shipped together      = one bundle
            if ($sku->isShippingSeparately) {
                $separatelyShipped += $quantity;
            }
            else {
                $looseBundle = 1;
            }
		}
	}
	if ($anyShippable) {
		$cost += $self->flatFee * ($separatelyShipped + $looseBundle);
	}
    return $cost;
}

1;
