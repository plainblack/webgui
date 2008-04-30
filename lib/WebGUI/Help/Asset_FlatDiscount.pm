package WebGUI::Help::Asset_FlatDiscount;

use strict; 


our $HELP = { 
	'template' => {	

		title => 'flat discount coupon template', 
		body => 'flat discount coupon template help',	
		isa => [
			{
			tag => 'sku properties',
			namespace => 'Asset_Sku',
			},
		],
		fields => [	
		],
		variables => [
			{	name => "formHeader" , required=>1},
			{	name => "formFooter" , required=>1 },
			{	name => "addToCartButton" , required=>1 },
			{	name => "mustSpend", description=>"must spend help" },
			{	name => "percentageDiscount", description=>"percentage discount help" },
			{	name => "priceDiscount", description=>"price discount help" },
			{	name => "templateId", description=>"template help" },
		],
		related => [  
		],
	},

};

1; 
