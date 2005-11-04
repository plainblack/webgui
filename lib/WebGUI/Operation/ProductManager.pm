package WebGUI::Operation::ProductManager;

use strict;
use WebGUI::Session;
use WebGUI::SQL;
use WebGUI::HTMLForm;
use WebGUI::Form;
use WebGUI::FormProcessor;
use WebGUI::Id;
use WebGUI::International;
use WebGUI::AdminConsole;
use Tie::IxHash;
use WebGUI::Product;
use WebGUI::Icon;
use WebGUI::HTML;
use WebGUI::Privilege;
use WebGUI::Grouping;

#-------------------------------------------------------------------
sub _submenu {
	my $i18n = WebGUI::International->new("ProductManager");

	my $workarea = shift;
        my $title = shift;
        $title = $i18n->get($title) if ($title);
        my $help = shift;
        my $ac = WebGUI::AdminConsole->new("productManager");
        if ($help) {
		$ac->setHelp($help, 'ProductManager');
        }

	my $productId = $session{form}{productId} || WebGUI::Session::getScratch('managingProduct');
	undef $productId if ($productId eq 'new');
	$ac->addSubmenuItem(WebGUI::URL::page('op=editProduct;productId=new'), $i18n->get('add product'));
	$ac->addSubmenuItem(WebGUI::URL::page('op=listProducts'), $i18n->get('list products'));
	$ac->addSubmenuItem(WebGUI::URL::page('op=manageProduct;productId='.$productId), $i18n->get('manage product')) if ($productId);
	$ac->addSubmenuItem(WebGUI::URL::page('op=listProductVariants;productId='.$productId), $i18n->get('list variants')) if ($productId);

	return $ac->render($workarea, $title);
}

#-------------------------------------------------------------------
sub www_deleteProductParameterOption {
	my $optionId = $session{form}{optionId};

	return WebGUI::Privilege::insufficient unless (WebGUI::Grouping::isInGroup(14));
	
	WebGUI::Product->getByOptionId($optionId)->deleteOption($optionId);

	return WebGUI::Operation::execute('manageProduct');
}

#-------------------------------------------------------------------
sub www_deleteProductParameter {
	my $parameterId = $session{form}{parameterId};

	return WebGUI::Privilege::insufficient unless (WebGUI::Grouping::isInGroup(14));
	
	WebGUI::Product->getByParameterId($parameterId)->deleteParameter($parameterId);

	return WebGUI::Operation::execute('manageProduct');
}

#-------------------------------------------------------------------
sub www_deleteProduct {
	my $productId = $session{form}{productId};

	return WebGUI::Privilege::insufficient unless (WebGUI::Grouping::isInGroup(14));
	
	WebGUI::Product->new($productId)->delete;

	return WebGUI::Operation::execute('listProducts');
}

