package WebGUI::i18n::English::Asset_Search;  ##Be sure to change the package name to match the filename

our $I18N = { ##hashref of hashes

	'search' => {
		message => q|search|,
		lastUpdated => 0,
		context => q|A label to place on the search button.|
	},

	'assetName' => {
		message => q|Search|,
		lastUpdated => 0,
	},

	'search template' => {
		message => q|Search Template|,
		lastUpdated => 1138900894,
		context => q|form field in add/edit search form|
	},

	'search template description' => {
		message => q|A template to display the search form and results.|,
		lastUpdated => 1138900894,
		context => q|hover help for search template|
	},

	'search root' => {
		message => q|Search Root|,
		lastUpdated => 1138900894,
		context => q|form field in add/edit search form|
	},

	'search root description' => {
		message => q|The Asset you select, and all Assets below it, will be searched.|,
		lastUpdated => 1138900894,
		context => q|hover help for search root|
	},

	'class limiter' => {
		message => q|Limit Asset classes to:|,
		lastUpdated => 1138900894,
		context => q|form field in add/edit search form|
	},

	'class limiter description' => {
		message => q|This will limit the types of Assets that are searched to only those that you select.|,
		lastUpdated => 1138900894,
		context => q|hover help for search root|
	},

	'search template body' => {
		message => q|<p>The following template variables are available for Search Asset templates.  All of these variables are required.</p>

<p><b>form_header*</b><br />
HTML Code to begin the search form
</p>

<p><b>form_footer*</b><br />
HTML Code to end the search form
</p>

<p><b>form_submit*</b><br />
A button to allow the user to submit a search.
</p>

<p><b>form_keywords*</b><br />
A form to let the user enter in keywords for the search.
</p>

<p><b>result_set*</b><br />
Paginated search results with pagination controls.
</p>
|,
		lastUpdated => 1142051703,
	},

	'add/edit title' => {
		message => q|Add/Edit Search|,
		lastUpdated => 1142052517,
	},

	'add/edit body' => {
		message => q|<p>The Search Asset is used to search WebGUI content.  In addition to the properties below, Search Assets also have the properties of Wobjects and Assets.</p>|,
		lastUpdated => 1142052519,
	},

};

1;
