package WebGUI::i18n::English::AuthLDAP;

our $I18N = {
	'account-1' => {
		message => q|LDAP Authentication Display Account Template|,
		lastUpdated => 1078852969
	},

	'11' => {
		message => q|No connect DN specified for this user|,
		lastUpdated => 1071848383
	},

	'7' => {
		message => q|LDAP Identity Name|,
		lastUpdated => 1031514049
	},

	'2' => {
		message => q|Cannot connect to LDAP server.|,
		lastUpdated => 1031514049
	},

	'create-1' => {
		message => q|LDAP Authentication Anonymous Registration Template|,
		lastUpdated => 1078855925
	},

	'1' => {
		message => q|LDAP Authentication Options|,
		lastUpdated => 1039450730
	},

	'login-2' => {
		message => q|The following template variables are available for LDAP Authentication Login templates. 
<P>
<B>login.form.header</B><BR>
The required form elements that go at the top of the login page.<P><B>login.form.hidden</B><BR>
Hidden form fields required for form submission<P><B>login.form.footer</B><BR>
The required form elements that go after the login page form.</P>
<P>
<B>login.form.submit</B><BR>
The default submit button for the login form.

<P>
<B>login.form.username</B><BR>
Default username form field

<P>
<B>login.form.username.label</B><BR>
Default text for username form field

<P>
<B>login.form.password</B><BR>
Default password form field

<P>
<B>login.form.password.label</B><BR>
Default text for password form field

<P>
<B>title</B><BR>
Default page title 

<P>
<B>login.message</B><BR>
Any message returned by the system.  Usually displays after the form is submitted.

<P>
<B>anonymousRegistration.isAllowed</B><BR>
Flag indicating whether or not anoymous registrations are allowed

<P>
<B>createAccount.url</B><BR>
URL for the anonymous registration page

<P>
<B>createAccount.label</B><BR>
Default label for the anonymous registration link
<P>|,
		lastUpdated => 1100226017
	},

	'13' => {
		message => q|Invalid LDAP connection URL. Contact your administrator.|,
		lastUpdated => 1071849063
	},

	'6' => {
		message => q|LDAP Identity (default)|,
		lastUpdated => 1031514049
	},

	'3' => {
		message => q|LDAP URL|,
		lastUpdated => 1031514049
	},

	'9' => {
		message => q|User RDN|,
		lastUpdated => 1053777552
	},

	'12' => {
		message => q|No LDAP Url Specified for this user|,
		lastUpdated => 1071848371
	},

	'8' => {
		message => q|LDAP Password Name|,
		lastUpdated => 1031514049
	},

	'4' => {
		message => q|Connect DN|,
		lastUpdated => 1031514049
	},

	'account-2' => {
		message => q|The following template variables are available for the LDAP Authentication Display Account templates. 
<P>
<B>account.form.karma</B><BR>
A read only form property displaying the amount of karma a user has.  Karma is a configurable user setting that is turned off by default  

<P>
<B>account.form.karma.label</B><BR>
Internationalized text label for the karma form value  

<P>
<B>account.options</B><BR>
Links list of options which allow users to turn on Admin, view and edit profile, view the messageLog, etc.

<P>
<B>displayTitle</B><BR>
Page title

<P>
<B>account.message</B><BR>
Any message returned by the system.  Usually displays after the form is submitted.<P>|,
		lastUpdated => 1100226287
	},

	'10' => {
		message => q|Password (confirm)|,
		lastUpdated => 1071845113
	},

	'create-2' => {
		message => q|The following template variables are available for LDAP Authentication Anonymous Registration templates.
<P>
<B>create.form.header</B><BR>
The required form elements that go at the top of the anonymous registration page.
<P>
<B>create.form.hidden</B><BR>
Hidden form fields required for form submittal

<P>
<B>create.form.footer</B><BR>
The required form elements that go after the anonymous registration page form. 

<P>
<B>create.form.submit</B><BR>
The default submit button for the anonymous registration form.

<P>
<B>title</B><BR>
Default page title 

<P>
<B>create.form.profile</B><BR>
A loop containing visible and required profile fields for registration
<blockquote>

<P>
<B>profile.formElement</B><BR>
Form element for visible or required profile field

<P>
<B>profile.formElement.label</B><BR>
Default text label for profile form element
</blockquote>

<P>
<B>login.url</B><BR>
URL for the login page

<P>
<B>login.label</B><BR>
Default text label for login page link.
<P>
<B>create.message</B><BR>
Any message returned by the system.  Usually displays after the form is submitted.
<P>
<B>create.form.ldapId</B><BR>
Default ldapId form field

<P>
<B>create.form.ldapId.label</B><BR>
Default text for ldapId form field

<P>
<B>create.form.password</B><BR>
Default password form field

<P>
<B>create.form.password.label</B><BR>
Default text for password form field|,
		lastUpdated => 1100225561
	},

	'5' => {
		message => q|LDAP URL (default)|,
		lastUpdated => 1031514049
	},

	'login-1' => {
		message => q|LDAP Authentication Login Template|,
		lastUpdated => 1078854953
	},

};

1;