#-------------------------------------------------------------------
sub www_editProduct {
	my ($productId, $product, $f, $i18n);

	return WebGUI::Privilege::insufficient unless (WebGUI::Grouping::isInGroup(14));

	$i18n = WebGUI::International->new('ProductManager');	
	$productId = $session{form}{productId};
	
	unless ($productId eq 'new') {
		$product = WebGUI::Product->new($productId)->get;
	}
	
	$f = WebGUI::HTMLForm->new;
	$f->hidden(
		-name => 'op', 
		-value => 'editProductSave'
		);
	$f->hidden(
		-name => 'productId', 
		-value => $productId
	);
	$f->text(
		-name		=> 'title',
		-label		=> $i18n->get('title'),
		-hoverHelp	=> $i18n->get('title description'),
		-value		=> $session{form}{title} || $product->{title},
		-maxlength	=> 255,
	);
	$f->textarea(
		-name		=> 'description',
		-label		=> $i18n->get('description'),
		-hoverHelp	=> $i18n->get('description description'),
		-value		=> $session{form}{decsription} || $product->{description},
	);
	$f->float(
		-name		=> 'price',
		-label		=> $i18n->get('price'),
		-hoverHelp	=> $i18n->get('price description'),
		-value		=> $session{form}{price} || $product->{price},
		-maxlength	=> 13,
	);
	$f->float(
		-name		=> 'weight',
		-label		=> $i18n->get('weight'),
		-hoverHelp	=> $i18n->get('weight description'),
		-value		=> $session{form}{weight} || $product->{weight},
		-maxlength	=> 9,
	);
	$f->text(
		-name		=> 'sku',
		-label		=> $i18n->get('sku'),
		-hoverHelp	=> $i18n->get('sku description'),
		-value		=> $session{form}{sku} || $product->{SKU},
		-maxlength	=> 64,
	);
	$f->template(
		-name		=> 'templateId',
		-label		=> $i18n->get('template'),
		-hoverHelp	=> $i18n->get('template description'),
		-value		=> $session{form}{templateId} || $product->{templateId},
		-namespace	=> 'Commerce/Product',
	);
	$f->text(
		-name		=> 'skuTemplate',
		-label		=> $i18n->get('sku template'),
		-hoverHelp	=> $i18n->get('sku template description'),
		-value		=> $session{form}{skuTemplate} || $product->{skuTemplate},
		-maxlength	=> 255,
	);
	$f->submit;

	return _submenu($f->print, 'edit product', 'edit product', 'ProductManager');
}

#-------------------------------------------------------------------
sub www_editProductSave {
	my ($self, @error, $productId, $product, $i18n);

	return WebGUI::Privilege::insufficient unless (WebGUI::Grouping::isInGroup(14));

	$i18n = WebGUI::International->new('ProductManager');
	
	push(@error, $i18n->get('edit product title error')) unless $session{form}{title};
	push(@error, $i18n->get('edit product price error')) unless ($session{form}{price} && $session{form}{price} =~ /^\d+(\.\d+)?$/);
	push(@error, $i18n->get('edit product weight error')) unless (defined $session{form}{weight} && $session{form}{price} =~ /^\d+(\.\d+)?$/);
	push(@error, $i18n->get('edit product sku error')) unless ($session{form}{sku});
	
	return '<ul><li>'.join('</li><li>', @error).'</li></ul><br />'.WebGUI::Operation::execute('editProduct') if (@error);	

	$productId = $session{form}{productId};
	$product = WebGUI::Product->new($productId);
	$product->set({
		title		=> $session{form}{title},
		description	=> $session{form}{description},
		price		=> $session{form}{price},
		weight		=> $session{form}{weight},
		sku		=> $session{form}{sku},
		templateId	=> $session{form}{templateId},
		skuTemplate	=> $session{form}{skuTemplate},
	});
	
	$session{form}{productId} = $product->get('productId');
	return WebGUI::Operation::execute('manageProduct');
}
		
#-------------------------------------------------------------------
sub www_editProductParameter {
	my ($parameterId, $product, $productId, $parameter, $f, $i18n);

	return WebGUI::Privilege::insufficient unless (WebGUI::Grouping::isInGroup(14));
	
	$i18n = WebGUI::International->new('ProductManager');
	
	$parameterId = $session{form}{parameterId};
	$productId = $session{form}{productId};
	
	unless ($parameterId eq 'new') {
		$product = WebGUI::Product->getByParameterId($parameterId);
		$parameter = $product->getParameter($parameterId);
		$productId = $product->get('productId');
	}
	
	$f = WebGUI::HTMLForm->new;
	$f->hidden(
		-name => 'op',
		-value => 'editProductParameterSave',
	);
	$f->hidden(
		-name => 'parameterId',
		-value => $parameterId,
	);
	$f->hidden(
		-name => 'productId',
		-value => $productId,
	);
	$f->readOnly(
		-label		=> $i18n->get('parameter ID'),
		-value		=> $parameterId,
	);
	$f->text(
		-name		=> 'name',
		-label		=> $i18n->get('edit parameter name'),
		-hoverHelp	=> $i18n->get('edit parameter name description'),
		-value		=> $session{form}{name} || $parameter->{name},
		-maxlength	=> 64,
	);
	$f->submit;

	return _submenu($f->print, 'edit parameter', 'edit parameter', 'ProductManager');
}

