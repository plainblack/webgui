package WebGUI::Help::Product;

our $HELP = {
	'product add/edit' => {
		title => 38,
		body => 39,
		related => [
			{
				tag => 'product related add/edit',
				namespace => 'Product'
			},
			{
				tag => 'product accessory add/edit',
				namespace => 'Product'
			},
			{
				tag => 'product benefit add/edit',
				namespace => 'Product'
			},
			{
				tag => 'product feature add/edit',
				namespace => 'Product'
			},
			{
				tag => 'product specification add/edit',
				namespace => 'Product'
			},
			{
				tag => 'product template',
				namespace => 'Product'
			},
			{
				tag => 'wobjects using',
				namespace => 'WebGUI'
			}
		]
	},
	'product feature add/edit' => {
		title => 40,
		body => 41,
		related => [
			{
				tag => 'product benefit add/edit',
				namespace => 'Product'
			},
			{
				tag => 'product add/edit',
				namespace => 'Product'
			}
		]
	},
	'product specification add/edit' => {
		title => 42,
		body => 43,
		related => [
			{
				tag => 'product add/edit',
				namespace => 'Product'
			}
		]
	},
	'product accessory add/edit' => {
		title => 44,
		body => 45,
		related => [
			{
				tag => 'product add/edit',
				namespace => 'Product'
			}
		]
	},
	'product related add/edit' => {
		title => 46,
		body => 47,
		related => [
			{
				tag => 'product add/edit',
				namespace => 'Product'
			}
		]
	},
	'product benefit add/edit' => {
		title => 49,
		body => 50,
		related => [
			{
				tag => 'product feature add/edit',
				namespace => 'Product'
			},
			{
				tag => 'product add/edit',
				namespace => 'Product'
			}
		]
	},
	'product template' => {
		title => 62,
		body => 63,
		related => [
			{
				tag => 'product add/edit',
				namespace => 'Product'
			},
			{
				tag => 'wobject template',
				namespace => 'WebGUI'
			}
		]
	},
};

1;
