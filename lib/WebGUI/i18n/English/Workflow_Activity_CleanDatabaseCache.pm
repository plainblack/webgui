package WebGUI::i18n::English::Workflow_Activity_CleanDatabaseCache;

our $I18N = {
	'size limit help' => {
		message => q|How big should WebGUI allow the cache to get before pruning down old cache entries?|,
		context => q|the hover help for the cache field|,
		lastUpdated => 0,
	},

	'size limit' => {
		message => q|Size Limit|,
		context => q|a label indicating how big we're willing to allow the cache to get on this site|,
		lastUpdated => 0,
	},

	'bytes' => {
		message => q|Bytes|,
		context => q|The unit of measurement for the size limit field.|,
		lastUpdated => 0,
	},

	'activityName' => {
		message => q|Clean Database Cache|,
		context => q|The name of this workflow activity.|,
		lastUpdated => 0,
	},

	'clean database cache body' => {
		message => q|<p>This workflow activity will prune the size of a database based cache based on the user configured cache size and the expiration time of items in the cache.  If pruning expired items does not reduce the size of the cache to the value configured by the user, then the expiration time will be increased by 30 minutes and the process will repeat until it meets the size requirement.</p>|,
		lastUpdated => 0,
	},

};

1;