#-------------------------------------------------------------------
sub www_editProductParameterSave {
	my (@error, $parameterId, $product, $i18n, $skuTemplate, $oldName, $newName);

	return WebGUI::Privilege::insufficient unless (WebGUI::Grouping::isInGroup(14));
	
	$i18n = WebGUI::International->new('ProductManager');

	$parameterId = $session{form}{parameterId};
	
	push (@error, $i18n->get('edit parameter error name')) unless $session{form}{name};
	push (@error, $i18n->get('edit parameter productId error')) unless $session{form}{productId};

	return "<ul><li>".join('</li><li>', @error)."</li></ul>".WebGUI::Operation::execute('editProductParameter') if (@error);
	
	$product = WebGUI::Product->new($session{form}{productId});
	$skuTemplate = $product->get('skuTemplate');

	if ($parameterId eq 'new') {
		$parameterId = $product->addParameter;
	} else {
		($oldName = $product->getParameter($parameterId)->{name}) =~ s/[ ><]/\./g;
		($newName = $session{form}{name}) =~ s/[ ><]/\./g;
		$skuTemplate = $product->get('skuTemplate');
		$skuTemplate =~ s/< *?tmpl_var *?param\.$oldName *?>/<tmpl_var param.$newName>/i;
		$product->set({
			skuTemplate	=> $skuTemplate
			});
	}
	
	$product->setParameter($parameterId, {
		name		=> $session{form}{name}
		});
	
	return WebGUI::Operation::execute('editSkuTemplate') if ($session{form}{parameterId} eq 'new');
	return WebGUI::Operation::execute('manageProduct');
}

#-------------------------------------------------------------------
sub www_editProductParameterOption {
	my ($self, $optionId, $option, $f, $i18n);

	return WebGUI::Privilege::insufficient unless (WebGUI::Grouping::isInGroup(14));
	
	$i18n = WebGUI::International->new('ProductManager');
	
	$optionId = $session{form}{optionId};
	unless ($optionId eq 'new') {
		$option = WebGUI::Product->getByOptionId($optionId)->getOption($optionId);
	}

	$f = WebGUI::HTMLForm->new;
	$f->hidden(
		-name => 'op',
		-value => 'editProductParameterOptionSave',
	);
	$f->hidden(
		-name => 'optionId',
		-value => $optionId,
	);
	$f->hidden(
		-name => 'parameterId',
		-value => $session{form}{parameterId},
	);
	$f->readOnly(
		-label		=> $i18n->get('option ID'),
		-value		=> $optionId
	);
	$f->text(
		-name		=> 'value',
		-label		=> $i18n->get('edit option value'),
		-hoverHelp	=> $i18n->get('edit option value description'),
		-value		=> $session{form}{value} || $option->{value},
		-maxlength	=> 64,
	);
	$f->float(
		-name		=> 'priceModifier',
		-label		=> $i18n->get('edit option price modifier'),
		-hoverHelp	=> $i18n->get('edit option price modifier description'),
		-value		=> $session{form}{priceModifier} || $option->{priceModifier},
		-maxlength	=> 11,
	);
	$f->float(
		-name		=> 'weightModifier',
		-label		=> $i18n->get('edit option weight modifier'),
		-hoverHelp	=> $i18n->get('edit option weight modifier description'),
		-value		=> $session{form}{weightModifier} || $option->{weightModifier},
		-maxlength	=> 7,
	);
	$f->text(
		-name		=> 'skuModifier',
		-label		=> $i18n->get('edit option sku modifier'),
		-hoverHelp	=> $i18n->get('edit option sku modifier description'),
		-value		=> $session{form}{skuModifier} || $option->{skuModifier},
		-maxlength	=> 64,
	);
	$f->submit;

	return _submenu($f->print, 'edit option', 'edit option', 'ProductManager');
}

