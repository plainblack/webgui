package WebGUI::Help::Asset_Redirect;

our $HELP = {

        'redirect add/edit' => {
		title => 'redirect add/edit title',
		body => 'redirect add/edit body',
		fields => [
                        {
                                title => 'redirect url',
                                description => 'redirect url description',
                                namespace => 'Asset_Redirect',
                        },
		],
		related => [
			{
				tag => 'asset fields',
				namespace => 'Asset'
			},
		]
	},

};

1;
