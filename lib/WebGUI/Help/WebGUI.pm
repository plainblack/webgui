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
		]
	},

	'pagination template variables' => {
		title => '1085',
		body => '',
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

};

1;
