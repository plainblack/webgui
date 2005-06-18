package WebGUI::Help::Asset_Post;

our $HELP = {
	'post add/edit template' => {
		title => 'add/edit post template title',
		body => 'add/edit post template body',
		fields => [
		],
		related => [
			{
				tag => 'template language',
				namespace => 'Asset_Template'
			},
			{
				tag => 'post template variables',
				namespace => 'Asset_Post'
			},
		]
	},

	'post template variables' => {
		title => 'post template variables title',
		body => 'post template variables body',
		fields => [
		],
		related => [
			{
				tag => 'template language',
				namespace => 'Asset_Template'
			},
			{
				tag => 'collaboration template labels',
				namespace => 'Asset_Collaboration'
			},
		]
	},

	'notification template' => {
		title => 'notification template title',
		body => 'notification template body',
		fields => [
		],
		related => [
			{
				tag => 'template language',
				namespace => 'Asset_Template'
			},
			{
				tag => 'post template variables',
				namespace => 'Asset_Post'
			},
		]
	},

};

1;
