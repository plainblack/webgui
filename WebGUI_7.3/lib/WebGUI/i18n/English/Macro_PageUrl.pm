package WebGUI::i18n::English::Macro_PageUrl;

our $I18N = {

	'macroName' => {
		message => q|Page URL|,
		lastUpdated => 1128839374,
	},

	'page url title' => {
		message => q|Page URL Macro|,
		lastUpdated => 1112466408,
	},

	'page url body' => {
		message => q|
<p><b>&#94;PageUrl;</b><br />
<b>&#94;PageUrl(/sub/page);</b><br />
The URL to the current page (example: <i>/index.pl/pagename</i>). 
</p>

<p>The macro takes a single, optional argument; a URL.  The URL will be appended to
the end of the page's URL.  This is mainly useful when you enable Prevent Proxy Caching
in the WebGUI settings.</p>

<p>This Macro may be nested inside other Macros.</p>
|,
		lastUpdated => 1169588703,
	},
};

1;
