package WebGUI::Help::WebGUI;

our $HELP = {
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
	'content filtering' => {
		title => '418',
		body => 'content filter body',
		related => [
		],
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
		related => []
	},
	'style template' => {
		title => '1073',
		body => '1074',
		related => [
			{
				tag => 'style sheets using',
				namespace => 'WebGUI'
			},
			{
				tag => 'template language',
				namespace => 'Asset_Template'
			},
			{
				tag => 'templates manage',
				namespace => 'Asset_Template'
			}
		]
	},

	'style sheets using' => {
		title => '668',
		body => '623',
		related => [
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
			},
			{
				tag => 'database links manage',
				namespace => 'WebGUI'
			},
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
	'settings' => {
		title => 'settings',
		body => 'settings help',
		related => []
	},
	'groups default' => {
		title => 'groups default title',
		body => 'groups default body',
		related => [
			{
				tag => 'groups manage',
				namespace => 'WebGUI'
			}
		]
	},
	'groups manage' => {
		title => '660',
		body => '615',
		related => [
			{
				tag => 'groups default',
				namespace => 'WebGUI'
			},
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
				tag => 'page delete',
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
				namespace => 'Asset_Article'
			},
			{
				tag => 'group add/edit',
				namespace => 'WebGUI'
			},
			{
				tag => 'message board add/edit',
				namespace => 'Asset_MessageBoard'
			},
			{
				tag => 'poll add/edit',
				namespace => 'Asset_Poll'
			},
			{
				tag => 'settings',
				namespace => 'WebGUI'
			},
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
				tag => 'templates manage',
				namespace => 'Asset_Template'
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
				namespace => 'Asset_SQLReport'
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
				namespace => 'Asset_SQLReport'
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
				namespace => 'Asset_SQLReport'
			}
		]
	},
	'pagination template variables' => {
		title => '1085',
		body => '1086',
		related => [
			{
				tag => 'wobject template',
				namespace => 'Wobject'
			}
		]
	},
	'page export' => {
                title => 'Page, Export',
                body => 'Page, Export body',
                related => [
                ],
	},
	'glossary' => {
                title => 'glossary title',
                body => 'glossary body',
                related => [
                ],
	},
};

1;
