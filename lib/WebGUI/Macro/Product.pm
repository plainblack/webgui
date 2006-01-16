package WebGUI::Macro::Product;

use strict;
use WebGUI::Product;
use WebGUI::Asset::Template;
use WebGUI::International;

=head1 NAME

Package WebGUI::Macro::Product

=head1 DESCRIPTION

This macro looks up a Product in the Product Manager 

=head2 process ( ID/SKU [,templateId] )

=head3 productId or SKU

The productId or SKU of the project to look up.

=head3 templateId

An alternate template to use for formatting the link, referenced by templateId.  If this
is left blank, a default template from the Macro/Product namespace will be used.

=cut

sub process {
	my $session = shift; use WebGUI; WebGUI::dumpSession($session);
	my (@param, $productId, $variantId, $product, $variant, $output, $templateId, @variantLoop, %var);
	
	@param = @_;
	
	my $i18n = WebGUI::International->new($session,'Macro_Product');
	return $i18n->get('no sku or id') unless ($_[0]);

	($productId, $variantId) = $session->db->quickArray("select productId, variantId from productVariants where sku=".$session->db->quote($_[0]));
	($productId) = $session->db->quickArray("select productId from products where sku=".$session->db->quote($_[0])) unless ($productId);
	($productId) = $session->db->quickArray("select productId from products where productId=".$session->db->quote($_[0])) unless ($productId);
	
	return $i18n->get('cannot find product') unless ($productId);

	$product = WebGUI::Product->new($session,$productId);

	if ($variantId) {
		$variant = [ $product->getVariant($variantId) ];
	} else {
		$variant = $product->getVariant;
	};
		
	foreach (@$variant) {
		my @compositionLoop;
		foreach (split(/,/,$_->{composition})) {
			my ($parameterId, $optionId) = split(/\./, $_);
			push(@compositionLoop, {
				parameter 	=> $product->getParameter($parameterId)->{name},
				value		=> $product->getOption($optionId)->{value}
			});
		}

		push (@variantLoop, {
			'variant.variantId' => $_->{variantId},
		        'variant.price' => $_->{price},
			'variant.weight' => $_->{weight},
			'variant.sku' => $_->{sku},
			'variant.compositionLoop' => \@compositionLoop,
			'variant.addToCart.url' => $session->url->page('op=addToCart;itemType=Product;itemId='.$_->{variantId}),
			'variant.addToCart.label' => $i18n->get('add to cart'),
		}) if ($_->{available});
	}

	%var = %{$product->get};
	$var{variantLoop} = \@variantLoop;
	$var{'variants.message'} = $i18n->get('available product configurations');
	$templateId = $_[1] || $product->get('templateId');
	
	return WebGUI::Asset::Template->new($session,$templateId)->process(\%var);
}

1;
	
