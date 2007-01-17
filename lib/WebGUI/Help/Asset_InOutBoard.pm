package WebGUI::Help::Asset_InOutBoard;

our $HELP = {
	'in out board add/edit' => {
		title => '18',
		body => '19',
		isa => [
			{
				namespace => 'Asset_Wobject',
				tag => 'wobject add/edit',
			},
		],
		fields => [
                        {
                                title => '1',
                                description => '1 description',
                                namespace => 'Asset_InOutBoard',
                        },
                        {
                                title => '12',
                                description => '12 description',
                                namespace => 'Asset_InOutBoard',
                        },
                        {
                                title => 'In Out Template',
                                description => 'In Out Template description',
                                namespace => 'Asset_InOutBoard',
                        },
                        {
                                title => '13',
                                description => '13 description',
                                namespace => 'Asset_InOutBoard',
                        },
                        {
                                title => '3',
                                description => '3 description',
                                namespace => 'Asset_InOutBoard',
                        },
                        {
                                title => 'inOutGroup',
                                description => 'inOutGroup description',
                                namespace => 'Asset_InOutBoard',
                        },
		],
		related => [
			{
				tag => 'in out board template',
				namespace => 'Asset_InOutBoard',
			},
			{
				tag => 'in out board report template',
				namespace => 'Asset_InOutBoard',
			},
			{
				tag => 'wobjects using',
				namespace => 'Asset_Wobject',
			},
		],
	},

	'in out board template' => {
		title => '20',
		body => '21',
		isa => [
			{
				namespace => 'Asset_InOutBoard',
				tag => 'in out board asset template variables',
			},
			{
				namespace => 'Asset_Template',
				tag => 'template variables',
			},
			{
				namespace => 'Asset',
				tag => 'asset template',
			},
		],
		variables => [
		          {
		            'name' => 'canViewReport',
		          },
		          {
		            'name' => 'viewReportURL',
		          },
		          {
		            'name' => 'viewReportLabel',
		          },
		          {
		            'name' => 'selectDelegatesURL',
		          },
		          {
		            'name' => 'selectDelegatesLabel',
		          },
		          {
		            'name' => 'displayForm',
		          },
		          {
		            'name' => 'form',
		          },
		          {
		            'name' => 'rows_loop',
		            'variables' => [
		                             {
		                               'name' => 'deptHasChanged',
		                             },
		                             {
		                               'name' => 'department',
		                             },
		                             {
		                               'name' => 'username',
		                             },
		                             {
		                               'name' => 'status',
		                             },
		                             {
		                               'name' => 'dateStamp',
		                             },
		                             {
		                               'name' => 'message',
		                             },
		                           ],
		          },
		          {
		            'name' => 'paginateBar',
		          },
		],
		related => [
			{
				tag => 'in out board add/edit',
				namespace => 'Asset_InOutBoard',
			},
		],
	},

	'in out board report template' => {
		title => '22',
		body => '23',
		isa => [
			{
				namespace => 'Asset_InOutBoard',
				tag => 'in out board asset template variables',
			},
			{
				namespace => 'Asset_Template',
				tag => 'template variables',
			},
			{
				namespace => 'Asset',
				tag => 'asset template',
			},
		],
		variables => [
		          {
		            'name' => 'reportTitleLabel',
		          },
		          {
		            'name' => 'showReport',
		          },
		          {
		            'name' => 'form',
		            'description' => 'report.form',
		          },
		          {
		            'name' => 'username.label',
		          },
		          {
		            'name' => 'status.label',
		          },
		          {
		            'name' => 'date.label',
		          },
		          {
		            'name' => 'message.label',
		          },
		          {
		            'name' => 'updatedBy.label',
		          },
		          {
		            'name' => 'rows_loop',
		            'variables' => [
		                             {
		                               'name' => 'deptHasChanged',
		                             },
		                             {
		                               'name' => 'username',
		                             },
		                             {
		                               'name' => 'department',
		                             },
		                             {
		                               'name' => 'status',
		                             },
		                             {
		                               'name' => 'dateStamp',
		                             },
		                             {
		                               'name' => 'message',
		                             },
		                             {
		                               'name' => 'createdBy',
		                             },
		                           ],
		            'description' => 'report rows_loop',
		          },
		          {
		            'name' => 'paginateBar',
		          },
		],
		related => [
			{
				tag => 'in out board add/edit',
				namespace => 'Asset_InOutBoard',
			},
		],
	},

	'in out board asset template variables' => {
		title => 'in out board asset template variables title',
		body => 'in out board asset template variables body',
		isa => [
			{
				namespace => 'Asset_Wobject',
				tag => 'wobject template variables',
			},
		],
		fields => [
		],
		variables => [
		          {
		            'name' => 'statusList',
		          },
		          {
		            'name' => 'reportViewerGroup',
		          },
		          {
		            'name' => 'inOutGroup',
		          },
		          {
		            'name' => 'inOutTemplateId',
		          },
		          {
		            'name' => 'reportTemplateId',
		          },
		          {
		            'name' => 'paginateAfter',
		          },
		        ],
		related => [
		],
	},

};

1;

