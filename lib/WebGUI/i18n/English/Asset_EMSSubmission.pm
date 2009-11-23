package WebGUI::i18n::English::Asset_EMSSubmission;  ##Be sure to change the package name to match the filename

use strict; ##Required for all good Perl::Critic compliant code

our $I18N = { ##hashref of hashes

        'assetName' => {
                message => q|EMS Event Submission|,
                lastUpdated => 1131394072,
                context => q|Then name of the Asset ( Event Management System - Event Submission ).|
        },
	'send email label' => {
		message => q|Send Email when Submission Edited|,
		lastUpdated => 1258993281,
		context => q|This is the lable for the flag for setting the option to send email to the owner when the submission is edited.|
	},
	'send email label help' => {
		message => q|Check this box if you would like to recieve email for all changes made to your submission|,
		lastUpdated => 1131394072,
		context => q|This is the help text for the 'send email' flag.  If set to 'Yes', the user will recieve email for every change made to the submission.|
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

#	'TODO' => {
#		message => q|TODO|,
#		lastUpdated => 1131394072,
#		context => q|TODO|
#	},

};

1;
#vim:ft=perl
