package WebGUI::Help::MetaData;

our $HELP = {
	'metadata manage'=> {
		title => 'Metadata, Manage',
		body => 'metadata manage body',
		related => [
			{
				tag => 'metadata edit property',
				namespace => 'MetaData'
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
				namespace => 'MetaData'
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
