package WebGUI::Help::Asset;

our $HELP = {

        'asset macros' => {
		title => 'asset macros title',
		body => 'asset macros body',
		related => [
			{
				tag => 'macros using',
				namespace => 'WebGUI'
			},
		]
	},

	'asset fields' => {
		title => 'asset fields title',
		body => 'asset fields body',
		related => [
		]
	},

        'redirect add/edit' => {
		title => 'redirect add/edit title',
		body => 'redirect add/edit body',
		related => [
			{
				tag => 'asset fields',
				namespace => 'Asset'
			},
		]
	},

        'file add/edit' => {
		title => 'file add/edit title',
		body => 'file add/edit body',
		related => [
			{
				tag => 'asset fields',
				namespace => 'Asset'
			},
		]
	},

	'metadata manage'=> {
		title => 'content profiling',
		body => 'metadata manage body',
		related => [
			{
				tag => 'metadata edit property',
				namespace => 'Asset'
			},
			{
				tag => 'user macros',
				namespace => 'WebGUI'
			},
			{
				tag => 'wobject add/edit',
				namespace => 'WebGUI',
			},
		],
	},
	'metadata edit property' => {
                title => 'Metadata, Edit property',
                body => 'metadata edit property body',
                related => [
			{
				tag => 'metadata manage',
				namespace => 'Asset'
                        },
                        {
                                tag => 'user macros',
                                namespace => 'WebGUI'
                        },
                        {
                                tag => 'wobject add/edit',
                                namespace => 'WebGUI',
                        },
                ],
        },
};

1;
