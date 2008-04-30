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
			{	name => "shelves" , required=>1},
			{	name => "products" , required=>1, variables => [
					{ name => "thumbnailUrl" },
					{ name => "price" },
					],
				},
			{	name => "templateId", description=>"shelf template help" },
		],
		related => [  
		],
	},

};

1; 
