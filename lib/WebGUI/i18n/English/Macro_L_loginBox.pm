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

	'login box body' => {
		message => q|

<b>&#94;L; or &#94;L(); - Login Box</b><br />
A small login form. This macro takes up to three parameters.  The first is used to set the width of the login box: &#94;L(20);. The second sets the message displayed after the user is logged in: &#94;L(20,"Hi &#94;a(&#94;@;);. Click %here% if you wanna log out!");.  Text between percent signs (%) is replaced by a link to the logout operation.  The third parameter is the ID of a template in the Macro/L_loginBox namespace to replace the default template.  The variables below are
available in the template.  Not all of them are required, but variables that will cause the macro to output code that doesn't function properly (like not actually log someone in) are marked with an asterisk '*'
<p/>
<b>user.isVisitor</b><br />
True if the user is a visitor.
<p/>
<b>customText</b><br />
The user defined text to display if the user is logged in.
<p/>
<b>hello.label</b><br />
Internationalized welcome message.
<p/>
<b>customText</b><br />
The text supplied to the macro to display if the user is logged in.
<p/>
<b>account.display.url</b><br />
URL to display the account.
<p/>
<b>logout.label</b><br />
Internationalized logout message.
<p/>
<b>* form.header</b><br />
Form header.
<p/>
<b>username.label</b><br />
Internationalized label for "username".
<p/>
<b>* username.form</b><br />
Form element for the username.
<p/>
<b>password.label</b><br />
Internationalized label for "password".
<p/>
<b>* password.form</b><br />
Form element for the password.
<p/>
<b>* form.login</b><br />
Action to perform when logging in.
<p/>
<b>account.create.url</b><br />
URL to create an account.
<p/>
<b>account.create.label</b><br />
Internationalized label for "create an account"
<p/>
<b>* form.footer</b><br />
Form footer.
<p/>

<b>NOTE:</b> The .loginBox style sheet class is tied to this macro.
<p>

|,
		lastUpdated => 1112466919,
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
