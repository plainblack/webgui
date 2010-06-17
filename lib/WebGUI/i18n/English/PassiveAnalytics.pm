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

	'default pause interval' => {
		message => q|Default Pause Threshold|,
		lastUpdated => 0,
	},

	'default pause interval help' => {
		message => q|Set the default pause interval displayed the user sees in the Passive Analytics screen.|,
		lastUpdated => 0,
	},

	'other' => {
		message => q|Other|,
		lastUpdated => 0,
		context => q|Meaning not like anything in a set.  This, that and the other one.  Also, a catch all.|
	},

	'Bucket Passive Analytics' => {
		message => q|Bucket Passive Analytics|,
		lastUpdated => 0,
		context => q|Name of the activity that puts log entries into buckets for analysis.|
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
home\?func=match<br />
|,
		lastUpdated => 1248191303,
		context => q||
	},

	'Passive Analytics' => {
		message => q|Passive Analytics|,
		lastUpdated => 0,
		context => q||
	},

	'Passive Analytics Settings' => {
		message => q|Passive Analytics Settings|,
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
		message => q|The user who will receive an email when bucket processing is done.|,
		lastUpdated => 1248191382,
		context => q||
	},

	'Begin analysis' => {
		message => q|Begin analysis|,
		lastUpdated => 0,
		context => q|Button label to begin analyzing the logs.|
	},

	'Delete Delta Table?' => {
		message => q|Delete Delta Table?|,
		lastUpdated => 0,
		context => q|Button label to begin analyzing the logs.|
	},

	'Delete Delta Table? help' => {
		message => q|Should the delta table be cleaned up after the Passive Analytics analyzer is done?|,
		lastUpdated => 0,
		context => q|Button label to begin analyzing the logs.|
	},

	'Enabled?' => {
		message => q|Enable Passive Analytics?|,
		lastUpdated => 0,
		context => q||
	},

	'Enabled? help' => {
		message => q|Passive Analytics will do no logging until enabled.|,
		lastUpdated => 0,
		context => q||
	},

	'Regular Expression Error:' => {
		message => q|Regular Expression Error:|,
		lastUpdated => 0,
		context => q|Error displayed when a user enters in a bad regular expression.  This label will be followed by the error from perl.|
	},

	'Export bucket data' => {
		message => q|Export bucket data|,
		lastUpdated => 0,
		context => q|URL label to export data in CSV format|,
	},

	'Export delta data' => {
		message => q|Export delta data|,
		lastUpdated => 0,
		context => q|URL label to export data in CSV format|,
	},

	'Export raw logs' => {
		message => q|Export raw logs|,
		lastUpdated => 0,
		context => q|URL label to raw log data in CSV format|,
	},

	'confirm delete rule' => {
		message => q|Are you sure that you want to delete this rule?|,
		lastUpdated => 0,
		context => q|Confirm label in deleting a rule.|,
	},

	'manage ruleset' => {
		message => q|Manage Ruleset|,
		lastUpdated => 0,
		context => q|Admin console submenu label.  Ruleset is a set of rules.|,
	},

	'already active' => {
		message => q|Passive Analytics is already active.  Please do not try to subvert the UI in the future.|,
		lastUpdated => 0,
		context => q|Error message|,
	},

	'workflow deleted' => {
		message => q|The Passive Analytics workflow has been deleted.  Please contact an Administrator immediately.|,
		lastUpdated => 0,
		context => q|Error message|,
	},

	'currently running' => {
		message => q|A Passive Analytics analysis is currently running.|,
		lastUpdated => 0,
		context => q|Error message|,
	},

	'error creating workflow' => {
		message => q|Error creating the workflow instance.|,
		lastUpdated => 0,
		context => q|Error message|,
	},

};

1;
#vim:ft=perl
