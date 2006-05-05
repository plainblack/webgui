package WebGUI::i18n::English::Macro_Product;

our $I18N = {
	'add to cart' => {
		message => q|Add to cart|,
		lastUpdated => 0,
		context => q|The label for the add to cart link.|
	},
	'available product configurations' => {
		message => q|Available product configurations|,
		lastUpdated => 0,
		context => q|Message indicatin the available configurations.|
	},
	'macroName' => {
		message => q|Product|,
		lastUpdated => 1128918830,
	},

	'no sku or id' => {
		message => q|No SKU or productId passed|,
		lastUpdated => 1135117939,
	},

	'cannot find product' => {
		message => q|Cannot find product|,
		lastUpdated => 1128976376,
	},

	'product title' => {
		message => q|Product Macro|,
		lastUpdated => 1128965480,
	},

	'product body' => {
		message => q|

<p><b>&#94;Product(<i>SKU or productId</i>, [<i>templateId</i>]);</b><br />
This macro looks up a Product in the Product Manager by SKU or productId and
allows information about it to be displayed.  If the SKU or productId cannot
be found, the message ^International("cannot find product","Macro_Product"); will
be displayed.</p>
<p>The macro takes one optional argument, an alternate template in the Macro/Product namespace for formatting information about the Product.  The following variables are available in the template:</p>

<p><b>variants.message</b><br />
The internationalized text "^International("available product configurations","Macro_Product");"
</p>

<p><b>variantLoop</b><br />
A loop containing information about all variants about the Product.
</p>

<div class="helpIndent">

<p><b>variant.compositionLoop</b><br />
A loop containing information about all variants about the Product.
</p>

<div class="helpIndent">

<p><b>parameter</b><br />
The parameter that defines this variant, for example, size.
</p>

<p><b>value</b><br />
The value of the parameter, for the example of size, XL.
</p>

</div>

<p><b>variant.variantId</b><br />
The Id for this variant of the Product.
</p>

<p><b>variant.price</b><br />
The price for this variant of the Product.
</p>

<p><b>variant.weight</b><br />
The weight for this variant of the Product.
</p>

<p><b>variant.sku</b><br />
The SKU for this variant of the Product.
</p>

<p><b>variant.addToCart.url</b><br />
A URL to add this variant of the Product to the user's shopping cart.
</p>

<p><b>variant.addToCart.label</b><br />
An internationalized label, "^International("add to cart","Macro_Product");",
to display to the user for adding this variant
of the Product to their shopping cart.
</p>

</div>

<p><b>productId</b><br />
The unique identifier of this Product.</p>

<p><b>title</b><br />
The title for this Product.</p>

<p><b>description</b><br />
The description of this Product.
</p>

<p><b>price</b><br />
The Product's base cost.
</p>

<p><b>weight</b><br />
The Product's base weight.
</p>

<p><b>sku</b><br />
The Product's base SKU.
</p>

|,
		lastUpdated => 1146609252,
	},

};

1;

