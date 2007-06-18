package WebGUI::i18n::English::Invite;

our $I18N = {

	'invite a friend title' => {
		message => q|Invite A Friend|,
		lastUpdated => 1181103900,
	},

	'default invite' => {
		message => q|I'm a member of a site that I thought you would find very useful, so I'm sending this invitation hoping you'll join me here. Click on the link below to register.|,
		lastUpdated => 1181106351,
	},

	'missing email' => {
		message => q|The invitation cannot be sent because you did not enter an email address.|,
		lastUpdated => 1181409056,
	},

	'missing message' => {
		message => q|Your invitiation must have a message.|,
		lastUpdated => 1181409432,
	},

	'missing subject' => {
		message => q|Your invitation must have a subject.|,
		lastUpdated => 1181409433,
	},

	'already a member' => {
		message => q|Already a member.|,
		lastUpdated => 1181410226,
	},

	'invitation sent' => {
		message => q|Your invitation has been sent.|,
		lastUpdated => 1181410226,
	},

	'invalid invite code' => {
		message => q|Invalid invitation code|,
		lastUpdated => 1181428043,
	},

	'invalid invite code message' => {
		message => q|The invitation code in your URL is invalid.|,
		lastUpdated => 1181410226,
	},

	'already a member message' => {
		message => q|The invitation code in your URL is invalid.|,
		lastUpdated => 1181410226,
        context => q|This message is displayed when someone who is already signed up tries to use an invite code.|,
	},

	'invite form template title' => {
		message => q|User Invitation Form Template|,
		lastUpdated => 1181492752,
	},

	'invite form template body' => {
		message => q|This template is used to customize and display the form that users fill out to invite friends to create an account.|,
		lastUpdated => 1181492842,
	},

	'inviteFormError' => {
		message => q|Any errors from submitting the form.  Error messages are internationalized.|,
		lastUpdated => 1181492842,
	},

	'formHeader' => {
		message => q|HTML code for starting the form.|,
		lastUpdated => 1181492842,
	},

	'formFooter' => {
		message => q|HTML code for ending the form.|,
		lastUpdated => 1181492842,
	},

	'title' => {
		message => q|An internationalized title for the form.|,
		lastUpdated => 1181492842,
	},

	'emailAddressLabel' => {
		message => q|An internationalized label for the email address field.|,
		lastUpdated => 1181492842,
	},

	'emailAddressForm' => {
		message => q|HTML code for the email address field.|,
		lastUpdated => 1181492842,
	},

	'subjectLabel' => {
		message => q|An internationalized label for the subject field.|,
		lastUpdated => 1181492842,
	},

	'subjectForm' => {
		message => q|HTML code for the subject field.|,
		lastUpdated => 1181492842,
	},

	'messageLabel' => {
		message => q|An internationalized label for the message field.|,
		lastUpdated => 1181492842,
	},

	'messageForm' => {
		message => q|HTML code for the message field.|,
		lastUpdated => 1181492842,
	},

	'submitButton' => {
		message => q|HTML code for the submit button, with internationalized label.|,
		lastUpdated => 1181492842,
	},

	'topicName' => {
		message => q|User Invitations.|,
		lastUpdated => 1181493546,
	},

	'invite email template title' => {
		message => q|User Invitation Email Template|,
		lastUpdated => 1181970017,
	},

	'invite email template body' => {
		message => q|This template is used to customize and display the invitation that is sent via email.|,
		lastUpdated => 1181970016,
	},

	'registrationUrl' => {
		message => q|The URL that the recipient will use to accept the invitation.|,
		lastUpdated => 1181970016,
	},

	'invitationMessage' => {
		message => q|The message entered by the user, filtered for HTML to prevent XSS attacks.|,
		lastUpdated => 1181970094,
	},

};

1;
