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
<b>packages.label</b><br/>
The internationalized label for adding packages.

<p/>
<b>packages.canAdd</b><br/>
A boolean indicating whether the current user can add packages.

<p/>
<b>addContent.label</b><br/>
The internationalized label for adding content.

<p/>
<b>contenttypes_loop</b><br/>
The loop containing different types of content to add

<blockquote>
<p/>
<b>contenttype.label</b><br/>
The internationalized label for this content type.

<p/>
<b>contenttype.url</b><br/>
The URL for adding an instance of this content type.

</blockquote>

<p/>
<b>addpage.label</b><br/>
The internationalized label for adding a page.

<p/>
<b>addpage.url</b><br/>
The URL for adding a page.

<p/>
<b>clipboard.label</b><br/>
The internationalized label for the clipboard.

<p/>
<b>clipboard_loop</b><br/>
The loop containing a list of items in the clipboard.

<blockquote>
<p/>
<b>clipboard.label</b><br/>
The label for this item in the clipboard.

<p/>
<b>clipboard.url</b><br/>
The URL for pasting this clipboard item onto the current page.

</blockquote>

<p/>
<b>admin.label</b><br/>
The internationalized label for administrative functions.

<p/>
<b>admin_loop</b><br/>
The loop containing a list of administrative functions, such as turning off admin mode or
validating the current page.

<blockquote>
<p/>
<b>admin.label</b><br/>
The label for this item in the clipboard.

<p/>
<b>admin.url</b><br/>
The URL for executing this admin function.

</blockquote>

<p/>
 The <i>.adminBar</i> style sheet class is tied to the default template for this macro.
|,
		lastUpdated => 1112583521,
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

	'macroName' => {
		message => q|AdminBar|,
		lastUpdated => 1128837324
	},

};

1;
