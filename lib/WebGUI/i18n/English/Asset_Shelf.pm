package WebGUI::i18n::English::Asset_Shelf;

use strict;

our $I18N = { 
	'price' => {
		message 	=> q|The price of this sku.|,
		lastUpdated => 0,
		context		=> q|a template variable|,
	},

	'thumbnailUrl' => {
		message 	=> q|The URL for a thumbnail image of this sku. If it has no thumbnail, then this variable will be empty.|,
		lastUpdated => 0,
		context		=> q|a template variable|,
	},

	'shelves' => {
		message 	=> q|A loop containing the list of shelves that are children of this one in the asset tree. Each record in the loop contains all the properties of a shelf.|,
		lastUpdated => 0,
		context		=> q|a template variable|,
	},

	'products' => {
		message 	=> q|A loop containing the list of products that match the keywords specified in this shelf. Each record in the loop contains all the properties of the matching sku, plus the following variables.|,
		lastUpdated => 0,
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

	'assetName' => {
		message 	=> q|Shelf|,
		lastUpdated => 0,
		context		=> q|the name of the asset|,
	},
};

1;
