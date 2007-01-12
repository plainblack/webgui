package WebGUI::i18n::English::Macro_Execute;

our $I18N = {

    'macroName' => {
        message => q|Execute|,
        lastUpdated => 1128838230,
    },

    'execute error' => {
        message => q|SECURITY VIOLATION|,
        lastUpdated => 1134850023,
    },

    'execute title' => {
        message => q|Execute Macro|,
        lastUpdated => 1112466408,
    },

	'execute body' => {
		message => q|

<p><b>&#94;Execute();</b><br />
Allows a content manager or administrator to execute an external program. Takes the format of <b>&#94;Execute("/this/file.sh");</b>.
</p>
<p>This Macro may be nested inside other Macros if the text it returns does not contain commas or quotes.</p>
|,
		lastUpdated => 1168558923,
	},
};

1;
