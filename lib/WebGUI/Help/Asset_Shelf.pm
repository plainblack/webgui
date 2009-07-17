package WebGUI::Help::Asset_Shelf;

use strict; 


our $HELP = { 
	'template' => {	

		title => 'shelf template', 
		body => '',	
		isa => [
            {   namespace => "Asset_Wobject",
                tag       => "wobject template variables"
            },
			 {   tag       => 'pagination template variables',
                namespace => 'WebGUI'
            },
		],
		fields => [	
		],
		variables => [
			{	name => "shelves" , required=>1, variables => [
					{ name => "title",
                      description => 'shelf_title', },
					{ name => "url",
                      description => 'shelf_url', },
                ],
            },
			{	name => "products" , required=>1, variables => [
					{ name => "url",
                      description => 'product_url', },
					{ name => "thumbnailUrl" },
					{ name => "price" },
					{ name => "addToCartForm" },
					],
				},
			{	name => "templateId", description=>"shelf template help" },
			{	name => "noViewableSkus", },
			{	name => "emptyShelf",      },
		],
		related => [  
		],
	},

};

1; 
