package WebGUI::Help::PayDriver_PayPalStd;

use strict; 


our $HELP = { 

	'cart summary template' => {	
		title 		=> 'cart summary template', 
		body 		=> '',	
		isa 		=> [
            {   namespace => "PayDriver",
                tag       => "cart summary variables"
            },
        ],
		fields 		=> [],
		variables 	=> [
			{
				name		=> "proceedButton",
				required	=> 1,
                namespace   => 'PayDriver',
			},
		],
		related 	=> [  
		],
	},

};

1;  
