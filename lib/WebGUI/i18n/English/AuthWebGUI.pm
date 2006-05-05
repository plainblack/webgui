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
		message => q|<p>The following template variables are available for WebGUI Authentication Login templates. 
</p>
<p><strong>login.form.header</strong><br />
The required form elements that go at the top of the login page.
</p>

<p><strong>login.form.hidden</strong><br />
Hidden form fields required for form submission
</p>

<p><strong>login.form.footer</strong><br />
The required form elements that go after the login page form.
</p>

<p><strong>login.form.submit</strong><br />
The default submit button for the login form.
</p>

<p><strong>login.form.username</strong><br />
Default username form field
</p>

<p><strong>login.form.username.label</strong><br />
Default text for username form field
</p>

<p><strong>login.form.password</strong><br />
Default password form field
</p>

<p><strong>login.form.password.label</strong><br />
Default text for password form field
</p>

<p><strong>title</strong><br />
Default page title 
</p>

<p><strong>login.message</strong><br />
Any message returned by the system.  Usually displays after the form is submitted.
</p>

<p><strong>anonymousRegistration.isAllowed</strong><br />
Flag indicating whether or not anonymous registrations are allowed
</p>

<p><strong>createAccount.url</strong><br />
URL for the anonymous registration page
</p>

<p><strong>createAccount.label</strong><br />
Default label for the anonymous registration link
</p>

<p><strong>recoverPassword.isAllowed</strong><br />
Flag indicating whether or not password recovery is enabled
</p>

<p><strong>recoverPassword.url</strong><br />
URL for the password recovery page.
</p>

