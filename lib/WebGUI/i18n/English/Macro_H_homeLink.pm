package WebGUI::i18n::English::Macro_H_homeLink;

our $I18N = {

	'macroName' => {
		message => q|Home Link|,
		lastUpdated => 1128838633,
	},

	'home link title' => {
		message => q|Home Link Macro|,
		lastUpdated => 1112466408,
	},

	'homeLink.url' => {
		message => q|The URL to the home page.|,
		lastUpdated => 1149217666,
	},

	'homeLink.text' => {
		message => q|The translated label for the link to the home page or the text that you supply to the macro.|,
		lastUpdated => 1149217666,
	},

	'home link body' => {
		message => q|
<p><b>&#94;H; or &#94;H(); - Home Link</b><br />A link to the home page of this site. In addition you can change the link text by creating a macro like this <b>&#94;H("Go Home");</b>.</p>
<p><b>NOTES:</b> You can also use the special case &#94;H(linkonly); to return only the URL to the home page and nothing more. Also, the .homeLink style sheet class is tied to this macro. And you can specify a second parameter that with the name of a template in the Macro/H_homeLink namespace that will override the default template. The following variables are available for use in the template:</p>
|,
		lastUpdated => 1149217683,
	},

	'47' => {
		message => q|Home|,
		lastUpdated => 1031514049
	},
};

1;
