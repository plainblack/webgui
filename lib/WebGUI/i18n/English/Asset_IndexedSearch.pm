package WebGUI::i18n::English::Asset_IndexedSearch;

our $I18N = {
	'11' => {
		message => q|Paginate after|,
		lastUpdated => 1066252409
	},

	'21' => {
		message => q|Content|,
		lastUpdated => 1066765681
	},

	'7' => {
		message => q|Only results created by|,
		lastUpdated => 1066252303
	},

	'26' => {
		message => q|Search, Add/Edit|,
		lastUpdated => 1067346336
	},

	'assetName' => {
		message => q|Search|,
		lastUpdated => 1066593262
	},

	'2' => {
		message => q|No index created. The scheduler must run and create the index first.|,
		lastUpdated => 1066252099
	},

	'22' => {
		message => q|Profile|,
		lastUpdated => 1066765844
	},

	'1' => {
		message => q|Table Search_docInfo can't be opened.|,
		lastUpdated => 1066252055
	},

	'18' => {
		message => q|Any namespace|,
		lastUpdated => 1066593420
	},

	'23' => {
		message => q|Any Content Type|,
		lastUpdated => 1066766053
	},

	'16' => {
		message => q|Search|,
		lastUpdated => 1066565087
	},

	'13' => {
		message => q|Highlight results ?|,
		lastUpdated => 1066252498
	},

	'29' => {
		message => q|Search template|,
		lastUpdated => 1070202588
	},

	'27' => {
		message => q|
<P>The Search adds advanced search capabilities to your WebGUI site. </P>
<P><STRONG>Index to use</STRONG><BR>
The Search uses an index to retrieve it's 
results from. Indexes are created with the scheduler. You can create more then one index. Choose here which index to use.</P>
<P><STRONG>Search through</STRONG><BR>
By default all pages are searched. You can 
limit the search to certain page roots. Multiple choices are allowed.</P>
<P><STRONG>Only results created by</STRONG><BR>
You can limit the results to 
items created by certain users. By default items from any user are returned.</P>
<P><STRONG>Only results in namespace</STRONG><BR>
By default all namespaces are 
searched. You can limit the search to certain namespaces. An example of usage is 
to search only in products.</P>
<P><STRONG>Only results in language</STRONG><BR>
If you have a multi-lingual 
site, you can use this option to limit the search results to a certain 
language.</P>
<P><STRONG>Only results of type</STRONG><BR>
You can limit the search to certain 
types of content.</P>
<BLOCKQUOTE dir=ltr style="MARGIN-RIGHT: 0px">
<P align=left><EM>Discussion:</EM> Messages on the forums, discussions on 
articles or USS.<BR><EM>Help:</EM> Content in the online WebGUI help 
system<BR><EM>Page:</EM><STRONG> </STRONG>Page title and 
synopsis<BR><EM>Profile:</EM> User Profiles<BR><EM>Wobject: </EM>Wobject Title 
and Description<BR><EM>Wobject details: </EM>All other wobject data. For example 
FAQ question, Calendar item, etc.</P></BLOCKQUOTE>
<P dir=ltr align=left><b>Force users to use selected roots</b><br>Enabling this option will cause the search to be over all of the selected page roots regardless of what the user entered via the search form.</b></p> 
<P dir=ltr align=left><STRONG>Template<BR></STRONG>Select a template to layout 
your Search. The different templates have different functionality.</P>
<P dir=ltr align=left><STRONG>Paginate after<BR></STRONG>The number of results 
you'd like to display on a page.</P>
<P dir=ltr align=left><STRONG>Context preview length<BR></STRONG>The maximum 
number of characters in each of the context sections. Default is 130 characters. 
A negative length gives the complete body, while a preview length of null gives 
no preview.</P>
<P dir=ltr align=left><STRONG>Highlight results ?<BR></STRONG>If you want to 
highlight the search results in the preview you'll want to check this box.</P>
<P dir=ltr align=left><STRONG>Highlight color n<BR></STRONG>The colors that are 
used to highlight the corresponding words in the query.</P>|,
		lastUpdated => 1101773588
	},

	'25' => {
		message => q|Any user|,
		lastUpdated => 1066766053
	},

	'6' => {
		message => q|Search through|,
		lastUpdated => 1066252264
	},

	'28' => {
		message => q|
<P>This is the list of template variables available for 
search templates:</P>
<P><STRONG>query</STRONG><BR>
Contains the value of the <EM>query</EM> form 
variable. <BR>The <EM>allWords</EM>, <EM>atLeastOne</EM>, <EM>exactPhrase</EM> 
and <EM>without</EM> values are appended to this variable.</P>
<P><STRONG>queryHighlighted</STRONG><BR>
Same as <STRONG>query</STRONG> but highlighted.</P>
<P><STRONG>allWords</STRONG><BR>
Contains the value of the <EM>allWords</EM> form variable.</P>
<P><STRONG>atLeastOne</STRONG><BR>
Contains the value of the <EM>atLeastOne</EM> form variable.</P>
<P><STRONG>exactPhrase</STRONG><BR>
Contains the value of the <EM>exactPhrase</EM> form variable.</P>
<P><STRONG>without</STRONG><BR>
Contains the value of the <EM>without</EM> form variable.</P>
<P><STRONG>duration</STRONG><BR>
The duration of the search process in seconds.</P>
<P><STRONG>numberOfResults</STRONG><BR>
The number of results.</P>
<P><STRONG>startNr</STRONG><BR>
The number of the first search result on the page.</P>
<P><STRONG>endNr</STRONG><BR>
The number of the last search result on the page.</P>
<P><STRONG>submit</STRONG><BR>
A form button with the word "Search" printed on it.</P>
<P><STRONG>wid</STRONG><BR>
The wobject Id of this wobject.</P>
<P><STRONG>resultsLoop</STRONG><BR>
A loop containing the search results. Inside the loop the following template variables are available:</P>
<BLOCKQUOTE dir=ltr style="MARGIN-RIGHT: 0px">
<P><STRONG>username</STRONG><BR>
The username of the person that created this search result.</P>
<P><STRONG>ownerId</STRONG><BR>
The Id of the person that created this search result.</P>
<P><STRONG>userProfile</STRONG><BR>
An url to the profile of the creator of this search result.</P>
<P><STRONG>header</STRONG><BR>The title of the search result. (This can be the 
subject of a message, the question of a FAQ, the title of an Article, etc)</P>
<P><STRONG>body</STRONG><BR>A preview of the content of the search result.</P>
<P><STRONG>namespace</STRONG><BR>The namespace in which this search result 
resides.</P>
<P><STRONG>location</STRONG><BR>The URL of this search result.</P>
<P><STRONG>crumbtrail</STRONG><BR>A crumbtrail to this search result.</P>
<P><STRONG>contentType</STRONG><BR>The type of this search 
result.</P></BLOCKQUOTE>
<P dir=ltr>The loops <STRONG>contentTypes</STRONG>, 
<STRONG>contentTypesSimple</STRONG>, <STRONG>languages</STRONG>, 
<STRONG>namespaces</STRONG> and <STRONG>users</STRONG> all look the same. 
They can be used to create a select list, radio list or check list so users can 
refine their search.</P>
<P dir=ltr>This template variables are available inside the loops:</P>
<BLOCKQUOTE dir=ltr style="MARGIN-RIGHT: 0px">
<P dir=ltr><STRONG>name</STRONG><BR>The (possibly internationalized) name of the 
option.<BR><BR><STRONG>value<BR></STRONG>The value of the 
option.<BR><BR><STRONG>selected<BR></STRONG>A conditional indicating whether 
this option is selected or not.</P></BLOCKQUOTE>
<P dir=ltr><B>searchRoots</B><BR>A loop containing the available roots to search through.
<BLOCKQUOTE dir=ltr><P dir=ltr>
<b>title</b><br>The title of the pageroot.<br><br>
<b>urlizedTitle</b><br>The urlizedTitle of the pageroot.<br><br>
<b>menuTitle</b><br>The menu title of the pageroot.<br><br>
<b>value</b><br>The value you should pass as a form param.<br><br>
<b>checked</b><br>True if this pageroot is selected.<br><br>
</p></blockquote>
<p dir=ltr><b>rootPage.<i>urlizedTitle</i>.id</b><br>
This is a direct link to the value property of the rootpage identified with <i>urlizedTitle</i> that is also given by the value property of the <B>searchRoots</B> loop.</p>
<p dir=ltr><b>rootPage.<i>urlizedTitle</i>.checked</b><br>
This is a direct link to the checked property of the rootpage identified with <i>urlizedTitle</i> that is also given by the checked property of the <B>searchRoots</B> loop.</p>
<P><B>firstPage</B><BR>A link to the first page in the paginator. 
<P><B>lastPage</B><BR>A link to the last page in the paginator. 
<P><B>nextPage</B><BR>A link to the next page forward in the paginator. 
<P><B>previousPage</B><BR>A link to the next page backward in the paginator. 
<P><B>pageList</B><BR>A list of links to all the pages in the paginator. 
<P><B>multiplePages</B><BR>A conditional indicating whether there is more than 
one page in the paginator. 
<P><B>isFirstPage</B><BR>A conditional indicating whether the visitor is viewing 
the first page. 
<P><B>isLastPage</B><BR>A conditional indicating whether the visitor is viewing 
the last page.</P>|,
		lastUpdated => 1101773812
	},

	'3' => {
		message => q|Please refer to the documentation for more info.|,
		lastUpdated => 1066252166
	},

	'9' => {
		message => q|Only results in language|,
		lastUpdated => 1066252363
	},

	'12' => {
		message => q|Context preview length|,
		lastUpdated => 1066252463
	},

	'15' => {
		message => q|All pages|,
		lastUpdated => 1066253116
	},

	'14' => {
		message => q|Highlight color|,
		lastUpdated => 1066252536
	},

	'20' => {
		message => q|Wobject details|,
		lastUpdated => 1066765556
	},

	'8' => {
		message => q|Only results in namespace|,
		lastUpdated => 1066252344
	},

	'4' => {
		message => q|This page|,
		lastUpdated => 1066252218
	},

	'24' => {
		message => q|Any language|,
		lastUpdated => 1066766053
	},

	'force search roots' => {
		message => q|Force users to use the selected roots|,
		lastUpdated => 1133844716
	},

	'19' => {
		message => q|Wobject|,
		lastUpdated => 1066765495
	},

	'10' => {
		message => q|Only results of type|,
		lastUpdated => 1066252387
	},

	'5' => {
		message => q|Index to use|,
		lastUpdated => 1066252241
	},

	'page' => {
		message => q|Page|,
		lastUpdated => 1109789907,
	},

	'discussion' => {
		message => q|Discussion|,
		lastUpdated => 1109789911,
	},

};

1;
