package WebGUI::Help::Asset_Template;

our $HELP = {

	'templates manage' => {
		title => '683',
		body => '638',
		fields => [
		],
		related => [
			{
				tag => 'template add/edit',
				namespace => 'Asset_Template'
			},
			{
				tag => 'template delete',
				namespace => 'Asset_Template'
			},
			{
				tag => 'template language',
				namespace => 'Asset_Template'
			},
			{
				tag => 'template variables',
				namespace => 'Asset_Template'
			},
		]
	},
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
			{
				tag => 'templates manage',
				namespace => 'Asset_Template'
			}
		]
	},

	'template delete' => {
		title => '685',
		body => '640',
		fields => [
		],
		related => [
			{
				tag => 'templates manage',
				namespace => 'Asset_Template'
			}
		]
	},

	'template language' => {
		title => '825',
		body => '826',
		fields => [
		],
		related => [
			{
				tag => 'templates manage',
				namespace => 'Asset_Template'
			},
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
			{
				tag => 'templates manage',
				namespace => 'Asset_Template'
			}
		]
	},

};

1;
