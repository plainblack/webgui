package WebGUI::i18n::English::Asset_EventManagementSystem;

our $I18N = { ##hashref of hashes
	'display template' => { 
		message => q|Display Template|,
		lastUpdated => 1131394070, #seconds from the epoch
		context => q|Field label for template selector|
	},

	'display template description' => {
		message => q|Controls the layout, look, and appearence of an Event Management System.|,
		lastUpdated => 1131394072,
		context => q|Describes this template field selector|
	},

	'paginate after' => {
		message => q|Paginate After|,
		lastUpdated => 1131394072,
		context => q|Field label for Paginate After|
	},
	
	'paginate after description' => {
		message => q|Number of events to display on one page.|,
		lastUpdated => 1131394072,
		context => q|Describes the Paginate After field|
	},
	
	'group to add events' => {
		message => q|Group to Add Events|,
		lastUpdated => 1131394072,
		context => q|Field label|
	},
	
	'group to add events description' => {
		message => q|Members of the selected group will have the ability to add events to an Event Management System.
		Events added will not be available for purchase until the event is approved by a member of the Group to Approve Events.|,
		lastUpdated => 1131394072,
		context => q|Describes the Group To Add Events field|
	},
	
	'group to approve events' => {
		message => q|Group to Approve Events|,
		lastUpdated => 1131394072,
		context => q|Field Label|
	},
	
	'group to approve events description' => {
		message => q|Members of the selected group will have the ability to approve a pending event so that it is available for purchase.|,
		lastUpdated => 1131394072,
		context => q|Describes the Group To Approve Events field|
	},
	
	
	#If the help file documents an Asset, it must include an assetName key
	#If the help file documents an Macro, it must include an macroName key
	#For all other types, use topicName
	'assetName' => {
		message => q|Event Management System|,
		lastUpdated => 1131394072,
	},

};

1;
