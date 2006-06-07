package WebGUI::Help::Asset_Poll;

our $HELP = {
	'poll add/edit' => {
		title => '61',
		body => '71',
		fields => [
                        {
                                title => '73',
                                description => '73 description',
                                namespace => 'Asset_Poll',
                        },
                        {
                                title => '3',
                                description => '3 description',
                                namespace => 'Asset_Poll',
                        },
                        {
                                title => '4',
                                description => '4 description',
                                namespace => 'Asset_Poll',
                        },
                        {
                                title => '20',
                                description => '20 description',
                                namespace => 'Asset_Poll',
                        },
                        {
                                title => '5',
                                description => '5 description',
                                namespace => 'Asset_Poll',
                        },
                        {
                                title => '6',
                                description => '6 description',
                                namespace => 'Asset_Poll',
                        },
                        {
                                title => '7',
                                description => '7 description',
                                namespace => 'Asset_Poll',
                        },
                        {
                                title => '72',
                                description => '72 description',
                                namespace => 'Asset_Poll',
                        },
                        {
                                title => '10',
                                description => '10 description',
                                namespace => 'Asset_Poll',
                        },
		],
		related => [
			{
				tag => 'poll template',
				namespace => 'Asset_Poll'
			},
			{
				tag => 'wobjects using',
				namespace => 'Asset_Wobject'
			}
		]
	},
	'poll template' => {
		title => '73',
		body => '74',
		fields => [
		],
		variables => [
		          {
		            'name' => 'canVote'
		          },
		          {
		            'name' => 'question'
		          },
		          {
		            'name' => 'form.start'
		          },
		          {
		            'name' => 'answer_loop',
		            'variables' => [
		                             {
		                               'name' => 'answer.form'
		                             },
		                             {
		                               'name' => 'answer.text'
		                             },
		                             {
		                               'name' => 'answer.number'
		                             },
		                             {
		                               'name' => 'answer.graphWidth'
		                             },
		                             {
		                               'name' => 'answer.percent'
		                             },
		                             {
		                               'name' => 'answer.total'
		                             }
		                           ]
		          },
		          {
		            'name' => 'form.submit'
		          },
		          {
		            'name' => 'form.end'
		          },
		          {
		            'name' => 'responses.label'
		          },
		          {
		            'name' => 'responses.total'
		          }
		],
		related => [
			{
				tag => 'poll add/edit',
				namespace => 'Asset_Poll'
			},
			{
				tag => 'wobject template',
				namespace => 'Asset_Wobject'
			}
		]
	},
};

1;
