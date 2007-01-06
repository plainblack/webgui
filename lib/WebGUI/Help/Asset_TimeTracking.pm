package WebGUI::Help::Asset_TimeTracking;

our $HELP = {
	'time tracking add/edit' => {
		title => 'timetracking add/edit title',
		body => 'timetracking add/edit body',
		isa => [
			{
				namespace => "Asset_Wobject",
				tag => "wobject add/edit"
			},
		],
		fields => [
                        {
                                title => 'userViewTemplate label',
                                description => 'userViewTemplate hoverhelp',
                                namespace => 'Asset_TimeTracking',
                        },
                        {
                                title => 'managerViewTemplate label',
                                description => 'managerViewTemplate hoverhelp',
                                namespace => 'Asset_TimeTracking',
                        },
                        {
                                title => 'timeRowTemplateId label',
                                description => 'timeRowTemplateId hoverhelp',
                                namespace => 'Asset_TimeTracking',
                        },
                        {
                                title => 'groupToManage label',
                                description => 'groupToManage hoverhelp',
                                namespace => 'Asset_TimeTracking',
                        },
                        {
                                title => 'Project Management Integration',
                                description => 'Choose yes to pull projects and task information from the various project management assets on your site',
                                namespace => 'Asset_TimeTracking',
                        },
		],
		related => [
		],
	},

	'manage projects' => {
		title => 'manage projects screen label',
		body => 'manage projects body',
		fields => [
		],
		related => [
		],
	},

	'edit project' => {
		title => 'edit project screen label',
		body => 'edit projects body',
		fields => [
                        {
                                title => 'edit project id label',
                                description => 'edit project id hoverhelp',
                                namespace => 'Asset_TimeTracking',
                        },
                        {
                                title => 'edit project resource label',
                                description => 'edit project resource hoverhelp',
                                namespace => 'Asset_TimeTracking',
                        },
                        {
                                title => 'edit project tasks label',
                                description => 'edit project tasks hoverhelp',
                                namespace => 'Asset_TimeTracking',
                        },
		],
		related => [
		],
	},

	'user view template variables' => {
		title => 'user view template title',
		body => 'user view template body',
		isa => [
			{
				namespace => "Asset_Wobject",
				tag => "wobject template variables"
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
				'name' => 'extras',
			},
			{
				'name' => 'project.manage.url',
			},
			{
				'name' => 'project.manage.label',
			},
			{
				'name' => 'form.header',
				'required' => 1,
			},
			{
				'name' => 'form.footer',
				'required' => 1,
			},
			{
				'name' => 'project.task.array',
				'required' => 1,
			},
			{
				'name' => 'js.alert.removeRow.error',
			},
			{
				'name' => 'js.alert.validate.hours.error',
			},
			{
				'name' => 'js.alert.validate.incomplete.error',
			},
			{
				'name' => 'form.isComplete',
			},
			{
				'name' => 'time.report.rows.total',
			},
			{
				'name' => 'form.timetracker',
			},
		],
		fields => [
		],
		related => [
		],
	},

	'time row template variables' => {
		title => 'time row template title',
		body => 'time row template body',
		isa => [
			{
				namespace => "Asset_Wobject",
				tag => "wobject template variables"
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
				'name' => 'extras',
			},
			{
				'name' => 'report.nextWeek.url',
			},
			{
				'name' => 'report.lastWeek.url',
			},
			{
				'name' => 'time.report.header',
			},
			{
				'name' => 'time.report.totalHours.label',
			},
			{
				'name' => 'time.report.date.label',
			},
			{
				'name' => 'time.report.project.label',
			},
			{
				'name' => 'time.report.task.label',
			},
			{
				'name' => 'time.report.hours.label',
			},
			{
				'name' => 'time.report.comments.label',
			},
			{
				'name' => 'time.add.row.label',
			},
			{
				'name' => 'time.save.label',
			},
			{
				'name' => 'time.report.complete.label',
			},
			{
				'name' => 'report.isComplete',
			},
			{
				'name' => 'time.totalHours',
			},
			{
				'name' => 'time.entry.loop',
				'variables' => [
					{
						'name' => 'row.id',
					},
					{
						'name' => 'form.taskEntryId',
						'required' => 1,
					},
					{
						'name' => 'form.project',
						'required' => 1,
					},
					{
						'name' => 'form.task',
						'required' => 1,
					},
					{
						'name' => 'form.date',
						'required' => 1,
					},
					{
						'name' => 'form.hours',
						'required' => 1,
					},
					{
						'name' => 'form.comments',
						'required' => 1,
					},
					{
						'name' => 'entry.hours',
					},
				],
			},
		],
		fields => [
		],
		related => [
		],
	},

	'time tracking asset template variables' => {
		title => 'time tracking asset template variables title',
		body => 'time tracking asset template variables body',
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
		            'name' => 'userViewTemplateId'
		          },
		          {
		            'name' => 'managerViewTemplateId'
		          },
		          {
		            'name' => 'timeRowTemplateId'
		          },
		          {
		            'name' => 'groupToManage',
		          },
		          {
		            'name' => 'pmIntegration'
		          },
		        ],
		related => [
		]
	},

};

1;  ##All perl modules must return true
