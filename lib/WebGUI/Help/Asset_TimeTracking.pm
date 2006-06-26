package WebGUI::Help::Asset_TimeTracking;

our $HELP = {
	'time tracking add/edit' => {
		title => 'timetracking add/edit title',
		body => 'timetracking add/edit body',
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

	'user view template variables' => {
		title => 'user view template title',
		body => 'user view template body',
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
				'name' => 'js.alert.removeRow.error',
			},
			{
				'name' => 'js.alert.validate.hours.error',
			},
			{
				'name' => 'js.alert.validate.incomplete.error',
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

};

1;  ##All perl modules must return true
