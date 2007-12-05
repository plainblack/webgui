package WebGUI::Operation::ProductManager;

use strict;
use WebGUI::SQL;
use WebGUI::HTMLForm;
use WebGUI::Form;
use WebGUI::International;
use WebGUI::AdminConsole;
use Tie::IxHash;
use WebGUI::Product;
use WebGUI::HTML;

#-------------------------------------------------------------------

=head2 _submenu ( $session )

Returns a rendered Admin Console view, with a standard list of five submenu items.

=head3 $session

The current WebGUI session object.

=head3 workarea

A scalar of HTML that defines the current workarea.

=head3 title

The i18n key of the title of this workarea.

=cut

sub _submenu {
	my $session = shift;
	my $i18n = WebGUI::International->new($session, "ProductManager");

	my $workarea = shift;
        my $title = shift;
        $title = $i18n->get($title) if ($title);
        my $ac = WebGUI::AdminConsole->new($session,"productManager");

	my $productId = $session->form->process("productId") || $session->scratch->get('managingProduct');
	undef $productId if ($productId eq 'new');
	$ac->addSubmenuItem($session->url->page('op=editProduct;productId=new'), $i18n->get('add product'));
	$ac->addSubmenuItem($session->url->page('op=listProducts'), $i18n->get('list products'));
	$ac->addSubmenuItem($session->url->page('op=manageProduct;productId='.$productId), $i18n->get('manage product')) if ($productId);
	$ac->addSubmenuItem($session->url->page('op=listProductVariants;productId='.$productId), $i18n->get('list variants')) if ($productId);

	return $ac->render($workarea, $title);
}

#----------------------------------------------------------------------------

=head2 canView ( session [, user] )

Returns true if the user can administrate this operation. user defaults to 
the current user.

=cut

sub canView {
    my $session     = shift;
    my $user        = shift || $session->user;
    return $user->isInGroup( $session->setting->get("groupIdAdminProductManager") );
}

#-------------------------------------------------------------------

=head2 www_deleteProductParameterOption ( $session )

Deletes a product parameter option specified by form parameter 'optionId'.

=head3 $session

The current WebGUI session object.

=cut

sub www_deleteProductParameterOption {
	my $session = shift;
	my $optionId = $session->form->process("optionId");

	return $session->privilege->insufficient unless canView($session);
	
	WebGUI::Product->getByOptionId($session,$optionId)->deleteOption($optionId);

	return WebGUI::Operation::execute($session,'manageProduct');
}

#-------------------------------------------------------------------

=head2 www_deleteProductParameter ( $session )

Deletes a product parameter specified by form parameter 'parameterId'.

=head3 $session

The current WebGUI session object.

=cut

sub www_deleteProductParameter {
	my $session = shift;
	my $parameterId = $session->form->process("parameterId");

	return $session->privilege->insufficient unless canView($session);
	
	WebGUI::Product->getByParameterId($session,$parameterId)->deleteParameter($parameterId);

	return WebGUI::Operation::execute($session,'manageProduct');
}

#-------------------------------------------------------------------

=head2 www_deleteProduct ( $session )

Deletes a product specified by form parameter 'productId'.

=head3 $session

The current WebGUI session object.

=cut

sub www_deleteProduct {
	my $session = shift;
	my $productId = $session->form->process("productId");

	return $session->privilege->insufficient unless canView($session);
	
	WebGUI::Product->new($session,$productId)->delete;

	return WebGUI::Operation::execute($session,'listProducts');
}

#-------------------------------------------------------------------

=head2 www_editProduct ( $session )

Returns a form to edit or add a new product.

=head3 $session

The current WebGUI session object.

=cut

