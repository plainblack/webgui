package WebGUI::i18n::English::Macro_D_date;

our $I18N = {

    'macroName' => {
        message => q|Date|,
        lastUpdated => 1128837997,
    },

    'date title' => {
        message => q|Date Macro|,
        lastUpdated => 1112466408,
    },

	'date body' => {
		message => q|
<p><b>&#94;D();</b><br />
<b>&#94;D([<i>date formatting code</i>],[<i>epoch date</i>]);</b><br />
The current date and time.
</p>

<p>You can configure the date by using date formatting symbols. For instance, if you created a macro like this <b>&#94;D("%c %D, %y");</b> it would output <b>September 26, 2001</b>. The following are the available date formatting symbols:
</p>

<table><tbody>
<tr><td>%%</td><td>A literal percent sign '%'</td></tr>
<tr><td>%c</td><td>The calendar month name.</td></tr>
<tr><td>%C</td><td>The calendar month name abbreviated to 3 characters and represented in English.</td></tr>
<tr><td>%d</td><td>A two digit day.</td></tr>
<tr><td>%D</td><td>A variable digit day.</td></tr>
<tr><td>%h</td><td>A two digit hour (on a 12 hour clock).</td></tr>
<tr><td>%H</td><td>A variable digit hour (on a 12 hour clock).</td></tr>
<tr><td>%j</td><td>A two digit hour (on a 24 hour clock).</td></tr>
<tr><td>%J</td><td>A variable digit hour (on a 24 hour clock).</td></tr>
<tr><td>%m</td><td>A two digit month.</td></tr>
<tr><td>%M</td><td>A variable digit month.</td></tr>
<tr><td>%n</td><td>A two digit minute.</td></tr>
<tr><td>%o</td><td>Offset from local time represented as an integer.</td></tr>
<tr><td>%O</td><td>Offset from GMT represented in four digit form with a sign. Example: -0600</td></tr>
<tr><td>%p</td><td>A lower-case am/pm.</td></tr>
<tr><td>%P</td><td>An upper-case AM/PM.</td></tr>
<tr><td>%s</td><td>A two digit second.</td></tr>
<tr><td>%w</td><td>Day of the week.</td></tr>
<tr><td>%W</td><td>Day of the week abbreviated to 3 characters and represented in English.</td></tr>
<tr><td>%y</td><td>A four digit year.</td></tr>
<tr><td>%Y</td><td>A two digit year.</td></tr>
<tr><td>%z</td><td>The current user's date format preference, (default: '%H:%n %p').</td></tr>
<tr><td>%Z</td><td>The current user's time format preference, (default: '%M/%D/%y')</td></tr>
</tbody></table>

<p>The default format code is %z %Z.
</p>

<p>You can also pass in an epoch date into this macro as a secondary parameter. If no date is specified then today's date and time will be used.</p>
<p>One common task done with this macro is to display the date that an Asset was last modified.  It uses the <b>revisionDate</b> template variable which is available for all Assets.</p>
<p>&#94;D("%z",<tmpl_var revisionDate>);</p>
<p>This Macro may be nested inside other Macros if the formatted date does not contain commas or quotes.</p>

|,
		lastUpdated => 1168558613,
	},
};

1;
