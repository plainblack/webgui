package WebGUI::Help::ProductManager;

our $HELP = {
	'list products' => {
		title => 'help list products title',
		body => 'help list products body',
		fields => [
		],
		related => [
		]
	},

	'manage product' => {
		title => 'help manage product title',
		body => 'help manage product body',
		fields => [
		],
		related => [
		]
	},

	'edit product' => {
		title => 'help edit product title',
		body => 'help edit product body',
		fields => [
                        {
                                title => 'title',
                                description => 'title description',
                                namespace => 'ProductManager',
                        },
                        {
                                title => 'description',
                                description => 'description description',
                                namespace => 'ProductManager',
                        },
                        {
                                title => 'price',
                                description => 'price description',
                                namespace => 'ProductManager',
                        },
                        {
                                title => 'weight',
                                description => 'weight description',
                                namespace => 'ProductManager',
                        },
                        {
                                title => 'sku',
                                description => 'sku description',
                                namespace => 'ProductManager',
                        },
                        {
                                title => 'template',
                                description => 'template description',
                                namespace => 'ProductManager',
                        },
                        {
                                title => 'sku template',
                                description => 'sku template description',
                                namespace => 'ProductManager',
                        },
		],
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
		fields => [
		],
		related => [
		]
	},
	'edit option' => {
		title => 'help edit option title',
		body => 'help edit option body',
		fields => [
		],
		related => [
		]
	},
	'list variants' => {
		title => 'help list variants title',
		body => 'help list variants body',
		fields => [
		],
		related => [
		]
	},
	'edit variant' => {
		title => 'help edit variant title',
		body => 'help edit variant body',
		fields => [
		],
		related => [
		]
	},
	'edit sku template' => {
		title => 'help edit sku template title',
		body => 'help edit sku template body',
		fields => [
		],
		related => [
		]
	},

};

1;

