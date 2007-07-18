package WebGUI::Help::WebGUI;

our $HELP = {

	'style template' => {
		title => '1073',
		body => '',
		variables => [
		          {
		            'name' => 'body.content'
		          },
		          {
		            'name' => 'head.tags'
		          }
		],
		fields => [
		],
		related => [
			{
				tag => 'template language',
				namespace => 'Asset_Template'
			},
		]
	},

	'page delete' => {
		title => '653',
		body => '608',
		fields => [
		],
		related => [
		]
	},

	'trash manage' => {
		title => '960',
		body => '961',
		fields => [
		],
		related => [
		]
	},
	'clipboard manage' => {
		title => '957',
		body => '958',
		fields => [
		],
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
		fields => [
		],
		related => [
			{
				tag => 'article add/edit',
				namespace => 'Asset_Article'
			},
			{
				tag => 'message board add/edit',
				namespace => 'Asset_MessageBoard'
			},
			{
				tag => 'poll add/edit',
				namespace => 'Asset_Poll'
			},
		]
	},
	'edit user karma' => {
		title => '558',
		body => 'edit user karma body',
		fields => [
                        {
                                title => '556',
                                description => '556 description',
                                namespace => 'WebGUI',
                        },
                        {
                                title => '557',
                                description => '557 description',
                                namespace => 'WebGUI',
                        },
		],
		related => [
			{
				tag => 'article add/edit',
				namespace => 'Asset_Article'
			},
			{
				tag => 'message board add/edit',
				namespace => 'Asset_MessageBoard'
			},
			{
				tag => 'poll add/edit',
				namespace => 'Asset_Poll'
			},
		]
	},
	'clipboard empty' => {
		title => '968',
		body => '969',
		fields => [
		],
		related => [
			{
				tag => 'clipboard manage',
				namespace => 'WebGUI'
			}
		]
	},
	'database links manage' => {
		title => '997',
		body => '1000',
		fields => [
		],
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
		fields => [
                        {
                                title => '992',
                                description => '992 description',
                                namespace => 'WebGUI',
                        },
                        {
                                title => '993',
                                description => '993 description',
                                namespace => 'WebGUI',
                        },
                        {
                                title => '994',
                                description => '994 description',
                                namespace => 'WebGUI',
                        },
                        {
                                title => '995',
                                description => '995 description',
                                namespace => 'WebGUI',
                        },
			{
				title => 'allowed keywords',
				description => 'allowed keywords description',
				namespace => 'WebGUI',
			},
		],
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
		fields => [
		],
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
		variables => [
		          {
		            'name' => 'pagination.firstPage'
		          },
		          {
		            'name' => 'pagination.firstPageUrl'
		          },
		          {
		            'name' => 'pagination.firstPageText'
		          },
		          {
		            'name' => 'pagination.isFirstPage'
		          },
		          {
		            'name' => 'pagination.lastPage'
		          },
		          {
		            'name' => 'pagination.lastPageUrl'
		          },
		          {
		            'name' => 'pagination.lastPageText'
		          },
		          {
		            'name' => 'pagination.isLastPage'
		          },
		          {
		            'name' => 'pagination.nextPage'
		          },
		          {
		            'name' => 'pagination.nextPageUrl'
		          },
		          {
		            'name' => 'pagination.nextPageText'
		          },
		          {
		            'name' => 'pagination.previousPage'
		          },
		          {
		            'name' => 'pagination.previousPageUrl'
		          },
		          {
		            'name' => 'pagination.previousPageText'
		          },
		          {
		            'name' => 'pagination.pageNumber'
		          },
		          {
		            'name' => 'pagination.pageCount'
		          },
		          {
		            'name' => 'pagination.pageCount.isMultiple'
		          },
		          {
		            'name' => 'pagination.pageList',
		          },
		          {
		            'name' => 'pagination.pageLoop',
		            'variables' => [
		                             {
		                               'name' => 'pagination.url'
		                             },
		                             {
		                               'name' => 'pagination.text'
		                             }
		                           ]
		          },
		          {
		            'name' => 'pagination.pageList.upTo20'
		          },
		          {
		            'name' => 'pagination.pageLoop.upTo20',
		            'variables' => [
		                             {
		                               'name' => 'pagination.url'
		                             },
		                             {
		                               'name' => 'pagination.text'
		                             }
		                           ]
		          },
		          {
		            'name' => 'pagination.pageList.upTo10'
		          },
		          {
		            'name' => 'pagination.pageLoop.upTo10',
		            'variables' => [
		                             {
		                               'name' => 'pagination.url'
		                             },
		                             {
		                               'name' => 'pagination.text'
		                             }
		                           ]
		          }
		],
	fields => [
		],
		related => [
			{
				tag => 'wobject template',
				namespace => 'Asset_Wobject'
			}
		]
	},
	'glossary' => {
                title => 'glossary title',
                body => 'glossary body',
		fields => [
		],
                related => [
                ],
	},
	'webgui tips' => {
                title => 'webgui tips title',
                body => 'webgui tips body',
		fields => [
		],
                related => [
                ],
	},
};

1;
