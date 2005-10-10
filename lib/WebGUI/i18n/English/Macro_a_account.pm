package WebGUI::i18n::English::Macro_a_account;

our $I18N = {

    'account title' => {
        message => q|Account Macro|,
        lastUpdated => 1112466408,
    },

	'account body' => {
		message => q|

<b>&#94;a();</b><br>
<b>&#94;a([<i>link text</i>], [<i>template name</i>]);</b><br>
This macro creates a link to the current user's account information. The
Macro takes two optional arguments, the text that is displayed with the
link and a template from the Macro/a_account namespace to be used to
display the link and text.  If the <i>link text</i> is set to the word
"linkonly" then only the URL will be returned.<p>

The following is a list of variables available in the template:
<p/>
<b>account.url</b><br/>
The URL to the account page.

<p/>
<b>account.text</b><br/>
The translated label for the account link, or the text that you supply to the macro.
<p/>

<b>NOTES:</b> The .myAccountLink style sheet class is tied to this macro.
<p>

|,
		lastUpdated => 1112560585,
	},

	'46' => {
		message => q|My Account|,
		lastUpdated => 1031514049
	},

	'macroName' => {
		message => q|Account|,
		lastUpdated => 1128837060
	},
};

1;
