package WebGUI::Help::Shortcut;

our $HELP = {
	'shortcut add/edit' => {
		title => '5',
		body => '6',
		related => [
			{
				tag => 'wobjects using',
				namespace => 'WebGUI'
			},
                        {
                                tag => 'metadata manage',
                                namespace => 'Asset'
                        },

		]
	},

	'shortcut template' => {
		title => 'shortcut template title',
		body => 'shortcut template body',
		related => [
			{
				tag => 'wobjects using',
				namespace => 'WebGUI'
			},
                        {
                                tag => 'template language',
                                namespace => 'Template'
                        },

		]
	},
};

1;
