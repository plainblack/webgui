package WebGUI::Help::PayDriver_ITransact;

use strict; 


our $HELP = { 

	'edit credentials template' => {	
		title 		=> 'edit credentials template', 
		body 		=> 'edit credentials template help',	
		isa 		=> [],
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
				name		=> "addressField",
				description	=> "addressField help",
				required	=> 1,
			},
			{
				name		=> "cityField",
				description	=> "cityField help",
				required	=> 1,
                namespace   => 'Shop',
			},
			{
				name		=> "stateField",
				description	=> "stateField help",
				required	=> 1,
                namespace   => 'Shop',
			},
			{
				name		=> "countryField",
				description	=> "countryField help",
				required	=> 1,
                namespace   => 'Shop',
			},
			{
				name		=> "codeField",
				description	=> "codeField help",
				required	=> 1,
                namespace   => 'Shop',
			},
			{
				name		=> "phoneField",
				description	=> "phoneNumberField help",
				required	=> 1,
                namespace   => 'Shop',
			},
			{
				name		=> "emailField",
				description	=> "emailField help",
				required	=> 1,
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
