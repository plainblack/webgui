package WebGUI::Help::Asset_Thread;

our $HELP = {
	'thread template variables' => {
		title => 'thread template title',
		body => 'thread template body',
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
			{
				tag => 'collaboration template labels',
				namespace => 'Asset_Collaboration'
			},
			{
				tag => 'pagination template variables',
				namespace => 'WebGUI'
			},
		]
	},

};

1;
