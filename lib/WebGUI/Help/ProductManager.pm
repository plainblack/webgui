package WebGUI::Help::ProductManager;

our $HELP = {
	'list products' => {
		title => 'help list products title',
		body => 'help list products body',
		related => [
		]
	},

	'manage product' => {
		title => 'help manage product title',
		body => 'help manage product body',
		related => [
		]
	},

	'edit product' => {
		title => 'help edit product title',
		body => 'help edit product body',
		related => [
			{
				tag => 'template language',
				namespace => 'Asset_Template'
			},
		]
	},

	'edit parameter' => {
		title => 'help edit parameter title',
		body => 'help edit parameter body',
		related => [
		]
	},
	'edit option' => {
		title => 'help edit option title',
		body => 'help edit option body',
		related => [
		]
	},
	'list variants' => {
		title => 'help list variants title',
		body => 'help list variants body',
		related => [
		]
	},
	'edit variant' => {
		title => 'help edit variant title',
		body => 'help edit variant body',
		related => [
		]
	},
	'edit sku template' => {
		title => 'help edit sku template title',
		body => 'help edit sku template body',
		related => [
		]
	},

};

1;

