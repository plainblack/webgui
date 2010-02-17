package WebGUI::Shop::ShipDriver::FlatRate;

use strict;
use base qw/WebGUI::Shop::ShipDriver/;
use WebGUI::Exception;

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
			$cost += ($quantity * $sku->getPrice * $self->get("percentageOfPrice") / 100)  # cost by price
				   + ($quantity * $sku->getWeight * $self->get("pricePerWeight") / 100)	# cost by weight
				   + ($quantity * $self->get("pricePerItem"));								# cost by item
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
		$cost += $self->get('flatFee') * ($separatelyShipped + $looseBundle);
	}
    return $cost;
}

#-------------------------------------------------------------------

=head2 definition ( $session )

This subroutine returns an arrayref of hashrefs, used to validate data put into
the object by the user, and to automatically generate the edit form to show
the user.

=cut

sub definition {
    my $class      = shift;
    my $session    = shift;
    WebGUI::Error::InvalidParam->throw(error => q{Must provide a session variable})
        unless ref $session eq 'WebGUI::Session';
    my $definition = shift || [];
    my $i18n = WebGUI::International->new($session, 'ShipDriver_FlatRate');
    tie my %fields, 'Tie::IxHash';
    %fields = (
        flatFee => {
            fieldType    => 'float',
            label        => $i18n->get('flatFee'),
            hoverHelp    => $i18n->get('flatFee help'),
            defaultValue => 0,
        },
        percentageOfPrice => {
            fieldType    => 'float',
            label        => $i18n->get('percentageOfPrice'),
            hoverHelp    => $i18n->get('percentageOfPrice help'),
            defaultValue => 0,
        },
        pricePerWeight => {
            fieldType    => 'float',
            label        => $i18n->get('percentageOfWeight'),
            hoverHelp    => $i18n->get('percentageOfWeight help'),
            defaultValue => 0,
        },
        pricePerItem => {
            fieldType    => 'float',
            label        => $i18n->get('pricePerItem'),
            hoverHelp    => $i18n->get('pricePerItem help'),
            defaultValue => 0,
        },
    );
    my %properties = (
        name        => 'Flat Rate',
        properties  => \%fields,
    );
    push @{ $definition }, \%properties;
    return $class->SUPER::definition($session, $definition);
}

1;
