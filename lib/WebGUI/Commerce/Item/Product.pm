package WebGUI::Commerce::Item::Product;

=head1 LEGAL

 -------------------------------------------------------------------
  WebGUI is Copyright 2001-2006 Plain Black Corporation.
 -------------------------------------------------------------------
  Please read the legal notices (docs/legal.txt) and the license
  (docs/license.txt) that came with this distribution before using
  this software.
 -------------------------------------------------------------------
  http://www.plainblack.com                     info@plainblack.com
 -------------------------------------------------------------------

=head1 NAME

Package WebGUI::Commerce::Item::Product

=head1 DESCRIPTION

Item plugin for products in the Commerce system.

=cut

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

=head2 new ( $session )

Overload default constructor to glue in a WebGUI::Product object.

=cut

sub new {
	my ($class, $session, $sku, $product, $variantId);
	$class = shift;
	$session = shift;
	$variantId = shift;
	
	$product = WebGUI::Product->getByVariantId($session,$variantId);
	my $variant = $product->getVariant($variantId);
	my %parameters = map {split(/\./, $_)} split(/,/, $variant->{composition});
	my $composition = join(', ',map {$product->getParameter($_)->{name} .': '. $product->getOption($parameters{$_})->{value}} keys (%parameters));
	
	bless {_product => $product, _composition => $composition, _variant => $variant, _session => $session }, $class;
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