sub www_editProduct {
	my $session = shift;
	my ($productId, $product, $f, $i18n);

	return $session->privilege->insufficient unless canView($session);

	$i18n = WebGUI::International->new($session, 'ProductManager');	
	$productId = $session->form->process("productId");

	unless ($productId eq 'new') {
		$product = WebGUI::Product->new($session,$productId)->get;
	}

	$f = WebGUI::TabForm->new($session);
	$f->addTab("properties","Properties");
	$f->addTab("actions","Actions");

	$f->submit;
	$f->hidden({
		name => 'op', 
		value => 'editProductSave'
	});
	$f->hidden({
		name => 'productId', 
		value => $productId
	});
	$f->getTab("properties")->text(
		-name		=> 'title',
		-label		=> $i18n->get('title'),
		-hoverHelp	=> $i18n->get('title description'),
		-value		=> $session->form->process("title") || $product->{title},
		-maxlength	=> 255,
	);
	$f->getTab("properties")->textarea(
		-name		=> 'description',
		-label		=> $i18n->get('description'),
		-hoverHelp	=> $i18n->get('description description'),
		-value		=> $session->form->process("decsription") || $product->{description},
	);
	$f->getTab("properties")->float(
		-name		=> 'price',
		-label		=> $i18n->get('price'),
		-hoverHelp	=> $i18n->get('price description'),
		-value		=> $session->form->process("price") || $product->{price},
		-maxlength	=> 13,
	);
	$f->getTab("properties")->yesNo(
		-name		=> 'useSalesTax',
		-label		=> $i18n->get('useSalesTax'),
		-hoverHelp	=> $i18n->get('useSalesTax description'),
		-value		=> $session->form->process("useSalesTax") || $product->{useSalesTax},
	);
	$f->getTab("properties")->float(
		-name		=> 'weight',
		-label		=> $i18n->get('weight'),
		-hoverHelp	=> $i18n->get('weight description'),
		-value		=> $session->form->process("weight") || $product->{weight},
		-maxlength	=> 9,
	);
	$f->getTab("properties")->text(
		-name		=> 'sku',
		-label		=> $i18n->get('sku'),
		-hoverHelp	=> $i18n->get('sku description'),
		-value		=> $session->form->process("sku") || $product->{sku},
		-maxlength	=> 64,
	);
	$f->getTab("properties")->template(
		-name		=> 'templateId',
		-label		=> $i18n->get('template'),
		-hoverHelp	=> $i18n->get('template description'),
		-value		=> $session->form->process("templateId") || $product->{templateId},
		-namespace	=> 'Commerce/Product',
	);
	$f->getTab("properties")->text(
		-name		=> 'skuTemplate',
		-label		=> $i18n->get('sku template'),
		-hoverHelp	=> $i18n->get('sku template description'),
		-value		=> $session->form->process("skuTemplate") || $product->{skuTemplate},
		-maxlength	=> 255,
	);

       $f->getTab("actions")->group(
               -name           => 'groupId',
               -label          => $i18n->get('group id'),
               -hoverHelp      => $i18n->get('group id description'),
               -value          => $session->form->process("groupId") || $product->{groupId},
       );

       my %groupExpiresOffsetOptions;
       tie %groupExpiresOffsetOptions, 'Tie::IxHash',
               '1month'        => $i18n->get("1 month"),
               '6month'        => $i18n->get("6 months"),
               '1year'         => $i18n->get("1 year"),
               '2year'         => $i18n->get("2 years"),
               '3year'         => $i18n->get("3 years"),
               '5year'         => $i18n->get("5 years"),
               '10year'        => $i18n->get("10 years"),
               '1000year'      => $i18n->get("lifetime"),
               ;

       $f->getTab("actions")->selectBox(
               -name           => 'groupExpiresOffset',
               -label          => $i18n->get('group expires offset'),
               -hoverHelp      => $i18n->get('group expires offset description'),
               -value          => $session->form->process("groupExpiresOffset") || $product->{groupExpiresOffset},
               -options        => \%groupExpiresOffsetOptions,
               -defaultValue   => '1000year',
       );



	return _submenu($session,$f->print, 'edit product');
}

#-------------------------------------------------------------------

=head2 www_editProductSave ( $session )

Saves the properties of a product.

=head3 $session

The current WebGUI session object.

=cut

