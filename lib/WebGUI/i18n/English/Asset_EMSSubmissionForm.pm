package WebGUI::i18n::English::Asset_EMSSubmissionForm;  ##Be sure to change the package name to match the filename

use strict; ##Required for all good Perl::Critic compliant code

our $I18N = { ##hashref of hashes

	'assetName' => {
		message => q|EMS Event Submission Form|,
		lastUpdated => 1131394072,
		context => q|Then name of the Asset ( Event Management System - Event Submission Form ).|
	},
	'can submit group label' => {
		message => q|User Group Allowed to create Submissions|,
		lastUpdated => 1131394072,
		context => q|This label is for the field which indicates what user group will be allowed to submit items using this form.|
	},
	'can submit group label help' => {
		message => q|Select a user group which will be allowed to submit items using this form.|,
		lastUpdated => 1131394072,
		context => q|This is the help text for the field which indicates a user group which has permissions to use this form.|
	},
	'days before cleanup label' => {
		message => q|Number of days before cleanup|,
		lastUpdated => 1131394072,
		context => q|This is the label for the number of days before the cleanup job deletes old items from the submission queue.|
	},
	'days before cleanup label help' => {
		message => q|Enter the number of days you wish for old items to remain on the queue before they are deleted.  Enter '0'(zero) to never delete anything fromt he queue.  Also make sure the EMSCleanup Activity is assigned to a workflow that runs on a regular basis.|,
		lastUpdated => 1131394072,
		context => q|This is the help text for the 'days before cleanup' field.  Be sure to remind the user that zero indicates no rows are deleted and that the EMSCleanup Activity needs to run for rows to be deleted.|
	},
	'delete created items label' => {
		message => q|Delete Created Items?|,
		lastUpdated => 1131394072,
		context => q|This is the label for the 'delete created items' field.  The value will indicate if the EMSCleanup will delete items that have been converted to EMSTicket assets.|
	},
	'delete created items label help' => {
		message => q|Set this to 'Yes' if you want submissions to be deleted after they have been converted into EMSTisket assets.|,
		lastUpdated => 1131394072,
		context => q|This is the help text for the delete created items field, if it is set to yes the EMSCleanup activity will delete approved items after EMSTickets have been created from them.  This field depends on the 'days before cleanup' field and the EMSCleanup activity also.|
	},
	'form dscription label' => {
		message => q|Form Description|,
		lastUpdated => 1131394072,
		context => q|The label for the form description field.  Contains JSON text that descibes te form the user sees when they submit an item.|
	},
	'form dscription label help' => {
		message => q|This JSON text describes the form which will be built for the user when they create a submission to this EMS.  It is not a good idea to edit this unless you ~really~ know what you are doing.|,
		lastUpdated => 1131394072,
		context => q|This help text is for the form description field.  The user should be warned not to edit it unless they really know what they are doing.|
	},
	'activity title approve submissions' => {
		message => q|Process Approved EMS Submissions|,
		lastUpdated => 1131394072,
		context => q|This is the label used to describe the EMS submission approval activity|
	},
	'activity title cleanup submissions' => {
		message => q|Cleanup EMS Submissions|,
		lastUpdated => 1131394072,
		context => q|This is the label used to describe the EMS submission cleanup activity|
	},
	'past deadline message' => {
		message => q|The deadline for this submission is past, no more submissions will be taken at this time.|,
		lastUpdated => 1131394072,
		context => q|This is the default message for informing the user that the submission deadline is past.|
	},
	'past deadline label' => {
		message => q|Past Submission Deadline Text|,
		lastUpdated => 1131394072,
		context => q|This is the label for the message indicating that the deadline for submissions has past.|
	},
	'past deadline label help' => {
		message => q|Enter a message here to let the user know that submissions are no longer being taken because the deadline has past.|,
		lastUpdated => 1131394072,
		context => q|This help text should describe how the user tells submitters that the submission deadline has past.|
	},

	'submission deadline label' => {
		message => q|Submission Deadline|,
		lastUpdated => 1131394072,
		context => q|Label for the submission deadline field|
	},

	'submission deadline label help' => {
		message => q|Enter a date after which no more new submissions will be taken.|,
		lastUpdated => 1131394072,
		context => q|Help text for the submission deadline field.  After this date this submission form will not accept any more entries.|
	},

	'new form' => {
		message => q|New Form|,
		lastUpdated => 1131394072,
		context => q|This is the label for the tab when creating a new submission form.|
	},

	'turn on one field' => {
		message => q|You should turn on at least one entry field.|,
		lastUpdated => 1131394072,
		context => q|Remind the registrar to allow at least one field to be editted by the event submitter.|
	},

	'edit form' => {
		message => q|Edit Form|,
		lastUpdated => 1131394072,
		context => q|The label for the default edit form.|
	},

#	'TODO' => {
#		message => q|TODO|,
#		lastUpdated => 1131394072,
#		context => q|TODO|
#	},

};

1;
#vim:ft=perl
