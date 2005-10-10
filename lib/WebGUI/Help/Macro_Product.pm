package WebGUI::Help::Macro_Product;

our $HELP = {

        'product' => {
		title => 'product title',
		body => 'product body',
		fields => [
		],
		related => [
			{
				tag => 'macros using',
				namespace => 'Macros'
			},
			{
				tag => 'manage product',
				namespace => 'ProductManager'
			},
		]
	},

};

1;

