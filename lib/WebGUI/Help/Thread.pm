package WebGUI::Help::Thread;

our $HELP = {
	'thread template variables' => {
		title => 'thread template title',
		body => 'thread template body',
		related => [
			{
				tag => 'template language',
				namespace => 'Template'
			},
			{
				tag => 'post template variables',
				namespace => 'Post'
			},
			{
				tag => 'collaboration template labels',
				namespace => 'Collaboration'
			},
			{
				tag => 'pagination template variables',
				namespace => 'WebGUI'
			},
		]
	},

};

1;