sub www_editProductSave {
	my $session = shift;
	my ($self, @error, $productId, $product, $i18n);

	return $session->privilege->insufficient unless canView($session);

	$i18n = WebGUI::International->new($session, 'ProductManager');
	
	push(@error, $i18n->get('edit product title error')) unless $session->form->process("title");
	push(@error, $i18n->get('edit product price error')) unless ($session->form->process("price") && $session->form->process("price") =~ /^\d+(\.\d+)?$/);
	push(@error, $i18n->get('edit product weight error')) unless (defined $session->form->process("weight") && $session->form->process("price") =~ /^\d+(\.\d+)?$/);
	push(@error, $i18n->get('edit product sku error')) unless ($session->form->process("sku"));
	
	return '<ul><li>'.join('</li><li>', @error).'</li></ul><br />'.WebGUI::Operation::execute($session,'editProduct') if (@error);	

	$productId = $session->form->process("productId");
	$product = WebGUI::Product->new($session,$productId);
	$product->set({
		title		=> $session->form->process("title"),
		description	=> $session->form->process("description"),
		price		=> $session->form->process("price"),
		useSalesTax	=> $session->form->process("useSalesTax"),
		weight		=> $session->form->process("weight"),
		sku		=> $session->form->process("sku"),
		templateId	=> $session->form->process("templateId"),
		skuTemplate	=> $session->form->process("skuTemplate"),

		groupId         => $session->form->process('groupId'),
		groupExpiresOffset => $session->form->process('groupExpiresOffset'),

	});
	
	return www_manageProduct($session, $product->get('productId'));
}
		
#-------------------------------------------------------------------

=head2 www_editProductParameter ( $session )

Returns a form to edit a product parameter.

=head3 $session

The current WebGUI session object.

=cut

sub www_editProductParameter {
	my $session = shift;
	my ($parameterId, $product, $productId, $parameter, $f, $i18n);

	return $session->privilege->insufficient unless canView($session);
	
	$i18n = WebGUI::International->new($session, 'ProductManager');
	
	$parameterId = $session->form->process("parameterId");
	$productId = $session->form->process("productId");
	
	unless ($parameterId eq 'new') {
		$product = WebGUI::Product->getByParameterId($session,$parameterId);
		$parameter = $product->getParameter($parameterId);
		$productId = $product->get('productId');
	}
	
	$f = WebGUI::HTMLForm->new($session);
	$f->submit;
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
		-value		=> $session->form->process("name") || $parameter->{name},
		-maxlength	=> 64,
	);
	$f->submit;

	return _submenu($session,$f->print, 'edit parameter');
}

#-------------------------------------------------------------------

=head2 www_editProductParameterSave ( $session )

Saves the properties of a product parameter.

=head3 $session

The current WebGUI session object.

=cut

sub www_editProductParameterSave {
	my $session = shift;
	my (@error, $parameterId, $product, $i18n, $skuTemplate, $oldName, $newName);

	return $session->privilege->insufficient unless canView($session);
	
	$i18n = WebGUI::International->new($session, 'ProductManager');

	$parameterId = $session->form->process("parameterId");
	
	push (@error, $i18n->get('edit parameter name error')) unless $session->form->process("name");
	push (@error, $i18n->get('edit parameter productId error')) unless $session->form->process("productId");

	return "<ul><li>".join('</li><li>', @error)."</li></ul>".WebGUI::Operation::execute($session,'editProductParameter') if (@error);
	
	$product = WebGUI::Product->new($session,$session->form->process("productId"));
	$skuTemplate = $product->get('skuTemplate');

	if ($parameterId eq 'new') {
		$parameterId = $product->addParameter;
	} else {
		($oldName = $product->getParameter($parameterId)->{name}) =~ s/[ ><]/\./g;
		($newName = $session->form->process("name")) =~ s/[ ><]/\./g;
		$skuTemplate = $product->get('skuTemplate');
		$skuTemplate =~ s/< *?tmpl_var *?param\.$oldName *?>/<tmpl_var param.$newName>/i;
		$product->set({
			skuTemplate	=> $skuTemplate
			});
	}
	
	$product->setParameter($parameterId, {
		name		=> $session->form->process("name")
		});
	
	return WebGUI::Operation::execute($session,'editSkuTemplate') if ($session->form->process("parameterId") eq 'new');
	return WebGUI::Operation::execute($session,'manageProduct');
}

#-------------------------------------------------------------------

=head2 www_editProductParameterOption ( $session )

Edits the options of a product parameter.

=head3 $session

The current WebGUI session object.

=cut

