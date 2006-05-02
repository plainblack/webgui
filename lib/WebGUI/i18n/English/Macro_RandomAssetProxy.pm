package WebGUI::i18n::English::Macro_RandomAssetProxy;

our $I18N = {

	'macroName' => {
		message => q|Random Asset Proxy|,
		lastUpdated => 1128918962,
	},

	'random asset proxy title' => {
		message => q|Random Asset Proxy Macro|,
		lastUpdated => 1112315917,
	},

	'random asset proxy body' => {
		message => q|
<P><b>&#94;RandomAssetProxy</b>();<br />
<b>&#94;RandomAssetProxy</b>(<i>Asset URL</i>);<br />
This macro works similarly to the &#94;<b>AssetProxy</b>(); macro except instead of displaying the
Asset, it picks a random Asset from the descendents of the Asset whose URL is supplied as the
argument.
		|,
		lastUpdated => 1135101114,
	},

	'childless' => {
		message => q|Asset has no children.|,
		lastUpdated => 1135101140,
	},

	'invalid url' => {
		message => q|Invalid asset URL.|,
		lastUpdated => 1135101140,
	},

};

1;
