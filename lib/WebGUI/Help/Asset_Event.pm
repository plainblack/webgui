package WebGUI::Help::Asset_Event;

our $HELP = {
	'event add/edit' => {
		title => '72',
		body => '73',
		isa => [
			{
				tag => 'asset fields',
				namespace => 'Asset'
			},
		],
		fields => [
                        {
                                title => '512',
                                description => 'Description description',
                                namespace => 'Asset_Event',
                        },
                        {
                                title => '513',
                                description => 'Start Date description',
                                namespace => 'Asset_Event',
                        },
                        {
                                title => '514',
                                description => 'End Date description',
                                namespace => 'Asset_Event',
                        },
                        {
                                title => '515',
                                description => '515 description',
                                namespace => 'Asset_Event',
                        },
                        {
                                title => '530',
                                description => '530 description',
                                namespace => 'Asset_Event',
                        },
                        {
                                title => '8',
                                description => 'Recurs every description',
                                namespace => 'Asset_Event',
                        },
                ],
		related => [
			{
				tag => 'event template',
				namespace => 'Asset_Event'
			},
		]
	},

	##I didn't break out individual asset level variables here
	##because there are so few of them. --ck
	'event template' => {
		title => '96',
		body => '97',
		isa => [
			{
				tag => 'asset template',
				namespace => 'Asset'
			},
			{
				tag => 'template language',
				namespace => 'Asset_Template'
			},
		],
		fields => [
		],
		variables => [
		          {
		            'name' => 'title'
		          },
		          {
		            'name' => 'start.label'
		          },
		          {
		            'name' => 'eventStartDate'
		          },
		          {
		            'name' => 'start.date'
		          },
		          {
		            'name' => 'start.time'
		          },
		          {
		            'name' => 'eventEndDate'
		          },
		          {
		            'name' => 'end.date'
		          },
		          {
		            'name' => 'end.time'
		          },
		          {
		            'name' => 'end.label'
		          },
		          {
		            'name' => 'canEdit'
		          },
		          {
		            'name' => 'edit.url'
		          },
		          {
		            'name' => 'edit.label'
		          },
		          {
		            'name' => 'delete.url'
		          },
		          {
		            'name' => 'delete.label'
		          },
		          {
		            'name' => 'description'
		          },
		          {
		            'name' => 'eventLocation'
		          }
		],
		related => [
			{
				tag => 'template language',
				namespace => 'Asset_Template'
			},
		]
	},
};

1;
