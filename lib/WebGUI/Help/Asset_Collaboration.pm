package WebGUI::Help::Asset_Collaboration;

our $HELP = {
	'collaboration add/edit' => {
		title => 'collaboration add/edit title',
		body => 'collaboration add/edit body',
		fields => [
		],
		related => [
			{
				tag => 'content filtering',
				namespace => 'WebGUI'
			},
		]
	},

	'collaboration template labels' => {
		title => 'collaboration template labels title',
		body => 'collaboration template labels body',
		fields => [
		],
		related => [
		]
	},

	'collaboration post list template variables' => {
		title => 'collaboration post list template variables title',
		body => 'collaboration post list template variables body',
		fields => [
		],
		related => [
			{
				tag => 'asset fields',
				namespace => 'Asset'
			},
		]
	},

	'collaboration template' => {
		title => 'collaboration template title',
		body => 'collaboration template body',
		fields => [
		],
		related => [
			{
		   		tag => 'collaboration template labels',
				namespace => 'Asset_Collaboration',
			},
			{
		   		tag => 'collaboration post list template variables',
				namespace => 'Asset_Collaboration',
			},
		]
	},

	'collaboration search template' => {
		title => 'collaboration search template title',
		body => 'collaboration search template body',
		fields => [
		],
		related => [
			{
		   		tag => 'collaboration post list template variables',
				namespace => 'Asset_Collaboration',
			},
		]
	},

};

1;
