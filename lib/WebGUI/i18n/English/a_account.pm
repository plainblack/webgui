package WebGUI::i18n::English::a_account;

our $I18N = {

    'account title' => {
        message => q|Account Macro|,
        lastUpdated => 1112466408,
    },

	'account body' => {
		message => q|

<b>&#94;a; or &#94;a(); - My Account Link</b><br>
A link to your account information. In addition you can change the link text by creating a macro like this <b>&#94;a("Account Info");</b>.  If you specify "linkonly" in the first parameter then only the URL will be returned. Also, you can specify the name of a template in the Macro/a_account namespace as the second parameter to override the default template.
<p>
The following is a list of variables available in the template:
<p/>
<b>account.url</b><br/>
The URL to the account page.
<p/>
<b>account.text</b><br/>
The translated label for the account link, or the text that you supply to the macro.
<p/>

<b>NOTES:</b> You can also use the special case &#94;a(linkonly); to return only the URL to the account page and nothing more. Also, the .myAccountLink style sheet class is tied to this macro.
<p>


|,
		lastUpdated => 1112466919,
	},
};

1;
