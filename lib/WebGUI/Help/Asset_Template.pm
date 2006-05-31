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
                        {
                                title => 'head block',
                                description => 'head block description',
                                namespace => 'Asset_Template',
                        },
                        {
                                title => 'parser',
                                description => 'parser description',
                                namespace => 'Asset_Template',
                        },
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
		variables => [
			  {
			    'name' => 'webgui.version'
			  },
			  {
			    'name' => 'webgui.version'
			  },
			  {
			    'name' => 'webgui.status'
			  },
			  {
			    'name' => 'session.user.username'
			  },
			  {
			    'name' => 'session.user.firstDayOfWeek'
			  },
			  {
			    'name' => 'session.config.extrasurl'
			  },
			  {
			    'name' => 'session.var.adminOn'
			  },
			  {
			    'name' => 'session.setting.companyName'
			  },
			  {
			    'name' => 'session.setting.anonymousRegistration'
			  },
			  {
			    'name' => 'session form variables'
			  }
		],
		related => [
		]
	},

	'style wizard' => {
		title => 'style wizard',
		body => 'style wizard help',
		fields => [
                        {
                                title => 'site name',
                                description => 'site name description',
                                namespace => 'Asset_Template',
                        },
                        {
                                title => 'logo',
                                description => 'logo description',
                                namespace => 'Asset_Template',
                        },
                        {
                                title => 'page background color',
                                description => 'page background color description',
                                namespace => 'Asset_Template',
                        },
                        {
                                title => 'header background color',
                                description => 'header background color description',
                                namespace => 'Asset_Template',
                        },
                        {
                                title => 'header text color',
                                description => 'header text color description',
                                namespace => 'Asset_Template',
                        },
                        {
                                title => 'body background color',
                                description => 'body background color description',
                                namespace => 'Asset_Template',
                        },
                        {
                                title => 'body text color',
                                description => 'body text color description',
                                namespace => 'Asset_Template',
                        },
                        {
                                title => 'menu background color',
                                description => 'menu background color description',
                                namespace => 'Asset_Template',
                        },
                        {
                                title => 'link color',
                                description => 'link color description',
                                namespace => 'Asset_Template',
                        },
                        {
                                title => 'visited link color',
                                description => 'visited link color description',
                                namespace => 'Asset_Template',
                        },
		],
		related => [
		]
	},

};

1;