#-------------------------------------------------------------------
sub www_editProductParameterOptionSave {
	my ($self, @error, $optionId, $product, $i18n);

	return WebGUI::Privilege::insufficient unless (WebGUI::Grouping::isInGroup(14));
	
	$i18n = WebGUI::International->new('ProductManager');

	push (@error, $i18n->get('edit option value error')) unless ($session{form}{value});
	push (@error, $i18n->get('edit option parameterId error')) unless ($session{form}{parameterId});

	return '<ul><li>'.join('</li><li>', @error).'</li></ul><br />'.WebGUI::Operation::execute('editProduct') if (@error);

	$product = WebGUI::Product->getByParameterId($session{form}{parameterId});
	$optionId = $session{form}{optionId};
	$optionId = $product->addOptionToParameter($session{form}{parameterId}) if ($optionId eq 'new');
	$product->setOption($optionId, {
		value		=> $session{form}{value},
		priceModifier	=> $session{form}{priceModifier},
		weightModifier	=> $session{form}{weightModifier},
		skuModifier	=> $session{form}{skuModifier}
		});

	return WebGUI::Operation::execute('manageProduct');
}

#-------------------------------------------------------------------
sub www_editProductVariant {
	my ($variantId, $variant, $f, $i18n);

	return WebGUI::Privilege::insufficient unless (WebGUI::Grouping::isInGroup(14));

	$i18n = WebGUI::International->new("ProductManager");
	
	$variantId = $session{form}{variantId};
	$variant = WebGUI::Product->getByVariantId($variantId)->getVariant($variantId);
	
	$f = WebGUI::HTMLForm->new;
	$f->hidden(
		-name => 'op', 
		-value => 'editProductVariantSave'
	);
	$f->hidden(
		-name => 'variantId', 
		-value => $variantId
	);
	$f->readOnly(
		-label	=> $i18n->get('variant ID'),
		-value	=> $variant->{variantId}
	);
	$f->float(
		-name	=> 'price',
		-label	=> $i18n->get('price override'),
		-hoverHelp	=> $i18n->get('price override description'),
		-value	=> $variant->{priceOverride} ? $variant->{price} : ''
	);
	$f->float(
		-name	=> 'weight',
		-label	=> $i18n->get('weight override'),
		-hoverHelp	=> $i18n->get('weight override description'),
		-value	=> $variant->{weightOverride} ? $variant->{weight} : ''
	);
	$f->text(
		-name	=> 'sku',
		-label	=> $i18n->get('sku override'),
		-hoverHelp	=> $i18n->get('sku override description'),
		-value	=> $variant->{skuOverride} ? $variant->{sku} : ''
	);
	$f->yesNo(
		-name	=> 'available',
		-label	=> $i18n->get('available'),
		-hoverHelp	=> $i18n->get('available description'),
		-value	=> $variant->{available}
	);
	$f->submit;

	return _submenu($f->print, 'edit variant', 'edit variant', 'ProductManager');
}

#-------------------------------------------------------------------
sub www_editProductVariantSave {
my	$variantId = $session{form}{variantId};

	return WebGUI::Privilege::insufficient unless (WebGUI::Grouping::isInGroup(14));

	WebGUI::Product->getByVariantId($variantId)->setVariant($variantId, $session{form});

	return WebGUI::Operation::execute('listProductVariants');
}

#-------------------------------------------------------------------
sub www_editSkuTemplate {
	my ($product, $productId, $output, $f, $name, $i18n);

	return WebGUI::Privilege::insufficient unless (WebGUI::Grouping::isInGroup(14));
	
	$i18n = WebGUI::International->new("ProductManager");
	
	$productId = $session{form}{productId};
	$product = WebGUI::Product->new($productId);
	
	$output .= "Available are: <br />\n";
	$output .= "<ul><li>base</li>\n";
	foreach (@{$product->getParameter}) {
		($name = $_->{name}) =~ s/[ ><]/\./g;
		$output .= "<li>param.".$name."</li>\n";
	}
	$output .= "</ul><br />";
	
	$f = WebGUI::HTMLForm->new;
	$f->hidden(
		-name => 'op', 
		-value => 'editSkuTemplateSave'
		);
	$f->hidden(
		-name => 'productId', 
		-value => $productId
		);
	$f->text(
		-name	=> 'skuTemplate',
		-value	=> $product->get('skuTemplate'),
		-label	=> $i18n->get('sku template'),
		);
	$f->submit;
	$output .= $f->print;

	return _submenu($output, 'edit sku composition label', 'edit sku template', 'ProductManager');
}

