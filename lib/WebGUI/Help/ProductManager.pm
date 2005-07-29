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
                        {
                                title => 'edit parameter name',
                                description => 'edit parameter name description',
                                namespace => 'ProductManager',
                        },
		],
		related => [
		]
	},
	'edit option' => {
		title => 'help edit option title',
		body => 'help edit option body',
		fields => [
                        {
                                title => 'edit option value',
                                description => 'edit option value description',
                                namespace => 'ProductManager',
                        },
                        {
                                title => 'edit option price modifier',
                                description => 'edit option price modifier description',
                                namespace => 'ProductManager',
                        },
                        {
                                title => 'edit option weight modifier',
                                description => 'edit option weight modifier description',
                                namespace => 'ProductManager',
                        },
                        {
                                title => 'edit option sku modifier',
                                description => 'edit option sku modifier description',
                                namespace => 'ProductManager',
                        },
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
                        {
                                title => 'price override',
                                description => 'price override description',
                                namespace => 'ProductManager',
                        },
                        {
                                title => 'weight override',
                                description => 'weight override description',
                                namespace => 'ProductManager',
                        },
                        {
                                title => 'sku override',
                                description => 'sku override description',
                                namespace => 'ProductManager',
                        },
                        {
                                title => 'available',
                                description => 'available description',
                                namespace => 'ProductManager',
                        },
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

