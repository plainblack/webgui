package WebGUI::Help::USS;

our $HELP = {
	'user submission system add/edit' => {
		title => '61',
		body => '71',
		related => [
			{
				tag => 'forum discussion properties',
				namespace => 'WebGUI'
			},
			{
				tag => 'submission form template',
				namespace => 'USS'
			},
			{
				tag => 'submission template',
				namespace => 'USS'
			},
			{
				tag => 'user submission system template',
				namespace => 'USS'
			},
			{
				tag => 'wobjects using',
				namespace => 'WebGUI'
			}
		]
	},
	'submission form template' => {
		title => '93',
		body => '94',
		related => [
			{
				tag => 'user submission system add/edit',
				namespace => 'USS'
			}
		]
	},
	'user submission system template' => {
		title => '74',
		body => '75',
		related => [
			{
				tag => 'pagination template variables',
				namespace => 'WebGUI'
			},
			{
				tag => 'user submission system add/edit',
				namespace => 'USS'
			},
			{
				tag => 'wobject template',
				namespace => 'WebGUI'
			}
		]
	},
	'submission template' => {
		title => '76',
		body => '77',
		related => [
			{
				tag => 'user submission system add/edit',
				namespace => 'USS'
			},
			{
				tag => 'wobject template',
				namespace => 'WebGUI'
			}
		]
	},
};

1;
