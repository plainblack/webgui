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

	'search asset template variables title' => {
		message => q|Search Asset Template Variables|,
		lastUpdated => 1164841146
	},

	'templateId' => {
		message => q|The ID of the template used to display the Search Asset.|,
		lastUpdated => 1168897708,
	},

	'searchRoot' => {
		message => q|The ID of the Asset where the searching will begin.|,
		lastUpdated => 1168897708,
	},

	'classLimiter' => {
		message => q|A string with all types of Assets to search.|,
		lastUpdated => 1168897708,
	},

	'url' => {
		message => q|The URL of the Asset found in the search.|,
		lastUpdated => 1169843468,
	},

	'title' => {
		message => q|The title of the Asset found in the search.|,
		lastUpdated => 1169843466,
	},

	'synopsis' => {
		message => q|The synopsis of the Asset found in the search.|,
		lastUpdated => 1169843465,
	},
	'assetId' => { 
                message => q|The assetId of the Asset found in the search.|,
                lastUpdated => 1169843465,
        },

	'results_found' => {
		message => q|A conditional variable that will be true if any results were found.|,
		lastUpdated => 1170549116,
	},

	'no results' => {
		message => q|No results were found.|,
		lastUpdated => 1170549113,
	},

	'no_results' => {
		message => q|An internationalized label for telling the user that no results were found.|,
		lastUpdated => 1170549119,
	},

};

1;
