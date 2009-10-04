package WebGUI::i18n::English::Asset_EMSSubmission;  ##Be sure to change the package name to match the filename

use strict; ##Required for all good Perl::Critic compliant code

our $I18N = { ##hashref of hashes

        'assetName' => {
                message => q|EMS Event Submission|,
                lastUpdated => 1131394072,
                context => q|Then name of the Asset ( Event Management System - Event Submission ).|
        },
	'send email label' => {
		message => q|Send Email when Submission Editted|,
		lastUpdated => 1131394072,
		context => q|This is the lable for the flag for setting the option to send email to the owner when the submission is eddited.|
	},
	'send email label help' => {
		message => q|Check this box if you would like to recieve email for all changes made to your submission|,
		lastUpdated => 1131394072,
		context => q|This is the help text for the 'send email' flag.  If set to 'Yes', the user will recieve email for every change made to the submission.|
	},

#	'TODO' => {
#		message => q|TODO|,
#		lastUpdated => 1131394072,
#		context => q|TODO|
#	},

};

1;
#vim:ft=perl
