package WebGUI::i18n::English::Workflow_Activity_CleanDatabaseCache;
use strict;

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

};

1;
