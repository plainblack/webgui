package WebGUI::i18n::English::Asset_Event;
use strict;

our $I18N = {

	'locale'	=> {
		message		=> q{en_US},
		lastUpdated	=> 0,
		context		=> q{The ISO locale name for month and day labels.},
	},

	'add/edit title'	=> {
		message		=> q{Event, Add/Edit Screen Template Variables},
		lastUpdated	=> 0,
		context		=> q{Title for the Event Add/Edit Help screen},
	},

	'formHeader'	=> {
		message		=> q|HTML and Javascript for the start of the Add/Edit Event form.|,
		lastUpdated	=> 1171067211,
	},

	'formFooter'	=> {
		message		=> q|HTML for the end of the Add/Edit Event form.|,
		lastUpdated	=> 1171067211,
	},

	'formTitle'	=> {
		message		=> q|HTML form for entering or editing the Event Title.|,
		lastUpdated	=> 1171067211,
	},

	'formMenuTitle'	=> {
		message		=> q|HTML form for entering or editing the Event Menu Title.|,
		lastUpdated	=> 1171067211,
	},

	'formLocation'	=> {
		message		=> q|HTML form for entering or editing the Event Location.|,
		lastUpdated	=> 1171067211,
	},

	'formDescription'	=> {
		message		=> q|HTML form for entering or editing the Event Description.|,
		lastUpdated	=> 1171067211,
	},

    'formGroupToView'   => {
        message     => q|HTML form for picking which group can view this Event.|,
        lastUpdated => 1177383777,
    },

    'formAttachments'   => {
        message     => q|HTML form for adding or removing files from this Event.|,
        lastUpdated => 1177383776,
    },
    
    'formUserDefinedN'   => {
        message     => q|For each of the 5 User Defined fields, a form widget for a single line of text.|,
        lastUpdated => 1190816264,
    },

    'formUserDefinedN_yesNo'   => {
        message     => q|For each of the 5 User Defined fields, a form widget for a yes/no field.|,
        lastUpdated => 1190816264,
    },

    'formUserDefinedN_textarea'   => {
        message     => q|For each of the 5 User Defined fields, a form widget for a text area.|,
        lastUpdated => 1190816264,
    },

    'formUserDefinedN_htmlarea'   => {
        message     => q|For each of the 5 User Defined fields, a form widget for a WYSIWIG HTML area.|,
        lastUpdated => 1190816264,
    },

    'formUserDefinedN_float'   => {
        message     => q|For each of the 5 User Defined fields, a form widget for a float.|,
        lastUpdated => 1190816264,
    },

	'formStartDate'	=> {
		message		=> q|HTML form for entering or editing the Event's start date.|,
		lastUpdated	=> 1171067211,
	},

	'formStartTime'	=> {
		message		=> q|HTML form for entering or editing the Event's start time.|,
		lastUpdated	=> 1171067211,
	},

	'formEndDate'	=> {
		message		=> q|HTML form for entering or editing the Event's end date.|,
		lastUpdated	=> 1171067211,
	},

	'formEndTime'	=> {
		message		=> q|HTML form for entering or editing the Event's end time.|,
		lastUpdated	=> 1171067211,
	},

	'formTime'	=> {
		message		=> q|An HTML form for manipulating the Event's start time and end times.  It has presets for all day long, no specific time, or a specific starting and ending time.|,
		lastUpdated	=> 1171067211,
	},

	'formRelatedLinks'	=> {
		message		=> q|An HTML text form for entering in URLs for websites with more information about this Event.  Individual links should be added one per line.|,
		lastUpdated	=> 1171067211,
	},

	'formRecurPattern'	=> {
		message		=> q|HTML and Javascript for a form that defines how an event recurs.|,
		lastUpdated	=> 1171067211,
	},

	'formRecurStart'	=> {
		message		=> q|HTML Date form for entering the first date an event recurs.|,
		lastUpdated	=> 1171067211,
	},

	'formRecurEnd'	=> {
		message		=> q|HTML Date form for entering when a recurring event ends, if ever.|,
		lastUpdated	=> 1171079974,
	},

	'formSave'	=> {
		message		=> q|HTML code for a button to save the Event data.|,
		lastUpdated	=> 1171079974,
	},

	'formCancel'	=> {
		message		=> q|HTML for a button to cancel adding or editing an event.|,
		lastUpdated	=> 1171079974,
	},

	'formErrors'	=> {
		message		=> q|This loop contains any errors from processing the Event form data.|,
		lastUpdated	=> 1171079974,
	},

	'message'	=> {
		message		=> q|An error message.|,
		lastUpdated	=> 1171079974,
	},

	'event common template variables title'	=> {
		message		=> q|Event Common Template Variables|,
		lastUpdated	=> 1171080606,
	},

	'event common template variables body'	=> {
		message		=> q|<p>These template variables are used by both the Event and the Calendar.</p>|,
		lastUpdated	=> 1171080606,
	},

	'isPublic'	=> {
		message		=> q|A conditional that will be true if the group to view this Event is Everyone.|,
		lastUpdated	=> 1171080606,
	},

	'groupToView'	=> {
		message		=> q|The ID of the Group that is allowed to view this event.|,
		lastUpdated	=> 1171080606,
	},

	'startDateSecond'	=> {
		message		=> q|The second, formatted to two digits with leading zeroes, that this event starts.|,
		lastUpdated	=> 1171080606,
	},

	'startDateMinute'	=> {
		message		=> q|The minute, formatted to two digits with leading zeroes, that this event starts.|,
		lastUpdated	=> 1171080606,
	},

	'startDateHour24'	=> {
		message		=> q|The hour, on a 24 hour clock, that this event starts.|,
		lastUpdated	=> 1171080606,
	},

	'startDateHour'	=> {
		message		=> q|The hour that this event starts.|,
		lastUpdated	=> 1171080606,
	},

	'startDateHourM'	=> {
		message 	=> q|Depending on whether the event occurs in the morning or afternoon, either the strings "am" or "pm"|,
		context 	=> q|Translator's note: Do not translate the strings in double quotes, they are literals.|,
		lastUpdated	=> 1171080991,
	},

	'startDateDayName'	=> {
		message 	=> q|The name of the day the Event starts.|,
		lastUpdated	=> 1171080991,
	},

	'startDateDayAbbr'	=> {
		message 	=> q|The abbreviation of the name of the day the Event starts.|,
		lastUpdated	=> 1171080991,
	},

	'startDateDayOfMonth'	=> {
		message 	=> q|The day of the month this Event starts, a number from 1 to 31.|,
		lastUpdated	=> 1171080991,
	},

	'startDateDayOfWeek'	=> {
		message 	=> q|The day of the week this Event starts, a number from 1 to 7.|,
		lastUpdated	=> 1171080991,
	},

	'startDateMonthName'	=> {
		message 	=> q|The name of the month this Event starts.|,
		lastUpdated	=> 1171080991,
	},

	'startDateMonthAbbr'	=> {
		message 	=> q|The abbreviation of the name of the month this Event starts.|,
		lastUpdated	=> 1171080991,
	},

	'startDateYear' => {
		message 	=> q|The year this Event starts, with 4 digits.|,
		lastUpdated 	=> 1171043883,
	},

	'startDateYmd' => {
		message 	=> q|This Event's start date in yyyy-mm-dd format, where yyyy is the year, mm is the month and dd is the day.|,
		lastUpdated 	=> 1171043883,
	},

	'startDateMdy' => {
		message 	=> q|This Event's start date in mm-dd-yyyy format, where yyyy is the year, mm is the month and dd is the day.|,
		lastUpdated 	=> 1171043883,
	},

	'startDateDmy' => {
		message 	=> q|This Event's start date in dd-mm-yyyy format, where yyyy is the year, mm is the month and dd is the day.|,
		lastUpdated 	=> 1171043883,
	},

	'startDateHms' => {
		message 	=> q|This Event's start time in hh:mm:ss format, where hh is the hour, mm is the minute and ss is the second.|,
		lastUpdated 	=> 1171043883,
	},

	'startDateEpoch' => {
		message 	=> q|This Event's start date and time in epoch format.|,
		lastUpdated 	=> 1171043883,
	},

	'endDateSecond'	=> {
		message		=> q|The second, formatted to two digits with leading zeroes, that this event ends.|,
		lastUpdated	=> 1171080606,
	},

	'endDateMinute'	=> {
		message		=> q|The minute, formatted to two digits with leading zeroes, that this event ends.|,
		lastUpdated	=> 1171080606,
	},

	'endDateHour24'	=> {
		message		=> q|The hour, on a 24 hour clock, that this event ends.|,
		lastUpdated	=> 1171080606,
	},

	'endDateHour'	=> {
		message		=> q|The hour that this event ends.|,
		lastUpdated	=> 1171080606,
	},

	'endDateHourM'	=> {
		message 	=> q|Depending on whether the event occurs in the morning or afternoon, either the strings "am" or "pm"|,
		context 	=> q|Translator's note: Do not translate the strings in double quotes, they are literals.|,
		lastUpdated	=> 1171080991,
	},

	'endDateDayName'	=> {
		message 	=> q|The name of the day the Event ends.|,
		lastUpdated	=> 1171080991,
	},

	'endDateDayAbbr'	=> {
		message 	=> q|The abbreviation of the name of the day the Event ends.|,
		lastUpdated	=> 1171080991,
	},

	'endDateDayOfMonth'	=> {
		message 	=> q|The day of the month this Event ends, a number from 1 to 31.|,
		lastUpdated	=> 1171080991,
	},

	'endDateDayOfWeek'	=> {
		message 	=> q|The day of the week this Event ends, a number from 1 to 7.|,
		lastUpdated	=> 1171080991,
	},

	'endDateMonthName'	=> {
		message 	=> q|The name of the month this Event ends.|,
		lastUpdated	=> 1171080991,
	},

	'endDateMonthAbbr'	=> {
		message 	=> q|The abbreviation of the name of the month this Event ends.|,
		lastUpdated	=> 1171080991,
	},

	'endDateYear' => {
		message 	=> q|The year this Event ends, with 4 digits.|,
		lastUpdated 	=> 1171043883,
	},

	'endDateYmd' => {
		message 	=> q|This Event's end date in yyyy-mm-dd format, where yyyy is the year, mm is the month and dd is the day.|,
		lastUpdated 	=> 1171043883,
	},

	'endDateMdy' => {
		message 	=> q|This Event's end date in mm-dd-yyyy format, where yyyy is the year, mm is the month and dd is the day.|,
		lastUpdated 	=> 1171043883,
	},

	'endDateDmy' => {
		message 	=> q|This Event's end date in dd-mm-yyyy format, where yyyy is the year, mm is the month and dd is the day.|,
		lastUpdated 	=> 1171043883,
	},

	'endDateHms' => {
		message 	=> q|This Event's end time in hh:mm:ss format, where hh is the hour, mm is the minute and ss is the second.|,
		lastUpdated 	=> 1171043883,
	},

	'endDateEpoch' => {
		message 	=> q|This Event's end date and time in epoch format.|,
		lastUpdated 	=> 1171043883,
	},

	'isAllDay' => {
		message 	=> q|A conditional that is true is this Event has been set to be all day long.|,
		lastUpdated 	=> 1171043883,
	},

	'isOneDay' => {
		message 	=> q|A conditional that is true is this Event starts and ends on the same day.|,
		lastUpdated 	=> 1171043883,
	},

	'dateSpan' => {
		message 	=> q|A friendly display of this Event's start and end dates and times.|,
		lastUpdated 	=> 1171043883,
	},

	'url' => {
		message 	=> q|The URL for this Event.|,
		lastUpdated 	=> 1171043883,
	},

	'urlDay' => {
		message 	=> q|A URL to show all Events on the same day in this Event's Calendar.|,
		lastUpdated 	=> 1171043883,
	},

	'urlList' => {
		message 	=> q|A URL to show Events as a list, rather than a calendar.|,
		lastUpdated 	=> 1240635548,
	},

	'urlWeek' => {
		message 	=> q|A URL to show all Events on the same week in this Event's Calendar.|,
		lastUpdated 	=> 1171043883,
	},

	'urlMonth' => {
		message 	=> q|A URL to show all Events on the same month in this Event's Calendar.|,
		lastUpdated 	=> 1171043883,
	},

	'urlParent' => {
		message 	=> q|A URL to the Calendar that contains this Event.|,
		lastUpdated 	=> 1240635921,
	},

	'urlSearch' => {
		message 	=> q|A URL to the Search form for the Calendar that contains this Event.|,
		lastUpdated 	=> 1172693363,
	},

	'urlEdit' => {
		message 	=> q|A URL to edit this Event.|,
		lastUpdated 	=> 1240635940,
	},

	'urlPrint' => {
		message 	=> q|A URL to render this Event with its template for printing.|,
		lastUpdated 	=> 1240635974,
	},

	'urlDelete' => {
		message 	=> q|A URL to delete this Event.|,
		lastUpdated 	=> 1240635972,
	},

	'relatedLinks' => {
		message 	=> q|This loop contains all links from this Event's set of related links.|,
		lastUpdated 	=> 1171043883,
	},

	'linkUrl' => {
		message 	=> q|A URL from the set of related links.|,
		lastUpdated 	=> 1171043883,
	},

	'event view template variables title'	=> {
		message		=> q|Event View Template Variables|,
		lastUpdated	=> 1171080606,
	},

	'event view template variables body'	=> {
		message		=> q|<p>These template variables are used by the template that shows this event to users.</p>|,
		lastUpdated	=> 1171080606,
	},

	'nextUrl'	=> {
		message		=> q|A URL to take the user to the next event in the calendar, by date and time.|,
		lastUpdated	=> 1171080606,
	},

	'prevUrl'	=> {
		message		=> q|A URL to take the user to the previous event in the calendar, by date and time.|,
		lastUpdated	=> 1171080606,
	},

	'event asset template variables title' => {
		message => q|Event Asset Template Variables|,
		lastUpdated => 1171123198
	},

	'event asset template variables body' => {
		message => q|Every asset provides a set of variables to most of its
templates based on the internal asset properties.  Some of these variables may
be useful, others may not.|,
		lastUpdated => 1171123200
	},

	'description' => {
		message => q|The description of this Event.|,
		lastUpdated => 1171123200
	},

	'startDate' => {
		message => q|The date this Event starts.|,
		lastUpdated => 1171123200
	},

	'startTime' => {
		message => q|The date this Event starts.|,
		lastUpdated => 1171123200
	},

	'endDate' => {
		message => q|The date this Event ends.|,
		lastUpdated => 1171123200
	},

	'endTime' => {
		message => q|The date this Event ends.|,
		lastUpdated => 1171123200
	},

	'recurId' => {
		message => q|A unique identifier for this Event's recurrance in the db.|,
		lastUpdated => 1171123200
	},

	'relatedLinks assetVar' => {
		message => q|The original, unprocessed, related links from the form.  This will be all links in one string joined by newlines.|,
		lastUpdated => 1171123200
	},

	'location' => {
		message 	=> q|The location of this Event.|,
		lastUpdated 	=> 1171043883,
	},

	'feedId' => {
		message 	=> q|The unique identifier for an iCal feed.|,
		lastUpdated 	=> 1171043883,
	},

	'feedUid' => {
		message 	=> q|The location of this Event.|,
		lastUpdated 	=> 1171043883,
	},

	'UserDefinedN' => {
		message => q|For each of the 5 User Defined fields, the value of that field.|,
		lastUpdated => 1149829706,
	},

    'image.url' => {
        message => q|The URL to the first image attached to the Post.|,
        lastUpdated => 1177384150,
    },

    'image.thumbnail' => {
        message => q|A thumbnail for the image attached to the Post.|,
        lastUpdated => 1177384152,
    },

    'attachment.url' => {
        message => q|The URL to download the first attachment attached to the Post.|,
        lastUpdated => 1177384153,
    },

    'attachment.icon' => {
        message => q|An icon showing the file type of this attachment.|,
        lastUpdated => 1177384155,
    },

    'attachment.name' => {
        message => q|The name of the first attachment found on the Post.|,
        lastUpdated => 1177384156,
    },

    'attachment_loop' => {
        message => q|A loop containing all file and image attachments to this Post.|,
        lastUpdated => 1177384159,
    },

    'attachment_url' => {
        message => q|The URL to download this attachment.|,
        lastUpdated => 1177384161,
    },

    'icon' => {
        message => q|The icon representing the file type of this attachment.|,
        lastUpdated => 1177384169,
    },

    'filename' => {
        message => q|The name of this attachment.|,
        lastUpdated => 1177384171,
    },

    'thumbnail' => {
        message => q|A thumbnail of this attachment, if applicable.|,
        lastUpdated => 1177384174,
    },

    'isImage' => {
        message => q|A conditional indicating whether this attachment is an image.|,
        lastUpdated => 1177384177,
    },

    'canEdit' => {
        message     => q{This variable is true if the current user can edit this event.},
        lastUpdated     => 0,
    },  

	'assetName' => {
		message 	=> q{Event},
		lastUpdated 	=> 1131394072,
	},

    'edit' => {
        message     => q{Edit},
        lastUpdated => 1204668000,
    },
    'delete' => {
        message     => q{Delete},
        lastUpdated => 1204668000,
    },
    'print' => {
        message     => q{Print},
        lastUpdated => 1204668000,
    },
    'previous event' => {
        message     => q{Previous Event},
        lastUpdated => 1204668000,
    },
    'next event' => {
        message     => q{Next Event},
        lastUpdated => 1204668000,
    },
    'event details' => {
        message     => q{Event Details},
        lastUpdated => 1204668000,
    },
    'event title' => {
        message     => q{Event Title},
        lastUpdated => 1204668000,
    },
    'location' => {
        message     => q{Location},
        lastUpdated => 1204668000,
    },
    'description label' => {
        message     => q{Description},
        lastUpdated => 1204668000,
    },
    'scheduled' => {
        message     => q{Scheduled},
        lastUpdated => 1204668000,
    },
    'related material' => {
        message     => q{Related Material},
        lastUpdated => 1204668000,
    },
    'attachments' => {
        message     => q{Attachments},
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
    'errors' => {
        message     => q{Errors!},
        lastUpdated => 1204668000,
    },
    'tab event' => {
        message     => q{Event},
        lastUpdated => 1204668000,
    },
    'recurrence' => {
        message     => q{Recurrence},
        lastUpdated => 1204668000,
    },
    'short title' => {
        message     => q{Short Title},
        lastUpdated => 1204668000,
    },
    'time' => {
        message     => q{Time},
        lastUpdated => 1204668000,
    },
    'add related link' => {
        message     => q{Add New Related Link},
        lastUpdated => 1204668000,
    },
    'link description' => {
        message     => q{Link Desc},
        lastUpdated => 1204668000,
    },
    'link view group' => {
        message     => q{View Group},
        lastUpdated => 1204668000,
    },
    'group to view' => {
        message     => q{Group to View this Event},
        lastUpdated => 1204668000,
    },
    'attachments for event' => {
        message     => q{Attachments for this Event},
        lastUpdated => 1204668000,
    },
    'recurrence pattern' => {
        message     => q{Recurrence Pattern},
        lastUpdated => 1204668000,
    },
    'recurrence range' => {
        message     => q{Recurrence Range},
        lastUpdated => 1204668000,
    },
    'start' => {
        message     => q{Start},
        lastUpdated => 1204668000,
    },
    'end' => {
        message     => q{End},
        lastUpdated => 1204668000,
    },
    'include dates' => {
        message     => q{Include Dates},
        lastUpdated => 1204668000,
    },
    'exclude dates' => {
        message     => q{Exclude Dates},
        lastUpdated => 1204668000,
    },

    'The event end date must be after the event start date.' => {
        message     => q{The event end date must be after the event start date.},
        lastUpdated => 1246549332,
    },

    'The event end time must be after the event start time.' => {
        message     => q{The event end time must be after the event start time.},
        lastUpdated => 1204668000,
    },

};

1;

