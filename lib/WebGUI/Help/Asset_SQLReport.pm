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
                        { #templateId
                                title => '72',
                                description => '72 description',
                                namespace => 'Asset_SQLReport',
                        },
                        { #debug mode
                                title => '16',
                                description => '16 description',
                                namespace => 'Asset_SQLReport',
                        },
                        {
                                title => 'cache timeout',
                                description => 'cache timeout description',
                                namespace => 'Asset_SQLReport',
                        },
                        {
                                title => 'Placeholder Parameters',
                                description => 'Placeholder Parameters description',
                                namespace => 'Asset_SQLReport',
                        },
                        { #preprocess macros
                                title => '15',
                                description => '15 description',
                                namespace => 'Asset_SQLReport',
                        },
			{
				title => 'Prequery statements',
				description => 'Prequery statements description',
				namespace => 'Asset_SQLReport',
			},
                        { #db query
                                title => '4',
                                description => '4 description',
                                namespace => 'Asset_SQLReport',
                        },
                        { #pagination
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
		isa => [
			{
				namespace => "Asset_SQLReport",
				tag => "sql report asset template variables"
			},
			{
				namespace => "Asset_Template",
				tag => "template variables"
			},
			{
				namespace => "Asset",
				tag => "asset template"
			},
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

	'sql report asset template variables' => {
		private => 1,
		title => 'sql report asset template variables title',
		body => 'sql report asset template variables body',
		isa => [
			{
				namespace => "Asset_Wobject",
				tag => "wobject template variables"
			},
		],
		fields => [
		],
		variables => [
		          {
		            'name' => 'templateId'
		          },
		          {
		            'name' => 'cacheTimeout'
		          },
		          {
		            'name' => 'paginateAfter'
		          },
		          {
		            'name' => 'dbQuery1'
		          },
		          {
		            'name' => 'prequeryStatements1'
		          },
		          {
		            'name' => 'preprocessMacros1'
		          },
		          {
		            'name' => 'placeholderParams1'
		          },
		          {
		            'name' => 'databaseLinkId1'
		          },
		          {
		            'name' => 'dbQuery2'
		          },
		          {
		            'name' => 'prequeryStatements2'
		          },
		          {
		            'name' => 'preprocessMacros2'
		          },
		          {
		            'name' => 'placeholderParams2'
		          },
		          {
		            'name' => 'databaseLinkId2'
		          },
		          {
		            'name' => 'dbQuery3'
		          },
		          {
		            'name' => 'prequeryStatements3'
		          },
		          {
		            'name' => 'preprocessMacros3'
		          },
		          {
		            'name' => 'placeholderParams3'
		          },
		          {
		            'name' => 'databaseLinkId3'
		          },
		          {
		            'name' => 'dbQuery4'
		          },
		          {
		            'name' => 'prequeryStatements4'
		          },
		          {
		            'name' => 'preprocessMacros4'
		          },
		          {
		            'name' => 'placeholderParams4'
		          },
		          {
		            'name' => 'databaseLinkId4'
		          },
		          {
		            'name' => 'dbQuery5'
		          },
		          {
		            'name' => 'prequeryStatements5'
		          },
		          {
		            'name' => 'preprocessMacros5'
		          },
		          {
		            'name' => 'placeholderParams5'
		          },
		          {
		            'name' => 'databaseLinkId5'
		          },
		          {
		            'name' => 'debugMode'
		          },
		        ],
		related => [
		]
	},

};

1;
