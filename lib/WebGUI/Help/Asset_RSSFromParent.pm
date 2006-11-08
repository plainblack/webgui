package WebGUI::Help::Asset_RSSFromParent;

our $HELP = {
	'rss from parent' => {
		title => 'rss from parent title',
		body => 'rss from parent body',
		# use the following to inherit stuff other help entries
		isa => [
		],
		fields => [	#This array is used to list hover help for form fields.
		],
		variables => [
		          {
		            'name' => 'title',
			    'description' => 'title.parent'
		          },
		          {
		            'name' => 'link',
			    'description' => 'title.parent'
		          },
		          {
		            'name' => 'description',
			    'description' => 'description.parent'
		          },
		          {
		            'name' => 'generator'
		          },
		          {
		            'name' => 'lastBuildDate'
		          },
		          {
		            'name' => 'webMaster'
		          },
		          {
		            'name' => 'docs'
		          },
		          {
		            'name' => 'item_loop',
			    variables => [
				  {
				    'name' => 'title',
				    'description' => 'title.item'
				  },
				  {
				    'name' => 'link',
				    'description' => 'title.item'
				  },
				  {
				    'name' => 'description',
				    'description' => 'description.item'
				  },
				  {
				    'name' => 'guid'
				  },
				  {
				    'name' => 'pubDate'
				  },
			    ]
		          },
		],
		related => [  ##This lists other help articles that are related to this one
		],
	},

};

1;  ##All perl modules must return true
