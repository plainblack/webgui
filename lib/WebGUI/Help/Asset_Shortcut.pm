package WebGUI::Help::Asset_Shortcut;

our $HELP = {
	'shortcut add/edit' => {
		title => '5',
		body => '6',
		related => [
			{
				tag => 'wobjects using',
				namespace => 'Wobject'
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
				namespace => 'Wobject'
			},
                        {
                                tag => 'template language',
                                namespace => 'Asset_Template'
                        },

		]
	},
};

1;
