package WebGUI::Help::Asset_Navigation;

our $HELP = {
	'navigation add/edit' => {
		title => '1098',
		body => '1093',
		fields => [
                        {
                                title => '1096',
                                description => '1096 description',
                                namespace => 'Asset_Navigation',
			},
                        {
                                title => 'mimeType',
                                description => 'mimeType description',
                                namespace => 'Asset_Navigation',
                        },
                        {
                                title => 'Start Point Type',
                                description => 'Start Point Type description',
                                namespace => 'Asset_Navigation',
                        },
                        {
                                title => 'Start Point',
                                description => 'Start Point description',
                                namespace => 'Asset_Navigation',
                        },
                        {
                                title => 'Ancestor End Point',
                                description => 'Ancestor End Point description',
                                namespace => 'Asset_Navigation',
                        },
                        {
                                title => 'Relatives To Include',
                                description => 'Relatives To Include description',
                                namespace => 'Asset_Navigation',
                        },
                        {
                                title => 'Descendant End Point',
                                description => 'Descendant End Point description',
                                namespace => 'Asset_Navigation',
                        },
                        {
                                title => '30',
                                description => '30 description',
                                namespace => 'Asset_Navigation',
                        },
                        {
                                title => '31',
                                description => '31 description',
                                namespace => 'Asset_Navigation',
                        },
                        {
                                title => '32',
                                description => '32 description',
                                namespace => 'Asset_Navigation',
                        },
			{
				title => 'reverse page loop',
				description => 'reverse page loop description',
				namespace => 'Asset_Navigation',
			},
		],
		related => [
			{
				tag => 'navigation template',
				namespace => 'Asset_Navigation'
			},
			{
				tag => 'navigation manage',
				namespace => 'Asset_Navigation'
			},
			{
				tag => 'template add/edit',
				namespace => 'Asset_Template'
			}
		]
	},

	'navigation template' => {
		title => '1096',
		body => '1097',
		fields => [
		],
		variables => [
		          {
		            'name' => 'currentPage.menuTitle'
		          },
		          {
		            'name' => 'currentPage.assetId'
		          },
		          {
		            'name' => 'currentPage.parentId'
		          },
		          {
		            'name' => 'currentPage.ownerUserId'
		          },
		          {
		            'name' => 'currentPage.synopsis'
		          },
		          {
		            'name' => 'currentPage.newWindow'
		          },
		          {
		            'name' => 'currentPage.menuTitle'
		          },
		          {
		            'name' => 'currentPage.title'
		          },
		          {
		            'name' => 'currentPage.isHome'
		          },
		          {
		            'name' => 'currentPage.url'
		          },
		          {
		            'name' => 'currentPage.rank'
		          },
		          {
		            'name' => 'currentPage.hasChild'
		          },
		          {
		            'name' => 'currentPage.hasSibling'
		          },
		          {
		            'name' => 'currentPage.hasViewableSiblings'
		          },
		          {
		            'name' => 'currentPage.hasViewableChildren'
		          },
		          {
		            'name' => 'page_loop',
		            'variables' => [
		                             {
		                               'name' => 'page.assetId'
		                             },
		                             {
		                               'name' => 'page.parentId'
		                             },
		                             {
		                               'name' => 'page.ownerUserId'
		                             },
		                             {
		                               'name' => 'page.synopsis'
		                             },
		                             {
		                               'name' => 'page.newWindow'
		                             },
		                             {
		                               'name' => 'page.menuTitle'
		                             },
		                             {
		                               'name' => 'page.title'
		                             },
		                             {
		                               'name' => 'page.rank'
		                             },
		                             {
		                               'name' => 'page.absDepth'
		                             },
		                             {
		                               'name' => 'page.relDepth'
		                             },
		                             {
		                               'name' => 'page.isSystem'
		                             },
		                             {
		                               'name' => 'page.isHidden'
		                             },
		                             {
		                               'name' => 'page.isContainer'
		                             },
		                             {
		                               'name' => 'page.isUtility'
		                             },
		                             {
		                               'name' => 'page.isViewable'
		                             },
		                             {
		                               'name' => 'page.url'
		                             },
		                             {
		                               'name' => 'page.indent'
		                             },
		                             {
		                               'name' => 'page.indent_loop',
		                               'variables' => [
		                                                {
		                                                  'name' => 'indent'
		                                                }
		                                              ]
		                             },
		                             {
		                               'name' => 'page.isBranchRoot'
		                             },
		                             {
		                               'name' => 'page.isTopOfBranch'
		                             },
		                             {
		                               'name' => 'page.isChild'
		                             },
		                             {
		                               'name' => 'page.isParent'
		                             },
		                             {
		                               'name' => 'page.isCurrent'
		                             },
		                             {
		                               'name' => 'page.isDescendent'
		                             },
		                             {
		                               'name' => 'page.isAncestor'
		                             },
		                             {
		                               'name' => 'page.inBranchRoot'
		                             },
		                             {
		                               'name' => 'page.isSibling'
		                             },
		                             {
		                               'name' => 'page.inBranch'
		                             },
		                             {
		                               'name' => 'page.hasChild'
		                             },
		                             {
		                               'name' => 'page.hasViewableChildren'
		                             },
		                             {
		                               'name' => 'page.depthIsN'
		                             },
		                             {
		                               'name' => 'page.relativeDepthIsN'
		                             },
		                             {
		                               'name' => 'page.depthDiff'
		                             },
		                             {
		                               'name' => 'page.depthDiffIsN'
		                             },
		                             {
		                               'name' => 'page.depthDiff_loop'
		                             },
		                             {
		                               'name' => 'page.isRankedFirst'
		                             },
		                             {
		                               'name' => 'page.isRankedLast'
		                             },
		                             {
		                               'name' => 'page.parent.menuTitle'
		                             },
		                             {
		                               'name' => 'page.parent.title'
		                             },
		                             {
		                               'name' => 'page.parent.url'
		                             },
		                             {
		                               'name' => 'page.parent.assetId'
		                             },
		                             {
		                               'name' => 'page.parent.parentId'
		                             },
		                             {
		                               'name' => 'page.parent.ownerUserId'
		                             },
		                             {
		                               'name' => 'page.parent.synopsis'
		                             },
		                             {
		                               'name' => 'page.parent.newWindow'
		                             },
					     {
					       'name' => 'page.parent.rank'
					     },
		                           ]
		          }
		],
		related => [
			{
				tag => 'navigation add/edit',
				namespace => 'Asset_Navigation'
			},
			{
				tag => 'navigation manage',
				namespace => 'Asset_Navigation'
			},
			{
				tag => 'template language',
				namespace => 'Asset_Template'
			}
		]
	},

	'navigation manage' => {
		title => '1094',
		body => '1095',
		fields => [
		],
		related => [
			{
				tag => 'navigation template',
				namespace => 'Asset_Navigation'
			},
			{
				tag => 'navigation add/edit',
				namespace => 'Asset_Navigation'
			}
		]
	},
};

1;
