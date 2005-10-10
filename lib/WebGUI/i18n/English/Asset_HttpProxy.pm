package WebGUI::i18n::English::Asset_HttpProxy;

our $I18N = {
	'6' => {
		message => q|Remove style?|,
		lastUpdated => 1047837230
	},

	'11' => {
		message => q|The HTTP Proxy wobject is a very powerful tool. It enables you to embed external sites and applications into your site. For example, if you have a web mail system that you wish your staff could access through the intranet, then you could use the HTTP Proxy to accomplish that.
<p>

<i>Note: The <b>Search for</b> and <b>Stop at</b> strings are included in the content in the default template. You can change this by creating your own template.</i>
<p>
|,
		lastUpdated => 1119244182,
	},

	'http proxy template title' => {
		message => q|HTTP Proxy Template|,
		lastUpdated => 1109714266,
	},

	'http proxy template body' => {
		message => q|<p>The following variables are available in templates for HTTP Proxies:</p>
<p><b>header</b><br>
The header from the proxied URL.

<p><b>content</b><br>
The content from the proxied URL.  If the <b>Search for</b> or <b>Stop at</b> properties are used, then the content will not contain either of those.

<p><b>search.for</b><br>
The string used to start the content search.

<p><b>stop.at</b><br>
The string used to stop the content search.

<p><b>content.leading</b><br>
Any text before the <b>Search For</b> string.

<p><b>content.trailing</b><br>
Any text after the <b>Stop At</b> string.

</p>
|,
		lastUpdated => 1109714266,
	},

        '1 description' => {
                message => q|The starting URL for the proxy.|,
                lastUpdated => 1119244033,
        },

        '5 description' => {
                message => q|If you proxy a site like Yahoo! that links to other domains, do you wish to allow the user to follow the links to those other domains, or should the proxy stop them as they try to leave the original site you specified?|,
                lastUpdated => 1119244033,
        },

        '8 description' => {
                message => q|Sometimes the URL to a page is actually a redirection to another page. Do you wish to follow those redirections when they occur?|,
                lastUpdated => 1119244033,
        },

        '12 description' => {
                message => q|Switch this to No if you want to deep link an external page.|,
                lastUpdated => 1119244033,
        },

        'http proxy template title description' => {
                message => q|Use this select list to choose a template to show the output of the proxied content.|,
                lastUpdated => 1119244033,
        },

        '6 description' => {
                message => q|Do you wish to remove the stylesheet from the proxied content in favor of the stylesheet from your site?|,
                lastUpdated => 1119244033,
        },

        '4 description' => {
                message => q|The amount of time (in seconds) that WebGUI should wait for a connection before giving up on an external page.|,
                lastUpdated => 1119244033,
        },

        '13 description' => {
                message => q|A search string used as starting point. Use this when you want to display only a part of the proxied content. Content before this point is not displayed|,
                lastUpdated => 1119244033,
        },

        '14 description' => {
                message => q|A search string used as ending point. Content after this point is not displayed.|,
                lastUpdated => 1119244033,
        },

	'assetName' => {
		message => q|HTTP Proxy|,
		lastUpdated => 1128831337
	},

	'9' => {
		message => q|Cookie Jar|,
		lastUpdated => 1047835842
	},

	'12' => {
		message => q|Rewrite URLs ?|,
		lastUpdated => 1101773211
	},

	'2' => {
		message => q|Edit HTTP Proxy|,
		lastUpdated => 1031510000
	},

	'14' => {
		message => q|Stop at|,
		lastUpdated => 1060433963
	},

	'8' => {
		message => q|Follow redirects?|,
		lastUpdated => 1047837255
	},

	'1' => {
		message => q|URL to proxy|,
		lastUpdated => 1031510000
	},

	'4' => {
		message => q|Timeout|,
		lastUpdated => 1047837283
	},

	'13' => {
		message => q|Search for|,
		lastUpdated => 1060433963
	},

	'10' => {
		message => q|HTTP Proxy, Add/Edit|,
		lastUpdated => 1047858432
	},

	'5' => {
		message => q|Allow proxying of other domains?|,
		lastUpdated => 1047835817
	},

};

1;
