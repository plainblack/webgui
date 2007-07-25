package WebGUI::i18n::English::Asset_WSClient;

our $I18N = {
	'35' => {
		message => q|<b>Debug:</b> No template specified, using default.|,
		lastUpdated => 1033575504
	},

	'32' => {
		message => q|<b>Debug:</b> Error: Could not connect to the SOAP server.|,
		lastUpdated => 1033575504
	},

	'11' => {
		message => q|Execute by default?|,
		lastUpdated => 1033575504
	},

	'21' => {
		message => q|There were no results for this query.|,
		lastUpdated => 1033575504
	},

	'71' => {
		message => q|<p>A Web Services Client allows a user to query data from any SOAP server to which they have access.  This wobject is in development status and should not be made accessible to untrusted site administrators.</p>

<p>A few tricks...</p>
<div>
<ul>
<li>If you want to process a SOAP call (for example, one that sets or updates a value on the remote SOAP server) but then redirect to a completely different page, add a form input parameter <code>redirectURL</code>.  The value of redirectURL can be any valid URI understood by a web browser.</li>
<li>To trigger a SOAP wobject that has "Execute by default?" turned off, pass a form input param of targetWobjects=<i>call</i> where call is the SOAP method.</li>
<li>To completely ignore a SOAP wobject, including any possible cached returns, pass a form input param of disableWobjects=<i>call</i> where call is the SOAP method.</li></ul></div>
|,
		lastUpdated => 1146800732,
	},

        '72 description' => {
                message => q|Select a template to display the output of the Web Service Client Asset.|,
                lastUpdated => 1119981444,
        },

        '8 description' => {
                message => q|<p>If you're using WebGUI macros in your query you'll want to check this box.</p>|,
                lastUpdated => 1119981444,
        },

        '13 description' => {
                message => q|<p>How many rows should be displayed before splitting the results into separate pages? In other words, how many rows should be displayed per page?</p>|,
                lastUpdated => 1119981444,
        },

        '14 description' => {
                message => q|<p>Because a SOAP call can return complex data structures, you'll need to specify which named variable is to be paginated.  If none is specified, no pagination will occur.</p>|,
                lastUpdated => 1119981444,
        },

        '2 description' => {
                message => q|<p>From the SOAP::Lite man page, "URIs are just identifiers. They may look like URLs, but they are not guaranteed to point to anywhere and shouldn't be used as such pointers.  URIs assume to be unique within the space of all XML documents, so consider them as unique identifiers and nothing else."  If you specify a URI, you probably also need a proxy below.  Alternatively, you can specify a WSDL file in place of a URI.  This file refers to a real location at which a SOAP service description can be downloaded and used. For our purposes, the file must end in ".wsdl" to be properly recognized.  If you use a WSDL file, you probably don't need to specify a proxy.</p>|,
                lastUpdated => 1119981444,
        },

        '3 description' => {
                message => q|<p>The SOAP proxy is the full name of the server and/or script that is listening for SOAP calls.  For example:
<code>http://mydomain.com/cgi-bin/soaplistener.pl</code></p>|,
                lastUpdated => 1119981444,
        },

        '4 description' => {
                message => q|<p>The SOAP method is the name of the function to be invoked by the SOAP server. Include any extra parameters in the SOAP Call Parameters field below.</p>|,
                lastUpdated => 1119981444,
        },

        '5 description' => {
                message => q|<p>If your SOAP call requires any additional parameters, include them here as a valid Perl hash, array or scalar.  For example: <code>'userid' => '12',<br />companyid => '&#94;FormParam("companyid");'  Whether you need to use scalar, hash or array is entirely dependent on what your SOAP service expects as input.  Likewise, what you get back is entirely dependent on what the service deems to return.</code>.</p>|,
                lastUpdated => 1167970155,
        },

        '16 description' => {
                message => q|If <i>soapHttpHeaderOverride</i> is set in the WebGUI configuration file, then this
property allows you to override the default MIME type for this page.|,
                lastUpdated => 1119981444,
        },

        '11 description' => {
                message => q|<p>Leave this set to yes unless your page is calling itself with additional parameters.  You will probably know if/when you need to turn off default execution.  To force execution when it has been disabled by default, pass a form variable "targetWobjects" specifying the name of the SOAP call to force execution.  If current cached results already exist for this wobject they will be returned regardless.  If you don't want <i>any</i> results returned no matter what, see the Tricks section below.</p>|,
                lastUpdated => 1119981444,
        },

        '9 description' => {
                message => q|<p>If you want to display debugging and error messages on the page, check this box.</p>|,
                lastUpdated => 1119981444,
        },

        '15 description' => {
                message => q|<p>This option will only display if you have Data::Structure::Util installed.  SOAP calls return UTF8 strings even if they may not have UTF8 characters within them.  This converts UTF8 characters so that there aren't collisions with any character sets specified in the page header.  Decoding is turned off by default, but try turning it on if you see goofy gibberish, especially with the display of copyright symbols and the like.</p>|,
                lastUpdated => 1167970807,
        },

        '28 description' => {
                message => q|<p>By default, SOAP calls are cached uniquely for each user session.  By selecting "Global" call returns can be shared between users.</p>|,
                lastUpdated => 1119981444,
        },

        '27 description' => {
                message => q|<p>The number of seconds returned SOAP results will be cached.  Set to 1 to essentially skip caching.</p>|,
                lastUpdated => 1167970680,
        },

	'26' => {
		message => q|Could not connect to SOAP server.|,
		lastUpdated => 1055349311
	},

	'2' => {
		message => q|SOAP URI or WSDL|,
		lastUpdated => 1033575504
	},

	'22' => {
		message => q|Parse error on SOAP parameters.|,
		lastUpdated => 1055348597
	},

	'assetName' => {
		message => q|Web Services Client|,
		lastUpdated => 1128834404
	},

	'72' => {
		message => q|Web Services Client Template|,
		lastUpdated => 1072812143
	},

	'30' => {
		message => q|<b>Debug:</b> Error: The URI/WSDL specified is of an improper format.|,
		lastUpdated => 1033575504
	},

	'13' => {
		message => q|Pagination after|,
		lastUpdated => 1072810296
	},

	'16' => {
		message => q|HTTP Header Override|,
		lastUpdated => 1033575504
	},

	'23' => {
		message => q|The URI/WSDL specified is of an improper format.|,
		lastUpdated => 1055348955
	},

	'29' => {
		message => q|Session|,
		lastUpdated => 1088120988
	},

	'25' => {
		message => q|There was a problem with the SOAP call: |,
		lastUpdated => 1055349116
	},

	'27' => {
		message => q|Cache expires|,
		lastUpdated => 1055349028
	},

	'28' => {
		message => q|Cache|,
		lastUpdated => 1088972047
	},

	'3' => {
		message => q|SOAP Proxy|,
		lastUpdated => 1033575504
	},

	'61' => {
		message => q|Web Services Client, Add/Edit|,
		lastUpdated => 1033575504
	},

	'9' => {
		message => q|Debug?|,
		lastUpdated => 1033575504
	},

	'12' => {
		message => q|Msg if no results|,
		lastUpdated => 1033575504
	},

	'14' => {
		message => q|Pagination variable|,
		lastUpdated => 1072810296
	},

	'15' => {
		message => q|Decode UTF8 data?|,
		lastUpdated => 1101795689,
	},

	'20' => {
		message => q|Edit Web Services Client|,
		lastUpdated => 1033575504
	},

	'8' => {
		message => q|Preprocess macros on query?|,
		lastUpdated => 1033575504
	},

	'4' => {
		message => q|SOAP Method/Call|,
		lastUpdated => 1033575504
	},

	'disableWobject' => {
		message => q|If the page was called with a form param of disableWobjects, this variable will
be set to true.|,
		lastUpdated => 1149568071,
	},

	'results' => {
		message => q|This loop contains all the results from
the SOAP call.  Within the loop, you may access specific data elements by the
names set for them by the SOAP server (i.e. perhaps "localTime" for a time query).|,
		lastUpdated => 1167971387,
	},

	'numResults' => {
		message => q|Number of rows found by the client, if an array was returned.|,
		lastUpdated => 1149568071,
	},

	'73' => {
		message => q|<p>This is the list of template variables available for Web Services Client templates.</p>
|,
		lastUpdated => 1149568096
	},

	'24' => {
		message => q|SOAP return is type: |,
		lastUpdated => 1055349028
	},

	'19' => {
		message => q|Global|,
		lastUpdated => 1088972047
	},

	'31' => {
		message => q|<b>Debug:</b> Error: There was a problem with the SOAP call.|,
		lastUpdated => 1033575504
	},

	'5' => {
		message => q|SOAP Call Parameters|,
		lastUpdated => 1033575504
	},

	'soapError' => {
		message => q|This template variable will contain any errors from trying to fetch the SOAP content.|,
		lastUpdated => 1167969800
	},

	'templateId' => {
		message => q|The ID of the template used to display this Asset.|,
		lastUpdated => 1167969800
	},

	'callMethod' => {
		message => q|The name of the function to be invoked by the SOAP server.|,
		lastUpdated => 1167969800
	},

	'debugMode' => {
		message => q|A boolean indicating whether or not debug and error messages should be displayed.|,
		lastUpdated => 1167969800
	},

	'execute_by_default' => {
		message => q|A boolean indicating whether or not the WSClient was set to execute by default.|,
		lastUpdated => 1167969800
	},

	'paginateAfter' => {
		message => q|The number of rows of SOAP results to paginate.|,
		lastUpdated => 1167969800
	},

	'paginateVar' => {
		message => q|Determins which variable in the SOAP data returned by the will be used for pagination.|,
		lastUpdated => 1167969800
	},

	'params' => {
		message => q|Any user entered parameters, as perl code.|,
		lastUpdated => 1167969800
	},

	'preprocessMacros' => {
		message => q|If set to true, then macros in the params and callMethod will be evaluated.|,
		lastUpdated => 1167969800
	},

	'proxy' => {
		message => q|The full name of the SOAP server and/or script.|,
		lastUpdated => 1167969800
	},

	'uri' => {
		message => q|The URI of the SOAP server.|,
		lastUpdated => 1167969800
	},

	'decodeUtf8' => {
		message => q|Whether or not SOAP UTF8 results should be converted to the encoding used by the page.|,
		lastUpdated => 1167969800
	},

	'httpHeader' => {
		message => q|An alternate HTTP header that may be used to override the default MIME type for this page.|,
		lastUpdated => 1167969800
	},

	'cacheTTL' => {
		message => q|The number of seconds to cache SOAP results.|,
		lastUpdated => 1167969800
	},

	'sharedCache' => {
		message => q|A boolean indicating whether or not cached SOAP results will be shared between users or whether each user will have their own individual cache.|,
		lastUpdated => 1167970639
	},

	'ws client asset template variables title' => {
		message => q|Web Services Client Asset Template Variables|,
		lastUpdated => 1164841146
	},

	'ws client asset template variables body' => {
		message => q|Every asset provides a set of variables to most of its
templates based on the internal asset properties.  Some of these variables may
be useful, others may not.|,
		lastUpdated => 1164841201
	},

};

1;