#-------------------------------------------------------------------
sub www_editSkuTemplateSave {
	my ($productId) = $session{form}{productId};

	return WebGUI::Privilege::insufficient unless (WebGUI::Grouping::isInGroup(14));
	
	WebGUI::Product->new($productId)->set({
		skuTemplate	=> $session{form}{skuTemplate},
		});

	return WebGUI::Operation::execute('manageProduct');
}

#-------------------------------------------------------------------
sub www_listProducts {
	my ($self, $sth, $output, $row, $i18n);

	return WebGUI::Privilege::insufficient unless (WebGUI::Grouping::isInGroup(14));
	
	$i18n = WebGUI::International->new('ProductManager');
	
	WebGUI::Session::setScratch('managingProduct', '-delete-');
	
	$sth = WebGUI::SQL->read('select * from products order by title');

	$output .= '<table>';
	while ($row = $sth->hashRef) {
		$output .= '<tr>';
		$output .= '<td>';
		$output .= deleteIcon('op=deleteProduct;productId='.$row->{productId});
		$output .= editIcon('op=manageProduct;productId='.$row->{productId});
		$output .= '</td>';
		$output .= '<td>'.$row->{title}.'</td>';
		$output .= '</tr>';
	}
	$output .= '</table>';

	return _submenu($output, 'list products', 'list products', 'ProductManager');
}

#-------------------------------------------------------------------
sub www_listProductVariants {
	my ($productId, $product, @variants, %parameters, %options, $output, %composition, $i18n);

	return WebGUI::Privilege::insufficient unless (WebGUI::Grouping::isInGroup(14));

	$i18n = WebGUI::International->new("ProductManager");
	
	$productId = $session{form}{productId} || WebGUI::Session::getScratch('managingProduct');

	return WebGUI::Operation::execute('listProducts') if ($productId eq 'new' || !$productId);
	
	$product = WebGUI::Product->new($productId);

	@variants = sort {$a->{composition}  cmp $b->{composition}} @{$product->getVariant};
	tie %parameters, "Tie::IxHash";
	%parameters = map {$_->{parameterId} => $_->{name}} sort {$a->{name} <=> $b->{name}} @{$product->getParameter};
	%options = map {$_->{optionId} => $_->{value}} @{$product->getOption};

	$output = WebGUI::Form::formHeader;
	$output .= WebGUI::Form::hidden({
		name	=> 'op',
		value	=> 'listProductVariantsSave',
		});
	$output .= WebGUI::Form::hidden({
		name	=> 'productId',
		value	=> $productId,
		});
	$output .= '<table><tr align="left">';
	$output .= "<th>".join('</th><th>', values(%parameters))."</th>" if (%parameters);
	$output .= '<th colspan="2">'.$i18n->get('sku').'</th>'.
		'<th colspan="2">'.$i18n->get('price').'</th>'.
		'<th colspan="2">'.$i18n->get('weight').'</th>'.
		'<th>'.$i18n->get('available').'</th>';
	$output .= "</tr>";
	foreach (@variants) {
		$output .= "<tr>";
		%composition = map {split(/\./, $_)} split(/,/, $_->{composition});
		foreach (keys(%parameters)) {
			$output .= '<td align="left">'.$options{$composition{$_}}.'</td>';
		}
		$output .= '<td align="left">'.$_->{sku}."</td><td>";
		$output .= '*' if ($_->{skuOverride});
		$output .= '</td><td align="right">'.$_->{price}."</td><td>";
		$output .= '*'if ($_->{priceOverride});
		$output .= '</td><td align="right">'.$_->{weight}."</td><td>";
		$output .= '*' if ($_->{weightOverride});
		$output .= "</td>";
		$output .= "<td>".WebGUI::Form::checkbox({
			name	=> 'available',
			value	=> $_->{variantId},
			checked	=> $_->{available},
			}).editIcon('op=editProductVariant;variantId='.$_->{variantId})."</td>";
		$output .= "</tr>";
	}
	$output .= "</table>";
	$output .= WebGUI::Form::submit();
	$output .= WebGUI::Form::formFooter();

	return _submenu($output, 'list variants label', 'list variants', 'ProductManager');
}

