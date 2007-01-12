package WebGUI::i18n::English::Macro_AdminText;

our $I18N = {

    'macroName' => {
        message => q|Admin Text|,
        lastUpdated => 1128837612,
    },

    'admin text title' => {
        message => q|Admin Text Macro|,
        lastUpdated => 1112466408,
    },

	'admin text body' => {
		message => q|
<p><b>&#94;AdminText(<i>text message</i>);</b><br />
Displays a small text message to a user who is in admin mode. Example: &#94;AdminText("You are in admin mode!");
</p>
<p>This Macro may be nested inside other Macros if the text does not contain commas or quotes.</p>
|,
		lastUpdated => 1168558334,
	},
};

1;
