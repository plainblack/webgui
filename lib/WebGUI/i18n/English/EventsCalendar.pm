package WebGUI::i18n::English::EventsCalendar;

our $I18N = {
	89 => q|Show 3 months from start.|,

	2 => q|Events Calendar|,

	4 => q|Happens only once.|,

	20 => q|Add an event.|,

	93 => q|Next Event|,

	8 => q|Recurs every|,

	9 => q|until|,

	78 => q|Don't delete anything, I made a mistake.|,

	12 => q|Edit Events Calendar|,

	13 => q|Edit Event|,

	90 => q|Default Month|,

	14 => q|Start Date|,

	15 => q|End Date|,

	19 => q|Paginate After|,

	77 => q|Delete this event <b>and</b> all of its recurrences.|,

	82 => q|Current.|,

	88 => q|Show 6 months from start.|,

	76 => q|Delete only this event.|,

	80 => q|Event Template|,

	75 => q|Which do you wish to do?|,

	85 => q|Last in the calendar.|,

	81 => q|Start Month|,

	61 => q|Events Calendar, Add/Edit|,

	71 => q|Events calendars are used on many intranets to keep track of internal dates that affect a whole organization. Also, Events Calendars on consumer sites are a great way to let your customers know what events you'll be attending and what promotions you'll be having.
<br><br>

<b>Main Template</b><br>
Choose a layout for the events calendar.
<br><br>

<b>Event Template</b><br>
Choose a layout for the individual events within the calendars.
<br><br>

<b>Start Month</b><br>
Choose the start month for your calendar. If you choose "current" the calendar will always start on the current month, therefore it will change from month to month. If you choose "first in the calendar" then it will start at whatever the earliest date in the calendar is.
<br><br>

<b>End Month</b><br>
Choose the end month for your calendar. If you choose "show X months from start", then only X months worth of information will ever be displayed. If you choose "current" then the calendar will end on the month you are currently in. If you choose "last in calendar" then the calendar will end on the last date entered into the calendar.
<br><br>

<b>Default Month</b><br>
Choose which month for this calendar to start on when a visitor comes to the page containing the calendar.
<br><br>

<b>Is master?</b><br>
If set to yes then this calendar will display events from all other calendars in the system.
<br><br>

<b>Paginate After</b><br>
When using a list-style calendar, how many events should be shown per page?
<br><br>
<b>Proceed to add event?</b><br>
Leave this set to yes if you want to add events to the Events Calendar directly after creating it.
<br><br>

<i>Note:</i> Events that have already happened will not be displayed on the events calendar.
<br><br>
<hr size="1">
<i><b>Note:</b></i> The following style is specific to the Events Calendar.
<br><br>
<b>.eventTitle </b><br>
The title of an individual event.

|,

	72 => q|Event, Add/Edit|,

	73 => q|<b>Title</b><br>
The title for this event.
<p>

<b>Description</b><br>
Describe the activities of this event or information about where the event is to be held.
<p>

<b>Start Date</b><br>
On what date will this event begin?
<p>

<b>End Date</b><br>
On what date will this event end?
<p>

<b>Recurs every<b><br>
Select a recurrence interval for this event. 

<p>

<b>What next?</b><br>
Select "add new event" if you'd like to add another event, otherwise select "go back to page".
<p>
|,

	83 => q|First in the calendar.|,

	87 => q|Show 9 months from start.|,

	92 => q|Previous Event|,

	86 => q|Show 12 months from start.|,

	91 => q|Add a new event.|,

	84 => q|End Month|,

	96 => q|Event Template|,

	97 => q|The following is the list of template variables available in event templates.
<p/>

<b>title</b><br/>
The title of this event.
<p/>

<b>start.label</b><br/>
The translated label for the start date.
<p/>

<b>start.date</b><br/>
The date this event starts.
<p/>

<b>start.time</b><br/>
The time this event starts.
<p/>

<b>end.date</b><br/>
The date this event ends.
<p/>

<b>end.time</b><br/>
The time this event ends.
<p/>

<b>end.label</b><br/>
The translated label for the end date.
<p/>

<b>canEdit</b><br/>
A condition indicating whether the current user can edit an event.
<p/>

<b>edit.url</b><br/>
The URL to edit this event.
<p/>

<b>edit.label</b><br/>
The translated label for the edit URL.
<p/>

<b>delete.url</b><br/>
The URL to delete this event.
<p/>

<b>delete.label</b><br/>
The translated label for the delete URL.
<p/>

<b>previous.url</b><br/>
The URL to view the event before this one.
<p/>

<b>previous.label</b><br/>
The translated label for the previous URL.
<p/>

<b>next.label</b><br/>
The translated label for the next URL.
<p/>

<b>next.url</b><br/>
The URL to view the event after this one.
<p/>

<b>description</b><br/>
The description of this event.
<p/>
|,

	94 => q|Events Calendar Template|,

	95 => q|The following template variables are available for you to customize your events calendar.
<p/>
<b>addevent.url</b><br/>
The URL to add an event to the calendar.
<p/>

<b>addevent.label</b><br/>
The translated label for the add event link.
<p/>

<b>month_loop</b><br>
A loop containing all the months in the calendar.
<p>

<blockquote>

<b>daysInMonth</b><br>
The number of days in this month.
<p>

<b>day_loop</b><br>
A loop containing all the days in the month.
<p>

<blockquote>

<b>dayOfWeek</b><br>
The day number for the day in the week.
<p>

<b>day</b><br>
The day of the month.
<p>

<b>isStartOfWeek</b><br>
A boolean indicating this is the first day in the week.
<p>

<b>isEndOfWeek</b><br>
A boolean indicating this is the last day in the week.
<p>

<b>isToday</b><br>
A boolean indicating that this day is today.
<p>

<b>event_loop</b><br>
A loop containing all of the events in this day.
<p>

<blockquote>

<b>description</b><br>
The description or detail of this event.
<p>

<b>name</b><br>
The name or title of this event.
<p>

<b>start.date.human</b><br>
The human representation of the start date of this event.
<p>

<b>start.time.human</b><br>
The human representation of the start time of this event.
<p>

<b>start.date.epoch</b><br>
The epoch representation of the start date of this event.
<p>

<b>start.year</b><br>
The year this event starts.
<p>

<b>start.month</b><br>
The month this event starts.
<p>

<b>start.day</b><br>
The day this event starts.
<p>

<b>end.date.human</b><br>
The human representation of the end date of this event.
<p>

<b>end.time.human</b><br>
The human representation of the end time of this event.
<p>

<b>end.date.epoch</b><br>
The epoch representation of the end date of this event.
<p>

<b>end.year</b><br>
The year this event ends.
<p>

<b>end.month</b><br>
The month this event ends.
<p>

<b>end.day</b><br>
The day this event ends.
<p>

<b>startEndYearMatch</b><br>
A boolean indicating whether the start and end year match.
<p>

<b>startEndMonthMatch</b><br>
A boolean indicating whether the start and end month match.
<p>

<b>startEndDayMatch</b><br>
A boolean indicating whether the start and end day match.
<p>

<b>isFirstDayOfEvent</b><br>
A boolean indicating whether this day is the first day of the event.
<p>

<b>dateIsSameAsPrevious</b><br>
A boolean indicating whether the start and end date of this event are the same as the previous event's start and end date.
<p>

<b>daysInEvent</b><br>
The length of this event in days.
<p>

<b>url</b><br>
The URL to view this event in detail.
<p>



</blockquote>


<b>url</b><br>
A URL to today's events.
<p>



</blockquote>

<b>prepad_loop</b><br>
A loop containing info to prepad the days in the month before the start day.
<p>

<blockquote>
<b>count</b><br>
The day of the week for this pad.
<p>


</blockquote>

<b>postpad_loop</b><br>
A loop containing the info to postpad the days in the month after the last day.
<p>

<blockquote>
<b>count</b><br>
The day of the week for this pad.
<p>

</blockquote>

<b>month</b><br>
The name of this month.
<p>

<b>year</b><br>
The name of this year.
<p>



</blockquote>

<b>sunday.label</b><br>
A label representing "Sunday".
<p>

<b>monday.label</b><br>
A label representing "Monday".
<p>

<b>tuesday.label</b><br>
A label representing "Tuesday".
<p>

<b>wednesday.label</b><br>
A label representing "Wednesday".
<p>

<b>thursday.label</b><br>
A label representing "Thursday".
<p>

<b>friday.label</b><br>
A label representing "Friday".
<p>

<b>saturday.label</b><br>
A label representing "Saturday".
<p>


<b>sunday.label.short</b><br>
A label representing the abbreviated version of "Sunday".
<p>

<b>monday.label.short</b><br>
A label representing the abbreviated version of "Monday".
<p>

<b>tuesday.label.short</b><br>
A label representing the abbreviated version of "Tuesday".
<p>

<b>wednesday.label.short</b><br>
A label representing the abbreviated version of "Wednesday".
<p>

<b>thursday.label.short</b><br>
A label representing the abbreviated version of "Thursday".
<p>

<b>friday.label.short</b><br>
A label representing the abbreviated version of "Friday".
<p>

<b>saturday.label.short</b><br>
A label representing the abbreviated version of "Saturday".
<p>

|,

	98 => q|Now!|,

	99 => q|Is master?|,

};

1;
