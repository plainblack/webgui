package WebGUI::i18n::English::Asset_HttpProxy;

our $I18N = {
	'use ampersand help' => {
		message => q|By default we use semicolons to separate parameters in a URL. However, some older applications require the use of ampersands.|,
		context => q|asset property hover help|,
		lastUpdated => 1165517983
		},

	'use ampersand' => {
		message => q|Use ampersand as separator?|,
		context => q|asset property|,
		lastUpdated => 1165517982
		},

	'cache timeout description' => {
		message => q|How long should the proxy cache a page, so that if it's requested again, it won't have to refetch it?|,
		lastUpdated => 1047837230
	},

	'cache timeout' => {
		message => q|Cache Timeout|,
		lastUpdated => 1047837230
	},

	'6' => {
		message => q|Remove style?|,
		lastUpdated => 1047837230
	},

	'11' => {
		message => q|<p>The HTTP Proxy wobject is a very powerful tool. It enables you to embed external sites and applications into your site. For example, if you have a web mail system that you wish your staff could access through the intranet, then you could use the HTTP Proxy to accomplish that.
</p>

<p><i>Note: The <b>Search for</b> and <b>Stop at</b> strings are included in the content in the default template. You can change this by creating your own template.</i></p>
|,
		lastUpdated => 1146775758,
	},

	'http proxy template title' => {
		message => q|HTTP Proxy Template|,
		lastUpdated => 1109714266,
	},

	'header' => {
		message => q|The header from the proxied URL.|,
		lastUpdated => 1149393165,
	},

	'content' => {
		message => q|The content from the proxied URL.  If the <b>Search for</b> or <b>Stop at</b> properties are used, then the content will not contain either of those.|,
		lastUpdated => 1149393165,
	},

	'search.for' => {
		message => q|The string used to start the content search.|,
		lastUpdated => 1149393165,
	},

	'stop.at' => {
		message => q|The string used to stop the content search.|,
		lastUpdated => 1149393165,
	},

	'content.leading' => {
		message => q|Any text before the <b>Search For</b> string.|,
		lastUpdated => 1149393165,
	},

	'content.trailing' => {
		message => q|Any text after the <b>Stop At</b> string.|,
		lastUpdated => 1149393165,
	},


	'http proxy template body' => {
		message => q|<p>The following variables are available in templates for HTTP Proxies:</p>
|,
		lastUpdated => 1149393194,
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

	'no frame error message' => {
		message => q|<h1>HttpProxy: Can't display frames</h1>Try fetching it directly <a href='%s'>here.</a>|,
		lastUpdated => 1162959817,
		context => q|This entry is used to tell the user that the HttpProxy cannot display frames.  Please leeave the %s part of the string as is, since this entry is used in sprintf|,
	},

	'may not leave error message' => {
		message => q|<h1>You are not allowed to leave %s</h1>|,
		lastUpdated => 1163746361,
		context => q|This entry is used to tell the user that the HttpProxy cannot leave this URL.  Please leave the %s part of the string as is, since this entry is used in sprintf|,
	},

	'no recursion' => {
		message => q|<p>Error: HttpProxy can't recursively proxy its own content.</p>|,
		lastUpdated => 1162959817,
		context => q|This entry is used to tell the user that the HttpProxy cannot leave this URL.  Please leeave the %s part of the string as is, since this entry is used in sprintf|,
	},

	'http proxy asset template variables title' => {
		message => q|Http Proxy Asset Template Variables|,
		lastUpdated => 1168994434
	},

	'http proxy asset template variables body' => {
		message => q|Every asset provides a set of variables to most of its
templates based on the internal asset properties.  Some of these variables may
be useful, others may not.|,
		lastUpdated => 1168994436
	},

	'templateId' => {
		message => q|The ID of the template used to display the output of the Http Proxy.|,
		lastUpdated => 1168994434
	},

	'proxiedUrl' => {
		message => q|The URL to proxy.|,
		lastUpdated => 1168994434
	},

	'useAmpersand' => {
		message => q|A conditional which is true if the Http Proxy has been set to join parameters in the URL.|,
		lastUpdated => 1168994434
	},

	'timeout' => {
		message => q|The amount of time in seconds that WebGUI will wait for a connection before giving up on an external page.|,
		lastUpdated => 1168994613
	},

	'removeStyle' => {
		message => q|A conditional that will be true if the Http Proxy was configured to remove the stylesheet from the proxied page and replace it with the stylesheet from your site.|,
		lastUpdated => 1168994613
	},

	'cacheTimeout' => {
		message => q|The amount of time in seconds output from the Http Proxy will be cached.|,
		lastUpdated => 1168994613
	},

	'filterHtml' => {
		message => q|The level of HTML filtering that has been set for proxied content.|,
		lastUpdated => 1168994613
	},

	'followExternal' => {
		message => q|A conditional that is true if the Http Proxy is set up to allow it follow external links.|,
		lastUpdated => 1168994613
	},

	'rewriteUrls' => {
		message => q|A conditional that is true if the Http Proxy is set up to rewrite external links.|,
		lastUpdated => 1168994613
	},

	'followRedirect' => {
		message => q|A conditional that is true if the Http Proxy is set up to follow redirects.|,
		lastUpdated => 1168994613
	},

	'searchFor' => {
		message => q|A search string that will define the starting point for displayed content.|,
		lastUpdated => 1168994613
	},

	'stopAt' => {
		message => q|A search string that will define the stopping point for displayed content.|,
		lastUpdated => 1168994613
	},

	'cookieJarStorageId' => {
		message => q|The ID of the storage object where cookies will be stored.|,
		lastUpdated => 1168994613
	},

	'fetch page error' => {
		message => q|<b>Getting <a href='%s'>%s</a> failed</b><p><i>GET status line: %s</i>|,
		context => q|Translator note: the "%s" tokens in the message should not be translated.|,
		lastUpdated => 1168994613
	},

};

1;
