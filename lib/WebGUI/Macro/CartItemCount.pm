package WebGUI::Macro::CartItemCount;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2012 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use strict;
use WebGUI::Shop::Cart;

=head1 NAME

Package WebGUI::Macro::CartItemCount

=head1 DESCRIPTION

Returns an integer of the number of items currently in the cart.

=head2 process( $session )

Renders the macro.

=cut


#-------------------------------------------------------------------
sub process {
	my ($session) = @_;
	my $cart = WebGUI::Shop::Cart->newBySession($session);
	my $count = 0;
	foreach my $item (@{$cart->getItems}) {
		$count += $item->get('quantity');
	}
	return $count;
}

1;


