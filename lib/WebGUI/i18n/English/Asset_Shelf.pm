package WebGUI::i18n::English::Asset_Shelf;

use strict;

our $I18N = { 
    'import' => {
        message => q|Import Products|,
        lastUpdated => 1212550974,
        context => q|Label for bringing data into the Shop (Tax, Product, etc.)|
    },

	'export' => {
		message => q|Export Products|,
		lastUpdated => 1212550978,
		context => q|Label for taking data out of the Shop (Tax, Product, etc.)|,
	},

    'import successful' => {
        message => q|Your products have been imported.|,
        lastUpdated => 1213047491,
        context => q|Message telling the user the their products have been imported successfully.|
    },

    'price' => {
        message 	=> q|The price of this sku, formatted to 2 decimal places using a decimal point (not comma), and with no monetary symbol.|,
        lastUpdated => 0,
        context		=> q|a template variable|,
    },

	'thumbnailUrl' => {
		message 	=> q|The URL for a thumbnail image of this sku. If it has no thumbnail, then this variable will be empty.|,
		lastUpdated => 0,
		context		=> q|a template variable|,
	},

	'product_url' => {
		message 	=> q|The URL to this sku.|,
		lastUpdated => 0,
		context		=> q|a template variable|,
	},

	'addToCartForm' => {
		message 	=> q|If this product supports it, the form to add this product to the cart.  It will contain a submit button and all required form elements needed to add the product to the cart.|,
		lastUpdated => 0,
		context		=> q|a template variable|,
	},

	'shelves' => {
		message 	=> q|A loop containing the list of shelves that are children of this one in the asset tree. Each record in the loop contains all the properties of a shelf.  Only shelves that the user can see will be in the loop.|,
		lastUpdated => 0,
		context		=> q|a template variable|,
	},

	'shelf_title' => {
		message 	=> q|The title of this shelf|,
		lastUpdated => 0,
		context		=> q|a template variable|,
	},

	'shelf_url' => {
		message 	=> q|The url of this shelf|,
		lastUpdated => 0,
		context		=> q|a template variable|,
	},

	'products' => {
		message 	=> q|A loop containing the list of products that match the keywords specified in this shelf, or that are children of this shelf. Only products that the user can see will be in the loop. Each record in the loop contains all the properties of the matching sku, plus the following variables.|,
		lastUpdated => 1247603018,
		context		=> q|a template variable|,
	},

	'subcategories' => {
		message 	=> q|Subcategories|,
		lastUpdated => 0,
		context		=> q|a template label|,
	},

	'shelf template' => {
		message 	=> q|Shelf Template|,
		lastUpdated => 0,
		context		=> q|a property|,
	},

	'shelf template help' => {
		message 	=> q|Choose the template that will display the list of products associated with this shelf.|,
		lastUpdated => 0,
		context		=> q|help for a property|,
	},

	'noViewableSkus' => {
		message 	=> q|A boolean which is true if there are no products on this shelf which the current user can view.|,
		lastUpdated => 0,
		context		=> q|Template variable help|,
	},

	'emptyShelf' => {
		message 	=> q|A boolean which is true if this shelf has any Products at all.|,
		lastUpdated => 0,
		context		=> q|Template variable help|,
	},

	'this shelf is empty' => {
		message 	=> q|This shelf is empty.|,
		lastUpdated => 0,
		context		=> q|template label|,
	},

	'You do not have permission to view the products on this shelf' => {
		message 	=> q|You do not have permission to view the products on this shelf.|,
		lastUpdated => 0,
		context		=> q|template label|,
	},

	'assetName' => {
		message 	=> q|Shelf|,
		lastUpdated => 0,
		context		=> q|the name of the asset|,
	},
};

1;
