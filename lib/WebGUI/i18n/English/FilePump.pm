package WebGUI::i18n::English::FilePump;

use strict;

our $I18N = {

	'bundle name' => {
		message => q|Bundle name|,
		lastUpdated => 1131394070,
		context => q|Label for the name of a bundle (group, clump) of files.|
	},

	'last build' => {
		message => q|Last Build|,
		lastUpdated => 1242493652,
		context => q|The time the bundle was built last|
	},

	'last modified' => {
		message => q|Last Modified|,
		lastUpdated => 1242493669,
		context => q|The time the bundle was last modified.|
	},

	'bundle name help' => {
		message => q|A unique, human readable name for this bundle.  Bundle names must be unique.|,
		lastUpdated => 1131394072,
		context => q|Hover help for bundle name.|
	},

	'new bundle' => {
		message => q|New bundle|,
		lastUpdated => 1131394072,
		context => q|Hover help for bundle name.|
	},

	'File Pump' => {
		message => q|File Pump|,
		lastUpdated => 1242439269,
		context => q|File Pump is a system for pushing out lots of files at once.|
	},

	'add a bundle' => {
		message => q|Add a Bundle|,
		lastUpdated => 1242439269,
		context => q|Admin console label.  Bundle is a loose set of similar, but not identical objects.  Similar to pile.|
	},

	'Add Bundle' => {
		message => q|Add Bundle|,
		lastUpdated => 1242439269,
		context => q|Admin console label.  Bundle is a loose set of similar, but not identical objects.  Similar to pile.|
	},

	'list bundles' => {
		message => q|List Bundles|,
		lastUpdated => 1242495011,
		context => q|Admin console label.  Bundle is a loose set of similar, but not identical objects.  Similar to pile.|
	},

	'jsFiles' => {
		message => q|JavaScript|,
		lastUpdated => 1242495011,
		context => q|Edit bundle label.|
	},

	'cssFiles' => {
		message => q|CSS|,
		lastUpdated => 1242495011,
		context => q|Edit bundle label.|
	},

	'otherFiles' => {
		message => q|Collateral|,
		lastUpdated => 1247196636,
		context => q|Edit bundle label.|
	},

	'build this bundle' => {
		message => q|Build this bundle|,
		lastUpdated => 1242495011,
		context => q|Edit bundle label.|
	},

	'build' => {
		message => q|Build|,
		lastUpdated => 1242495011,
		context => q|List bundles label.  Meaning to construct.  The short version of Build this bundle.|
	},

	'build error' => {
		message => q|Problem fetching this URI: %s|,
		lastUpdated => 1242495011,
		context => q|Edit bundle error label.|
	},

	'not yet' => {
		message => q|Not yet|,
		lastUpdated => 1242515308,
		context => q|Meaning that something has not been done at this time.  Before the first time.|
	},

	'duplicate file' => {
		message => q|A file with the same name already exists in the build directory.|,
		lastUpdated => 1242515308,
		context => q|Error message when building a new bundle.|
	},

	'duplicate directory' => {
		message => q|A directory with the same name already exists in the build directory.|,
		lastUpdated => 1242515308,
		context => q|Error message when building a new bundle.|
	},

};

1;
#vim:ft=perl
