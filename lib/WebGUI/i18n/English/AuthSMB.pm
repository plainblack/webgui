package WebGUI::i18n::English::AuthSMB;

our $I18N = {
	'9' => {
		message => q|NT Password|,
		lastUpdated => 1039453225
	},

	'8' => {
		message => q|NT Login|,
		lastUpdated => 1039452980
	},

	'7' => {
		message => q|NT Domain|,
		lastUpdated => 1039452950
	},

	'6' => {
		message => q|BDC|,
		lastUpdated => 1039452936
	},

	'5' => {
		message => q|PDC|,
		lastUpdated => 1039452926
	},

	'4' => {
		message => q|SMB Logon Error (3)<br>You have supplied an invalid username/password pair. Probably a typo, please try again.|,
		lastUpdated => 1039452797
	},

	'3' => {
		message => q|SMB Protocol Error (2)<br>Please contact your sysadmin.|,
		lastUpdated => 1039452769
	},

	'2' => {
		message => q|SMB Server Error (1)<br>Something went wrong accessing the domain controller. Perhaps the connection timed out. Please try again or contact your sysadmin.|,
		lastUpdated => 1039452744
	},

	'1' => {
		message => q|SMB Authentication Options|,
		lastUpdated => 1039451963
	},

	'10' => {
		message => q|No SMB username specfified.|,
		lastUpdated => 1071926471
	},

	'create-1' => {
		message => q|SMB Authentication Anonymous Registration Template|,
		lastUpdated => 1078856081
	},

	'create-2' => {
		message => q|The following template variables are available for&nbsp;SMB Authentication Anonymous Registration templates. <BR><BR><STRONG>create.form.header</STRONG><BR>The required form elements that go at the top of the&nbsp;anonymous registration&nbsp;page.<BR><BR><STRONG>create.form.hidden<BR></STRONG>Hidden form fields required for form submittal<BR><BR><STRONG>create.form.footer</STRONG><BR>The required form elements that go after the anonymous registration page form. 
<P><STRONG>create.form.submit<BR></STRONG>The default submit button for the&nbsp;anonymous registration form. <BR><BR><STRONG>title<BR></STRONG>Default page title 
<P><STRONG>create.form.profile<BR></STRONG>A loop containing visible and required profile fields for registration<BR><BR>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; <STRONG>profile.formElement</STRONG><BR>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;Form element for visible or required profile field<BR><BR>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; <STRONG>profile.formElement.label</STRONG><BR><STRONG>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp; </STRONG>Default text label for profile form element<BR><BR><BR><STRONG>login.url<BR></STRONG>URL for the login page<BR><BR><STRONG>login.label</STRONG><BR>Default text label for login page link.<BR><BR><STRONG>create.message</STRONG><BR>Any message returned by the system.&nbsp; Usually displays after the form is submitted.<BR><BR><STRONG>create.form.loginId</STRONG><BR>Default&nbsp;SMB loginId form field<BR><BR><STRONG>create.form.loginId.label</STRONG><BR>Default text for&nbsp;SMB loginId form field<BR><BR><STRONG>create.form.password<BR></STRONG>Default password form field<BR><BR><STRONG>create.form.password.label<BR></STRONG>Default text for password form field</P>|,
		lastUpdated => 1078856081
	},

	'login-1' => {
		message => q|SMB Authentication Login Template|,
		lastUpdated => 1078854992
	},

	'login-2' => {
		message => q|The following template variables are available for&nbsp;SMB Authentication&nbsp;Login&nbsp;templates. 
<P><STRONG>login.form.header</STRONG><BR>The required form elements that go at the top of the&nbsp;login page.<BR><BR><STRONG>login.form.hidden</STRONG><BR>Hidden form fields required for form submission<BR><BR><STRONG>login.form.footer</STRONG><BR>The required form elements that go after the login page form.</P>
<P><STRONG>login.form.submit<BR></STRONG>The default submit button for the&nbsp;login form. <BR><BR><STRONG>login.form.username<BR></STRONG>Default username form field<BR><BR><STRONG>login.form.username.label<BR></STRONG>Default text for username form field<BR><BR><STRONG>login.form.password<BR></STRONG>Default password form field<BR><BR><STRONG>login.form.password.label<BR></STRONG>Default text for password form field<BR><BR><STRONG>title<BR></STRONG>Default page title 
<P><STRONG>login.message</STRONG><BR>Any message returned by the system.&nbsp; Usually displays after the form is submitted.<BR><BR><STRONG>anonymousRegistration.isAllowed<BR></STRONG>Flag indicating whether or not anoymous registrations are allowed<BR><BR><STRONG>createAccount.url</STRONG><BR>URL&nbsp;for&nbsp;the anonymous registration page<BR><BR><STRONG>createAccount.label<BR></STRONG>Default label for the anonymous registration link</P>|,
		lastUpdated => 1078854992
	},

	'account-1' => {
		message => q|SMB Authentication Display Account Template|,
		lastUpdated => 1078853113
	},

	'account-2' => {
		message => q|The following template variables are available for&nbsp;the&nbsp;SMB Authentication Display Account&nbsp;templates. 
<P><STRONG>account.form.karma</STRONG><BR>A read only form property displaying the amount of karma a user has.&nbsp; Karma&nbsp;is a&nbsp;configurable user setting that is turned off by default&nbsp; 
<P><STRONG>account.form.karma.label</STRONG><BR>Internationalized text label for&nbsp;the karma form value&nbsp; 
<P><STRONG>account.options</STRONG><BR>Links list of options&nbsp;which&nbsp;allow users to&nbsp;turn on Admin, view and edit profile, view the messageLog, etc.&nbsp; <BR><BR><STRONG>displayTitle<BR></STRONG>Page title<BR><STRONG><BR>account.message</STRONG><BR>Any message returned by the system.&nbsp; Usually displays after the form is submitted.</P>|,
		lastUpdated => 1078853113
	},

};

1;
