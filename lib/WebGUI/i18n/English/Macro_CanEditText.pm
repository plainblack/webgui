package WebGUI::i18n::English::Macro_CanEditText;

our $I18N = {

    'macroName' => {
        message => q|Can Edit Text|,
        lastUpdated => 1128837964,
    },

    'can edit text title' => {
        message => q|Can Edit Text Macro|,
        lastUpdated => 1112466408,
    },

	'can edit text body' => {
		message => q|

<b>&#94;CanEditText(<i>text message</i>);</b><br />
Display a message to a user that can edit the current Asset.
<p>
<i>Example:</i><br />
&#94;CanEditText("You may edit this Asset");<br />
&#94;CanEditText(&#94;AdminToggle;);
<p>
Do not use this Macro outside of an Asset as it will have unpredictable
results.
|,
		lastUpdated => 1134773763,
	},
};

1;
