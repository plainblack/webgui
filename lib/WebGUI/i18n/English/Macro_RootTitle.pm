package WebGUI::i18n::English::Macro_RootTitle;

our $I18N = {

	'macroName' => {
		message => q|Root Title|,
		lastUpdated => 1128918994,
	},

	'root title title' => {
		message => q|Root Title Macro|,
		lastUpdated => 1112466408,
	},

	'root title body' => {
		message => q|
<p><b>&#94;RootTitle;</b><br />
Returns the title of the root of the current page. For instance, the main root in WebGUI is the "Home" page. Many advanced sites have many roots and thus need a way to display to the user which root they are in.
</p>
<p>If the macro is called outside of an asset, or if the root can't be found, then
the macro returns an empty string</p>
<p>This Macro may be nested inside other Macros if the title does not contain commas or quotes.</p>
|,
		lastUpdated => 1168622930,
	},
};

1;
