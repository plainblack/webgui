package WebGUI::i18n::English::D_date;

our $I18N = {

    'date title' => {
        message => q|Date Macro|,
        lastUpdated => 1112466408,
    },

	'date body' => {
		message => q|

<b>&#94;D; or &#94;D(); - Date</b><br>
The current date and time.
<p>

You can configure the date by using date formatting symbols. For instance, if you created a macro like this <b>&#94;D("%c %D, %y");</b> it would output <b>September 26, 2001</b>. The following are the available date formatting symbols:
<p>

<table><tbody><tr><td>%%</td><td>%</td></tr><tr><td>%y</td><td>4 digit year</td></tr><tr><td>%Y</td><td>2 digit year</td></tr><tr><td>%m</td><td>2 digit month</td></tr><tr><td>%M</td><td>variable digit month</td></tr><tr><td>%c</td><td>month name</td></tr><tr><td>%d</td><td>2 digit day of month</td></tr><tr><td>%D</td><td>variable digit day of month</td></tr><tr><td>%w</td><td>day of week name</td></tr><tr><td>%h</td><td>2 digit base 12 hour</td></tr><tr><td>%H</td><td>variable digit base 12 hour</td></tr><tr><td>%j</td><td>2 digit base 24 hour</td></tr><tr><td>%J</td><td>variable digit base 24 hour</td></tr><tr><td>%p</td><td>lower case am/pm</td></tr><tr><td>%P</td><td>upper case AM/PM</td></tr><tr><td>%z</td><td>user preference date format</td></tr><tr><td>%Z</td><td>user preference time format</td></tr></tbody></table>
<p>
You can also pass in an epoch date into this macro as a secondary parameter. If no date is specified then today's date and time will be used.


|,
		lastUpdated => 1112466919,
	},
};

1;
