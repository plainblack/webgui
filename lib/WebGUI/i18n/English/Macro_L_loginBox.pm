package WebGUI::i18n::English::Macro_L_loginBox;

our $I18N = {

	'macroName' => {
		message => q|Login Box|,
		lastUpdated => 1128839093,
	},

	'login box title' => {
		message => q|Login Box Macro|,
		lastUpdated => 1112466408,
	},

	'user.isVisitor' => {
		message => q|True if the user is a visitor.|,
		lastUpdated => 1148963673,
	},

	'customText' => {
		message => q|The user defined text to display if the user is logged in.|,
		lastUpdated => 1148963673,
	},

	'hello.label' => {
		message => q|Internationalized welcome message.|,
		lastUpdated => 1148963673,
	},

	'customText' => {
		message => q|The text supplied to the macro to display if the user is logged in.|,
		lastUpdated => 1148963673,
	},

	'account.display.url' => {
		message => q|URL to display the account.|,
		lastUpdated => 1148963673,
	},

	'logout.label' => {
		message => q|Internationalized logout message.|,
		lastUpdated => 1148963673,
	},

	'form.header' => {
		message => q|Form header.|,
		lastUpdated => 1148963673,
	},

	'username.label' => {
		message => q|Internationalized label for "username".|,
		lastUpdated => 1148963673,
	},

	'username.form' => {
		message => q|Form element for the username.|,
		lastUpdated => 1148963673,
	},

	'password.label' => {
		message => q|Internationalized label for "password".|,
		lastUpdated => 1148963673,
	},

	'password.form' => {
		message => q|Form element for the password.|,
		lastUpdated => 1148963673,
	},

	'form.login' => {
		message => q|Action to perform when logging in.|,
		lastUpdated => 1148963673,
	},

	'account.create.url' => {
		message => q|URL to create an account.|,
		lastUpdated => 1148963673,
	},

	'account.create.label' => {
		message => q|Internationalized label for "create an account"|,
		lastUpdated => 1148963673,
	},

	'form.footer' => {
		message => q|Form footer.|,
		lastUpdated => 1148963673,
	},

	'login box body' => {
		message => q|
<p><b>&#94;L; or &#94;L(); - Login Box</b><br />
A small login form. This macro takes up to three parameters.  The first is used to set the width of the login box: &#94;L(20);. The second sets the message displayed after the user is logged in: &#94;L(20,"Hi &#94;a(&#94;@;);. Click %here% if you wanna log out!");.  Text between percent signs (%) is replaced by a link to the logout operation.  The third parameter is the ID of a template in the Macro/L_loginBox namespace to replace the default template.  The variables below are
available for use in the template.</p>

<p><b>NOTE:</b> The .loginBox style sheet class is tied to this macro.
</p>

|,
		lastUpdated => 1148963753,
	},

	'48' => {
		message => q|Hello|,
		lastUpdated => 1031514049,
	},

	'49' => {
		message => q|Click here to log out.|,
		lastUpdated => 1031514049,
	},
};

1;
