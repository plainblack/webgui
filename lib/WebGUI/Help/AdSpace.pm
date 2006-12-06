package WebGUI::Help::AdSpace;

our $HELP = {

	'edit ad' => {
                title => 'edit advertisement',
                body => 'edit advertisement body',
		source => 'www_editAd',
		fields => [
                        {
                                title => 'is active',
                                description => 'is active help',
                                namespace => 'AdSpace',
                        },
                        {
                                title => 'title',
                                description => 'title help',
                                namespace => 'AdSpace',
                        },
                        {
                                title => 'url',
                                description => 'url help',
                                namespace => 'AdSpace',
                        },
                        {
                                title => 'priority',
                                description => 'priority help',
                                namespace => 'AdSpace',
                        },
                        {
                                title => 'impressions bought',
                                description => 'impressions bought help',
                                namespace => 'AdSpace',
                        },
                        {
                                title => 'clicks bought',
                                description => 'clicks bought help',
                                namespace => 'AdSpace',
                        },
                        {
                                title => 'type',
                                description => 'type help',
                                namespace => 'AdSpace',
                        },
                        {
                                title => 'ad text',
                                description => 'ad text help',
                                namespace => 'AdSpace',
                        },
                        {
                                title => 'border color',
                                description => 'border color help',
                                namespace => 'AdSpace',
                        },
                        {
                                title => 'text color',
                                description => 'text color help',
                                namespace => 'AdSpace',
                        },
                        {
                                title => 'background color',
                                description => 'background color help',
                                namespace => 'AdSpace',
                        },
                        {
                                title => 'image',
                                description => 'image help',
                                namespace => 'AdSpace',
                        },
                        {
                                title => 'rich',
                                description => 'rich help',
                                namespace => 'AdSpace',
                        },
                        {
                                title => 'title',
                                description => 'title help',
                                namespace => 'AdSpace',
                        },
		],
                related => [
                        {
                                tag => 'edit ad space',
                                namespace => 'AdSpace',
                        },
                        {
                                tag => 'ad space',
                                namespace => 'Macro_AdSpace',
                        },
                ],
	},

	'edit ad space' => {
                title => 'edit ad space',
                body => 'edit ad space body',
		source => 'www_editAdSpace',
		fields => [
                        {
                                title => 'name',
                                description => 'name help',
                                namespace => 'AdSpace',
                        },
                        {
                                title => 'title',
                                description => 'title help',
                                namespace => 'AdSpace',
                        },
                        {
                                title => 'description',
                                description => 'description help',
                                namespace => 'AdSpace',
                        },
                        {
                                title => 'width',
                                description => 'width help',
                                namespace => 'AdSpace',
                        },
                        {
                                title => 'height',
                                description => 'height help',
                                namespace => 'AdSpace',
                        },
		],
                related => [
                        {
                                tag => 'manage ad spaces',
                                namespace => 'AdSpace',
                        },
                        {
                                tag => 'edit ad',
                                namespace => 'AdSpace',
                        },
                ],
	},

	'manage ad spaces' => {
                title => 'manage ad spaces',
                body => 'add ad space body',
		source => 'www_manageAdSpaces',
		fields => [
		],
                related => [
                        {
                                tag => 'edit ad space',
                                namespace => 'AdSpace',
                        },
                ],
	},

};

1;
