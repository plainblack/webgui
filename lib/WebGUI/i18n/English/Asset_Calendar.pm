package WebGUI::i18n::English::Asset_Calendar;
use strict;

our $I18N = { 
	#'key1' => {
	#	message 	=> q{},
	#	lastUpdated 	=> 0,
	#	context 	=> q{},
	#},

	'assetName' => {
		message 	=> q{Calendar},
		lastUpdated 	=> 1131394072,
	},

	'locale'	=> {
		message		=> q{en_US},
		lastUpdated	=> 0,
		context		=> q{The ISO locale name for month and day labels.},
	},

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
	'defaultView value list' => {
		message 	=> q{List},
		lastUpdated 	=> 0,
		context 	=> q{A value for the Default View field.},
	},


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


	'sortEventsBy label' => {
		message		=> q{Daily Events Sort Order},
		lastUpdated	=> 0,
		context		=> q{A specification for determining daily Event display order.},
	},
	'sortEventsBy description' => {
		message		=> q{The order in which daily Events are displayed.},
		lastUpdated	=> 0,
		context		=> q{Hover Help for the Daily Events Sort Order field.},
	},
	'sortEventsBy value time' => {
		message		=> q{Order by Start Date/End Date.},
		lastUpdated	=> 0,
		context		=> q{A value for the Daily Event Sort Order field.},
	},
	'sortEventsBy value sequencenumber' => {
		message		=> q{Order by Sequence Number.},
		lastUpdated	=> 0,
		context		=> q{A value for the Daily Events Sort Order field.},
	},


        'editForm listViewPageInterval label' => {
            message     => "List View Page Interval",
            lastUpdated => 0,
            context     => 'Label for the asset property',
        },
        'editForm listViewPageInterval description' => {
            message     => "Period of time displayed in a single page of the list view",
            lastUpdated => 0,
            context     => 'Description of the asset property',
        },

        'editForm icalInterval label' => {
            message     => "ICalendar Feed Interval",
            lastUpdated => 0,
            context     => 'Label for the asset property',
        },
        'editForm icalInterval description' => {
            message     => "Period of time displayed in the iCalendar feed",
            lastUpdated => 0,
            context     => 'Description of the asset property',
        },




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





	'feeds' => {
		message		=> q{Feeds},
		lastUpdated	=> 0,
		context		=> q{The label for the Feeds tab.},
	},






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

	'editForm templateIdList label' => {
		message 	=> q{List View Template},
		lastUpdated 	=> 0,
		context 	=> q{The label for the default List template.},
	},
	'editForm templateIdList description' => {
		message 	=> q{This template shows the calendar in List form.},
		lastUpdated 	=> 0,
		context 	=> q{Hover Help for the default List template.},
	},

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

	'editForm templateIdPrintList label' => {
		message 	=> q{Print List View Template},
		lastUpdated 	=> 0,
		context 	=> q{The label for the default Print List template.},
	},
	'editForm templateIdPrintList description' => {
		message 	=> q{This template print the calendar in List form.},
		lastUpdated 	=> 0,
		context 	=> q{Hover Help for the default Print List template.},
	},

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

	'searchButtonLabel' => {
		message 	=> q|Search|,
		lastUpdated 	=> 1170803504,
	},

	'add event' => {
		message 	=> q|Add Event|,
		lastUpdated 	=> 1171043337,
	},

	'print' => {
		message 	=> q|Print|,
		lastUpdated 	=> 1171043337,
	},

	'iCal' => {
		message 	=> q|iCal|,
		lastUpdated 	=> 1171043337,
	},

	'view calendar title' => {
		message 	=> q|Calendar View Template Variables|,
		lastUpdated 	=> 1268671312,
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
		message 	=> q|Calendar View Day Template Variables|,
		lastUpdated 	=> 1268671336,
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
		message 	=> q|Calendar View Week Template Variables|,
		lastUpdated 	=> 1268671327,
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


        'help view list title' => {
            message         => 'Calendar List View',
            lastUpdated     => 0,
            context         => 'Title for help page',
        },

        'help view list body' => {
            message         => 'These variables are available to the Calendar List View',
            lastUpdated     => 0,
            context         => 'Body of help page',
        },

        'helpvar newYear' => {
            message         => 'This variable is true when the current event is in a different
                                year than the previous event.',
            lastUpdated     => 0,
            context         => 'Description of template variable',
        },

        'helpvar newMonth'  => {
            message         => 'This variable is true when the current event is in a different
                                month than the previous event.',
            lastUpdated     => 0,
            context         => 'Description of template variable',
        },

        'helpvar newDay'    => {
            message         => 'This variable is true when the current event is in a different
                                day than the previous event.',
            lastUpdated     => 0,
            context         => 'Description of template variable',
        },

        'helpvar url_previousPage' => {
            message         => 'The URL to the previous page. If there is no previous page, this
                                variable will not exist.',
            lastUpdated     => 0,
            context         => 'Description of template variable',
        },

        'helpvar url_nextPage' => {
            message         => 'The URL to the next page. If there is no next page, this
                                variable will not exist.',
            lastUpdated     => 1204303378,
            context         => 'Description of template variable',
        },


        'help calendar dateTime title' => {
            message         => 'Calendar Date/Time variables',
            lastUpdated     => 0,
            context         => 'Title for help page',
        },

        'help calendar dateTime body' => {
            message         => 'These variables are available for most dates and times in the Calendar. <br/><br/>
                                NOTE: Sometimes these variables have a prefix, like "start" or "end". 
                                In that case, the first letter of the variables below is capitalized, so
                                "monthName" with a prefix of "start" becomes "startMonthName".',
            lastUpdated     => 1204303540,
            context         => 'Body for help page',
        },

        'helpvar dateTime second' => {
            message         => 'The seconds',
            lastUpdated     => 0,
            context         => 'Description of template variable',
        },

        'helpvar dateTime minute' => {
            message         => 'The minutes',
            lastUpdated     => 0,
            context         => 'Description of template variable',
        },

        'helpvar dateTime meridiem' => {
            message         => 'The meridiem (A.M. or P.M.)',
            lastUpdated     => 0,
            context         => 'Description of template variable',
        },

        'helpvar dateTime month' => {
            message         => 'The month number (01)',
            lastUpdated     => 0,
            context         => 'Description of template variable',
        },

        'helpvar dateTime monthName' => {
            message         => 'The month name ("January")',
            lastUpdated     => 0,
            context         => 'Description of template variable',
        },,

        'helpvar dateTime monthAbbr' => {
            message         => 'The abbreviated month name ("Jan")',
            lastUpdated     => 0,
            context         => 'Description of template variable',
        },

        'helpvar dateTime dayOfMonth' => {
            message         => 'The number of the day of the month',
            lastUpdated     => 0,
            context         => 'Description of template variable',
        },

        'helpvar dateTime dayName' => {
            message         => 'The day name (Sunday)',
            lastUpdated     => 0,
            context         => 'Description of template variable',
        },

        'helpvar dateTime dayAbbr' => {
            message         => 'The abbreviated day name (Sun)',
            lastUpdated     => 0,
            context         => 'Description of template variable',
        },

        'helpvar dateTime year' => {
            message         => 'The year',
            lastUpdated     => 0,
            context         => 'Description of template variable',
        },

        'helpvar dateTime dayOfWeek' => {
            message         => 'The number of the day of the week (1 is Monday, 7 is Sunday)',
            lastUpdated     => 0,
            context         => 'Description of template variable',
        },

        'helpvar dateTime ymd' => {
            message         => 'The year, month, and day in ISO format: YYYY-MM-DD',
            lastUpdated     => 0,
            context         => 'Description of template variable',
        },

        'helpvar dateTime mdy' => {
            message         => 'The month, day, and year in US format: MM/DD/YYYY',
            lastUpdated     => 0,
            context         => 'Description of template variable',
        },

        'helpvar dateTime dmy' => {
            message         => 'The day, month, and year in UK format: DD/MM/YYYY',
            lastUpdated     => 0,
            context         => 'Description of template variable',
        },

        'helpvar dateTime epoch' => {
            message         => 'The epoch date (number of seconds since 1970-01-01 00:00:00). Suitable to be used in the Date macro.',
            lastUpdated     => 0,
            context         => 'Description of template variable',
        },

        'helpvar dateTime start' => {
            message         => 'A set of date/time variables with the prefix "start" that all deal with the starting date of the displayed interval for the List view of the Calendar. See "Calendar Date/Time Variables" for more information.',
            lastUpdated     => 1226959335,
            context         => 'Description of template variable.',
        },

        'helpvar dateTime end' => {
            message         => 'A set of date/time variables with the prefix "end" that all deal with the ending date of the displayed window for the List view of the Calendar. See "Calendar Date/Time Variables" for more information.',
            lastUpdated     => 1204303480,
            context         => 'Description of template variable',
        },

        'help event variables title' => {
            message         => "Calendar Event Variables",
            lastUpdated     => 0,
            context         => 'Title for help page',
        },

        'help event variables body' => {
            message         => q{When the Calendar is displaying an Event, it gets the entire set of Event template variables and changes the name slightly. <br/><br/>
                                The Event template variable "title" becomes "eventTitle". The Event template variable "startDate" becomes "eventStartDate" and so on.
            },
            lastUpdated     => 0,
            context         => 'Body for help page',
        },

    'label day' => {
        message     => q{Day},
        lastUpdated => 1204668000,
    },
    'label week' => {
        message     => q{Week},
        lastUpdated => 1204668000,
    },
    'label month' => {
        message     => q{Month},
        lastUpdated => 1204668000,
    },
    'label search' => {
        message     => q{Search},
        lastUpdated => 1204668000,
    },
    'subscribe' => {
        message     => q{Subscribe},
        lastUpdated => 1204668000,
    },
    'current' => {
        message     => q{current},
        lastUpdated => 1204668000,
    },
    'previous week' => {
        message     => q{Previous Week},
        lastUpdated => 1204668000,
    },
    'next week' => {
        message     => q{Next Week},
        lastUpdated => 1204668000,
    },
    'previous day' => {
        message     => q{Previous Day},
        lastUpdated => 1204668000,
    },
    'next day' => {
        message     => q{Next Day},
        lastUpdated => 1204668000,
    },
    'previous page' => {
        message     => q{Previous Page},
        lastUpdated => 1204668000,
    },
    'next page' => {
        message     => q{Next Page},
        lastUpdated => 1204668000,
    },
    'start date' => {
        message     => q{Start Date},
        lastUpdated => 1204668000,
    },
    'end date' => {
        message     => q{End Date},
        lastUpdated => 1204668000,
    },
    'page x of x' => {
        message     => q{Displaying page %s of %s},
        lastUpdated => 1204668000,
    },
    'keyword' => {
        message     => q{Keyword},
        lastUpdated => 1204668000,
    },
    'search results' => {
        message     => q{Search Results},
        lastUpdated => 1204668000,
    },

    'editForm workflowIdCommit label' => {
        message     => "Commit Workflow for Events",
        lastUpdated => 0,
        context     => 'Label for the asset property workflowIdCommit',
    },

    'editForm workflowIdCommit description' => {
        message     => "Select a workflow to use to commit events when they are edited or created.",
        lastUpdated => 0,
        context     => 'Description of the asset property workflowIdCommit',
    },
    'asset not committed' => {
		message => q{<h1>Error!</h1><p>You need to commit this calendar before you can create a new event</p>},
        lastUpdated => 1166848379,
    },

    'New Year' => {
        message => q{New Year},
        context => q{template label,  In a list of events, used to indicate that the year has changed},
        lastUpdated => 1229310924,
    },

    'New Month' => {
        message => q{New Month},
        context => q{template label,  In a list of events, used to indicate that the month has changed},
        lastUpdated => 1229310924,
    },

    'New Day' => {
        message => q{New Day},
        context => q{template label,  In a list of events, used to indicate that the day has changed},
        lastUpdated => 1229311001,
    },

    'UP' => {
        message => q{UP},
        context => q{template label,  referring to the previous week, up.  Should be an abbreviation with 2 characters},
        lastUpdated => 1230356830,
    },

    'DN' => {
        message => q{DN},
        context => q{template label,  referring to the next week, down.  Should be an abbreviation with 2 characters},
        lastUpdated => 1230356830,
    },

    'Add a feed' => {
        message => q{Add a feed},
        context => q{feed refers to an iCalendar/iCal feed},
        lastUpdated => 1230931579,
    },

    'Add' => {
        message => q{Add},
        context => q{to add, or append to a list},
        lastUpdated => 1230931579,
    },

    'Feed URL' => {
        message => q{Feed URL},
        context => q{},
        lastUpdated => 1230931579,
    },

	'pageNextUrl monthVar' => {
		message 	=> q|A URL to the next month in the calendar.|,
		lastUpdated 	=> 1269839944,
	},

	'pagePrevUrl monthVar' => {
		message 	=> q|A URL to the previous month in the calendar.|,
		lastUpdated 	=> 1269839951,
	},

	'pageNextYear' => {
		message 	=> q|The year that follows the current one in the Calendar.|,
		lastUpdated 	=> 1268669460,
	},

	'pagePrevYear' => {
		message 	=> q|The year that preceeds the current one in the Calendar.|,
		lastUpdated 	=> 1268669463,
	},

	'dayNames' => {
		message 	=> q|A loop containing names and abbreviations for the days of the week.|,
		lastUpdated 	=> 1268669463,
	},

	'months' => {
		message 	=> q|A loop containing names and URLs for navigating among the months in a year.|,
		lastUpdated 	=> 1268669463,
	},

	'monthEpoch' => {
		message 	=> q|The epoch date for this month.|,
		lastUpdated 	=> 1268669463,
	},

	'monthUrl' => {
		message 	=> q|The URL to change the calendar to display this month.|,
		lastUpdated 	=> 1268669463,
	},

	'monthCurrent' => {
		message 	=> q|A boolean which is true if the calendar is displaying this month.|,
		lastUpdated 	=> 1268669463,
	},

	'view calendar month title' => {
		message 	=> q|Calendar View Month Template Variables|,
		lastUpdated 	=> 1268671291,
	},

	'view calendar month body' => {
		message 	=> q|<p>This template shows all events in a month in the calendar.</p>|,
		lastUpdated 	=> 1171172004,
	},

	'weeks' => {
		message 	=> q|A loop containing loops of events, by day.|,
		lastUpdated 	=> 1171172004,
	},

	'weeks' => {
		message 	=> q|A loop containing loops of events, by day.|,
		lastUpdated 	=> 1171172004,
	},

	'dayUrl' => {
		message 	=> q|A URL to view all events on this day.|,
		lastUpdated 	=> 1171172004,
	},

	'dayCurrent' => {
		message 	=> q|A boolean which is true if this day is today.|,
		lastUpdated 	=> 1171172004,
	},

};

1;
