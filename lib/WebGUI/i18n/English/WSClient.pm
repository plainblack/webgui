package WebGUI::i18n::English::WSClient;

our $I18N = {
	4 => q|SOAP Method/Call|,

	11 => q|Execute by default?|,

	8 => q|Preprocess macros on query?|,

	5 => q|SOAP Call Parameters|,

	35 => q|<b>Debug:</b> No template specified, using default.|,

	1 => q|Web Services Client|,

	61 => q|Web Services Client, Add/Edit|,

	3 => q|SOAP Proxy|,

	32 => q|<b>Debug:</b> Error: Could not connect to the SOAP server.|,

	2 => q|SOAP URI or WSDL|,

	9 => q|Debug?|,

	24 => q|SOAP return is type: |,

	31 => q|<b>Debug:</b> Error: There was a problem with the SOAP call.|,

	25 => q|There was a problem with the SOAP call: |,

	27 => q|Cache expires|,

	23 => q|The URI/WSDL specified is of an improper format.|,

	12 => q|Msg if no results|,

	21 => q|There were no results for this query.|,

	22 => q|Parse error on SOAP parameters.|,

	20 => q|Edit Web Services Client|,

	16 => q|HTTP Header Override|,

	72 => q|Web Services Client Template|,

	73 => q|This is the list of
template variables available for Web Services Client
templates.<p></p><b>results</b><br />This loop contains all the results from
the SOAP call.  Within the loop, you may access specific data elements by the
names set for them by the SOAP server (i.e. perhaps "localTime" for a time query).  In addition, there are a number of special template variables:

<blockquote><b>numResults</b><br />Number of rows found by the client, if an array was returned.<p></p>

<b>firstPage</b><br />Link to first page in a paginated set.<p></p>

<b>lastPage</b><br />Link to last page in a paginated set.<p></p>

<b>nextPage</b><br />Link to next page in a paginated set.<p></p>

<b>pageList</b><br />List of all pages in a paginated set.<p></p>

<b>previousPage</b><br />Link to previous page in a paginated set.<p></p>

<b>multiplePages</b><br />Boolean indicating multiple pages in a paginated set.<p></p>

<b>numberOfPages</b><br />Number of pages in a paginated set.<p></p>

<b>pageNumber</b><br />Current page number in a paginated set.</blockquote>|,

	15 => q|Decode utf8 data?|,

	14 => q|Pagination variable|,

	30 => q|<b>Debug:</b> Error: The URI/WSDL specified is of an improper format.|,

	13 => q|Pagination after|,

	26 => q|Could not connect to SOAP server.|,

	71 => q|Web Services Client allows a user to query data from any SOAP server to which they have access.  This wobject is in development status and should not be made accessible to un-trusted site administratores.<p></p>

<b>SOAP URI/WSDL</b><br>
From the SOAP::Lite manpage, \"URIs are just identifiers. They may look like URLs, but they are not guaranteed to point to anywhere and shouldn\'t be used as such pointers.  URIs assume to be unique within the space of all XML documents, so consider them as unique identifiers and nothing else.\"  If you specify a URI, you probably also need a proxy below.  Alternatively, you can specify a WSDL file in place of a URI.  This file refers to a real location at which a SOAP service description can be downloaded and used. For our purposes, the file must end in \".wsdl\" to be properly recognized.  If you use a WSDL file, you probably don\'t need to specify a proxy.<p></p>

<b>SOAP Proxy</b><br>
The SOAP proxy is the full name of the server and/or script that is listening for SOAP calls.  For example:
<code>http://mydomain.com/cgi-bin/soaplistener.pl</code>

<b>SOAP Method/Call</b><br>
The SOAP method is the name of the function to be invoked by the SOAP server. Include any extra parameters in the SOAP Call Parameters field below.<p></p>

<b>SOAP Call Parameters</b><br>
If your SOAP call requires any additional parameters, include them here as a valid perl hash, array or scalar.  For example: <code>\'userid\' => \'12\', companyid => \'^FormParam(\"companyid\");  Whether you need to use scalar, hash or array is entirely dependent on what your SOAP service expects as input.  Likewise, what you get back is entirely dependent on what the service deems to return.\'</code>.<p></p>

<b>Execute by default?</b><br>
Leave this set to yes unless your page is calling itself with additional parameters.  You will probably know if/when you need to turn off default execution.  To force execution when it has been disabled by default, pass a form variable \"targetWobjects\" specifying the name of the SOAP call to force execution.<p></p>

<b>Template</b><br>
Choose a layout for this SOAP client.<p></p>

<b>Preprocess macros on query?</b><br>
If you\'re using WebGUI macros in your query you\'ll want to check this box.<p></p>

<b>Pagination After</b><br>
How many rows should be displayed before splitting the results into separate pages? In other words, how many rows should be displayed per page?<p></p>

<b>Pagination Variable</b><br>
Because a SOAP call can return complex data structures, you\'ll need to specify which named variable is to be paginated.  If none is specified, no pagination will occur.<p></p>

<b>Debug?</b><br>
If you want to display debugging and error messages on the page, check this box.<p></p>

<b>Decode utf8?</b><br />
This option will only display if you have Data::Structure::Util installed.  SOAP calls return utf8 strings even if they may not have utf8 characters within them.  This converts utf8 characters to that there aren\'t collisions with any character sets specified in the page header.  Deocing is turned off by default, but try turning it on if you see goofy gibberish, especially with the display of copyright symbols and the like.<p></p>

<b>Cache</b><br />
By default, SOAP calls are cached uniquely for each user session.  By selecting "Global" call returns can be shared between users.<p></p>

<b>Cache expires</b><br>
Number of seconds a SOAP return will be cached.  Set to 1 to essentially skip caching.|,

	27=> q|Cache expires|,
	28 => q|Cache|,
	29 => q|Session|,
	19 => q|Global|,
};

1;
