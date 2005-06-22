package WebGUI::Help::Asset_Image;

our $HELP = {

        'image add/edit' => {
		title => 'image add/edit title',
		body => 'image add/edit body',
		fields => [
                        {
                                title => 'Thumbnail size',
                                description => 'Thumbnail size description',
                                namespace => 'Asset_Image',
                        },
                        {
                                title => 'Parameters',
                                description => 'Parameters description',
                                namespace => 'Asset_Image',
                        },
                        {
                                title => 'Thumbnail',
                                description => 'Thumbnail description',
                                namespace => 'Asset_Image',
                        },
		],
		related => [
			{
				tag => 'asset fields',
				namespace => 'Asset'
			},
			{
				tag => 'file add/edit',
				namespace => 'Asset_File'
			},
		]
	},

};

1;
