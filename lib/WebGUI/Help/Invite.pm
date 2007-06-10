package WebGUI::Help::Invite;

our $HELP = {

	'invite form template' => {
		title => 'invite form template title',
		body => 'invite form template body',
		variables => [
			{
				name     => 'inviteFormError',
                required => 1,
			}, 
			{
				name     => 'formHeader',
                required => 1,
			}, 
			{
				name => 'formFooter',
                required => 1,
			}, 
			{
				name => 'title',
			}, 
			{
				name => 'emailAddressLabel',
			}, 
			{
				name => 'emailAddressForm',
			}, 
			{
				name => 'subjectLabel',
			}, 
			{
				name => 'subjectForm',
			}, 
			{
				name => 'messageLabel',
			}, 
			{
				name => 'messageForm',
			}, 
			{
				name => 'submitButton',
			}, 
		],
		fields => [
		],
		related => [
		]
	},

};

1;  ##All perl modules must return true
