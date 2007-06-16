package WebGUI::i18n::English::Asset_Newsletter;  

our $I18N = { 

	'newsletterTitle' => {
		message => q|Whatever this newsletter is called.|,
		lastUpdated => 0, 
		context => q|newsletter template variable|
	},

	'newsletterDescription' => {
		message => q|Whatever is in the description field of this newsletter.|,
		lastUpdated => 0, 
		context => q|newsletter template variable|
	},

	'thread_loop' => {
		message => q|A loop containing all the matching threads for this user's personalized newsletter.|,
		lastUpdated => 0, 
		context => q|newsletter template variable|
	},

	'threadTitle' => {
		message => q|The title of this thread.|,
		lastUpdated => 0, 
		context => q|newsletter template variable|
	},

	'threadSynopsis' => {
		message => q|The short version of this story.|,
		lastUpdated => 0, 
		context => q|newsletter template variable|
	},

	'threadBody' => {
		message => q|The full version of this story.|,
		lastUpdated => 0, 
		context => q|newsletter template variable|
	},

	'threadUrl' => {
		message => q|The fully qualified URL that points to this thread.|,
		lastUpdated => 0, 
		context => q|newsletter template variable|
	},

	'categoriesLoop' => {
		message => q|A loop containing all the categories of data the users may choose from.|,
		lastUpdated => 0, 
		context => q|template variable|
	},

	'optionsLoop' => {
		message => q|A loop containing all the options in a given category.|,
		lastUpdated => 0, 
		context => q|template variable|
	},

	'categoryName' => {
		message => q|The name of this specific category within the loop.|,
		lastUpdated => 0, 
		context => q|template variable|
	},

	'optionName' => {
		message => q|The name of this specific option within this category.|,
		lastUpdated => 0, 
		context => q|template variable|
	},

	'optionForm' => {
		message => q|The checkbox form control for this specific option within this category.|,
		lastUpdated => 0, 
		context => q|template variable|
	},

	'formSubmit' => {
		message => q|The save button for the form.|,
		lastUpdated => 0, 
		context => q|template variable|
	},

	'formHeader' => {
		message => q|The top of the subscription form.|,
		lastUpdated => 0, 
		context => q|template variable|
	},

	'formFooter' => {
		message => q|The bottom of the subscription form.|,
		lastUpdated => 0, 
		context => q|template variable|
	},

	'newsletter add/edit' => {
		message => q|Newsletter, Add/Edit|,
		lastUpdated => 0, 
		context => q|help title|
	},

	'newsletter add/edit desc' => {
		message => q|The Newsletter asset is used to create news stories and then send subscribed users an email
        based upon their chosen interests. This asset requires content profiling to be enabled in order to
        function.|,
		lastUpdated => 0, 
		context => q|help description|
	},

	'mySubscriptionsUrl' => {
		message => q|The URL for a user to click on to manage their subscriptions.|,
		lastUpdated => 0, 
		context => q|newsletter template variable|
	},

	'content profiling needed' => {
		message => q|WARNING: You need to enable content profiling for this asset to work.|,
		lastUpdated => 0, 
		context => q|title for edit screen|
	},

	'edit title' => {
		message => q|Edit Newsletter|,
		lastUpdated => 0, 
		context => q|title for edit screen|
	},

	'newsletter categories' => {
		message => q|Newsletter Categories|,
		lastUpdated => 0, 
		context => q|asset property|
	},

	'newsletter categories help' => {
		message => q|Choose the metadata fields you wish to use as categories. Only select box, check list, and
        radio list categories may be used.|,
		lastUpdated => 0,
		context => q|help for asset property|
	},

	'newsletter template' => {
		message => q|Newsletter Template|,
		lastUpdated => 0, 
		context => q|asset property|
	},

	'newsletter template help' => {
		message => q|Which template would you like to use for the newsletter when it is sent out to users?|,
		lastUpdated => 0,
		context => q|help for asset property|
	},

	'my subscriptions' => {
		message => q|My Subscriptions|,
		lastUpdated => 0, 
		context => q|label for user to click on to manage their subscriptions|
	},

	'my subscriptions template' => {
		message => q|My Subscriptions Template|,
		lastUpdated => 0, 
		context => q|asset property|
	},

	'my subscriptions template help' => {
		message => q|Which template would you like to use for users selecting which cateogries they will subscribe
        to?|,
		lastUpdated => 0,
		context => q|help for asset property|
	},

	'newsletter header' => {
		message => q|Newsletter Header|,
		lastUpdated => 0, 
		context => q|asset property|
	},

	'newsletteer header help' => {
		message => q|A message the will be placed at the top of the newsletter; like a greeting.|,
		lastUpdated => 0,
		context => q|help for asset property|
	},

	'newsletter footer' => {
		message => q|Newsletter Footer|,
		lastUpdated => 0, 
		context => q|asset property|
	},

	'newsletteer footer help' => {
		message => q|A message the will be placed at the bottom of the newsletter; like a salutation.|,
		lastUpdated => 0,
		context => q|help for asset property|
	},

	'send activity name' => {
		message => q|Send Newsletters|,
		lastUpdated => 0,
		context => q|the name of the workflow activity that sends out the newsletters|
	},

	'assetName' => {
		message => q|Newsletter|,
		lastUpdated => 1131394072,
	},

};

1;
