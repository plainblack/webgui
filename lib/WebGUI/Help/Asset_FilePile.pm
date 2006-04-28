package WebGUI::Help::Asset_FilePile;

our $HELP = {

        'file pile add/edit' => {
		title => 'file pile add/edit title',
		body => 'file pile add/edit body',
		fields => [
                        {	#isHidden
                                title => '886',
                                description => '886 description',
                                namespace => 'Asset_FilePile',
                        },
                        {	#newWindow
                                title => '940',
                                description => '940 description',
                                namespace => 'Asset_FilePile',
                        },
                        {	#ownerUserId
                                title => '108',
                                description => '108 description',
                                namespace => 'Asset_FilePile',
                        },
                        {	#groupIdView
                                title => '872',
                                description => '872 description',
                                namespace => 'Asset_FilePile',
                        },
                        {	#groupIdEdit
                                title => '871',
                                description => '871 description',
                                namespace => 'Asset_FilePile',
                        },
                        {
                                title => 'upload files',
                                description => 'upload files description',
                                namespace => 'Asset_FilePile',
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
