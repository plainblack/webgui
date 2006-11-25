package WebGUI::Help::Asset_SQLReport;

our $HELP = {
	'sql report add/edit' => {
		title => '61',
		body => '71',
		isa => [
			{
				namespace => "Asset_Wobject",
				tag => "wobject add/edit"
			},
		],
		fields => [
                        {
                                title => '72',
                                description => '72 description',
                                namespace => 'Asset_SQLReport',
                        },
                        {
                                title => 'cache timeout',
                                description => 'cache timeout description',
                                namespace => 'Asset_SQLReport',
                        },
                        {
                                title => '16',
                                description => '16 description',
                                namespace => 'Asset_SQLReport',
                        },
                        {
                                title => 'Placeholder Parameters',
                                description => 'Placeholder Parameters description',
                                namespace => 'Asset_SQLReport',
                        },
                        {
                                title => '15',
                                description => '15 description',
                                namespace => 'Asset_SQLReport',
                        },
			{
				title => 'Prequery statements',
				description => 'Prequery statements description',
				namespace => 'Asset_SQLReport',
			},
                        {
                                title => '4',
                                description => '4 description',
                                namespace => 'Asset_SQLReport',
                        },
                        {
                                title => '14',
                                description => '14 description',
                                namespace => 'Asset_SQLReport',
                        },
		],
		related => [
			{
				tag => 'sql report template',
				namespace => 'Asset_SQLReport'
			},
			{
				tag => 'wobjects using',
				namespace => 'Asset_Wobject'
			},
			{
				tag => 'database links manage',
				namespace => 'WebGUI',
			},
		]
	},
	'sql report template' => {
		title => '72',
		body => '73',
		fields => [
		],
		variables => [
		          {
		            'name' => 'columns_loop',
		            'variables' => [
		                             {
		                               'name' => 'column.number'
		                             },
		                             {
		                               'name' => 'column.name'
		                             }
		                           ]
		          },
		          {
		            'name' => 'rows.count'
		          },
		          {
		            'name' => 'rows.count.isZero'
		          },
		          {
		            'name' => 'rows.count.isZero.label'
		          },
		          {
		            'name' => 'rows_loop',
		            'variables' => [
		                             {
		                               'name' => 'row.number'
		                             },
		                             {
		                               'name' => 'row.field.__NAME__.value'
		                             },
		                             {
		                               'name' => 'row.field_loop',
		                               'variables' => [
		                                                {
		                                                  'name' => 'field.number'
		                                                },
		                                                {
		                                                  'name' => 'field.name'
		                                                },
		                                                {
		                                                  'name' => 'field.value'
		                                                }
		                                              ]
		                             }
		                           ]
		          },
		          {
		            'name' => 'hasNest'
		          },
		          {
		            'name' => 'queryN.columns_loop',
		            'variables' => [
		                             {
		                               'name' => 'column.number'
		                             },
		                             {
		                               'name' => 'column.name'
		                             }
		                           ]
		          },
		          {
		            'name' => 'queryN.rows.count'
		          },
		          {
		            'name' => 'queryN.count.isZero'
		          },
		          {
		            'name' => 'queryN.rows.count.isZero.label'
		          },
		          {
		            'name' => 'queryN.rows_loop',
		            'variables' => [
		                             {
		                               'name' => 'queryN.row.number'
		                             },
		                             {
		                               'name' => 'queryN.row.field.__NAME__.value'
		                             },
		                             {
		                               'name' => 'queryN.row.field_loop',
		                               'variables' => [
		                                                {
		                                                  'name' => 'field.number'
		                                                },
		                                                {
		                                                  'name' => 'field.name'
		                                                },
		                                                {
		                                                  'name' => 'field.value'
		                                                }
		                                              ]
		                             }
		                           ]
		          },
		          {
		            'name' => 'queryN.hasNest'
		          }
		        ],
		related => [
			{
				tag => 'pagination template variables',
				namespace => 'WebGUI'
			},
			{
				tag => 'sql report add/edit',
				namespace => 'Asset_SQLReport'
			},
			{
				tag => 'wobject template',
				namespace => 'Asset_Wobject'
			}
		]
	},
};

1;
