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

	'form_header' => {
		message => q|HTML Code to begin the search form|,
		lastUpdated => 1149567859,
	},

	'form_footer' => {
		message => q|HTML Code to end the search form|,
		lastUpdated => 1149567859,
	},

	'form_submit' => {
		message => q|A button to allow the user to submit a search.|,
		lastUpdated => 1149567859,
	},

	'form_keywords' => {
		message => q|A form to let the user enter in keywords for the search.|,
		lastUpdated => 1149567859,
	},

	'result_set' => {
		message => q|Paginated search results with pagination controls.|,
		lastUpdated => 1149567859,
	},

	'search template body' => {
		message => q|<p>The following template variables are available for Search Asset templates.  All of these variables are required.</p>
|,
		lastUpdated => 1149567912,
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
