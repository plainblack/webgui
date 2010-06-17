package WebGUI::i18n::English::Workflow_Activity_ExpireIncompleteSurveyResponses;
use strict;

our $I18N = {
    'name' => {
        message => q|Expire Incomplete Survey Responses|,
        lastUpdated => 0,
    },
	'Delete expired survey responses' => {
		message => q|Delete expired survey responses|,
		context => q|the hover help for the delete responses field|,
		lastUpdated => 0,
	},
	'delete expired' => {
		message => q|When run, every survey response which is expired will be completely removed from the database.|,
		context => q|the hover help for the delete responses field|,
		lastUpdated => 0,
	},
	'Email users that responses were deleted' => {
		message => q|Email users that responses were deleted|,
		context => q|the hover help for the email users field|,
		lastUpdated => 0,
	},
	'email users' => {
		message => q|When a survey response is deleted, should the user be informed of this via email?|,
		context => q|the hover help for the email users field|,
		lastUpdated => 0,
	},
	'email template' => {
		message => q|When an email is sent updating the user that their response has been deleted, this is the text that is sent to them.|,
		context => q|the hover help for the email template field|,
		lastUpdated => 0,
	},
	'from' => {
		message => q|Email from field|,
		context => q||,
		lastUpdated => 0,
	},
	'from mouse over' => {
		message => q|This is the from field that will show up in the sent email.|,
		context => q||,
		lastUpdated => 0,
	},
	'subject' => {
		message => q|Email subject field|,
		context => q||,
		lastUpdated => 0,
	},
	'subject mouse over' => {
		message => q|This is the subject field that will show up in the sent email.|,
		context => q||,
		lastUpdated => 0,
	},
	'Email template sent to user' => {
		message => q|The template for the email|,
		context => q||,
		lastUpdated => 0,
	},
	'email template' => {
		message => q|This is the email template that will be sent to the user|,
		context => q||,
		lastUpdated => 0,
	},

};

1;
