package WebGUI::Help::WebGUI;

our $HELP = {
	'image add/edit' => {
		title => '670',
		body => '625',
		related => [
			{
				tag => 'collateral manage',
				namespace => 'WebGUI'
			}
		]
	},
	'root manage' => {
		title => '678',
		body => '633',
		related => [
			{
				tag => 'page add/edit',
				namespace => 'WebGUI'
			},
			{
				tag => 'page delete',
				namespace => 'WebGUI'
			}
		]
	},
	'packages creating' => {
		title => '681',
		body => '636',
		related => [
			{
				tag => 'package add',
				namespace => 'WebGUI'
			},
			{
				tag => 'page add/edit',
				namespace => 'WebGUI'
			},
			{
				tag => 'page delete',
				namespace => 'WebGUI'
			}
		]
	},
	'package add' => {
		title => '680',
		body => '635',
		related => [
			{
				tag => 'packages creating',
				namespace => 'WebGUI'
			}
		]
	},
	'search engine using' => {
		title => '675',
		body => '630',
		related => [
			{
				tag => 'style macros',
				namespace => 'WebGUI'
			}
		]
	},
	'company information edit' => {
		title => '656',
		body => '611',
		related => [
			{
				tag => 'settings manage',
				namespace => 'WebGUI'
			}
		]
	},
	'trash empty' => {
		title => '696',
		body => '651',
		related => [
			{
				tag => 'trash manage',
				namespace => 'WebGUI'
			}
		]
	},
	'profile settings edit' => {
		title => '672',
		body => '627',
		related => [
			{
				tag => 'settings manage',
				namespace => 'WebGUI'
			}
		]
	},
	'miscellaneous settings edit' => {
		title => '674',
		body => '629',
		related => [
			{
				tag => 'settings manage',
				namespace => 'WebGUI'
			}
		]
	},
	'style template' => {
		title => '1073',
		body => '1074',
		related => [
			{
				tag => 'style macros',
				namespace => 'WebGUI'
			},
			{
				tag => 'style sheets using',
				namespace => 'WebGUI'
			},
			{
				tag => 'template language',
				namespace => 'WebGUI'
			},
			{
				tag => 'templates manage',
				namespace => 'WebGUI'
			}
		]
	},
	'messaging settings edit' => {
		title => '663',
		body => '618',
		related => [
			{
				tag => 'settings manage',
				namespace => 'WebGUI'
			}
		]
	},
	'wobjects using' => {
		title => '671',
		body => '626',
		related => [
			{
				tag => 'macros using',
				namespace => 'WebGUI'
			},
			{
				tag => 'style sheets using',
				namespace => 'WebGUI'
			},
			{
				tag => 'wobject add/edit',
				namespace => 'WebGUI'
			},
			{
				tag => 'wobject delete',
				namespace => 'WebGUI'
			}
		]
	},
	'wobject add/edit' => {
		title => '677',
		body => '632',
		related => [
			{
				tag => 'article add/edit',
				namespace => 'Article'
			},
			{
				tag => 'events calendar add/edit',
				namespace => 'EventsCalendar'
			},
			{
				tag => 'file manager add/edit',
				namespace => 'FileManager'
			},
			{
				tag => 'http proxy add/edit',
				namespace => 'HttpProxy'
			},
			{
				tag => 'data form add/edit',
				namespace => 'DataForm'
			},
			{
				tag => 'message board add/edit',
				namespace => 'MessageBoard'
			},
			{
				tag => 'metadata manage',
				namespace => 'WebGUI'
			},
			{
				tag => 'poll add/edit',
				namespace => 'Poll'
			},
			{
				tag => 'product add/edit',
				namespace => 'Product'
			},
			{
				tag => 'site map add/edit',
				namespace => 'SiteMap'
			},
			{
				tag => 'sql report add/edit',
				namespace => 'SQLReport'
			},
			{
				tag => 'survey add/edit',
				namespace => 'Survey'
			},
			{
				tag => 'syndicated content add/edit',
				namespace => 'SyndicatedContent'
			},
			{
				tag => 'user submission system add/edit',
				namespace => 'USS'
			},
			{
				tag => 'wobject proxy add/edit',
				namespace => 'WobjectProxy'
			},
			{
				tag => 'wobjects using',
				namespace => 'WebGUI'
			}
		]
	},
	'style sheets using' => {
		title => '668',
		body => '623',
		related => [
			{
				tag => 'page template',
				namespace => 'WebGUI'
			},
			{
				tag => 'style template',
				namespace => 'WebGUI'
			}
		]
	},
	'group add/edit' => {
		title => '667',
		body => '622',
		related => [
			{
				tag => 'groups manage',
				namespace => 'WebGUI'
			}
		]
	},
	'user settings edit' => {
		title => '652',
		body => '607',
		related => [
			{
				tag => 'settings manage',
				namespace => 'WebGUI'
			}
		]
	},
	'group delete' => {
		title => '665',
		body => '620',
		related => [
			{
				tag => 'groups manage',
				namespace => 'WebGUI'
			}
		]
	},
	'wobject delete' => {
		title => '664',
		body => '619',
		related => [
			{
				tag => 'wobjects using',
				namespace => 'WebGUI'
			}
		]
	},
	'settings manage' => {
		title => '662',
		body => '617',
		related => [
			{
				tag => 'company information edit',
				namespace => 'WebGUI'
			},
			{
				tag => 'content settings edit',
				namespace => 'WebGUI'
			},
			{
				tag => 'messaging settings edit',
				namespace => 'WebGUI'
			},
			{
				tag => 'miscellaneous settings edit',
				namespace => 'WebGUI'
			},
			{
				tag => 'profile settings edit',
				namespace => 'WebGUI'
			},
			{
				tag => 'user settings edit',
				namespace => 'WebGUI'
			}
		]
	},
	'groups manage' => {
		title => '660',
		body => '615',
		related => [
			{
				tag => 'group add/edit',
				namespace => 'WebGUI'
			},
			{
				tag => 'group delete',
				namespace => 'WebGUI'
			},
			{
				tag => 'users manage',
				namespace => 'WebGUI'
			}
		]
	},
	'users manage' => {
		title => '658',
		body => '613',
		related => [
			{
				tag => 'groups manage',
				namespace => 'WebGUI'
			},
			{
				tag => 'user profile edit',
				namespace => 'WebGUI'
			},
			{
				tag => 'user add/edit',
				namespace => 'WebGUI'
			},
			{
				tag => 'user delete',
				namespace => 'WebGUI'
			}
		]
	},
	'user delete' => {
		title => '657',
		body => '612',
		related => [
			{
				tag => 'users manage',
				namespace => 'WebGUI'
			}
		]
	},
	'user profile edit' => {
		title => '682',
		body => '637',
		related => [
			{
				tag => 'users manage',
				namespace => 'WebGUI'
			}
		]
	},
	'user add/edit' => {
		title => '655',
		body => '610',
		related => [
			{
				tag => 'users manage',
				namespace => 'WebGUI'
			}
		]
	},
	'page delete' => {
		title => '653',
		body => '608',
		related => [
			{
				tag => 'page add/edit',
				namespace => 'WebGUI'
			}
		]
	},
	'page add/edit' => {
		title => '642',
		body => '606',
		related => [
			{
				tag => 'page template',
				namespace => 'WebGUI'
			},
			{
				tag => 'page delete',
				namespace => 'WebGUI'
			}
		]
	},
	'content settings edit' => {
		title => '679',
		body => '634',
		related => [
			{
				tag => 'settings manage',
				namespace => 'WebGUI'
			}
		]
	},
	'templates manage' => {
		title => '683',
		body => '638',
		related => [
			{
				tag => 'themes manage',
				namespace => 'WebGUI'
			},
			{
				tag => 'template add/edit',
				namespace => 'WebGUI'
			},
			{
				tag => 'template delete',
				namespace => 'WebGUI'
			},
			{
				tag => 'template language',
				namespace => 'WebGUI'
			}
		]
	},
	'template add/edit' => {
		title => '684',
		body => '639',
		related => [
			{
				tag => 'templates manage',
				namespace => 'WebGUI'
			}
		]
	},
	'template delete' => {
		title => '685',
		body => '640',
		related => [
			{
				tag => 'templates manage',
				namespace => 'WebGUI'
			}
		]
	},
	'macros using' => {
		title => '669',
		body => '624',
		related => [
			{
				tag => 'collateral macros',
				namespace => 'WebGUI'
			},
			{
				tag => 'navigation macro',
				namespace => 'WebGUI'
			},
			{
				tag => 'programmer macros',
				namespace => 'WebGUI'
			},
			{
				tag => 'style macros',
				namespace => 'WebGUI'
			},
			{
				tag => 'user macros',
				namespace => 'WebGUI'
			}
		]
	},
	'trash manage' => {
		title => '960',
		body => '961',
		related => [
			{
				tag => 'trash empty',
				namespace => 'WebGUI'
			}
		]
	},
	'clipboard manage' => {
		title => '957',
		body => '958',
		related => [
			{
				tag => 'clipboard empty',
				namespace => 'WebGUI'
			}
		]
	},
	'karma using' => {
		title => '697',
		body => '698',
		related => [
			{
				tag => 'article add/edit',
				namespace => 'Article'
			},
			{
				tag => 'group add/edit',
				namespace => 'WebGUI'
			},
			{
				tag => 'message board add/edit',
				namespace => 'MessageBoard'
			},
			{
				tag => 'poll add/edit',
				namespace => 'Poll'
			},
			{
				tag => 'user settings edit',
				namespace => 'WebGUI'
			},
			{
				tag => 'user submission system add/edit',
				namespace => 'USS'
			}
		]
	},
	'collateral manage' => {
		title => '785',
		body => '786',
		related => [
			{
				tag => 'collateral macros',
				namespace => 'WebGUI'
			},
			{
				tag => 'file add/edit',
				namespace => 'WebGUI'
			},
			{
				tag => 'folder add/edit',
				namespace => 'WebGUI'
			},
			{
				tag => 'image add/edit',
				namespace => 'WebGUI'
			},
			{
				tag => 'themes manage',
				namespace => 'WebGUI'
			},
			{
				tag => 'snippet add/edit',
				namespace => 'WebGUI'
			}
		]
	},
	'template language' => {
		title => '825',
		body => '826',
		related => [
			{
				tag => 'templates manage',
				namespace => 'WebGUI'
			}
		]
	},
	'wobject template' => {
		title => '827',
		body => '828',
		related => [
			{
				tag => 'article template',
				namespace => 'Article'
			},
			{
				tag => 'data form template',
				namespace => 'DataForm'
			},
			{
				tag => 'events calendar template',
				namespace => 'EventsCalendar'
			},
			{
				tag => 'file manager template',
				namespace => 'FileManager'
			},
			{
				tag => 'message board template',
				namespace => 'MessageBoard'
			},
			{
				tag => 'product template',
				namespace => 'Product'
			},
			{
				tag => 'site map template',
				namespace => 'SiteMap'
			},
			{
				tag => 'syndicated content template',
				namespace => 'SyndicatedContent'
			},
			{
				tag => 'templates manage',
				namespace => 'WebGUI'
			},
			{
				tag => 'user submission system template',
				namespace => 'USS'
			}
		]
	},
	'page template' => {
		title => '829',
		body => '830',
		related => [
			{
				tag => 'page add/edit',
				namespace => 'WebGUI'
			},
			{
				tag => 'templates manage',
				namespace => 'WebGUI'
			}
		]
	},
	'collateral macros' => {
		title => '831',
		body => '832',
		related => [
			{
				tag => 'collateral manage',
				namespace => 'WebGUI'
			},
			{
				tag => 'macros using',
				namespace => 'WebGUI'
			}
		]
	},
	'file add/edit' => {
		title => '833',
		body => '834',
		related => [
			{
				tag => 'collateral manage',
				namespace => 'WebGUI'
			}
		]
	},
	'snippet add/edit' => {
		title => '835',
		body => '836',
		related => [
			{
				tag => 'collateral manage',
				namespace => 'WebGUI'
			}
		]
	},
	'folder add/edit' => {
		title => '837',
		body => '838',
		related => [
			{
				tag => 'collateral manage',
				namespace => 'WebGUI'
			}
		]
	},
	'programmer macros' => {
		title => '839',
		body => '840',
		related => [
			{
				tag => 'macros using',
				namespace => 'WebGUI'
			}
		]
	},
	'navigation macro' => {
		title => '841',
		body => '842',
		related => [
			{
				tag => 'macros using',
				namespace => 'WebGUI'
			}
		]
	},
	'user macros' => {
		title => '843',
		body => '844',
		related => [
			{
				tag => 'macros using',
				namespace => 'WebGUI'
			}
		]
	},
	'style macros' => {
		title => '845',
		body => '846',
		related => [
			{
				tag => 'macros using',
				namespace => 'WebGUI'
			},
			{
				tag => 'style template',
				namespace => 'WebGUI'
			}
		]
	},
	'clipboard empty' => {
		title => '968',
		body => '969',
		related => [
			{
				tag => 'clipboard manage',
				namespace => 'WebGUI'
			}
		]
	},
	'themes manage' => {
		title => '931',
		body => '932',
		related => [
			{
				tag => 'collateral manage',
				namespace => 'WebGUI'
			},
			{
				tag => 'templates manage',
				namespace => 'WebGUI'
			},
			{
				tag => 'theme delete',
				namespace => 'WebGUI'
			},
			{
				tag => 'theme edit',
				namespace => 'WebGUI'
			},
			{
				tag => 'theme import',
				namespace => 'WebGUI'
			}
		]
	},
	'theme edit' => {
		title => '933',
		body => '934',
		related => [
			{
				tag => 'themes manage',
				namespace => 'WebGUI'
			}
		]
	},
	'theme import' => {
		title => '936',
		body => '937',
		related => [
			{
				tag => 'themes manage',
				namespace => 'WebGUI'
			}
		]
	},
	'theme delete' => {
		title => '938',
		body => '939',
		related => [
			{
				tag => 'themes manage',
				namespace => 'WebGUI'
			}
		]
	},
	'database links manage' => {
		title => '997',
		body => '1000',
		related => [
			{
				tag => 'database link add/edit',
				namespace => 'WebGUI'
			},
			{
				tag => 'database link delete',
				namespace => 'WebGUI'
			},
			{
				tag => 'sql report add/edit',
				namespace => 'SQLReport'
			}
		]
	},
	'database link add/edit' => {
		title => '998',
		body => '1001',
		related => [
			{
				tag => 'database links manage',
				namespace => 'WebGUI'
			},
			{
				tag => 'database link delete',
				namespace => 'WebGUI'
			},
			{
				tag => 'sql report add/edit',
				namespace => 'SQLReport'
			}
		]
	},
	'database link delete' => {
		title => '999',
		body => '1002',
		related => [
			{
				tag => 'database links manage',
				namespace => 'WebGUI'
			},
			{
				tag => 'database link add/edit',
				namespace => 'WebGUI'
			},
			{
				tag => 'sql report add/edit',
				namespace => 'SQLReport'
			}
		]
	},
	'forum discussion properties' => {
		title => '1054',
		body => '1055',
		related => [
			{
				tag => 'forum notification template',
				namespace => 'WebGUI'
			},
			{
				tag => 'forum post form template',
				namespace => 'WebGUI'
			},
			{
				tag => 'forum post template',
				namespace => 'WebGUI'
			},
			{
				tag => 'forum search template',
				namespace => 'WebGUI'
			},
			{
				tag => 'forum template',
				namespace => 'WebGUI'
			},
			{
				tag => 'forum thread template',
				namespace => 'WebGUI'
			}
		]
	},
	'forum template' => {
		title => '1056',
		body => '1057',
		related => [
			{
				tag => 'forum discussion properties',
				namespace => 'WebGUI'
			},
			{
				tag => 'template language',
				namespace => 'WebGUI'
			},
			{
				tag => 'templates manage',
				namespace => 'WebGUI'
			}
		]
	},
	'forum post template' => {
		title => '1058',
		body => '1059',
		related => [
			{
				tag => 'forum discussion properties',
				namespace => 'WebGUI'
			},
			{
				tag => 'template language',
				namespace => 'WebGUI'
			},
			{
				tag => 'templates manage',
				namespace => 'WebGUI'
			}
		]
	},
	'forum thread template' => {
		title => '1060',
		body => '1061',
		related => [
			{
				tag => 'forum discussion properties',
				namespace => 'WebGUI'
			},
			{
				tag => 'forum post template',
				namespace => 'WebGUI'
			},
			{
				tag => 'template language',
				namespace => 'WebGUI'
			},
			{
				tag => 'templates manage',
				namespace => 'WebGUI'
			}
		]
	},
	'forum notification template' => {
		title => '1062',
		body => '1063',
		related => [
			{
				tag => 'forum discussion properties',
				namespace => 'WebGUI'
			},
			{
				tag => 'forum post template',
				namespace => 'WebGUI'
			},
			{
				tag => 'template language',
				namespace => 'WebGUI'
			},
			{
				tag => 'templates manage',
				namespace => 'WebGUI'
			}
		]
	},
	'forum post form template' => {
		title => '1065',
		body => '1066',
		related => [
			{
				tag => 'forum discussion properties',
				namespace => 'WebGUI'
			},
			{
				tag => 'forum post template',
				namespace => 'WebGUI'
			},
			{
				tag => 'template language',
				namespace => 'WebGUI'
			},
			{
				tag => 'templates manage',
				namespace => 'WebGUI'
			}
		]
	},
	'forum search template' => {
		title => '1067',
		body => '1068',
		related => [
			{
				tag => 'forum discussion properties',
				namespace => 'WebGUI'
			},
			{
				tag => 'template language',
				namespace => 'WebGUI'
			},
			{
				tag => 'templates manage',
				namespace => 'WebGUI'
			}
		]
	},
	'pagination template variables' => {
		title => '1085',
		body => '1086',
		related => [
			{
				tag => 'wobject template',
				namespace => 'WebGUI'
			}
		]
	},
	'gradebook report template' => {
		title => '1087',
		body => '1088',
		related => [
			{
				tag => 'pagination template variables',
				namespace => 'WebGUI'
			},
			{
				tag => 'survey template',
				namespace => 'Survey'
			},
			{
				tag => 'survey template common vars',
				namespace => 'Survey'
			}
		]
	},
	'survey response template' => {
		title => '1089',
		body => '1090',
		related => [
			{
				tag => 'survey template common vars',
				namespace => 'Survey'
			},
			{
				tag => 'survey add/edit',
				namespace => 'Survey'
			}
		]
	},
	'statistical overview report template' => {
		title => '1091',
		body => '1092',
		related => [
			{
				tag => 'pagination template variables',
				namespace => 'WebGUI'
			},
			{
				tag => 'survey template common vars',
				namespace => 'Survey'
			},
			{
				tag => 'survey add/edit',
				namespace => 'Survey'
			}
		]
	},
	'navigation add/edit' => {
		title => '1098',
		body => '1093',
		related => [
			{
				tag => 'navigation macro',
				namespace => 'WebGUI'
			},
			{
				tag => 'navigation template',
				namespace => 'WebGUI'
			},
			{
				tag => 'navigation manage',
				namespace => 'WebGUI'
			},
			{
				tag => 'template add/edit',
				namespace => 'WebGUI'
			}
		]
	},
	'navigation manage' => {
		title => '1094',
		body => '1095',
		related => [
			{
				tag => 'navigation macro',
				namespace => 'WebGUI'
			},
			{
				tag => 'navigation template',
				namespace => 'WebGUI'
			},
			{
				tag => 'navigation add/edit',
				namespace => 'WebGUI'
			}
		]
	},
	'navigation template' => {
		title => '1096',
		body => '1097',
		related => [
			{
				tag => 'navigation macro',
				namespace => 'WebGUI'
			},
			{
				tag => 'navigation add/edit',
				namespace => 'WebGUI'
			},
			{
				tag => 'navigation manage',
				namespace => 'WebGUI'
			},
			{
				tag => 'template language',
				namespace => 'WebGUI'
			}
		]
	},
	'metadata manage'=> {
		title => 'Metadata, Manage',
		body => 'metadata manage body',
		related => [
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
				namespace => 'WebGUI'
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
	'page export' => {
                title => 'Page, Export',
                body => 'Page, Export body',
                related => [
                ],
        },
	'forum post preview template' => {
		title => 'Forum, Post Preview Template Title',
		body => 'Forum, Post Preview Template Body',
		related => [
			{
				tag => 'forum post template',
				namespace => 'WebGUI'
			},
			{
				tag => 'forum discussion properties',
				namespace => 'WebGUI'
			},
			{
				tag => 'template language',
				namespace => 'WebGUI'
			},
			{
				tag => 'templates manage',
				namespace => 'WebGUI'
			}
		],
	}
};

1;
