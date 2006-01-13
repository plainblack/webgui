package WebGUI::Commerce::Item::Product;

use strict;
#use WebGUI::SQL;
use WebGUI::Product;

our @ISA = qw(WebGUI::Commerce::Item);

#-------------------------------------------------------------------
sub available {
	return $_[0]->{_variant}->{available};
}

#-------------------------------------------------------------------
sub description {
	return $_[0]->{_product}->get('description');
}

#-------------------------------------------------------------------
#sub duration {
#

#-------------------------------------------------------------------
#sub handler {
#}

#-------------------------------------------------------------------
sub id {
	return $_[0]->{_variant}->{variantId};
}

#-------------------------------------------------------------------
sub isRecurring {
	return 0;
}

#-------------------------------------------------------------------
sub name {
	return $_[0]->{_product}->get('title').' ('.$_[0]->{_composition}.')';
}

#-------------------------------------------------------------------
sub new {
	my ($class, $sku, $product, $variantId);
	$class = shift;
	$variantId = shift;
	
	$product = WebGUI::Product->getByVariantId($session,$variantId);
my	$variant = $product->getVariant($variantId);
my	%parameters = map {split(/\./, $_)} split(/,/, $variant->{composition});
my	$composition = join(', ',map {$product->getParameter($_)->{name} .': '. $product->getOption($parameters{$_})->{value}} keys (%parameters));
	
	bless {_product => $product, _composition => $composition, _variant => $variant}, $class;
}

#-------------------------------------------------------------------
sub needsShipping {
	return 1;
}

#-------------------------------------------------------------------
sub price {
	return $_[0]->{_variant}->{price};
}

#-------------------------------------------------------------------
sub type {
	return 'Product';
}

#-------------------------------------------------------------------
sub weight {
	return $_[0]->{_variant}->{weight};
}

1;

