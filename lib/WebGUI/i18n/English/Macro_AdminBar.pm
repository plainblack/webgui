package WebGUI::i18n::English::Macro_AdminBar;

our $I18N = {

    'admin bar title' => {
        message => q|Admin Bar Macro|,
        lastUpdated => 1112374923,
    },

	'admin bar body' => {
		message => q|

<b>&#94;AdminBar;</b><br>
<b>&#94;AdminBar(<i>custom template ID</i>);</b><br>
Places the administrative tool bar on the page. Omitting this macro will prevent you from adding content, pasting
content from the clipboard, accessing the help system and other administrative functions.
<p>
The macro may take one optional argument, an alternate template in the Macro/AdminBar namespace for generating the AdminBar.  The following variables are available in the template:

<p/>
<b>adminbar_loop</b><br/>
A loop containing the various lists of data to display.
<blockquote>
<b>label</b><br />
A heading label for this category.
<p />

<b>name</b><br />
A javascript friendly name for this category.
<p />

<b>items</b>
A loop containing the list if items in this category.
<blockquote>

<b>title</b><br />
The displayable link title for this item.
<p />

<b>url</b><br />
The link URL for this item.
<p />

<b>icon</b><br />
The URL of an icon to associate with this item.
<p />

</blockquote>

</blockquote>
<p/>
|,
		lastUpdated => 1141328392,
	},

	'376' => {
		message => q|Package|,
		lastUpdated => 1031514049
	},

	'1083' => {
		message => q|New Content|,
		lastUpdated => 1076866510
	},

	'1082' => {
		message => q|Clipboard|,
		lastUpdated => 1076866475
	},

	'399' => {
		message => q|Validate this page.|,
		lastUpdated => 1031514049
	},

	'12' => {
		message => q|Turn admin off.|,
		lastUpdated => 1031514049
	},

	'commit my changes' => {
		message => q|Commit My Changes|,
		lastUpdated => 0
	},

	'macroName' => {
		message => q|AdminBar|,
		lastUpdated => 1128837324
	},

};

1;
