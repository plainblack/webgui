package WebGUI::Help::Post;

our $HELP = {
	'post add/edit template' => {
		title => 'add/edit post template title',
		body => 'add/edit post template body',
		related => [
			{
				tag => 'template language',
				namespace => 'Template'
			},
			{
				tag => 'post template variables',
				namespace => 'Post'
			},
		]
	},

	'post template variables' => {
		title => 'post template variables title',
		body => 'post template variables body',
		related => [
			{
				tag => 'template language',
				namespace => 'Template'
			},
			{
				tag => 'collaboration template labels',
				namespace => 'Collaboration'
			},
		]
	},

	'notification template' => {
		title => 'notification template title',
		body => 'notification template body',
		related => [
			{
				tag => 'template language',
				namespace => 'Template'
			},
			{
				tag => 'post template variables',
				namespace => 'Post'
			},
		]
	},

};

1;
