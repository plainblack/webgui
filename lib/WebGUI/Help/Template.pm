package WebGUI::Help::Template;

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
				namespace => 'Template'
			},
			{
				tag => 'template delete',
				namespace => 'Template'
			},
			{
				tag => 'template language',
				namespace => 'Template'
			}
		]
	},
	'template add/edit' => {
		title => '684',
		body => '639',
		related => [
			{
				tag => 'templates manage',
				namespace => 'Template'
			}
		]
	},

	'template delete' => {
		title => '685',
		body => '640',
		related => [
			{
				tag => 'templates manage',
				namespace => 'Template'
			}
		]
	},

	'template language' => {
		title => '825',
		body => '826',
		related => [
			{
				tag => 'templates manage',
				namespace => 'Template'
			}
		]
	},

};

1;
