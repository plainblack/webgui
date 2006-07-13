package WebGUI::i18n::English::Macro_GroupText;

our $I18N = {

	'macroName' => {
		message => q|Group Text|,
		lastUpdated => 1128838520,
	},

	'group not found' => {
		message => q|Group %s was not found|,
		lastUpdated => 1112466408,
		context => q|Error message when a group is not found during a by-name lookup of groups.|,
	},

	'group text title' => {
		message => q|Group Text Macro|,
		lastUpdated => 1112466408,
	},

	'group text body' => {
		message => q|
<p><b>&#94;GroupText();</b><br />
Displays a small text message to the user if they belong to the specified group. And you can specify an alternate message to those who are not in the group.
</p>
<p><i>Example:</i> &#94;GroupText("Visitors","You need an account to do anything cool on this site!","We value our registered users!");
</p>
|,
		lastUpdated => 1146686292,
	},
};

1;
