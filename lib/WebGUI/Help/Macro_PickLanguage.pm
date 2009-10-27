package WebGUI::Help::Macro_PickLanguage;

use strict; 


our $HELP = { 
	'template variables' => {     
		title => 'PickLanguage macro',
		body => '',
		'variables' => [
			{
				name => "lang_loop",
				variables => [
					{
					name => "language_lang",
					},
					{
					name => "language_langAbbr",
					},
					{
					name => "language_langAbbrLoc",
					},
					{
					name => "language_langEng",
					},
				],
			},
		],
		related => [  
		],
	},

};

1;  ##All perl modules must return true
#vim:ft=perl
