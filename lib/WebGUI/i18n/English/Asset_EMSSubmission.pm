package WebGUI::i18n::English::Asset_EMSSubmission;  ##Be sure to change the package name to match the filename

use strict; ##Required for all good Perl::Critic compliant code

our $I18N = { ##hashref of hashes

        'assetName' => {
                message => q|EMS Event Submission|,
                lastUpdated => 1131394072,
                context => q|Then name of the Asset ( Event Management System - Event Submission ).|
        },

	'comments' => {
		message => q|Comments|,
		lastUpdated => 1131394072,
		context => q|Label for the comments tab.|
	},

	'submission status' => {
		message => q|Submission Status|,
		lastUpdated => 1131394072,
		context => q|Label for the submission status field.|
	},

	'submission status help' => {
		message => q|The status of the submission: pending is waiting for the registrar; feedback is waiting for the owner; denied is denied; approved is waiting to create a ticket; created means the ticket is created successfully, failed means ticket creation was not successfull.|,
		lastUpdated => 1131394072,
		context => q|Help text for the submission status field.|
	},

	'your submission has been updated' => {
		message => q|Your event submission has been updated.|,
		lastUpdated => 1131394072,
		context => q|Message used to notify user when someone else changes their event submission.|
	},

	'edit asset' => {
		message => q|Edit Asset|,
		lastUpdated => 1131394072,
		context => q|The label for the default edit page.|
	},

	'submission id' => {
		message => q|Submission Id|,
		lastUpdated => 1131394072,
		context => q|The label for the submission id column in the submission queue data table.|
	},

	'subject' => {
		message => q|Subject|,
		lastUpdated => 1131394072,
		context => q|The label for the title or subject column in the submission queue data table.|
	},

	'submitted by' => {
		message => q|Submitted By|,
		lastUpdated => 1131394072,
		context => q|The label for the 'submitted by' column in the submission queue data table.|
	},

	'creation date' => {
		message => q|Creation Date|,
		lastUpdated => 1131394072,
		context => q|The label for the creation date column in the submission queue data table.|
	},

	'submission status' => {
		message => q|Submission Status|,
		lastUpdated => 1131394072,
		context => q|The label for the status column in the submission queue data table.|
	},

	'last reply by' => {
		message => q|Last Reply By|,
		lastUpdated => 1131394072,
		context => q|The label for the 'last reply by' column in the submission queue data table.|
	},

#	'TODO' => {
#		message => q|TODO|,
#		lastUpdated => 1131394072,
#		context => q|TODO|
#	},

};

1;
#vim:ft=perl