<p><strong>recoverPassword.label</strong><br />
Default label for the password recovery link
</p>
|,

		lastUpdated => 1101772000
	},

	'18' => {
		message => q|Allow Users to Change Passwords?|,
		lastUpdated => 1076357595
	},

	'expired template body' => {
		message => q|
	<p>The following template variables are available for WebGUI Authentication Password Expiration templates.</p>
	
<p><strong>expired.form.header</strong><br />
The required form elements that go at the top of the password expiration page.
</p>

<p><strong>expired.form.hidden</strong><br />
Hidden form fields required for form submittal.
</p>

<p><strong>expired.form.footer</strong><br />
The required form elements that go after the password expiration page form. 
</p>

<p><strong>expired.form.submit</strong><br />
The default submit button for the password expiration form.
</p>

<p><strong>displayTitle</strong><br />
Default page title.
</p>

<p><strong>expired.message</strong><br />
Any message returned by the system.  Usually displays after the form is submitted.
</p>

<p><strong>create.form.oldPassword</strong><br />
Default old password form field.
</p>

<p><strong>create.form.oldPassword.label</strong><br />
Default text for old password form field.
</p>

<p><strong>expired.form.password</strong><br />
Default password form field.
</p>

<p><strong>expired.form.password.label</strong><br />
Default text for password form field.
</p>

<p><strong>expired.form.passwordConfirm</strong><br />
Default password confirm form field.
</p>

<p><strong>expired.form.passwordConfirm.label</strong><br />
Default text for password confirm form field
</p>

|,
		lastUpdated => 1146848431
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
		message => q|<p>The following template variables are available for WebGUI Authentication Password Recovery templates.</p>

<p><strong>recover.form.header</strong><br />
The required form elements that go at the top of the password recovery page.
</p>

<p><strong>recover.form.hidden</strong><br />
Hidden form fields required for form submission.
</p>

<p><strong>recover.form.footer</strong><br />
The required form elements that go after the password recovery page form.
</p>

<p><strong>recover.form.submit</strong><br />
The default submit button for the password recovery form. 
</p>

<p><strong>login.form.email</strong><br />
Default email form field.
</p>

<p><strong>login.form.email.label</strong><br />
Default text for email form field
</p>

<p><strong>title</strong><br />
Default page title.
</p> 

<p><strong>recover.message</strong><br />
Any message returned by the system.  Usually displays after the form is submitted.
</p>

<p><strong>anonymousRegistration.isAllowed</strong><br />
Flag indicating whether or not anonymous registrations are allowed.
</p>

<p><strong>createAccount.url</strong><br />
URL for the anonymous registration page.
</p>

<p><strong>createAccount.label</strong><br />
Default label for the anonymous registration link.
</p>

<p><strong>login.url</strong><br />
URL for the login page.
</p>

<p><strong>login.label</strong><br />
Default text label for login page link.
</p>

|,

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
		message => q|<p>The following template variables are available for WebGUI Authentication Display Account templates. </p>

<p><strong>account.form.header</strong><br />
The required form elements that go at the top of the display account page.
</p>

<p><strong>account.form.footer</strong><br />
The required form elements that go after the display account page form.
</p>

<p><strong>account.form.karma</strong><br />
A read only form property displaying the amount of karma a user has.  Karma is a configurable user setting that is turned off by default  
</p>

<p><strong>account.form.karma.label</strong><br />
Internationalized text label for the karma form value.
</p>

<p><strong>account.form.submit</strong><br />
The default submit button for the display account form. 
</p>

<p><strong>account.options</strong><br />
Links list of options which allow users to turn on Admin, view and edit profile, view the inbox, etc.  
</p>

<p><strong>displayTitle<br /></strong>
Page title.
</p>

<p><strong>account.message</strong><br />
Any message returned by the system.  Usually displays after the form is submitted.
</p>

<p><strong>account.form.username</strong><br />
Default username form field.
</p>

<p><strong>account.form.username.label</strong><br />
Default text for username form field.
</p>

<p><strong>account.form.password</strong><br />
Default password form field.
</p>

<p><strong>account.form.password.label</strong><br />
Default text for password form field.
</p>

<p><strong>account.form.passwordConfirm</strong><br />
Default password confirm form field.
</p>

<p><strong>account.form.passwordConfirm.label</strong><br />
Default text for password confirm form field.
</p>

<p><strong>account.noform</strong><br />
Indicates whether or not the display account form has any visible fields.
</p>

<p><strong>account.nofields</strong><br />
Default display in the case that there are no form elements to display.
</p>

|,
		lastUpdated => 1101772016
	},

	'anon reg template body' => {
		message => q|<p>The following template variables are available for WebGUI Authentication Anonymous Registration templates. </p>

<p><strong>create.form.header</strong><br />
The required form elements that go at the top of the anonymous registration page.
</p>

<p><strong>create.form.hidden</strong><br />
Hidden form fields required for form submittal.
</p>

<p><strong>create.form.footer</strong><br />
The required form elements that go after the anonymous registration page form. 
</p>

<p><strong>create.form.submit</strong><br />
The default submit button for the anonymous registration form. 
</p>

<p><strong>title</strong><br />
Default page title.
</p>

<p><strong>create.form.profile</strong><br />
A loop containing visible and required profile fields for anonymous registration.
</p>

<p><strong>profile.formElement</strong><br />
Form element for visible or required profile field.
</p>

<p><strong>profile.formElement.label</strong><br />
Default text label for profile form element.
</p>

<p><strong>login.url</strong><br />
URL for the login page.
</p>

<p><strong>login.label</strong><br />
Default text label for login page link.
</p>

<p><strong>create.message</strong><br />
Any message returned by the system.  Usually displays after the form is submitted.
</p>

<p><strong>create.form.username</strong><br />
Default username form field.
</p>

<p><strong>create.form.username.label</strong><br />
Default text for username form field.
</p>

<p><strong>create.form.password<br />
</strong>Default password form field.
</p>

<p><strong>create.form.password.label</strong><br />
Default text for password form field.
</p>

<p><strong>create.form.passwordConfirm</strong><br />
Default password confirm form field.
</p>

<p><strong>create.form.passwordConfirm.label</strong><br />
Default text for password confirm form field.
</p>

<p><strong>recoverPassword.isAllowed</strong><br />
Flag indicating whether or not password recovery is enabled.
</p>

<p><strong>recoverPassword.url</strong><br />
URL for the password recovery page.
</p>

<p><strong>recoverPassword.label</strong><br />
Default label for the password recovery link.
</p>

|,
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
