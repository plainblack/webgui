package WebGUI::Help::Asset_ProjectManager;

##Stub document for creating help documents.

our $HELP = {
	'project manager add/edit' => {
		title => 'pm add/edit title',
		body => 'pm add/edit body',
		isa => [
			{
				namespace => 'Asset_Wobject',
				tag => 'wobject add/edit'
			},
		],
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

	'project dashboard template' => {
		title => 'project dashboard template title',
		body => 'project dashboard template body',
		isa => [
			{
				namespace => 'Asset_ProjectManager',
				tag => 'project manager asset template variables'
			},
			{
				namespace => 'Asset_Template',
				tag => 'template variables'
			},
		],
		variables => [
		          {
		            'name' => 'extras',
		          },
		          {
		            'name' => 'project.create',
		          },
		          {
		            'name' => 'project.create.label',
		          },
		          {
		            'name' => 'project.name.label',
		          },
		          {
		            'name' => 'project.startDate.label',
		          },
		          {
		            'name' => 'project.endDate.label',
		          },
		          {
		            'name' => 'project.cost.label',
		          },
		          {
		            'name' => 'project.complete.label',
		          },
		          {
		            'name' => 'project.actions.label',
		          },
		          {
		            'name' => 'empty.colspan',
		          },
		          {
		            'name' => 'canEditProjects',
		          },
		          {
		            'name' => 'project.delete.warning',
		          },
		          {
		            'name' => 'noProjects',
		          },
		          {
		            'name' => 'project.loop',
			    'variables' => [
				  {
				    'name' => 'project.view.url',
				  },
				  {
				    'name' => 'project.name.data',
				  },
				  {
				    'name' => 'project.description.data',
				  },
				  {
				    'name' => 'project.startDate.data',
				  },
				  {
				    'name' => 'project.cost.data.int',
				  },
				  {
				    'name' => 'project.cost.data.float',
				  },
				  {
				    'name' => 'project.complete.data.int',
				  },
				  {
				    'name' => 'project.complete.data.float',
				  },
				  {
				    'name' => 'project.edit.url',
				  },
				  {
				    'name' => 'project.edit.title',
				  },
				  {
				    'name' => 'project.delete.url',
				  },
				  {
				    'name' => 'project.delete.title',
				  },
			    ],
		          },
		],
		fields => [ ],
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
		isa => [
			{
				namespace => 'Asset_ProjectManager',
				tag => 'project manager asset template variables'
			},
			{
				namespace => 'Asset_Template',
				tag => 'template variables'
			},
		],
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
		isa => [
			{
				namespace => 'Asset_ProjectManager',
				tag => 'project manager asset template variables'
			},
			{
				namespace => 'Asset_Template',
				tag => 'template variables'
			},
		],
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
		isa => [
			{
				namespace => 'Asset_ProjectManager',
				tag => 'project manager asset template variables'
			},
			{
				namespace => 'Asset_Template',
				tag => 'template variables'
			},
		],
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

	'project manager asset template variables' => {
		title => 'project manager asset template variables title',
		body => 'project manager asset template variables body',
		isa => [
			{
				namespace => 'Asset_Wobject',
				tag => 'wobject template variables'
			},
		],
		fields => [
		],
		variables => [
		          {
		            'name' => 'projectDashboardTemplateId'
		          },
		          {
		            'name' => 'projectDisplayTemplateId'
		          },
		          {
		            'name' => 'ganttChartTemplateId'
		          },
		          {
		            'name' => 'editTaskTemplateId'
		          },
		          {
		            'name' => 'resourcePopupTemplateId'
		          },
		          {
		            'name' => 'resourceListTemplateId'
		          },
		          {
		            'name' => 'groupToAdd'
		          },
		        ],
		related => [
		]
	},

	'add resource popup template' => {
		title => 'add resource popup template title',
		body => 'add resource popup template body',
		isa => [
			{
				namespace => 'Asset_ProjectManager',
				tag => 'project manager asset template variables'
			},
			{
				namespace => 'Asset_Template',
				tag => 'template variables'
			},
		],
		variables => [
		          {
		            'name' => 'title',
		          },
		          {
		            'name' => 'searchText',
		          },
		          {
		            'name' => 'foundMessage',
		          },
		          {
		            'name' => 'notFoundMessage',
		          },
		          {
		            'name' => 'assetExtras',
		          },
		          {
		            'required' => 1,
		            'name' => 'func',
		          },
		          {
		            'required' => 1,
		            'name' => 'callback',
		          },
		          {
		            'name' => 'exclude',
		          },
		          {
		            'name' => 'previousSearch',
		          },
		          {
		            'name' => 'selfUrl',
		          },
		          {
		            'name' => 'doingSearch',
		          },
		          {
		            'name' => 'foundResults',
		          },
		          {
		            'required' => 1,
		            'name' => 'resourceDiv',
		          },
		],
		fields => [ ],
		related => [
                        {
                                tag => 'project manager add/edit',
                                namespace => 'Asset_ProjectManager',
                        },
		],
	},

	'list resource popup template' => {
		title => 'list resource popup template title',
		body => 'list resource popup template body',
		isa => [
			{
				namespace => 'Asset_ProjectManager',
				tag => 'project manager asset template variables'
			},
			{
				namespace => 'Asset_Template',
				tag => 'template variables'
			},
		],
		variables => [
		          {
		            'name' => 'assetExtras',
		          },
		          {
		            'name' => 'resourceLoop',
			    'variables' => [
				  {
				    'name' => 'resourceKind',
				  },
				  {
				    'name' => 'resourceId',
				  },
				  {
				    'name' => 'opCallbackJs',
				  },
				  {
				    'name' => 'opIcon',
				  },
				  {
				    'name' => 'opTitle',
				  },
				  {
				    'name' => 'odd',
				  },
				  {
				    'required' => 1,
				    'name' => 'hiddenFields',
				  },
				  {
				    'name' => 'resourceName',
				  },
				  {
				    'name' => 'resourceIcon',
				  },
				  {
				    'name' => 'assetExtras',
				  },
			    ],
		          },
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
