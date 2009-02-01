package WebGUI::i18n::English::PassiveAnalytics;

use strict;

our $I18N = {

	'Summarize Passive Analytics' => {
		message => q|Summarize Passive Analytics|,
		context => q|The name of this workflow activity.|,
		lastUpdated => 0,
	},

	'pause interval' => {
		message => q|Pause threshold|,
		lastUpdated => 0,
	},

	'pause interval help' => {
		message => q|Set the time between clicks that is interpreted as the user reading the page, as opposed to beginning a new browsing session, or leaving the site.|,
		lastUpdated => 0,
	},

	'other' => {
		message => q|Other|,
		lastUpdated => 0,
		context => q|Meaning not like anything in a set.  This, that and the other one.  Also, a catch all.|
	},

	'Bucket Name' => {
		message => q|Bucket Name|,
		lastUpdated => 0,
		context => q|To name a container, or bucket.|
	},

	'Bucket Name help' => {
		message => q|Pick a unique, descriptive short name for this bucket.|,
		lastUpdated => 0,
		context => q||
	},

	'regexp' => {
		message => q|Regular expression|,
		lastUpdated => 0,
		context => q||
	},

	'regexp help' => {
		message => q|Define a regular expression to pick log entries for this bucket.<br />
^ = beginning of url<br />
$ = end of url<br />
. = any character<br />
* = any amount<br />
+ = 1 or more<br />
? = 0 or 1<br />
Meta characters should be backslash-escaped if you want to match them as ordinary text, e.g.<br />
home\?func=match, or<br />
|,
		lastUpdated => 0,
		context => q||
	},

	'Passive Analytics' => {
		message => q|Passive Analytics|,
		lastUpdated => 0,
		context => q||
	},

	'Edit Rule' => {
		message => q|Edit Rule|,
		lastUpdated => 0,
		context => q||
	},

	'Add a bucket' => {
		message => q|Add a bucket|,
		lastUpdated => 0,
		context => q||
	},

	'User' => {
		message => q|User|,
		lastUpdated => 0,
		context => q||
	},

	'User help' => {
		message => q|The user who will recieve an email when bucket processing is done.|,
		lastUpdated => 0,
		context => q||
	},

	'Begin analysis' => {
		message => q|Begin analysis|,
		lastUpdated => 0,
		context => q|Button label to begin analyzing the logs.|
	},

};

1;
#vim:ft=perl
