package WebGUI::Help::Commerce;

our $HELP = {
	'commerce manage' => {
		title => 'help manage commerce title',
		body => 'help manage commerce body',
		related => [
		]
	},

	'list pending transactions' => {
		title => 'help manage pending transactions title',
		body => 'help manage pending transactions body',
		related => [
		]
	},

	'cancel template' => {
		title => 'help cancel checkout template title',
		body => 'help cancel checkout template body',
		related => [
			{
				tag => 'template language',
				namespace => 'Asset_Template'
			},
			{
				tag => 'templates manage',
				namespace => 'Asset_Template'
			}
		]
	},

	'confirm template' => {
		title => 'help checkout confirm template title',
		body => 'help checkout confirm template body',
		related => [
			{
				tag => 'template language',
				namespace => 'Asset_Template'
			},
			{
				tag => 'templates manage',
				namespace => 'Asset_Template'
			}
		],
	},

	'error template' => {
		title => 'help checkout error template title',
		body => 'help checkout error template body',
		related => [
			{
				tag => 'template language',
				namespace => 'Asset_Template'
			},
			{
				tag => 'templates manage',
				namespace => 'Asset_Template'
			}
		]
	},

	'select payment gateway template' => {
		title => 'help select payment template title',
		body => 'help select payment template body',
		related => [
			{
				tag => 'template language',
				namespace => 'Asset_Template'
			},
			{
				tag => 'templates manage',
				namespace => 'Asset_Template'
			}
		]
	},

};

1;
