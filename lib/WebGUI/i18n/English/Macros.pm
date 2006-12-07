package WebGUI::i18n::English::Macros;

our $I18N = {

	'macro name' => {
		message => q|Macro Name|,
		lastUpdated => 1112591288
	},

	'macro shortcut' => {
		message => q|Macro Shortcut|,
		lastUpdated => 1112591289,
	},

	'macro enabled header' => {
		message => q|Macro Enabled?|,
		lastUpdated => 1112591289,
		context => q|Table heading in List of Macros help page.  Short for "Is this Macro enabled?"|,
	},

	'macros list title' => {
		message => q|Macros, List of Available|,
        	lastUpdated => 1112395935,
	},

	'macros list body' => {
                message => q|<p>Making a macro available for use on your site is a two step process.</p>
<div>
<ol>
<li>The macro must be put in the Macros directory in the WebGUI source code: lib/WebGUI/Macros/.</li>
<li>The macro must be enabled in your WebGUI.conf file, in the "macros" section.  In that section, you can assign a shortcut that is different from the macro's name.</li>
</ol>
</div>
<p>The table below shows which macros are installed on your site and which have been configured in your WebGUI.conf file.</p>

|,
		context => 'Content for dynamically generated macro list',
		lastUpdated => 1150994876,
	},

	'macro enabled' => {
		message => q|This macro is enabled in the WebGUI configuration file and can be used on this site.|,
		lastUpdated => 1046656837,
	},

	'macro disabled' => {
		message => q|This macro is not enabled in the WebGUI configuration file and cannot be used on this site.|,
		lastUpdated => 1046656837,
	},

	'macros using title' => {
		message => q|Macros, Using|,
		lastUpdated => 1046656837
	},

	'macros using body' => {
		message => q|<p>WebGUI macros are used to create dynamic content within otherwise static content. For instance, you may wish to show which user is logged in on every page, or you may wish to have a dynamically built menu or crumb trail. 
</p>

<p>Macros always begin with a caret (&#94;) and follow with at least one other character and end with a semicolon (;). Some macros can be extended/configured by taking the format of <b>&#94;x</b>("<i>config text</i>");.  When providing  multiple arguments to a macro, they should be separated by only commas:<br />
<b>&#94;x</b>(<i>"First argument",2</i>);
</p>

|,
		lastUpdated => 1165518386,
        },

	'topicName' => {
		message => q|Macros|,
		lastUpdated => 1128920014,
	},

};

1;