#-------------------------------------------------------------------
sub www_listProductVariantsSave {

	return WebGUI::Privilege::insufficient unless (WebGUI::Grouping::isInGroup(14));
	
	my %availableVariants = map {$_ => 1} WebGUI::FormProcessor::selectList('available');

	my $product = WebGUI::Product->new($session{form}{productId});
	my @variants = @{$product->getVariant};
	
	foreach (@variants) {
		$product->setVariant($_->{variantId}, {
			available => $availableVariants{$_->{variantId}} ? '1' : '0'});
	}

	return WebGUI::Operation::execute('listProductVariants');
}

#-------------------------------------------------------------------
sub www_manageProduct {
	my ($productId, $product, $output, $parameter, $option, $optionId, $i18n);

	return WebGUI::Privilege::insufficient unless (WebGUI::Grouping::isInGroup(14));

	$i18n = WebGUI::International->new("ProductManager");
	
	$productId = $session{form}{productId} || WebGUI::Session::getScratch('managingProduct');
	return WebGUI::Operation::execute('listProducts') if ($productId eq 'new' || !$productId);
	WebGUI::Session::setScratch('managingProduct', $productId);

	$product = WebGUI::Product->new($productId);
	
	$output .= "<h1>".$product->get('title')."</h1>";
	$output .= "<h2>".$i18n->get('properties').editIcon('op=editProduct;productId='.$productId)."</h2>";
	$output .= "<table>";
	$output .= "<tr><td>".$i18n->get('price')."</td><td>".$product->get('price')."</td></tr>";
	$output .= "<tr><td>".$i18n->get('weight')."</td><td>".$product->get('weight')."</td></tr>";
	$output .= "<tr><td>".$i18n->get('sku')."</td><td>".$product->get('sku')."</td></tr>";
	$output .= "<tr><td>".$i18n->get('description')."</td><td>".$product->get('description')."</td></tr>";
	$output .= "<tr><td>".$i18n->get('sku template')."</td><td>".WebGUI::HTML::format($product->get('skuTemplate'), 'text')."</td></tr>";
	$output .= "</table>";
	
	$output .= "<h2>Parameters</h2>";
	$output .= '<a href="'.WebGUI::URL::page('op=editProductParameter;parameterId=new;productId='.$product->get('productId')).'">'.
		$i18n->get('add parameter').'</a><br />';
	foreach $parameter (@{$product->getParameter}) {
		$output .= deleteIcon('op=deleteProductParameter;parameterId='.$parameter->{parameterId}).
			editIcon('op=editProductParameter;parameterId='.$parameter->{parameterId});
		$output .= '<span style="margin-left: 10px"><b>'.$parameter->{name}.'</b></span><br />';
		$output .= '<a style="margin-left: 20px" href="'.
			WebGUI::URL::page('op=editProductParameterOption;optionId=new;parameterId='.$parameter->{parameterId}).'">'.
			$i18n->get('add option').'</a><br />';
		foreach $optionId (@{$parameter->{options}}) {
			$option = $product->getOption($optionId);
			$output .= '<span style="margin-left: 20px">'.
				deleteIcon('op=deleteProductParameterOption;optionId='.$option->{optionId}).
				editIcon('op=editProductParameterOption;parameterId='.$parameter->{parameterId}.';optionId='.$option->{optionId}).$option->{value}.'</span><br />';
		}
		$output .= '<br />';
	}

	return _submenu($output, 'manage product', 'manage product', 'ProductManager');
}

1;

