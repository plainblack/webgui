package WebGUI::i18n::English::Asset_Calendar;

our $I18N = { 
	#'key1' => {
	#	message 	=> q{},
	#	lastUpdated 	=> 0,
	#	context 	=> q{},
	#},


#################### DATETIME LOCALE ####################
	'locale'	=> {
		message		=> q{en_US},
		lastUpdated	=> 0,
		context		=> q{The ISO locale name for month and day labels.},
	},
	
	
#################### CALENDAR PROPERTIES FIELDS ####################
	
	##### Subscriber Notify Offset #####
	'subscriberNotifyOffset label' => {
		message 	=> q{Subscriber Notify Offset},
		lastUpdated 	=> 0,
		context 	=> q{The label for the Subscriber Notify Offset field},
	},
	'subscriberNotifyOffset description' => {
		message 	=> q{Number of days before a subscriber is notified that an event is about to happen.},
		lastUpdated 	=> 0,
		context 	=> q{The Hover Help for the Subscriber Notify Offset field},
	},
	
	
	
#################### CALENDAR DISPLAY FIELDS ####################
	
	##### Default View #####
	'defaultView label' => {
		message 	=> q{Default View},
		lastUpdated 	=> 0,
		context 	=> q{The label for the Default View field},
	},
	'defaultView description' => {
		message 	=> q{The default view to show the user.},
		lastUpdated 	=> 0,
		context 	=> q{Hover Help for the Default View field},
	},
	'defaultView value month' => {
		message 	=> q{Month},
		lastUpdated 	=> 0,
		context 	=> q{A value for the Default View field.},
	},
	'defaultView value week' => {
		message 	=> q{Week},
		lastUpdated 	=> 0,
		context 	=> q{A value for the Default View field.},
	},
	'defaultView value day' => {
		message 	=> q{Day},
		lastUpdated 	=> 0,
		context 	=> q{A value for the Default View field.},
	},
	
	
	##### Default Date #####
	'defaultDate label' => {
		message 	=> q{Default Date},
		lastUpdated 	=> 0,
		context 	=> q{The label for the default date field.},
	},
	'defaultDate description' => {
		message 	=> q{The default date to show the user.},
		lastUpdated 	=> 0,
		context 	=> q{Hover Help for the default date field.},
	},
	'defaultDate value current' => {
		message		=> q{The current date},
		lastUpdated	=> 0,
		context		=> q{A value for the Default Date display field.},
	},
	'defaultDate value first' => {
		message		=> q{The first event in the calendar},
		lastUpdated	=> 0,
		context		=> q{A value for the Default Date display field.},
	},
	'defaultDate value last' => {
		message		=> q{The last event in the calendar},
		lastUpdated	=> 0,
		context		=> q{A value for the Default Date display field.},
	},
	
	
	##### Visitor Cache Timeout #####
	'visitorCacheTimeout label' => {
		message		=> q{Visitor Cache Timeout},
		lastUpdated	=> 0,
		context		=> q{The label for the Visitor Cache Timeout field.},
	},
	'visitorCacheTimeout description' => {
		message		=> q{The number of minutes before the visitor cache will be refreshed.},
		lastUpdated	=> 0,
		context		=> q{Hover Help for the Visitor Cache Timeout field.},
	},
	
	
	
	
	
	
#################### CALENDAR SECURITY FIELDS ####################
	
	##### Group to add/edit events #####
	'groupIdEventEdit label' => {
		message		=> q{Who can add/edit Events?},
		lastUpdated	=> 0,
		context		=> q{The label for the Group to Edit Events field.},
	},
	'groupIdEventEdit description' => {
		message		=> q{Members of this group can add and edit Events in this calendar.},
		lastUpdated	=> 0,
		context		=> q{Hover Help for the Group to Edit Events field.},
	},
	
	
	
	
#################### CALENDAR FEEDS FIELDS ####################
	
	##### Feeds tab #####
	'feeds' => {
		message		=> q{Feeds},
		lastUpdated	=> 0,
		context		=> q{The label for the Feeds tab.},
	},
	
	
	
#################### TEMPLATES ####################
	
	
	
	##### Template - Month #####
	'templateIdMonth label' => {
		message 	=> q{Month View Template},
		lastUpdated 	=> 0,
		context 	=> q{The label for the default month template.},
	},
	'templateIdMonth description' => {
		message 	=> q{This template shows the calendar in month form.},
		lastUpdated 	=> 0,
		context 	=> q{Hover Help for the default month template.},
	},
	
	##### Template - Week #####
	'templateIdWeek label' => {
		message 	=> q{Week View Template},
		lastUpdated 	=> 0,
		context 	=> q{The label for the default Week template.},
	},
	'templateIdWeek description' => {
		message 	=> q{This template shows the calendar in Week form.},
		lastUpdated 	=> 0,
		context 	=> q{Hover Help for the default Week template.},
	},
	
	##### Template - Day #####
	'templateIdDay label' => {
		message 	=> q{Day View Template},
		lastUpdated 	=> 0,
		context 	=> q{The label for the default Day template.},
	},
	'templateIdDay description' => {
		message 	=> q{This template shows the calendar in Day form.},
		lastUpdated 	=> 0,
		context 	=> q{Hover Help for the default Day template.},
	},
	
	##### Template - Event #####
	'templateIdEvent label' => {
		message 	=> q{Event Details Template},
		lastUpdated 	=> 0,
		context 	=> q{The label for the default Event template.},
	},
	'templateIdEvent description' => {
		message 	=> q{The template to show the details for an event.},
		lastUpdated 	=> 0,
		context 	=> q{Hover Help for the default Event template.},
	},
	
	##### Template - EventEdit #####
	'templateIdEventEdit label' => {
		message 	=> q{Event Edit Template},
		lastUpdated 	=> 0,
		context 	=> q{The label for the default Event Edit template.},
	},
	'templateIdEventEdit description' => {
		message 	=> q{The template to Edit Events.},
		lastUpdated 	=> 0,
		context 	=> q{Hover Help for the default Event Edit template.},
	},
	
	##### Template - Search #####
	'templateIdSearch label' => {
		message 	=> q{Search View Template},
		lastUpdated 	=> 0,
		context 	=> q{The label for the default Search template.},
	},
	'templateIdSearch description' => {
		message 	=> q{This template shows the calendar in Search form.},
		lastUpdated 	=> 0,
		context 	=> q{Hover Help for the default Search template.},
	},
	
	
	
	##### Template - Print Month #####
	'templateIdPrintMonth label' => {
		message 	=> q{Print Month Template},
		lastUpdated 	=> 0,
		context 	=> q{The label for the default month template.},
	},
	'templateIdPrintMonth description' => {
		message 	=> q{This template to print the calendar in month form.},
		lastUpdated 	=> 0,
		context 	=> q{Hover Help for the default month template.},
	},
	
	##### Template - Print Week #####
	'templateIdPrintWeek label' => {
		message 	=> q{Print Week Template},
		lastUpdated 	=> 0,
		context 	=> q{The label for the default Week template.},
	},
	'templateIdPrintWeek description' => {
		message 	=> q{This template to print the calendar in Week form.},
		lastUpdated 	=> 0,
		context 	=> q{Hover Help for the default Week template.},
	},
	
	##### Template - Print Day #####
	'templateIdPrintDay label' => {
		message 	=> q{Print Day Template},
		lastUpdated 	=> 0,
		context 	=> q{The label for the default Day template.},
	},
	'templateIdPrintDay description' => {
		message 	=> q{This template to print the calendar in Day form.},
		lastUpdated 	=> 0,
		context 	=> q{Hover Help for the default Day template.},
	},
	
	##### Template - Print Event #####
	'templateIdPrintEvent label' => {
		message 	=> q{Print Event Details Template},
		lastUpdated 	=> 0,
		context 	=> q{The label for the default Event template.},
	},
	'templateIdPrintEvent description' => {
		message 	=> q{The template to print the details for an event.},
		lastUpdated 	=> 0,
		context 	=> q{Hover Help for the default Event template.},
	},
	
	
	
#################### WORKFLOW ACTIVITIES ####################
	'workflow updateFeeds' => {
			message		=> q{Update Calendar Feeds},
			lastUpdated	=> 0,
			context		=> q{The name of the CalendarUpdateFeeds workflow activity},
		},
	
	
#################### ASSET NAME ####################
	'assetName' => {
		message 	=> q{Calendar},
		lastUpdated 	=> 1131394072,
	},

};

1;
