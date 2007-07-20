package WebGUI::Help::Asset_Matrix;

our $HELP = {
	'matrix add/edit' => {
		title => 'add/edit help title',
		body => 'add/edit help body',
		isa => [
		],
		fields => [
                        {
                                title => 'visitor cache timeout',
                                namespace => 'Asset_Matrix',
                                description => 'visitor cache timeout help',
				uiLevel => 8,
                        },
                        {
                                title => 'categories',
                                description => 'categories description',
                                namespace => 'Asset_Matrix',
                        },
                        {
                                title => 'max comparisons',
                                description => 'max comparisons description',
                                namespace => 'Asset_Matrix',
                        },
                        {
                                title => 'max comparisons privileged',
                                description => 'max comparisons privileged description',
                                namespace => 'Asset_Matrix',
                        },
                        {
                                title => 'detail template',
                                description => 'detail template description',
                                namespace => 'Asset_Matrix',
                        },
                        {
                                title => 'rating timeout',
                                description => 'rating timeout description',
                                namespace => 'Asset_Matrix',
                        },
                        {
                                title => 'rating timeout privileged',
                                description => 'rating timeout privileged description',
                                namespace => 'Asset_Matrix',
                        },
                        {
                                title => 'group to add',
                                description => 'group to add description',
                                namespace => 'Asset_Matrix',
                        },
                        {
                                title => 'privileged group',
                                description => 'privileged group description',
                                namespace => 'Asset_Matrix',
                        },
                        {
                                title => 'rating group',
                                description => 'rating group description',
                                namespace => 'Asset_Matrix',
                        },
                        {
                                title => 'main template',
                                description => 'main template description',
                                namespace => 'Asset_Matrix',
                        },
                        {
                                title => 'rating detail template',
                                description => 'rating detail template description',
                                namespace => 'Asset_Matrix',
                        },
                        {
                                title => 'search template',
                                description => 'search template description',
                                namespace => 'Asset_Matrix',
                        },
                        {
                                title => 'compare template',
                                description => 'compare template description',
                                namespace => 'Asset_Matrix',
                        },
		],
		related => [
			{
				tag => 'search template',
				namespace => 'Asset_Matrix'
			},
			{
				tag => 'compare template',
				namespace => 'Asset_Matrix'
			},
			{
				tag => 'ratings detail template',
				namespace => 'Asset_Matrix'
			},
			{
				tag => 'main template',
				namespace => 'Asset_Matrix'
			},
			{
				tag => 'listing detail template',
				namespace => 'Asset_Matrix'
			},
		],
	},

	'listing add/edit' => {
		title => 'listing add/edit help title',
		body => 'listing add/edit help body',
		fields => [
                        {
                                title => 'product name',
                                description => 'product name description',
                                namespace => 'Asset_Matrix',
                        },
                        {
                                title => 'version number',
                                description => 'version number description',
                                namespace => 'Asset_Matrix',
                        },
                        {
                                title => 'product url',
                                description => 'product url description',
                                namespace => 'Asset_Matrix',
                        },
                        {
                                title => 'manufacturer name',
                                description => 'manufacturer name description',
                                namespace => 'Asset_Matrix',
                        },
                        {
                                title => 'manufacturer url',
                                description => 'manufacturer url description',
                                namespace => 'Asset_Matrix',
                        },
                        {
                                title => 'description',
                                description => 'description description',
                                namespace => 'Asset_Matrix',
                        },
                        {
                                title => 'listing maintainer',
                                description => 'listing maintainer description',
                                namespace => 'Asset_Matrix',
                        },
                        {
                                title => 'matrix specific fields',
                                description => 'matrix specific fields description',
                                namespace => 'Asset_Matrix',
                        },
		],
		related => [
			{
				tag => 'matrix add/edit',
				namespace => 'Asset_Matrix'
			},
		],
	},

	'field add/edit' => {
		title => 'field add/edit help title',
		body => 'field add/edit help body',
		fields => [
                        {
                                title => 'field name',
                                description => 'field name description',
                                namespace => 'Asset_Matrix',
                        },
                        {
                                title => 'field label',
                                description => 'field label description',
                                namespace => 'Asset_Matrix',
                        },
                        {
                                title => 'field type',
                                description => 'field type description',
                                namespace => 'Asset_Matrix',
                        },
                        {
                                title => 'field description',
                                description => 'field description description',
                                namespace => 'Asset_Matrix',
                        },
                        {
                                title => 'default value',
                                description => 'default value description',
                                namespace => 'Asset_Matrix',
                        },
                        {
                                title => 'category',
                                description => 'category description',
                                namespace => 'Asset_Matrix',
                        },
		],
		related => [
			{
				tag => 'matrix add/edit',
				namespace => 'Asset_Matrix'
			},
		],
	},

	'search template' => {
		title => 'search template help title',
		body => 'search template help body',
		variables => [
		          {
		            'name' => 'compare.form',
		          },
		          {
		            'name' => 'form.header'
		          },
		          {
		            'name' => 'form.footer'
		          },
		          {
		            'name' => 'form.submit'
		          },
		          {
		            'name' => 'CATEGORY_NAME_loop',
		            'variables' => [
		                             {
		                               'name' => 'name',
		                               'description' => 'listing name'
		                             },
		                             {
		                               'name' => 'fieldType'
		                             },
		                             {
		                               'name' => 'label',
		                               'description' => 'listing label'
		                             },
		                             {
		                               'name' => 'description',
		                               'description' => 'search field description'
		                             },
		                             {
		                               'name' => 'form'
		                             }
		                           ],
		          }
		],
		related => [
			{
				tag => 'matrix add/edit',
				namespace => 'Asset_Matrix'
			},
			{
				tag => 'compare template',
				namespace => 'Asset_Matrix'
			},
			{
				tag => 'ratings detail template',
				namespace => 'Asset_Matrix'
			},
			{
				tag => 'main template',
				namespace => 'Asset_Matrix'
			},
			{
				tag => 'listing detail template',
				namespace => 'Asset_Matrix'
			},
		],
	},

	'compare template' => {
		title => 'comparison template help title',
		body => 'comparison template help body',
		variables => [
		          {
		            'name' => 'isTooMany'
		          },
		          {
		            'name' => 'isTooFew'
		          },
		          {
		            'name' => 'compare.form'
		          },
		          {
		            'name' => 'product_loop',
		            'variables' => [
		                             {
		                               'name' => 'name'
		                             },
		                             {
		                               'name' => 'version'
		                             },
		                             {
		                               'name' => 'url',
		                               'description' => 'details url'
		                             }
		                           ]
		          },
		          {
		            'name' => 'lastupdated_loop',
		            'variables' => [
		                             {
		                               'name' => 'lastUpdated'
		                             }
		                           ]
		          },
		          {
		            'name' => 'category_loop',
		            'variables' => [
		                             {
		                               'name' => 'category',
		                               'description' => 'tmplVar category'
		                             },
		                             {
		                               'name' => 'columnCount'
		                             },
		                             {
		                               'name' => 'row_loop',
		                               'variables' => [
		                                                {
		                                                  'name' => 'column_loop',
		                                                  'variables' => [
		                                                                   {
		                                                                     'name' => 'value'
		                                                                   },
		                                                                   {
		                                                                     'name' => 'class'
		                                                                   },
		                                                                   {
		                                                                     'name' => 'description',
		                                                                     'description' => 'tmplVar field.description'
		                                                                   }
		                                                                 ]
		                                                }
		                                              ]
		                             }
		                           ]
		          }
		],
		related => [
			{
				tag => 'matrix add/edit',
				namespace => 'Asset_Matrix'
			},
			{
				tag => 'search template',
				namespace => 'Asset_Matrix'
			},
			{
				tag => 'ratings detail template',
				namespace => 'Asset_Matrix'
			},
			{
				tag => 'main template',
				namespace => 'Asset_Matrix'
			},
			{
				tag => 'listing detail template',
				namespace => 'Asset_Matrix'
			},
		],
	},

	'ratings detail template' => {
		title => 'ratings detail template help title',
		body => 'ratings detail template help body',
		variables => [
		          {
		            'name' => 'rating_loop',
		            'variables' => [
		                             {
		                               'name' => 'category',
		                             },
		                             {
		                               'name' => 'detail_loop',
		                               'variables' => [
		                                                {
		                                                  'name' => 'url',
		                                                  'description' => 'tmplVar detail url'
		                                                },
		                                                {
		                                                  'name' => 'mean',
		                                                  'description' => 'detail mean'
		                                                },
		                                                {
		                                                  'name' => 'median',
		                                                  'description' => 'detail median'
		                                                },
		                                                {
		                                                  'name' => 'count',
		                                                  'description' => 'detail count'
		                                                },
		                                                {
		                                                  'name' => 'name',
		                                                  'description' => 'listing name'
		                                                }
		                                              ]
		                             }
		                           ]
		          }
		],
		related => [
			{
				tag => 'matrix add/edit',
				namespace => 'Asset_Matrix'
			},
			{
				tag => 'search template',
				namespace => 'Asset_Matrix'
			},
			{
				tag => 'compare template',
				namespace => 'Asset_Matrix'
			},
			{
				tag => 'main template',
				namespace => 'Asset_Matrix'
			},
			{
				tag => 'listing detail template',
				namespace => 'Asset_Matrix'
			},
		],
	},

	'main template' => {
		title => 'matrix template help title',
		body => 'matrix template help body',
		variables => [
		          {
		            'name' => 'compare.form',
		          },
		          {
		            'name' => 'search.url'
		          },
		          {
		            'name' => 'isLoggedIn'
		          },
		          {
		            'name' => 'field.list.url'
		          },
		          {
		            'name' => 'listing.add.url'
		          },
		          {
		            'name' => 'best.views.url'
		          },
		          {
		            'name' => 'best.views.count'
		          },
		          {
		            'name' => 'best.views.name'
		          },
		          {
		            'name' => 'best.compares.url'
		          },
		          {
		            'name' => 'best.compares.count'
		          },
		          {
		            'name' => 'best.compares.name'
		          },
		          {
		            'name' => 'best.clicks.url'
		          },
		          {
		            'name' => 'best.clicks.count'
		          },
		          {
		            'name' => 'best.clicks.name'
		          },
		          {
		            'name' => 'best_rating_loop',
		            'variables' => [
		                             {
		                               'name' => 'url',
		                               'description' => 'tmplVar best.url'
		                             },
		                             {
		                               'name' => 'category',
		                               'description' => 'tmplVar best.category'
		                             },
		                             {
		                               'name' => 'name',
		                               'description' => 'tmplVar best.name'
		                             },
		                             {
		                               'name' => 'mean'
		                             },
		                             {
		                               'name' => 'median'
		                             },
		                             {
		                               'name' => 'count'
		                             }
		                           ]
		          },
		          {
		            'name' => 'worst_rating_loop',
		            'variables' => [
		                             {
		                               'name' => 'url',
		                               'description' => 'tmplVar worst.url'
		                             },
		                             {
		                               'name' => 'category',
		                               'description' => 'tmplVar worst.category'
		                             },
		                             {
		                               'name' => 'name',
		                               'description' => 'tmplVar worst.name'
		                             },
		                             {
		                               'name' => 'mean',
		                               'description' => 'tmplVar worst.mean'
		                             },
		                             {
		                               'name' => 'median',
		                               'description' => 'tmplVar worst.median'
		                             },
		                             {
		                               'name' => 'count',
		                               'description' => 'tmplVar worst.count'
		                             }
		                           ]
		          },
		          {
		            'name' => 'ratings.details.url'
		          },
		          {
		            'name' => 'best.posts.url'
		          },
		          {
		            'name' => 'best.updated.url'
		          },
		          {
		            'name' => 'best.updated.date'
		          },
		          {
		            'name' => 'best.updated.name'
		          },
		          {
		            'name' => 'last_update_loop',
		            'variables' => [
		                             {
		                               'name' => 'url',
		                               'description' => 'tmplVar last.url'
		                             },
		                             {
		                               'name' => 'name',
		                               'description' => 'tmplVar last.name'
		                             },
		                             {
		                               'name' => 'lastUpdated',
		                               'description' => 'tmplVar last.lastUpdated'
		                             }
		                           ]
		          },
		          {
		            'name' => 'user.count'
		          },
		          {
		            'name' => 'current.user.count'
		          },
		          {
		            'name' => 'listing.count'
		          },
		          {
		            'name' => 'pending_list',
		            'variables' => [
		                             {
		                               'name' => 'url',
		                               'description' => 'tmplVar pending.url'
		                             },
		                             {
		                               'name' => 'productName',
		                               'description' => 'tmplVar pending.productName'
		                             }
		                           ]
		          }
		        ],
		related => [
			{
				tag => 'matrix add/edit',
				namespace => 'Asset_Matrix'
			},
			{
				tag => 'search template',
				namespace => 'Asset_Matrix'
			},
			{
				tag => 'compare template',
				namespace => 'Asset_Matrix'
			},
			{
				tag => 'ratings detail template',
				namespace => 'Asset_Matrix'
			},
			{
				tag => 'listing detail template',
				namespace => 'Asset_Matrix'
			},
		],
	},

	'listing detail template' => {
		title => 'detail template help title',
		body => 'detail template help body',
		variables => [
		          {
		            'name' => 'discussion'
		          },
		          {
		            'name' => 'screenshot',
		            'description' => 'tmplVar screenshot'
		          },
		          {
		            'name' => 'thumbnail'
		          },
		          {
		            'name' => 'email.form'
		          },
		          {
		            'name' => 'email.wasSent'
		          },
		          {
		            'name' => 'edit.url'
		          },
		          {
		            'name' => 'user.canEdit'
		          },
		          {
		            'name' => 'user.canApprove'
		          },
		          {
		            'name' => 'approve.url'
		          },
		          {
		            'name' => 'delete.url'
		          },
		          {
		            'name' => 'isPending'
		          },
		          {
		            'name' => 'lastUpdated.epoch'
		          },
		          {
		            'name' => 'lastUpdated.date'
		          },
		          {
		            'name' => 'id'
		          },
		          {
		            'name' => 'description',
		            'description' => 'listing description'
		          },
		          {
		            'name' => 'productName'
		          },
		          {
		            'name' => 'productUrl'
		          },
		          {
		            'name' => 'productUrl.click'
		          },
		          {
		            'name' => 'manufacturerName'
		          },
		          {
		            'name' => 'manufacturerUrl'
		          },
		          {
		            'name' => 'manufacturerUrl.click'
		          },
		          {
		            'name' => 'versionNumber'
		          },
		          {
		            'name' => 'views'
		          },
		          {
		            'name' => 'compares'
		          },
		          {
		            'name' => 'clicks'
		          },
		          {
		            'name' => 'ratings'
		          },
		          {
		            'name' => 'CATEGORY_NAME_loop',
		            'variables' => [
		                             {
		                               'name' => 'value',
		                             },
		                             {
		                               'name' => 'name',
		                               'description' => 'tmplVar name'
		                             },
		                             {
		                               'name' => 'label'
		                             },
		                             {
		                               'name' => 'description',
		                               'description' => 'category listing description'
		                             },
		                             {
		                               'name' => 'category',
		                               'description' => 'tmplVar category'
		                             },
		                             {
		                               'name' => 'class',
		                               'description' => 'tmplVar class'
		                             }
		                           ]
		          }
		        ],
		related => [
			{
				tag => 'matrix add/edit',
				namespace => 'Asset_Matrix'
			},
			{
				tag => 'search template',
				namespace => 'Asset_Matrix'
			},
			{
				tag => 'compare template',
				namespace => 'Asset_Matrix'
			},
			{
				tag => 'ratings detail template',
				namespace => 'Asset_Matrix'
			},
			{
				tag => 'main template',
				namespace => 'Asset_Matrix'
			},
		],
	},
};

1;
