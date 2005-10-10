package WebGUI::Help::Asset_Snippet;

our $HELP = {

        'snippet add/edit' => {
		title => 'snippet add/edit title',
		body => 'snippet add/edit body',
		fields => [
                        {
                                title => 'assetName',
                                description => 'snippet description',
                                namespace => 'Asset_Snippet',
                        },
                        {
                                title => 'process as template',
                                description => 'process as template description',
                                namespace => 'Asset_Snippet',
                        },
                        {
                                title => 'mimeType',
                                description => 'mimeType description',
                                namespace => 'Asset_Snippet',
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