sub www_editProductParameterOption {
	my $session = shift;
	my ($self, $optionId, $option, $f, $i18n);

	return $session->privilege->insufficient unless canView($session);
	
	$i18n = WebGUI::International->new($session, 'ProductManager');
	
	$optionId = $session->form->process("optionId");
	unless ($optionId eq 'new') {
		$option = WebGUI::Product->getByOptionId($session,$optionId)->getOption($optionId);
	}

	$f = WebGUI::HTMLForm->new($session);
	$f->submit;
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
		-value => $session->form->process("parameterId"),
	);
	$f->readOnly(
		-label		=> $i18n->get('option ID'),
		-value		=> $optionId
	);
	$f->text(
		-name		=> 'value',
		-label		=> $i18n->get('edit option value'),
		-hoverHelp	=> $i18n->get('edit option value description'),
		-value		=> $session->form->process("value") || $option->{value},
		-maxlength	=> 64,
	);
	$f->float(
		-name		=> 'priceModifier',
		-label		=> $i18n->get('edit option price modifier'),
		-hoverHelp	=> $i18n->get('edit option price modifier description'),
		-value		=> $session->form->process("priceModifier") || $option->{priceModifier},
		-maxlength	=> 11,
	);
	$f->float(
		-name		=> 'weightModifier',
		-label		=> $i18n->get('edit option weight modifier'),
		-hoverHelp	=> $i18n->get('edit option weight modifier description'),
		-value		=> $session->form->process("weightModifier") || $option->{weightModifier},
		-maxlength	=> 7,
	);
	$f->text(
		-name		=> 'skuModifier',
		-label		=> $i18n->get('edit option sku modifier'),
		-hoverHelp	=> $i18n->get('edit option sku modifier description'),
		-value		=> $session->form->process("skuModifier") || $option->{skuModifier},
		-maxlength	=> 64,
	);
	$f->submit;

	return _submenu($session,$f->print, 'edit option');
}

#-------------------------------------------------------------------

=head2 www_editProductParameterOptionSave ( $session )

Saves the properties of a Product Parameter Option

=head3 $session

The current WebGUI session object.

=cut

sub www_editProductParameterOptionSave {
	my $session = shift;
	my ($self, @error, $optionId, $product, $i18n);

	return $session->privilege->insufficient unless canView($session);
	
	$i18n = WebGUI::International->new($session, 'ProductManager');

	push (@error, $i18n->get('edit option value error')) unless ($session->form->process("value"));
	push (@error, $i18n->get('edit option parameterId error')) unless ($session->form->process("parameterId"));

	return '<ul><li>'.join('</li><li>', @error).'</li></ul><br />'.WebGUI::Operation::execute($session,'editProduct') if (@error);

	$product = WebGUI::Product->getByParameterId($session,$session->form->process("parameterId"));
	$optionId = $session->form->process("optionId");
	$optionId = $product->addOptionToParameter($session->form->process("parameterId")) if ($optionId eq 'new');
	$product->setOption($optionId, {
		value		=> $session->form->process("value"),
		priceModifier	=> $session->form->process("priceModifier"),
		weightModifier	=> $session->form->process("weightModifier"),
		skuModifier	=> $session->form->process("skuModifier")
		});

	return WebGUI::Operation::execute($session,'manageProduct');
}

#-------------------------------------------------------------------

=head2 www_editProductVariant ( $session )

Returns a form to edit a Product Variant.

=head3 $session

The current WebGUI session object.

=cut

sub www_editProductVariant {
	my $session = shift;
	my ($variantId, $variant, $f, $i18n);

	return $session->privilege->insufficient unless canView($session);

	$i18n = WebGUI::International->new($session, "ProductManager");
	
	$variantId = $session->form->process("variantId");
	$variant = WebGUI::Product->getByVariantId($session,$variantId)->getVariant($variantId);
	
	$f = WebGUI::HTMLForm->new($session);
	$f->submit;
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

	return _submenu($session,$f->print, 'edit variant');
}

#-------------------------------------------------------------------

=head2 www_editProductVariantSave ( $session )

Saves the properties of a Product Variant.

=head3 $session

The current WebGUI session object.

=cut

sub www_editProductVariantSave {
	my $session = shift;
my	$variantId = $session->form->process("variantId");

	return $session->privilege->insufficient unless canView($session);

	WebGUI::Product->getByVariantId($session,$variantId)->setVariant($variantId, $session->form->paramsHashRef);

	return WebGUI::Operation::execute($session,'listProductVariants');
}

