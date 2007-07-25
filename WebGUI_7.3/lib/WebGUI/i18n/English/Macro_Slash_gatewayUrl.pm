package WebGUI::i18n::English::Macro_Slash_gatewayUrl;

our $I18N = {

	'macroName' => {
		message => q|Gateway URL|,
		lastUpdated => 1128919030,
	},

	'gateway url title' => {
		message => q|Gateway URL Macro|,
		lastUpdated => 1112466408,
	},

	'gateway url body' => {
		message => q|
<p><b>&#94;/; - System URL</b><br />
<b>&#94;/(/home/page); - System URL</b><br />
The URL to the gateway script (example: <i>/</i>).</p>

<p>The macro takes a single, optional argument; a URL.  The URL will be appended to
the end of the gateway URL.  This is mainly useful when you enable Prevent Proxy Caching
in the WebGUI settings.</p>

<p>&#94;/;home/page will break with Prevent Proxy Caching set because the URL that is made
will look like this: /?noCache=37,1127808995home/page.  By passing the URL directly to the
macro, &#94;/(home/page);, the special param for disabling caching will be placed on the
end, /home/page?noCache=37,1127808995.  

<p>This Macro may be nested inside other Macros.</p>
|,
		lastUpdated => 1169584181,
	},
};

1;
