package WebGUI::Help::PayDriver_ITransact;

use strict; 


our $HELP = { 

	'edit credentials template' => {	
		title 		=> 'edit credentials template', 
		body 		=> 'edit credentials template help',	
		isa 		=> [
            {   namespace => "PayDriver",
                tag       => "cart summary variables"
            },
        ],
		fields 		=> [],
		variables 	=> [
			{
				name 		=> "errors",
				description => "errors help",
				required 	=> 1,
			},
			{
				name 		=> "error",
				description => "error help",
				required 	=> 1,
			},
			{
				name		=> "formHeader",
				description	=> "formHeader help",
				required	=> 1,
                namespace   => 'Shop',
			},
			{
				name		=> "formFooter",
				description	=> "formFooter help",
				required	=> 1,
                namespace   => 'Shop',
			},
			{
				name		=> "cardNumberField",
				description	=> "cardNumberField help",
				required	=> 1,
			},
			{
				name		=> "monthYearField",
				description	=> "monthYearField help",
				required	=> 1,
			},
			{
				name		=> "cvv2Field",
				description	=> "cvv2Field help",
				required	=> 1,
			},
			{
				name		=> "checkoutButton",
				description	=> "checkoutButton help",
				required	=> 1,
			},
		],
		related 	=> [  
		],
	},

};

1;  
