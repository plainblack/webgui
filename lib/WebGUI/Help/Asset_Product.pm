package WebGUI::Help::Asset_Product;

our $HELP = {
	'product add/edit' => {
		title => '38',
		body => '39',
		fields => [
                        {
                                title => 'cache timeout',
                                namespace => 'Asset_Product',
                                description => 'cache timeout help',
				uiLevel => 8,
                        },
                        {
                                title => '62',
                                description => '62 description',
                                namespace => 'Asset_Product',
                        },
                        {
                                title => '10',
                                description => '10 description',
                                namespace => 'Asset_Product',
                        },
                        {
                                title => '11',
                                description => '11 description',
                                namespace => 'Asset_Product',
                        },
                        {
                                title => '7',
                                description => '7 description',
                                namespace => 'Asset_Product',
                        },
                        {
                                title => '8',
                                description => '8 description',
                                namespace => 'Asset_Product',
                        },
                        {
                                title => '9',
                                description => '9 description',
                                namespace => 'Asset_Product',
                        },
                        {
                                title => '13',
                                description => '13 description',
                                namespace => 'Asset_Product',
                        },
                        {
                                title => '14',
                                description => '14 description',
                                namespace => 'Asset_Product',
                        },
                        {
                                title => '15',
                                description => '15 description',
                                namespace => 'Asset_Product',
                        },
		],
		related => [
			{
				tag => 'product related add/edit',
				namespace => 'Asset_Product'
			},
			{
				tag => 'product accessory add/edit',
				namespace => 'Asset_Product'
			},
			{
				tag => 'product benefit add/edit',
				namespace => 'Asset_Product'
			},
			{
				tag => 'product feature add/edit',
				namespace => 'Asset_Product'
			},
			{
				tag => 'product specification add/edit',
				namespace => 'Asset_Product'
			},
			{
				tag => 'product template',
				namespace => 'Asset_Product'
			},
			{
				tag => 'wobjects using',
				namespace => 'Asset_Wobject'
			}
		]
	},
	'product feature add/edit' => {
		title => '40',
		body => '41',
		fields => [
                        {
                                title => '23',
                                description => '23 description',
                                namespace => 'Asset_Product',
                        },
                        {
                                title => '24',
                                description => '24 description',
                                namespace => 'Asset_Product',
                        },
		],
		related => [
			{
				tag => 'product benefit add/edit',
				namespace => 'Asset_Product'
			},
			{
				tag => 'product add/edit',
				namespace => 'Asset_Product'
			}
		]
	},
	'product specification add/edit' => {
		title => '42',
		body => '43',
		fields => [
                        {
                                title => '26',
                                description => '26 description',
                                namespace => 'Asset_Product',
                        },
                        {
                                title => '27',
                                description => '27 description',
                                namespace => 'Asset_Product',
                        },
                        {
                                title => '29',
                                description => '29 description',
                                namespace => 'Asset_Product',
                        },
                        {
                                title => '28',
                                description => '28 description',
                                namespace => 'Asset_Product',
                        },
		],
		related => [
			{
				tag => 'product add/edit',
				namespace => 'Asset_Product'
			}
		]
	},
	'product accessory add/edit' => {
		title => '44',
		body => '45',
		fields => [
                        {
                                title => '17',
                                description => '17 description',
                                namespace => 'Asset_Product',
                        },
                        {
                                title => '18',
                                description => '18 description',
                                namespace => 'Asset_Product',
                        },
		],
		related => [
			{
				tag => 'product add/edit',
				namespace => 'Asset_Product'
			}
		]
	},
	'product related add/edit' => {
		title => '46',
		body => '47',
		fields => [
                        {
                                title => '20',
                                description => '20 description',
                                namespace => 'Asset_Product',
                        },
                        {
                                title => '21',
                                description => '21 description',
                                namespace => 'Asset_Product',
                        },
		],
		related => [
			{
				tag => 'product add/edit',
				namespace => 'Asset_Product'
			}
		]
	},
	'product benefit add/edit' => {
		title => '49',
		body => '50',
		fields => [
                        {
                                title => '51',
                                description => '51 description',
                                namespace => 'Asset_Product',
                        },
                        {
                                title => '52',
                                description => '52 description',
                                namespace => 'Asset_Product',
                        },
		],
		related => [
			{
				tag => 'product feature add/edit',
				namespace => 'Asset_Product'
			},
			{
				tag => 'product add/edit',
				namespace => 'Asset_Product'
			}
		]
	},
	'product template' => {
		title => '62',
		body => '63',
		fields => [
		],
		related => [
			{
				tag => 'product add/edit',
				namespace => 'Asset_Product'
			},
			{
				tag => 'wobject template',
				namespace => 'Asset_Wobject'
			}
		]
	},
};

1;
