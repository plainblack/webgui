package WebGUI::Help::Asset_Template;

our $HELP = {

	'templates manage' => {
		title => '683',
		body => '638',
		related => [
			{
				tag => 'themes manage',
				namespace => 'WebGUI'
			},
			{
				tag => 'template add/edit',
				namespace => 'Asset_Template'
			},
			{
				tag => 'template delete',
				namespace => 'Asset_Template'
			},
			{
				tag => 'template language',
				namespace => 'Asset_Template'
			}
		]
	},
	'template add/edit' => {
		title => '684',
		body => '639',
		related => [
			{
				tag => 'templates manage',
				namespace => 'Asset_Template'
			}
		]
	},

	'template delete' => {
		title => '685',
		body => '640',
		related => [
			{
				tag => 'templates manage',
				namespace => 'Asset_Template'
			}
		]
	},

	'template language' => {
		title => '825',
		body => '826',
		related => [
			{
				tag => 'templates manage',
				namespace => 'Asset_Template'
			}
		]
	},

};

1;
