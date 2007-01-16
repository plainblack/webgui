package WebGUI::Help::Asset_Poll;

our $HELP = {
	'poll add/edit' => {
		title => '61',
		body => '71',
		isa => [
			{
				namespace => 'Asset_Wobject',
				tag => 'wobject add/edit',
			},
		],
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
				namespace => 'Asset_Poll',
			},
			{
				tag => 'wobjects using',
				namespace => 'Asset_Wobject',
			}
		]
	},

	'poll template' => {
		title => '73',
		body => '74',
		isa => [
			{
				namespace => "Asset_Poll",
				tag => "poll asset template variables"
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
		fields => [
		],
		variables => [
		          {
		            'name' => 'canVote',
		          },
		          {
		            'name' => 'question',
		          },
		          {
		            'name' => 'form.start',
			    'required' => 1,
		          },
		          {
		            'name' => 'answer_loop',
		            'variables' => [
		                             {
		                               'name' => 'answer.form',
		                             },
		                             {
		                               'name' => 'answer.text',
		                             },
		                             {
		                               'name' => 'answer.number',
		                             },
		                             {
		                               'name' => 'answer.graphWidth',
		                             },
		                             {
		                               'name' => 'answer.percent',
		                             },
		                             {
		                               'name' => 'answer.total',
		                             }
		                           ]
		          },
		          {
		            'name' => 'form.submit',
			    'required' => 1,
		          },
		          {
		            'name' => 'form.end',
			    'required' => 1,
		          },
		          {
		            'name' => 'responses.label',
		          },
		          {
		            'name' => 'responses.total',
		          },
		          {
		            'name' => 'graphUrl',
		          },
		          {
		            'name' => 'hasImageGraph',
		          }
		],
		related => [
			{
				tag => 'poll add/edit',
				namespace => 'Asset_Poll',
			},
		]
	},

	'poll asset template variables' => {
		title => 'poll asset template variables title',
		body => 'poll asset template variables body',
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
		            'name' => 'templateId',
		          },
		          {
		            'name' => 'active',
		          },
		          {
		            'name' => 'karmaPerVote',
		          },
		          {
		            'name' => 'graphWidth',
		          },
		          {
		            'name' => 'voteGroup',
		          },
		          {
		            'name' => 'question',
		          },
		          {
		            'name' => 'randomizeAnswers',
		          },
		          {
		            'name' => 'aN',
		          },
		          {
		            'name' => 'graphConfiguration',
		          },
		          {
		            'name' => 'generateGraph',
		          },
		        ],
		related => [
		],
	},

};

1;
