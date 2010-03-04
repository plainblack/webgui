package WebGUI::Macro::MiniCart;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2009 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use strict;
use WebGUI::Asset::Template;
use WebGUI::Shop::Cart;


=head1 NAME

Package WebGUI::Macro::MiniCart

=head1 DESCRIPTION

Displays a miniature view of the shopping cart.

=head2 process( $session, [templateId])

Renders the macro.

=head3 templateId

The ID of a template to use other than the default.

=cut


#-------------------------------------------------------------------
sub process {
	my ($session, $templateId) = @_;
	my $cart = WebGUI::Shop::Cart->newBySession($session);
	my @items = ();
	my $totalItems = 0;
	my $totalPrice = 0;
	foreach my $item (@{$cart->getItems}) {
		my $sku = $item->getSku;
		my $price = $sku->getPrice;
		my $quantity = $item->get('quantity');
		push @items, {
			name		=> $item->get('configuredTitle'),
			quantity	=> $quantity,
			price		=> $price,
			url			=> $sku->getUrl('shop=cart;method=viewItem;itemId='.$item->getId),
			};
		$totalItems += $quantity;
		$totalPrice += $quantity * $price;
	}
	my %var = (
		items			=> \@items,
		totalPrice		=> sprintf("%.2f",$totalPrice),
		totalItems		=> $totalItems,
		);
	my $template = WebGUI::Asset::Template->newById($session, $templateId || 'EBlxJpZQ9o-8VBOaGQbChA');
	return $template->process(\%var);
}

1;


