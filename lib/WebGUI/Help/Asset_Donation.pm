package WebGUI::Help::Asset_Donation;

use strict; 


our $HELP = { 
	'template' => {	

		title => 'donation template help', 
		body => '',	
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
			{	name => "donateButton" , required=>1 },
			{	name => "priceField" , required=>1 },
			{	name => "hasAddedToCart" , required=>1 },
			{	name => "thankYouMessage", description=>"thank you message help" },
			{	name => "defaultPrice", description=>"default price help" },
			{   name => "continueShoppingUrl" },
			{	name => "templateId", description=>"donation template help" },
		],
		related => [  
		],
	},

};

1; 
