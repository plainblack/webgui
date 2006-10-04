package WebGUI::Help::Asset_ProjectManager;

##Stub document for creating help documents.

our $HELP = {
	'project manager add/edit' => {
		title => 'pm add/edit title',
		body => 'pm add/edit body',
		fields => [
                        {
                                title => 'projectDashboardTemplate label',
                                description => 'projectDashboardTemplate hoverhelp',
                                namespace => 'Asset_ProjectManager',
                        },
                        {
                                title => 'projectDisplayTemplate label',
                                description => 'projectDisplayTemplate hoverhelp',
                                namespace => 'Asset_ProjectManager',
                        },
                        {
                                title => 'ganttChartTemplate label',
                                description => 'ganttChartTemplate hoverhelp',
                                namespace => 'Asset_ProjectManager',
                        },
                        {
                                title => 'editTaskTemplate label',
                                description => 'editTaskTemplate hoverhelp',
                                namespace => 'Asset_ProjectManager',
                        },
                        {
                                title => 'groupToAdd label',
                                description => 'groupToAdd hoverhelp',
                                namespace => 'Asset_ProjectManager',
                        },
		],
		related => [
                        {
                                tag => 'project add/edit',
                                namespace => 'Asset_ProjectManager',
                        },
                        {
                                tag => 'task edit template',
                                namespace => 'Asset_ProjectManager',
                        },
                        {
                                tag => 'view project template',
                                namespace => 'Asset_ProjectManager',
                        },
		],
	},

	'project add/edit' => {
		title => 'edit project',
		body => 'project edit body',
		fields => [
                        {
                                title => 'project id',
                                description => 'project id',
                                namespace => 'Asset_ProjectManager',
                        },
                        {
                                title => 'project name label',
                                description => 'project name hoverhelp',
                                namespace => 'Asset_ProjectManager',
                        },
                        {
                                title => 'project description label',
                                description => 'project description hoverhelp',
                                namespace => 'Asset_ProjectManager',
                        },
                        {
                                title => 'project manager label',
                                description => 'project manager hoverhelp',
                                namespace => 'Asset_ProjectManager',
                        },
                        {
                                title => 'duration units label',
                                description => 'duration units hoverhelp',
                                namespace => 'Asset_ProjectManager',
                        },
                        {
                                title => 'hours per day label',
                                description => 'hours per day hoverhelp',
                                namespace => 'Asset_ProjectManager',
                        },
                        {
                                title => 'target budget label',
                                description => 'target budget hoverhelp',
                                namespace => 'Asset_ProjectManager',
                        },
		],
		related => [
                        {
                                tag => 'project manager add/edit',
                                namespace => 'Asset_ProjectManager',
                        },
		],
	},

	'task edit template' => {
		title => 'edit task template vars title',
		body => 'edit task template vars body',
		variables => [
		          {
		            'required' => 1,
		            'name' => 'form.header',
		            'description' => 'edit form.header'
		          },
		          {
		            'required' => 1,
		            'name' => 'form.name'
		          },
		          {
		            'required' => 1,
		            'name' => 'form.duration'
		          },
		          {
		            'required' => 1,
		            'name' => 'form.duration.units'
		          },
		          {
		            'required' => 1,
		            'name' => 'form.start'
		          },
		          {
		            'required' => 1,
		            'name' => 'form.end'
		          },
		          {
		            'required' => 1,
		            'name' => 'form.dependants'
		          },
		          {
		            'required' => 1,
		            'name' => 'form.resource'
		          },
		          {
		            'required' => 1,
		            'name' => 'form.milestone'
		          },
		          {
		            'required' => 1,
		            'name' => 'form.percentComplete'
		          },
		          {
		            'required' => 1,
		            'name' => 'form.save'
		          },
		          {
		            'required' => 1,
		            'name' => 'form.footer',
		            'description' => 'edit form.footer'
		          },
		          {
		            'name' => 'extras',
		            'description' => 'extras.base'
		          }
		],
		fields => [ ],
		related => [
                        {
                                tag => 'project manager add/edit',
                                namespace => 'Asset_ProjectManager',
                        },
		],
	},

	'view project template' => {
		title => 'view project template vars title',
		body => 'view project template vars body',
		variables => [
		          {
		            'name' => 'form.header'
		          },
		          {
		            'name' => 'form.footer'
		          },
		          {
		            'name' => 'project.canEdit'
		          },
		          {
		            'name' => 'project.resources.url'
		          },
		          {
		            'name' => 'project.resources.label'
		          },
		          {
		            'name' => 'extras'
		          },
		          {
		            'name' => 'extras.base'
		          },
		          {
		            'name' => 'project.durationUnits'
		          },
		          {
		            'name' => 'project.hoursPerDay'
		          },
		          {
		            'name' => 'task.name.label'
		          },
		          {
		            'name' => 'task.duration.label'
		          },
		          {
		            'name' => 'task.start.label'
		          },
		          {
		            'name' => 'task.end.label'
		          },
		          {
		            'name' => 'task.dependants.label'
		          },
		          {
		            'name' => 'form.name.error'
		          },
		          {
		            'name' => 'form.start.error'
		          },
		          {
		            'name' => 'form.start.error'
		          },
		          {
		            'name' => 'form.greaterThan.error'
		          },
		          {
		            'name' => 'form.previousPredecessor.error'
		          },
		          {
		            'name' => 'form.previousPredecessor.error'
		          },
		          {
		            'name' => 'form.invalidMove.error'
		          },
		          {
		            'name' => 'task.loop',
		            'variables' => [
		                             {
		                               'name' => 'task.number'
		                             },
		                             {
		                               'name' => 'task.row.id'
		                             },
		                             {
		                               'name' => 'task.name'
		                             },
		                             {
		                               'name' => 'task.start'
		                             },
		                             {
		                               'name' => 'task.dependants'
		                             },
		                             {
		                               'name' => 'task.end'
		                             },
		                             {
		                               'name' => 'task.duration'
		                             },
		                             {
		                               'name' => 'task.duration.units'
		                             },
		                             {
		                               'name' => 'task.isMilestone'
		                             },
		                             {
		                               'name' => 'task.edit.url'
		                             },
		                             {
		                               'name' => 'task.edit.url'
		                             }
		                           ]
		          },
		          {
		            'name' => 'project.gantt.rowspan'
		          },
		          {
		            'name' => 'project.ganttChart'
		          },
		          {
		            'name' => 'task.back.url'
		          },
		          {
		            'name' => 'task.back.label'
		          }
		],
		fields => [ ],
		related => [
                        {
                                tag => 'project manager add/edit',
                                namespace => 'Asset_ProjectManager',
                        },
                        {
                                tag => 'gantt chart template',
                                namespace => 'Asset_ProjectManager',
                        },
		],
	},

	'gantt chart template' => {
		title => 'gantt chart template vars title',
		body => 'gantt chart template vars body',
		variables => [
		          {
		            'name' => 'extras',
		          },
		          {
		            'name' => 'sunday.label'
		          },
		          {
		            'name' => 'monday.label'
		          },
		          {
		            'name' => 'tuesday.label'
		          },
		          {
		            'name' => 'wednesday.label'
		          },
		          {
		            'name' => 'thursday.label'
		          },
		          {
		            'name' => 'friday.label'
		          },
		          {
		            'name' => 'saturday.label'
		          },
		          {
		            'name' => 'daysLoop',
		            'variables' => [
		                             {
		                               'name' => 'month.name'
		                             },
		                             {
		                               'name' => 'saturday.label'
		                             },
		                             {
		                               'name' => 'daysLoop',
		                               'variables' => [
		                                                {
		                                                  'name' => 'day.number'
		                                                }
		                                              ]
		                             }
		                           ]
		          }
		],
		fields => [ ],
		related => [
                        {
                                tag => 'project manager add/edit',
                                namespace => 'Asset_ProjectManager',
                        },
		],
	},

};

1;  ##All perl modules must return true
