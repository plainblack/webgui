package WebGUI::i18n::English::Macro_LastModified;

our $I18N = {

	'never' => {
		message => q|Never|,
		lastUpdated => 1134969093
	},

	'macroName' => {
		message => q|LastModified|,
		lastUpdated => 1128839043,
	},

	'last modified title' => {
		message => q|LastModified Macro|,
		lastUpdated => 1112466408,
	},

	'last modified body' => {
		message => q|
<p><b>&#94;LastModified;</b><br />
<b>&#94;LastModified(<i>"text"</i>,<i>"date format"</i>);</b><br />
Displays the date that the current page was last edited. By default, the date is displayed based upon the user's date preferences. Optionally, it can take two parameters. The first is text to display before the date. The second is a date format string (see the date macro, &#94;D;, for details.
</p>
<p><i>Example:</i> &#94;LastModified("Updated: ","%c %D, %y");
</p>
<p>If you would like to get the last modified time of Assets on a page, see the Date macro for an example.
</p>
<p>This Macro may be nested inside other Macros if the text it returns does not contain commas or quotes.</p>
|,
		lastUpdated => 1170179085,
	},
};

1;
