package WebGUI::Help::Wobject;

our $HELP = {

	'wobjects using' => {
		title => '671',
		body => '626',
		fields => [
		],
		related => [
			{
				tag => 'macros using',
				namespace => 'Macros'
			},
			{
				tag => 'style sheets using',
				namespace => 'WebGUI'
			},
			{
				tag => 'wobject add/edit',
				namespace => 'Wobject'
			},
			{
				tag => 'wobject delete',
				namespace => 'Wobject'
			}
		]
	},

	'wobject add/edit' => {
		title => '677',
		body => '632',
		fields => [
		],
		related => [
			{
				tag => 'asset fields',
				namespace => 'Asset'
			},
			{
				tag => 'wobjects using',
				namespace => 'Wobject'
			}
		]
	},

	'wobject delete' => {
		title => '664',
		body => '619',
		fields => [
		],
		related => [
			{
				tag => 'wobjects using',
				namespace => 'Wobject'
			}
		]
	},

	'wobject template' => {
		title => '827',
		body => '828',
		fields => [
		],
		related => [
			{
				tag => 'pagination template variables',
				namespace => 'WebGUI'
			},
			{
				tag => 'template language',
				namespace => 'Asset_Template'
			},
			{
				tag => 'templates manage',
				namespace => 'Asset_Template'
			},
		]
	},
};

1;