#-------------------------------------------------------------------

=head2 www_editSkuTemplate ( $session )

Returns a form to edit a Sku Template.

=head3 $session

The current WebGUI session object.

=cut

sub www_editSkuTemplate {
	my $session = shift;
	my ($product, $productId, $output, $f, $name, $i18n);

	return $session->privilege->insufficient unless canView($session);
	
	$i18n = WebGUI::International->new($session, "ProductManager");
	
	$productId = $session->form->process("productId");
	$product = WebGUI::Product->new($session,$productId);
	
	$output .= "Available are: <br />\n";
	$output .= "<ul><li>base</li>\n";
	foreach (@{$product->getParameter}) {
		($name = $_->{name}) =~ s/[ ><]/\./g;
		$output .= "<li>param.".$name."</li>\n";
	}
	$output .= "</ul><br />";
	
	$f = WebGUI::HTMLForm->new($session);
	$f->submit;
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

	return _submenu($session,$output, 'edit sku composition label');
}

#-------------------------------------------------------------------

=head2 www_editSkuTemplateSave ( $session )

Saves the properties of a Sku Template.

=head3 $session

The current WebGUI session object.

=cut

sub www_editSkuTemplateSave {
	my $session = shift;
	my ($productId) = $session->form->process("productId");

	return $session->privilege->insufficient unless canView($session);
	
	WebGUI::Product->new($session,$productId)->set({
		skuTemplate	=> $session->form->process("skuTemplate"),
		});

	return WebGUI::Operation::execute($session,'manageProduct');
}

#-------------------------------------------------------------------

=head2 www_listProducts ( $session )

Returns a list of products with manage and delete buttons.

=head3 $session

The current WebGUI session object.

=cut

sub www_listProducts {
	my $session = shift;
	my ($self, $sth, $output, $row, $i18n);

	return $session->privilege->insufficient unless canView($session);
	
	$i18n = WebGUI::International->new($session, 'ProductManager');
	
	$session->scratch->delete('managingProduct');
	
	$sth = $session->db->read('select * from products order by title');

	$output .= '<table>';
	while ($row = $sth->hashRef) {
		$output .= '<tr>';
		$output .= '<td>';
		$output .= $session->icon->delete('op=deleteProduct;productId='.$row->{productId}, undef, $i18n->get("confirm delete product"));
		$output .= $session->icon->edit('op=manageProduct;productId='.$row->{productId});
		$output .= '</td>';
		$output .= '<td>'.$row->{title}.'</td>';
		$output .= '</tr>';
	}
	$output .= '</table>';

	return _submenu($session,$output, 'list products');
}

#-------------------------------------------------------------------

=head2 www_listProductVariants ( $session )

Returns a list of Product Variants.

=head3 $session

The current WebGUI session object.

=cut

