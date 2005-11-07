package WebGUI::Macro::Product;

use strict;
use WebGUI::Session;
use WebGUI::Product;
use WebGUI::Asset::Template;
use WebGUI::SQL;
use WebGUI::International;

sub process {
	my (@param, $productId, $variantId, $product, $variant, $output, $templateId, @variantLoop, %var);
	
	@param = @_;
	
	return 'No SKU or productId passed' unless ($_[0]);

	($productId, $variantId) = WebGUI::SQL->quickArray("select productId, variantId from productVariants where sku=".quote($_[0]));
	($productId) = WebGUI::SQL->quickArray("select productId from products where sku=".quote($_[0])) unless ($productId);
	($productId) = WebGUI::SQL->quickArray("select productId from products where productId=".quote($_[0])) unless ($productId);
	
	return WebGUI::International::get('cannot find product','Macro_Product') unless ($productId);

	$product = WebGUI::Product->new($productId);

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
			'variant.addToCart.url' => WebGUI::URL::page('op=addToCart;itemType=Product;itemId='.$_->{variantId}),
			'variant.addToCart.label' => WebGUI::International::get('add to cart', 'Macro_Product'),
		}) if ($_->{available});
	}

	%var = %{$product->get};
	$var{variantLoop} = \@variantLoop;
	$var{'variants.message'} = WebGUI::International::get('available product configurations', 'Macro_Product');
	$templateId = $_[1] || $product->get('templateId');
	
	return WebGUI::Asset::Template->new($templateId)->process(\%var);
}

1;
	
