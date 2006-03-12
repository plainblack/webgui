package WebGUI::Help::Asset_Template;

our $HELP = {

	'template add/edit' => {
		title => '684',
		body => '639',
		fields => [
                        {
                                title => 'namespace',
                                description => 'namespace description',
                                namespace => 'Asset_Template',
                        },
                        {
                                title => 'show in forms',
                                description => 'show in forms description',
                                namespace => 'Asset_Template',
                        },
                        {
                                title => 'assetName',
                                description => 'template description',
                                namespace => 'Asset_Template',
                        },
		],
		related => [
		]
	},

	'template delete' => {
		title => '685',
		body => '640',
		fields => [
		],
		related => [
		]
	},

	'template language' => {
		title => '825',
		body => '826',
		fields => [
		],
		related => [
			{
				tag => 'template variables',
				namespace => 'Asset_Template'
			},
		]
	},

	'template variables' => {
		title => 'template variable title',
		body => 'template variable body',
		fields => [
		],
		related => [
		]
	},

};

1;
