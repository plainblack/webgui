package WebGUI::i18n::English::Macro_a_account;

our $I18N = {

	'account title' => {
		message => q|Account Macro|,
		lastUpdated => 1112466408,
	},

	'account.url' => {
		message => q|The URL to the account page.|,
		lastUpdated => 1149177662,
	},

	'account.text' => {
		message => q|The translated label for the account link, or the text that you supply to the macro.|,
		lastUpdated => 1149177662,
	},

	'account body' => {
		message => q|

<p><b>&#94;a();</b><br />
<b>&#94;a([<i>link text</i>], [<i>template name</i>]);</b><br />
This macro creates a link to the current user's account information. The
Macro takes two optional arguments, the text that is displayed with the
link and a template from the Macro/a_account namespace to be used to
display the link and text.  If the <i>link text</i> is set to the word
"linkonly" then only the URL will be returned.</p>

<p><b>NOTES:</b><br />
<ul>
<li>The .myAccountLink style sheet class is tied to this macro.</li>
<li>This Macro may only be nested inside other Macros if the "linkonly" option is used.</li>
</p>

<p>The following is a list of variables available in the template:</p>

|,
		lastUpdated => 1168558260,
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
