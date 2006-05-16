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