sub www_listProductVariants {
	my $session = shift;
	my ($productId, $product, @variants, %parameters, %options, $output, %composition, $i18n);

	return $session->privilege->insufficient unless canView($session);

	$i18n = WebGUI::International->new($session, "ProductManager");
	
	$productId = $session->form->process("productId") || $session->scratch->get('managingProduct');

	return WebGUI::Operation::execute($session,'listProducts') if ($productId eq 'new' || !$productId);
	
	$product = WebGUI::Product->new($session,$productId);

	@variants = sort {$a->{composition}  cmp $b->{composition}} @{$product->getVariant};
	tie %parameters, "Tie::IxHash";
	%parameters = map {$_->{parameterId} => $_->{name}} sort {$a->{name} <=> $b->{name}} @{$product->getParameter};
	%options = map {$_->{optionId} => $_->{value}} @{$product->getOption};

	$output = WebGUI::Form::formHeader($session);
	$output .= WebGUI::Form::hidden($session,{
		name	=> 'op',
		value	=> 'listProductVariantsSave',
		});
	$output .= WebGUI::Form::hidden($session,{
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
		$output .= "<td>".WebGUI::Form::checkbox($session,{
			name	=> 'available',
			value	=> $_->{variantId},
			checked	=> $_->{available},
			}).$session->icon->edit('op=editProductVariant;variantId='.$_->{variantId})."</td>";
		$output .= "</tr>";
	}
	$output .= "</table>";
	$output .= WebGUI::Form::submit($session,);
	$output .= WebGUI::Form::formFooter($session,);

	return _submenu($session,$output, 'list variants label');
}

#-------------------------------------------------------------------

=head2 www_listProductVariantsSave ( $session )

Saves the properties of some product variants.

=head3 $session

The current WebGUI session object.

=cut

sub www_listProductVariantsSave {
	my $session = shift;

	return $session->privilege->insufficient unless canView($session);
	
	my %availableVariants = map {$_ => 1} $session->form->selectList('available');

	my $product = WebGUI::Product->new($session,$session->form->process("productId"));
	my @variants = @{$product->getVariant};
	
	foreach (@variants) {
		$product->setVariant($_->{variantId}, {
			available => $availableVariants{$_->{variantId}} ? '1' : '0'});
	}

	return WebGUI::Operation::execute($session,'listProductVariants');
}

#-------------------------------------------------------------------

=head2 www_manageProduct ( $session )

Returns a screen that displays lots of options for editing all aspects of a product.

=head3 $session

The current WebGUI session object.

=cut

sub www_manageProduct {
	my $session = shift;
	my ($product, $output, $option, $i18n);

	return $session->privilege->insufficient unless canView($session);

	$i18n = WebGUI::International->new($session, "ProductManager");
	
	my $productId = shift || $session->form->process("productId") || $session->scratch->get('managingProduct');
	return WebGUI::Operation::execute($session,'listProducts') if ($productId eq 'new' || !$productId);
	$session->scratch->set('managingProduct', $productId);

	$product = WebGUI::Product->new($session,$productId);
	
	$output .= "<h1>".$product->get('title')."</h1>";
	$output .= "<h2>".$i18n->get('properties').$session->icon->edit('op=editProduct;productId='.$productId)."</h2>";
	$output .= "<table>";
	$output .= "<tr><td>".$i18n->get('productId')."</td><td>".$productId."</td></tr>";
	$output .= "<tr><td>".$i18n->get('price')."</td><td>".$product->get('price')."</td></tr>";
	my $useSalesTax = $product->get('useSalesTax')
			? $i18n->get(138, 'WebGUI')
			: $i18n->get(139, 'WebGUI');
	$output .= "<tr><td>".$i18n->get('useSalesTax')."</td><td>".$useSalesTax."</td></tr>";
	$output .= "<tr><td>".$i18n->get('weight')."</td><td>".$product->get('weight')."</td></tr>";
	$output .= "<tr><td>".$i18n->get('sku')."</td><td>".$product->get('sku')."</td></tr>";
	$output .= "<tr><td>".$i18n->get('description')."</td><td>".$product->get('description')."</td></tr>";
	$output .= "<tr><td>".$i18n->get('sku template')."</td><td>".WebGUI::HTML::format($product->get('skuTemplate'), 'text')."</td></tr>";
	$output .= "</table>";
	
	$output .= "<h2>Parameters</h2>";
	$output .= '<a href="'.$session->url->page('op=editProductParameter;parameterId=new;productId='.$product->get('productId')).'">'.
		$i18n->get('add parameter').'</a><br />';
	foreach my $parameter (@{$product->getParameter}) {
		$output .= $session->icon->delete('op=deleteProductParameter;parameterId='.$parameter->{parameterId}).
			$session->icon->edit('op=editProductParameter;parameterId='.$parameter->{parameterId});
		$output .= '<span style="margin-left: 10px"><b>'.$parameter->{name}.'</b></span><br />';
		$output .= '<a style="margin-left: 20px" href="'.
			$session->url->page('op=editProductParameterOption;optionId=new;parameterId='.$parameter->{parameterId}).'">'.
			$i18n->get('add option').'</a><br />';
		foreach my $optionId (@{$parameter->{options}}) {
			$option = $product->getOption($optionId);
			$output .= '<span style="margin-left: 20px">'.
				$session->icon->delete('op=deleteProductParameterOption;optionId='.$option->{optionId}).
				$session->icon->edit('op=editProductParameterOption;parameterId='.$parameter->{parameterId}.';optionId='.$option->{optionId}).$option->{value}.'</span><br />';
		}
		$output .= '<br />';
	}

	return _submenu($session,$output, 'manage product');
}

1;

