package WebGUI::Help::Macro_PickLanguage;

use strict; 


our $HELP = { 
	'template variables' => {     
		title => 'picklanguage title',
		body => '',
		fields =>[],
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
			{
				name => "delete_url",
			},
			{
				name => "delete_label",
			},
		],
		related => [  
		],
	},

};

1;  ##All perl modules must return true
#vim:ft=perl
