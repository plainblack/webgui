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
		message		=> q{Who can add Events?},
		lastUpdated	=> 0,
		context		=> q{The label for the Group to Edit Events field.},
	},
	'groupIdEventEdit description' => {
		message		=> q{Members of this group can add Events to this calendar.},
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

	'workflow updateFeeds description' => {
			message 	=> q{This activity imports calendar events from calendar feeds},
			lastUpdated	=> 0,
			context		=> q{Description of what the Calendar Update Feeds workflow activity does},
	},	
	
	'workflow generateRecurringEvents' => {
			message		=> q{Generate Recurring Events},
			lastUpdated	=> 0,
			context		=> q{The name of the CalendarGenerateRecurringEvents workflow activity},
	},

	'workflow generateRecurringEvents description' => {
			message 	=> q{This activity generates recurring events for calendars. }
                        . q{This activity also maintains recurring events in the future.},
			lastUpdated	=> 0,
			context		=> q{Description of what the CalendarGenerateRecurringEvents workflow activity does},
	},	

#################### HELP PAGES ####################
    
    'help add/edit title' => {
		message 	=> q|Calendar, Add/Edit|,
		lastUpdated 	=> 1165878391,
	},

	'help add/edit body' => {
		message 	=> q|This Asset has no documentation.|,
		lastUpdated 	=> 1165878391,
	},


#################### HELP PAGES ####################
	'searchButtonLabel' => {
		message 	=> q|Search|,
		lastUpdated 	=> 1170803504,
	},

#################### HELP PAGES View Calendar ####################

	'view calendar title' => {
		message 	=> q|View Calendar Template Variables|,
		lastUpdated 	=> 1171043337,
	},

	'view calendar body' => {
		message 	=> q|<p>The Calendar can be viewed as an entire month, a week, or just a day.  Each view has its own individual template variables, but they also share several common variables.  These are listed below:</p>|,
		lastUpdated 	=> 1171043883,
	},

	'admin' => {
		message 	=> q|A conditional that will be true if the user has Admin mode turned on.|,
		lastUpdated 	=> 1171043883,
	},

	'adminControls' => {
		message 	=> q|These are the icons and URLs that allow editing, cutting, copying, deleting and reordering the Asset.|,
		lastUpdated 	=> 1171043883,
	},

	'editor' => {
		message 	=> q|A conditional that will be true if the user is in the group allowed to edit events in the calendar.|,
		lastUpdated 	=> 1171043883,
	},

	'urlAdd' => {
		message 	=> q|A URL to add an event to the calendar.|,
		lastUpdated 	=> 1171043883,
	},

	'urlDay' => {
		message 	=> q|A URL to the 1 day view of the calendar.|,
		lastUpdated 	=> 1171043883,
	},

	'urlWeek' => {
		message 	=> q|A URL to the week view of the calendar.|,
		lastUpdated 	=> 1171043883,
	},

	'urlMonth' => {
		message 	=> q|A URL to the month view of the calendar.|,
		lastUpdated 	=> 1171043883,
	},

	'urlSearch' => {
		message 	=> q|A URL to the search form for the calendar.|,
		lastUpdated 	=> 1171043883,
	},

	'urlPrint' => {
		message 	=> q|A URL to the printable view of the calendar.|,
		lastUpdated 	=> 1171043883,
	},

	'urlIcal' => {
		message 	=> q|A URL to the iCal feed for the calendar, starting at this month.|,
		lastUpdated 	=> 1175028512,
	},

	'paramStart' => {
		message 	=> q|The starting date of the calendar.|,
		lastUpdated 	=> 1171043883,
	},

	'paramType' => {
		message 	=> q|The current view of the calendar, one of the strings "day", "week", "month".|,
		context 	=> q|Translator's note: Do not translate the strings in double quotes, they are literals.|,
		lastUpdated 	=> 1171062302,
	},

	'extrasUrl' => {
		message 	=> q|A URL to the WebGUI extras directory.|,
		lastUpdated 	=> 1171062302,
	},

	'view calendar day title' => {
		message 	=> q|View Calendar Day Template Variables|,
		lastUpdated 	=> 1171043337,
	},

	'view calendar day body' => {
		message 	=> q|<p>This template shows all events in a single day in the calendar, sorted by hour.</p>|,
		lastUpdated 	=> 1171043883,
	},

	'hours' => {
		message 	=> q|This loop contains all the events and labels for the hours that they occur in.  Hours with no events will not be placed into the loop.|,
		lastUpdated 	=> 1171043883,
	},

	'hour12' => {
		message 	=> q|The hour in 12 hour format.  2:00 in the afternoon will be 2:00.|,
		lastUpdated 	=> 1171043883,
	},

	'hour24' => {
		message 	=> q|The hour in 24 hour format.  2:00 in the afternoon will be 14:00.|,
		lastUpdated 	=> 1171043883,
	},

	'hourM' => {
		message 	=> q|Depending on whether the hour occurs in the morning or afternoon, either the strings "am" or "pm"|,
		context 	=> q|Translator's note: Do not translate the strings in double quotes, they are literals.|,
		lastUpdated 	=> 1171043883,
	},

	'events dayVar' => {
		message 	=> q|This loop contains all the events for this hour.|,
		lastUpdated 	=> 1171169586,
	},

	'pageNextStart' => {
		message 	=> q|The date of the next day in the calendar in YYYY-MM-DD (Year, Month, Day) format.|,
		lastUpdated 	=> 1171043883,
	},

	'pageNextUrl dayVar' => {
		message 	=> q|A URL to the next day in the calendar.|,
		lastUpdated 	=> 1171043883,
	},

	'pagePrevStart' => {
		message 	=> q|The date of the previous day in the calendar in YYYY-MM-DD (Year, Month, Day) format.|,
		lastUpdated 	=> 1171043883,
	},

	'pagePrevUrl dayVar' => {
		message 	=> q|A URL to the previous day in the calendar.|,
		lastUpdated 	=> 1171043883,
	},

	'dayName' => {
		message 	=> q|The name of the current day.|,
		lastUpdated 	=> 1171043883,
	},

	'dayAbbr' => {
		message 	=> q|The abbreviation for the name of the current day.|,
		lastUpdated 	=> 1171043883,
	},

	'dayOfMonth' => {
		message 	=> q|Which day of the month this day is, an integer from 1..31.|,
		lastUpdated 	=> 1171043883,
	},

	'dayOfWeek' => {
		message 	=> q|Which day of the week this day is, an integer from 1..7.|,
		lastUpdated 	=> 1171043883,
	},

	'monthName' => {
		message 	=> q|The name of this month.|,
		lastUpdated 	=> 1171043883,
	},

	'monthAbbr' => {
		message 	=> q|The abbreviation of the name for this month.|,
		lastUpdated 	=> 1171043883,
	},

	'year' => {
		message 	=> q|The 4 digit year.|,
		lastUpdated 	=> 1171043883,
	},

	'ymd' => {
		message 	=> q|This day's date in yyyy-mm-dd format, where yyyy is the year, mm is the month and dd is the day.|,
		lastUpdated 	=> 1171043883,
	},

	'mdy' => {
		message 	=> q|This day's date in mm-dd-yyyy format, where yyyy is the year, mm is the month and dd is the day.|,
		lastUpdated 	=> 1171043883,
	},

	'dmy' => {
		message 	=> q|This day's date in dd-mm-yyyy format, where yyyy is the year, mm is the month and dd is the day.|,
		lastUpdated 	=> 1171043883,
	},

	'epoch' => {
		message 	=> q|This day's date in epoch format.|,
		lastUpdated 	=> 1171043883,
	},

	'view calendar week title' => {
		message 	=> q|View Calendar Week Template Variables|,
		lastUpdated 	=> 1171172007,
	},

	'view calendar week body' => {
		message 	=> q|<p>This template shows all events in a week in the calendar, sorted by day.</p>|,
		lastUpdated 	=> 1171172004,
	},

	'days' => {
		message 	=> q|This loop contains all the events and labels for the days that they occur in.  All days in a week are included in the loop, whether they contain events or not.|,
		lastUpdated 	=> 1171172001,
	},

	'events weekVar' => {
		message 	=> q|This loop contains all the events for this day.|,
		lastUpdated 	=> 1171169586,
	},

	'pageNextUrl weekVar' => {
		message 	=> q|A URL to the next week in the calendar.|,
		lastUpdated 	=> 1171172001,
	},

	'pagePrevUrl weekVar' => {
		message 	=> q|A URL to the previous week in the calendar.|,
		lastUpdated 	=> 1171171998,
	},

    'startMonth'    => {
        message     => q{The number (1-12) of the month this week starts.},
        lastUpdated => 1171043883,
    },

	'startMonthName' => {
		message 	=> q|The name of the month this week starts.|,
		lastUpdated 	=> 1171043883,
	},

	'startMonthAbbr' => {
		message 	=> q|The abbreviation of the name of the month this week starts.|,
		lastUpdated 	=> 1171043883,
	},

	'startDayOfMonth' => {
		message 	=> q|The day of the month this week starts, a number from 1 to 31.|,
		lastUpdated 	=> 1171043883,
	},

	'startDayName' => {
		message 	=> q|The name of the day this week starts with.|,
		lastUpdated 	=> 1171043883,
	},

	'startDayAbbr' => {
		message 	=> q|The abbreviation of the name of the day this week starts with.|,
		lastUpdated 	=> 1171043883,
	},

	'startYear' => {
		message 	=> q|The year this week starts in.|,
		lastUpdated 	=> 1171043883,
	},

    'endMonth'  => {
        message     => q{The number (1-12) of the month this week ends.},
        lastUpdated => 117104883,
    },

	'endMonthName' => {
		message 	=> q|The name of the month this week ends.|,
		lastUpdated 	=> 1171043883,
	},

	'endMonthAbbr' => {
		message 	=> q|The abbreviation of the name of the month this week ends.|,
		lastUpdated 	=> 1171043883,
	},

	'endDayOfMonth' => {
		message 	=> q|The day of the month this week ends, a number from 1 to 31.|,
		lastUpdated 	=> 1171043883,
	},

	'endDayName' => {
		message 	=> q|The name of the day this week ends with.|,
		lastUpdated 	=> 1171043883,
	},

	'endDayAbbr' => {
		message 	=> q|The abbreviation of the name of the day this week ends with.|,
		lastUpdated 	=> 1171043883,
	},

	'endYear' => {
		message 	=> q|The year this week ends in.|,
		lastUpdated 	=> 1171043883,
	},


#################### ASSET NAME ####################
	'assetName' => {
		message 	=> q{Calendar},
		lastUpdated 	=> 1131394072,
	},
};

1;
