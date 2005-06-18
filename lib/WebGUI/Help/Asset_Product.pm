package WebGUI::Help::Asset_Product;

our $HELP = {
	'product add/edit' => {
		title => '38',
		body => '39',
		fields => [
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
				namespace => 'Wobject'
			}
		]
	},
	'product feature add/edit' => {
		title => '40',
		body => '41',
		fields => [
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
				namespace => 'Wobject'
			}
		]
	},
};

1;
