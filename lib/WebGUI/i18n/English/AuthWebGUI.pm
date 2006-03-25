package WebGUI::i18n::English::AuthWebGUI;

our $I18N = {
	'no registration hack' => {
		message => q|complete anonymous registration by calling createAccountSave directly from the URL.|,
		lastUpdated => 1078852836
	
	},
	'account template' => {
		message => q|Account Template|,
		lastUpdated => 1078852836
	},

	'create account template' => {
		message => q|Create Account Template|,
		lastUpdated => 1078852836
	},

	'expired password template' => {
		message => q|Expired Password Template|,
		lastUpdated => 1078852836
	},

	'login template' => {
		message => q|Login Template|,
		lastUpdated => 1078852836
	},

	'password recovery template' => {
		message => q|Password Recovery Template|,
		lastUpdated => 1078852836
	},

	'use captcha' => {
		message => q|Use captcha image?|,
		lastUpdated => 1078852836
	},

	'validate email' => {
		message => q|Validate email addresses?|,
		lastUpdated => 1078852836
	},

	'captcha label' => {
		message => q|Verify Your Humanity|,
		lastUpdated => 1078852836
	},

	'captcha failure' => {
		message => q|You need to type in the six characters you see in the image to prove that you are human.|,
		lastUpdated => 1078852836
	},

	'email address validation email subject' => {
		message => q|Account Activation|,
		lastUpdated => 1078852836
	},

	'email address validation email body' => {
		message => q|Welcome to our site. Please click on the link below to activate your account.|,
		lastUpdated => 1078852836
	},

	'check email for validation' => {
		message => q|Please check your email to activate your account.|,
		lastUpdated => 1078852836
	},

	'display account template title' => {
		message => q|WebGUI Authentication Display Account Template|,
		lastUpdated => 1078852836
	},

	'11' => {
		message => q|New Password|,
		lastUpdated => 1071507924
	},

	'21' => {
		message => q|Allow User to Change Username?|,
		lastUpdated => 1076358688
	},

	'7' => {
		message => q|Passwords must have a minimum character length of|,
		lastUpdated => 1071507767
	},

	'17' => {
		message => q|Password Updated|,
		lastUpdated => 1071885563
	},

	'2' => {
		message => q|Password (confirm)|,
		lastUpdated => 1071507729
	},

	'anon reg template title' => {
		message => q|WebGUI Authentication Anonymous Registration Template|,
		lastUpdated => 1078856626
	},

	'22' => {
		message => q|There are no fields to update.|,
		lastUpdated => 1076361800
	},

	'1' => {
		message => q|WebGUI Authentication Options|,
		lastUpdated => 1071507721
	},

	'login template body' => {
		message => q|The following template variables are available for WebGUI Authentication Login templates. 
<P><STRONG>login.form.header</STRONG><BR>The required form elements that go at the top of the login page.<BR><BR><STRONG>login.form.hidden</STRONG><BR>Hidden form fields required for form submission<BR><BR><STRONG>login.form.footer</STRONG><BR>The required form elements that go after the login page form.</P>
<P><STRONG>login.form.submit<BR></STRONG>The default submit button for the login form. <BR><BR><STRONG>login.form.username<BR></STRONG>Default username form field<BR><BR><STRONG>login.form.username.label<BR></STRONG>Default text for username form field<BR><BR><STRONG>login.form.password<BR></STRONG>Default password form field<BR><BR><STRONG>login.form.password.label<BR></STRONG>Default text for password form field<BR><BR><STRONG>title<BR></STRONG>Default page title 
<P><STRONG>login.message</STRONG><BR>Any message returned by the system.  Usually displays after the form is submitted.<BR><BR><STRONG>anonymousRegistration.isAllowed<BR></STRONG>Flag indicating whether or not anonymous registrations are allowed<BR><BR><STRONG>createAccount.url</STRONG><BR>URL for the anonymous registration page<BR><BR><STRONG>createAccount.label<BR></STRONG>Default label for the anonymous registration link<BR><BR><STRONG>recoverPassword.isAllowed</STRONG><BR>Flag indicating whether or not password recovery is enabled<BR><BR><STRONG>recoverPassword.url<BR></STRONG>URL for the password recovery page.<BR><BR><STRONG>recoverPassword.label<BR></STRONG>Default label for the password recovery link</P>|,
		lastUpdated => 1101772000
	},

	'18' => {
		message => q|Allow Users to Change Passwords?|,
		lastUpdated => 1076357595
	},

	'expired template body' => {
		message => q|The following template variables are available for WebGUI Authentication Password Expiration templates. <BR><BR><STRONG>expired.form.header</STRONG><BR>The required form elements that go at the top of the password expiration page.<BR><BR><STRONG>expired.form.hidden<BR></STRONG>Hidden form fields required for form submittal<BR><BR><STRONG>expired.form.footer</STRONG><BR>The required form elements that go after the password expiration page form. 
<P><STRONG>expired.form.submit<BR></STRONG>The default submit button for the password expiration form. <BR><BR><STRONG>displayTitle<BR></STRONG>Default page title 
<P><STRONG>expired.message</STRONG><BR>Any message returned by the system.  Usually displays after the form is submitted.<BR><BR><STRONG>create.form.oldPassword</STRONG><BR>Default old password form field<BR><BR><STRONG>create.form.oldPassword.label</STRONG><BR>Default text for old password form field<BR><BR><STRONG>expired.form.password<BR></STRONG>Default password form field<BR><BR><STRONG>expired.form.password.label<BR></STRONG>Default text for password form field<BR><BR><STRONG>expired.form.passwordConfirm</STRONG><BR>Default password confirm form field<BR><BR><STRONG>expired.form.passwordConfirm.label<BR></STRONG>Default text for password confirm form field</P>|,
		lastUpdated => 1101772005
	},

	'16' => {
		message => q|Password Timeout|,
		lastUpdated => 1071885309
	},

	'13' => {
		message => q|Allow password recovery?|,
		lastUpdated => 1071507940
	},

	'6' => {
		message => q|Allow Password Recovery?|,
		lastUpdated => 1071507760
	},

	'recovery template title' => {
		message => q|WebGUI Authentication Password Recovery Template|,
		lastUpdated => 1078856556
	},

	'3' => {
		message => q|Your passwords did not match. Please try again.|,
		lastUpdated => 1071507737
	},

	'9' => {
		message => q|Expire passwords on user creation?|,
		lastUpdated => 1071507780
	},

	'12' => {
		message => q|You may not use your old password as your new password|,
		lastUpdated => 1071507932
	},

	'recovery template body' => {
		message => q|The following template variables are available for WebGUI Authentication Password Recovery templates. 
<P><STRONG>recover.form.header</STRONG><BR>The required form elements that go at the top of the password recovery page.<BR><BR><STRONG>recover.form.hidden</STRONG><BR>Hidden form fields required for form submission<BR><BR><STRONG>recover.form.footer</STRONG><BR>The required form elements that go after the password recovery page form.</P>
<P><STRONG>recover.form.submit<BR></STRONG>The default submit button for the password recovery form. <BR><BR><STRONG>login.form.email<BR></STRONG>Default email form field<BR><BR><STRONG>login.form.email.label<BR></STRONG>Default text for email form field<BR><BR><STRONG>title<BR></STRONG>Default page title 
<P><STRONG>recover.message</STRONG><BR>Any message returned by the system.  Usually displays after the form is submitted.<BR><BR><STRONG>anonymousRegistration.isAllowed<BR></STRONG>Flag indicating whether or not anonymous registrations are allowed<BR><BR><STRONG>createAccount.url</STRONG><BR>URL for the anonymous registration page<BR><BR><STRONG>createAccount.label<BR></STRONG>Default label for the anonymous registration link<BR><BR><STRONG>login.url<BR></STRONG>URL for the login page<BR><BR><STRONG>login.label</STRONG><BR>Default text label for login page link.</P>|,
		lastUpdated => 1101772010
	},

	'20' => {
		message => q|Allow User to Change Password?|,
		lastUpdated => 1076358606
	},

	'14' => {
		message => q|Minimum password length|,
		lastUpdated => 1071507951
	},

	'15' => {
		message => q|Minimum Password Length|,
		lastUpdated => 1071885112
	},

	'8' => {
		message => q|Your Password Has Expired|,
		lastUpdated => 1071507773
	},

	'4' => {
		message => q|Your password cannot be blank.|,
		lastUpdated => 1071507744
	},

	'expired template title' => {
		message => q|WebGUI Authentication Password Expiration Template|,
		lastUpdated => 1078857230
	},

	'display account template body' => {
		message => q|The following template variables are available for WebGUI Authentication Display Account templates. 
<P><STRONG>account.form.header</STRONG><BR>The required form elements that go at the top of the display account page.<BR><BR><STRONG>account.form.footer</STRONG><BR>The required form elements that go after the display account page form. </P>
<P><STRONG>account.form.karma</STRONG><BR>A read only form property displaying the amount of karma a user has.  Karma is a configurable user setting that is turned off by default  
<P><STRONG>account.form.karma.label</STRONG><BR>Internationalized text label for the karma form value  
<P><STRONG>account.form.submit<BR></STRONG>The default submit button for the display account form. <BR><BR><STRONG>account.options</STRONG><BR>Links list of options which allow users to turn on Admin, view and edit profile, view the inbox, etc.  <BR><BR><STRONG>displayTitle<BR></STRONG>Page title
<P><STRONG>account.message</STRONG><BR>Any message returned by the system.  Usually displays after the form is submitted.<BR><BR><STRONG>account.form.username</STRONG><BR>Default username form field<BR><BR><STRONG>account.form.username.label</STRONG><BR>Default text for username form field<BR><BR><STRONG>account.form.password<BR></STRONG>Default password form field<BR><BR><STRONG>account.form.password.label<BR></STRONG>Default text for password form field<BR><BR><STRONG>account.form.passwordConfirm</STRONG><BR>Default password confirm form field<BR><BR><STRONG>account.form.passwordConfirm.label<BR></STRONG>Default text for password confirm form field<BR><BR><STRONG>account.noform</STRONG><BR>Indicates whether or not the display account form has any visible fields<BR><BR><STRONG>account.nofields<BR></STRONG>Default display in the case that there are no form elements to display</P>|,
		lastUpdated => 1101772016
	},

	'anon reg template body' => {
		message => q|The following template variables are available for WebGUI Authentication Anonymous Registration templates. <BR><BR><STRONG>create.form.header</STRONG><BR>The required form elements that go at the top of the anonymous registration page.<BR><BR><STRONG>create.form.hidden<BR></STRONG>Hidden form fields required for form submittal<BR><BR><STRONG>create.form.footer</STRONG><BR>The required form elements that go after the anonymous registration page form. 
<P><STRONG>create.form.submit<BR></STRONG>The default submit button for the anonymous registration form. <BR><BR><STRONG>title<BR></STRONG>Default page title 
<P><STRONG>create.form.profile<BR></STRONG>A loop containing visible and required profile fields for anonymous registration<BR><BR>         <STRONG>profile.formElement</STRONG><BR>         Form element for visible or required profile field<BR><BR>         <STRONG>profile.formElement.label</STRONG><BR><STRONG>           </STRONG>Default text label for profile form element<BR><BR><BR><STRONG>login.url<BR></STRONG>URL for the login page<BR><BR><STRONG>login.label</STRONG><BR>Default text label for login page link.<BR><BR><STRONG>create.message</STRONG><BR>Any message returned by the system.  Usually displays after the form is submitted.<BR><BR><STRONG>create.form.username</STRONG><BR>Default username form field<BR><BR><STRONG>create.form.username.label</STRONG><BR>Default text for username form field<BR><BR><STRONG>create.form.password<BR></STRONG>Default password form field<BR><BR><STRONG>create.form.password.label<BR></STRONG>Default text for password form field<BR><BR><STRONG>create.form.passwordConfirm</STRONG><BR>Default password confirm form field<BR><BR><STRONG>create.form.passwordConfirm.label<BR></STRONG>Default text for password confirm form field<BR><BR><STRONG>recoverPassword.isAllowed<BR></STRONG>Flag indicating whether or not password recovery is enabled<BR><BR><STRONG>recoverPassword.url<BR></STRONG>URL for the password recovery page.<BR><BR><STRONG>recoverPassword.label<BR></STRONG>Default label for the password recovery link</P>|,
		lastUpdated => 1101772020
	},

	'19' => {
		message => q|Allow Users to Change Username?|,
		lastUpdated => 1076358029
	},

	'10' => {
		message => q|Old Password|,
		lastUpdated => 1071507875
	},

	'login template title' => {
		message => q|WebGUI Authentication Login Template|,
		lastUpdated => 1078854830
	},

	'5' => {
		message => q|Your password cannot be "password".|,
		lastUpdated => 1071507752
	},

	'topicName' => {
		message => q|WebGUI Authentication|,
		lastUpdated => 1128919828,
	},

};

1;
