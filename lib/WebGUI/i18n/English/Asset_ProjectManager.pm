package WebGUI::i18n::English::Asset_ProjectManager;

our $I18N = {
	'projectDashboardTemplate hoverhelp' => {
		message => q|Template to use for main view of Project Management Application|,
		lastUpdated => 0
		},

	'projectDashboardTemplate label' => {
		message => q|Default Project Manager View Template|,
		lastUpdated => 0
		},

	'projectDisplayTemplate hoverhelp' => {
		message => q|Template to use for displaying individual projects.  Default template displays Gantt chart representation of projects|,
		lastUpdated => 0
		},

	'projectDisplayTemplate label' => {
		message => q|Default Project Display Template|,
		lastUpdated => 0
		},

	'ganttChartTemplate hoverhelp' => {
		message => q|Template to use for drawing the gantt chart within the table.|,
		lastUpdated => 0
		},

	'ganttChartTemplate label' => {
		message => q|Default Gantt Chart Template|,
		lastUpdated => 0
		},

	'editTaskTemplate hoverhelp' => {
		message => q|Template to use for displaying the edit task dialog.|,
		lastUpdated => 0
		},

	'editTaskTemplate label' => {
		message => q|Default Edit Task Template|,
		lastUpdated => 0
		},

	'resourcePopupTemplate hoverhelp' => {
		message => q|Template to use for task resource selection popups.|,
		lastUpdated => 1157510786
		},

	'resourcePopupTemplate label' => {
		message => q|Default Resource Popup Template|,
		lastUpdated => 1157510786
		},

	'resourceListTemplate hoverhelp' => {
		message => q|Template to use for displaying resource lists.  Used by the resource popup template and the edit task template.|,
		lastUpdated => 1157510786
		},

	'resourceListTemplate label' => {
		message => q|Default Resource List Template|,
		lastUpdated => 1157510786
		},

	'groupToAdd hoverhelp' => {
		message => q|This group will be able to create, delete, and change the permissions on projects.  They will also have implicit managerial privileges to every project in the asset.|,
		lastUpdated => 0
		},

	'groupToAdd label' => {
		message => q|Group to Manage Project List|,
		lastUpdated => 0
		},

	'assetName' => {
		message => q|Project Management System|,
		lastUpdated => 0
		},

     'create project' => {
		message => q|Create New Project|,
		lastUpdated => 0
		},

	 'edit project' => {
		message => q|Edit Project|,
		lastUpdated => 0
		},

	 'project id' => {
		message => q|Project Id|,
		lastUpdated => 0
		},

	 'project id hoverhelp' => {
		message => q|A unique identifier used internally by WebGUI to reference this project.|,
		lastUpdated => 0
		},

	 'project name hoverhelp' => {
		message => q|Enter the name of the project|,
		lastUpdated => 0
		},

	 'project name label' => {
		message => q|Project Name|,
		lastUpdated => 0
		},

	 'project description hoverhelp' => {
		message => q|Enter a description for the project.|,
		lastUpdated => 0
		},

	 'project description label' => {
		message => q|Project Description|,
		lastUpdated => 0
		},

	 'project manager hoverhelp' => {
		message => q|Choose a group of users that are able to manage this project.  Project Managers will be able to edit project tasks.|,
		lastUpdated => 0
		},

	 'project manager label' => {
		message => q|Project Managers Group|,
		lastUpdated => 0
		},

	 'project observer hoverhelp' => {
		message => q|Choose a group of users that are able to observe this project.  Project Observers will be able to see the project in the project management asset's list, and will be able to see the task overview.|,
		lastUpdated => 1157675812
		},

	 'project observer label' => {
		message => q|Project Observers Group|,
		lastUpdated => 1157675812
		},

	 'hours per day hoverhelp' => {
		message => q|Choose number of hours which generally represents a full day of work.  This will serve as a basis for estimating how many days a task takes.  This will be overridden if a resource is set to work more or less hours in a day, and that resource is attached to the task.|,
		lastUpdated => 0
		},

	 'hours per day label' => {
		message => q|Working Hours Per Day|,
		lastUpdated => 0
		},

	 'duration units hoverhelp' => {
		message => q|Choose the unit of time by which you wish to track a project.  This will determine how you will enter the time each task takes.|,
		lastUpdated => 0
		},

	 'duration units label' => {
		message => q|Track Project In|,
		lastUpdated => 0
		},

	 'target budget hoverhelp' => {
		message => q|Enter the estimated cost amount the project should track to.  If your resources are properly configured, the system will track this target against actual costs.  Leave this value zero if you do not wish to track project costs|,
		lastUpdated => 0
		},

	 'target budget label' => {
		message => q|Project Cost Estimate|,
		lastUpdated => 0
		},

	 'project new label' => {
		message => q|New Project|,
		lastUpdated => 0
		},

	 'project name label' => {
		message => q|Project Name|,
		lastUpdated => 0
		},

	 'project start date label' => {
		message => q|Start|,
		lastUpdated => 0
		},

	 'project end date label' => {
		message => q|End|,
		lastUpdated => 0
		},

	 'project cost label' => {
		message => q|Estimated Cost|,
		lastUpdated => 0
		},

	 'project complete label' => {
		message => q|% Complete|,
		lastUpdated => 0
		},

	 'project action label' => {
		message => q|Actions|,
		lastUpdated => 0
		},

	 'no projects' => {
		message => q|Project List is Empty|,
		lastUpdated => 0
		},

	 'project edit title' => {
		message => q|Edit Project|,
		lastUpdated => 0
		},

	 'project delete title' => {
		message => q|Delete Project|,
		lastUpdated => 0
		},

	 'project delete warning' => {
		message => q|Are you sure you wish to delete this project and all of it's associated tasks?|,
		lastUpdated => 0
		},

	 'project start task label' => {
		message => q|Project Start|,
		lastUpdated => 0
		},

	  'hours label' => {
		message => q|Hours|,
		lastUpdated => 0
		},

	 'days label' => {
		message => q|Days|,
		lastUpdated => 0
		},

	  'hours label abbrev' => {
		message => q|hrs|,
		lastUpdated => 0,
		context => q|Abbreviation for hours|,
		},

	 'days label abbrev' => {
		message => q|days|,
		lastUpdated => 0
		},

	 'task name label' => {
		message => q|Task|,
		lastUpdated => 0
		},

	 'task duration label' => {
		message => q|Duration|,
		lastUpdated => 0
		},

	 'task start label' => {
		message => q|Start|,
		lastUpdated => 0
		},

	 'task end label' => {
		message => q|Finish|,
		lastUpdated => 0
		},

	 'task dependant label' => {
		message => q|Pred|,
		lastUpdated => 0,
		context => q|Abbreviation for predecessor|,
		},

	 'add task label' => {
		message => q|Add Task|,
		lastUpdated => 0
		},

	 'edit task label' => {
		message => q|Edit Task|,
		lastUpdated => 0
		},

	 'task name error' => {
		message => q|Task Name must be entered in order to save|,
		lastUpdated => 0
		},

	 'task start error' => {
		message => q|Start Date must be entered in order to save|,
		lastUpdated => 0
		},

	 'task end error' => {
		message => q|End Date must be entered in order to save|,
		lastUpdated => 0
		},

	 'task back label' => {
		message => q|Back To Dashboard|,
		lastUpdated => 0
		},

	 'task resources label' => {
		message => q|Manage Resources|,
		lastUpdated => 0
		},

	 'task greaterthan error' => {
		message => q|Start Date cannot be later than End Date|,
		lastUpdated => 1157680415
		},

	 'monday label' => {
		message => q|M|,
		lastUpdated => 0,
		context => q|Abbreviation for Monday|,
		},

	 'tuesday label' => {
		message => q|T|,
		lastUpdated => 0,
		context => q|Abbreviation for Tuesday|,
		},

	 'wednesday label' => {
		message => q|W|,
		lastUpdated => 0,
		context => q|Abbreviation for Wednesday|,
		},

	 'thursday label' => {
		message => q|T|,
		lastUpdated => 0,
		context => q|Abbreviation for Thursday|,
		},

	 'friday label' => {
		message => q|F|,
		lastUpdated => 0,
		context => q|Abbreviation for Friday|,
		},

	 'saturday label' => {
		message => q|S|,
		lastUpdated => 0,
		context => q|Abbreviation for Saturday|,
		},

	 'sunday label' => {
		message => q|S|,
		lastUpdated => 0,
		context => q|Abbreviation for Sunday|,
		},

	 'task previousPredecessor error' => {
		message => q|Predecessor must be a previous task.|,
		lastUpdated => 0
		},

	 'task samePredecessor error' => {
		message => q|Task cannot be it's own predecessor|,
		lastUpdated => 0
		},

	 'task noPredecessor error' => {
		message => q|Predecessor entered does not exist|,
		lastUpdated => 0
		},

	 'task untimedPredecessor error' => {
                message => q|Tasks are not permitted to have predecessors that are not timed tasks.|,
		lastUpdated => 1159825527,
         },

	 'task invalidMove error' => {
		message => q|The start date that you have selected for this task is invalid as its predecessor's end date will not be met.  Either remove the predecessor restriction from this task or change the end date of its predecessor to make this date valid.|,
		lastUpdated => 0
         },

	 'resource none' => {
		message => q|No Resource|,
		lastUpdated => 0
		},

	 'pm add/edit title' => {
		message => q|Add/Edit Project Manager|,
		lastUpdated => 0
		},

	 'pm add/edit body' => {
		message => q|<p>The Project Manager provides an interface for you to create a project, add tasks to it and monitor its status as it progresses.</p>|,
		lastUpdated => 0
		},

	 'project edit body' => {
		message => q|<p>In the Edit Project screen, you will define a new project or edit an existing project by giving general information about the project, including a name, a description, the group of users who are allowed to manage the project and the target budget.</p>|,
		lastUpdated => 0
		},

	'edit task template vars title' => {
		message => q|Edit Task Template Variables|,
		lastUpdated => 0
	},

	'edit form.header' => {
		message => q|Code to setup the Edit Task form.  Leaving out this variable will prevent the form
from working.|,
		lastUpdated => 1149825164,
	},

	'form.name' => {
		message => q|Form element for the user to enter/edit the name of the task.|,
		lastUpdated => 1149825164,
	},

	'form.duration' => {
		message => q|Form element for the duration of the task.|,
		lastUpdated => 1149825164,
	},

	'form.duration.units' => {
		message => q|Form element for the units of duration for the task.|,
		lastUpdated => 1149825164,
	},

	'form.start' => {
		message => q|Form element for the starting date for the task.|,
		lastUpdated => 1149825164,
	},

	'form.end' => {
		message => q|Form element for the ending date for the task.|,
		lastUpdated => 1149825164,
	},

	'form.dependants' => {
		message => q|Form element for entering in which task this task depends on, by number.|,
		lastUpdated => 1165512623,
	},

	'form.resource' => {
		message => q|Form element for selecting a user to accomplish this task.|,
		lastUpdated => 1149825164,
	},

	'form.milestone' => {
		message => q|Form element for setting this task to be a milestone in the project.|,
		lastUpdated => 1149825164,
	},

	'form.percentComplete' => {
		message => q|Form element for entering in how much of the project has been completed, as a percentage.|,
		lastUpdated => 1149825164,
	},

	'form.save' => {
		message => q|A button to save data entered into the form.|,
		lastUpdated => 1149825164,
	},

	'edit form.footer' => {
		message => q|Code to end the form.|,
		lastUpdated => 1149825164,
	},

	'edit task template vars body' => {
		message => q|<p>The Edit Task template has these template variables</p>
|,
		lastUpdated => 1149825739
	},

	'view project template vars title' => {
		message => q|View Project Template Variables|,
		lastUpdated => 0
	},

	'form.header' => {
		message => q|If the user is in the group to add projects, then this variable will contain HTML form code
to make on the fly editing of tasks work.|,
		lastUpdated => 1149824991,
	},

	'form.footer' => {
		message => q|If the user is in the group to add projects, then this variable will contain HTML form code
to make on the fly editing of tasks work.|,
		lastUpdated => 1149824991,
	},

	'project.canEdit' => {
		message => q|A conditional indicating whether or not this user is a member of the group to add projects.|,
		lastUpdated => 1149824991,
	},

	'project.resources.url' => {
		message => q|If the user is in the group to add projects, this will be the URL to the Manage Resources screen.|,
		lastUpdated => 1149824991,
	},

	'project.resources.label' => {
		message => q|If the user is in the group to add projects, this will be internationalized label to be used with <b>project.resources.label</b>.|,
		lastUpdated => 1149824991,
	},

	'extras' => {
		message => q|The URL to the Extras directory for the Project Manager.|,
		lastUpdated => 1149824991,
	},

	'extras.base' => {
		message => q|The URL to the top of the Extras directory.|,
		lastUpdated => 1149824991,
	},

	'project.durationUnits' => {
		message => q|An abbreviated version of the units of time that duration are measured.|,
		lastUpdated => 1149824991,
	},

	'project.hoursPerDay' => {
		message => q|The number of hours that represents a full day of work for this project.|,
		lastUpdated => 1149824991,
	},

	'task.name.label' => {
		message => q|The internationalized word "Task".|,
		lastUpdated => 1149824991,
	},

	'task.duration.label' => {
		message => q|The internationalized word "Duration".|,
		lastUpdated => 1149824991,
	},

	'task.start.label' => {
		message => q|The internationalized word "Start".|,
		lastUpdated => 1149824991,
	},

	'task.end.label' => {
		message => q|The internationalized word "End".|,
		lastUpdated => 1149824991,
	},

	'task.dependants.label' => {
		message => q|The internationalized word "Pred", short for Predecessor.|,
		lastUpdated => 1149824991,
	},

	'form.name.error' => {
		message => q|An internationalized error message for a missing task name.|,
		lastUpdated => 1149824991,
	},

	'form.start.error' => {
		message => q|An internationalized error message for not entering an start date.|,
		lastUpdated => 1149824991,
	},

	'form.start.error' => {
		message => q|An internationalized error message for not entering an end date.|,
		lastUpdated => 1149824991,
	},

	'form.greaterThan.error' => {
		message => q|An internationalized error message for entering a start date after the end date.|,
		lastUpdated => 1149824991,
	},

	'form.previousPredecessor.error' => {
		message => q|An internationalized error message for choosing a predecessor that is not a previous task.|,
		lastUpdated => 1149824991,
	},

	'form.previousPredecessor.error' => {
		message => q|An internationalized error message for choosing a predecessor task that does not exist.|,
		lastUpdated => 1149824991,
	},

	'form.invalidMove.error' => {
		message => q|An internationalized error message for choosing a task that is invalid as a predecessor because the end date is after the start date of this task.|,
		lastUpdated => 1149824991,
	},

	'task.loop' => {
		message => q|A loop containing all tasks for this project, in sequence order.|,
		lastUpdated => 1149824991,
	},

	'task.number' => {
		message => q|The sequence number for this task.|,
		lastUpdated => 1149824991,
	},

	'task.row.id' => {
		message => q|A unique identifier used internally by WebGUI for this task.|,
		lastUpdated => 1159980663,
	},

	'task.name' => {
		message => q|The name of this task.|,
		lastUpdated => 1149824991,
	},

	'task.start' => {
		message => q|If the user is in the group to add projects, then this will be a form field to edit the start date
for this task.  Otherwise, just the start date will be displayed as text.|,
		lastUpdated => 1149824991,
	},

	'task.dependants' => {
		message => q|If the user is in the group to add projects, then this will be a form field to edit the dependants
for this task.  Otherwise, just the list of dependants will be displayed as text.|,
		lastUpdated => 1149824991,
	},

	'task.end' => {
		message => q|If the user is in the group to add projects, then this will be a form field to edit the end date
for this task.  Otherwise, just the end date will be displayed as text.|,
		lastUpdated => 1149824991,
	},

	'task.duration' => {
		message => q|If the user is in the group to add projects, and this task is not a milestone, then a this variable
will be a form field to edit the duration.  
Otherwise, just the duration will be displayed as text.|,
		lastUpdated => 1149824991,
	},

	'task.duration.units' => {
		message => q|The units for the duration, typically hours or days.|,
		lastUpdated => 1149824991,
	},

	'task.isMilestone' => {
		message => q|A conditiional indicating whether or not this task is a milestone.|,
		lastUpdated => 1149824991,
	},

	'task.edit.url' => {
		message => q|If the user can add tasks to this project, then this will be a URL to take them to the Add Task screen.|,
		lastUpdated => 1149824991,
	},

	'task.edit.url' => {
		message => q|If the user can add tasks to this project, then this will contain an internationalized label to go with <b>task.edit.url</b>.|,
		lastUpdated => 1149824991,
	},

	'project.gantt.rowspan' => {
		message => q|The number of rows for the Gantt chart, 4 + the number of tasks.|,
		lastUpdated => 1153478000,
	},

	'project.ganttChart' => {
		message => q|The Gantt chart for this project and its tasks.|,
		lastUpdated => 1153478000,
	},

	'task.back.url' => {
		message => q|A link back to this screen.|,
		lastUpdated => 1149824991,
	},

	'task.back.label' => {
		message => q|A label to go with the link back to this screen.|,
		lastUpdated => 1149824991,
	},

	 'view project template vars body' => {
		message => q|<p>The View Project template has these template variables</p>
|,
		lastUpdated => 1149825022
	},

	'gantt chart template vars title' => {
		message => q|Gantt Chart Template Variables|,
		lastUpdated => 0
	},

	'sunday.label' => {
		message => q|The initial of the day for Sunday, internationalized.|,
		lastUpdated => 1149825039,
	},

	'monday.label' => {
		message => q|The initial of the day for Monday, internationalized.|,
		lastUpdated => 1149825039,
	},

	'tuesday.label' => {
		message => q|The initial of the day for Tuesday, internationalized.|,
		lastUpdated => 1149825039,
	},

	'wednesday.label' => {
		message => q|The initial of the day for Wednesday, internationalized.|,
		lastUpdated => 1149825039,
	},

	'thursday.label' => {
		message => q|The initial of the day for Thursday, internationalized.|,
		lastUpdated => 1149825039,
	},

	'friday.label' => {
		message => q|The initial of the day for Friday, internationalized.|,
		lastUpdated => 1149825039,
	},

	'saturday.label' => {
		message => q|The initial of the day for Saturday, internationalized.|,
		lastUpdated => 1149825039,
	},

	'daysLoop' => {
		message => q|The initial of the day for Saturday, internationalized.|,
		lastUpdated => 1149825039,
	},

	'month.name' => {
		message => q|The name of the current month|,
		lastUpdated => 1149825039,
	},

	'saturday.label' => {
		message => q|The initial of the day for Saturday, internationalized.|,
		lastUpdated => 1149825039,
	},

	'daysLoop' => {
		message => q|The initial of the day for Saturday, internationalized.|,
		lastUpdated => 1149825039,
	},

	'day.number' => {
		message => q|The ordinal number for this day of the week, an integer between 1 and 7|,
		lastUpdated => 1149825039,
	},

	'gantt chart template vars body' => {
		message => q|<p>These variables are available in the Gantt Chart Template:</p>|,
		lastUpdated => 1149825108
	},

	'resource add opTitle' => {
		message => q|Add to Task|,
		lastUpdated => 1157510786
	},

	'resource remove opTitle' => {
		message => q|Remove from Task|,
		lastUpdated => 1157510786
	},

	'user add popup hover' => {
		message => q|Add User to Task|,
		lastUpdated => 1157510786
	},

	'group add popup hover' => {
		message => q|Add Group to Task|,
		lastUpdated => 1157510786
	},

	'user add popup title' => {
		message => q|Search for User|,
		lastUpdated => 1157510786
	},

	'user add popup searchText' => {
		message => q|Search for user: |,
		lastUpdated => 1157510786
	},

	'user add popup foundMessage' => {
		message => q|Matching users: |,
		lastUpdated => 1157510786
	},

	'user add popup notFoundMessage' => {
		message => q|No matching users found.|,
		lastUpdated => 1157510786
	},

	'group add popup title' => {
		message => q|Search for Group|,
		lastUpdated => 1157510786
	},

	'group add popup searchText' => {
		message => q|Search for group: |,
		lastUpdated => 1157510786
	},

	'group add popup foundMessage' => {
		message => q|Matching groups: |,
		lastUpdated => 1157510786
	},

	'group add popup notFoundMessage' => {
		message => q|No matching groups found.|,
		lastUpdated => 1157510786
	},

	'taskType timed label' => {
		message => q|Timed|,
                lastUpdated => 1159557353
        },

	'taskType progressive label' => {
		message => q|Progressive|,
                lastUpdated => 1159557353
        },

	'taskType milestone label' => {
		message => q|Milestone|,
                lastUpdated => 1159557353
        },
};

1;
