package WebGUI::i18n::English::IndexedSearch;

our $I18N = {
	29 => q|Search template|,

	28 => q|
<P>This is the list of template variables available for 
search&nbsp;templates:</P>
<P><STRONG>query<BR></STRONG>Contains the value of the <EM>query</EM> form 
variable. <BR>The <EM>allWords</EM>, <EM>atLeastOne</EM>, <EM>exactPhrase</EM> 
and <EM>without</EM> values are appended to this variable.</P>
<P><STRONG>queryHighlighted<BR></STRONG>Same as <STRONG>query</STRONG> but 
highlighted.</P>
<P><STRONG>allWords<BR></STRONG>Contains the value of the <EM>allWords</EM> form 
variable.</P>
<P><STRONG>atLeastOne<BR></STRONG>Contains the value of the <EM>atLeastOne</EM> 
form variable.</P>
<P><STRONG>exactPhrase<BR></STRONG>Contains the value of the 
<EM>exactPhrase</EM> form variable.</P>
<P><STRONG>without<BR></STRONG>Contains the value of the <EM>without </EM>form 
variable.</P>
<P><STRONG>duration<BR></STRONG>The duration of the search process in seconds. 
</P>
<P><STRONG>numberOfResults<BR></STRONG>The number of results. </P>
<P><STRONG>startNr<BR></STRONG>The number of the first search result on the 
page.</P>
<P><STRONG>endNr<BR></STRONG>The number of the last search result on the 
page.</P>
<P><STRONG>submit<BR></STRONG>A form button with the word "Search" printed on 
it. </P>
<P><STRONG>wid</STRONG><BR>The wobject Id of this wobject.</P>
<P><STRONG>resultsLoop</STRONG><BR>A loop containing the search results. Inside 
the loop the following template variables are available:</P>
<BLOCKQUOTE dir=ltr style="MARGIN-RIGHT: 0px">
<P><STRONG>username<BR></STRONG>The username of the person that created this 
search result.</P>
<P><STRONG>ownerId<BR></STRONG>The Id of the person that created this search 
result.</P>
<P><STRONG>userProfile<BR></STRONG>An url to the profile of the creator of this 
search result.</P>
<P><STRONG>header<BR></STRONG>The title of the search result. (This can be the 
subject of a message, the question of a FAQ, the title of an Article, etc)</P>
<P><STRONG>body<BR></STRONG>A preview of the content of the search result.</P>
<P><STRONG>namespace<BR></STRONG>The namespace in which this search result 
resides.</P>
<P><STRONG>location<BR></STRONG>The URL of this search result.</P>
<P><STRONG>crumbtrail<BR></STRONG>A crumbtrail to this search result.</P>
<P><STRONG>contentType<BR></STRONG>The type of this search 
result.</P></BLOCKQUOTE>
<P dir=ltr>The loops <STRONG>contentTypes</STRONG>, 
<STRONG>contentTypesSimple</STRONG>, <STRONG>languages</STRONG>, 
<STRONG>namespaces</STRONG> and&nbsp;<STRONG>users </STRONG>all look the same. 
They can be used to create a select list, radio list or check list so users can 
refine their search.</P>
<P dir=ltr>This tempate variables are available inside the loops:</P>
<BLOCKQUOTE dir=ltr style="MARGIN-RIGHT: 0px">
<P dir=ltr><STRONG>name<BR></STRONG>The (possibly internationalized) name of the 
option.<BR><BR><STRONG>value<BR></STRONG>The value of the 
option.<BR><BR><STRONG>selected<BR></STRONG>A conditional indicating whether 
this option is selected or not.</P></BLOCKQUOTE>
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

	2 => q|No index created. The scheduler must run and create the index first.|,

	3 => q|Please refer to the documentation for more info.|,

	4 => q|This page|,

	5 => q|Index to use|,

	6 => q|Search through|,

	1 => q|Table Search_docInfo can't be opened.|,

	14 => q|Highlight color|,

	13 => q|Highlight results ?|,

	12 => q|Context preview length|,

	11 => q|Paginate after|,

	10 => q|Only results of type|,

	9 => q|Only results in language|,

	8 => q|Only results in namespace|,

	7 => q|Only results created by|,

	20 => q|Wobject details|,

	18 => q|Any namespace|,

	17 => q|Search|,

	16 => q|Search|,

	15 => q|All pages|,

	19 => q|Wobject|,

	22 => q|Profile|,

	25 => q|Any user|,

	24 => q|Any language|,

	23 => q|Any Content Type|,

	21 => q|Content|,

	26 => q|Search, Add/Edit|,

	27 => q|
<P>The Search adds advanced search capabilities to your WebGUI site. </P>
<P><STRONG>Index to use<BR></STRONG>The Search uses an index to retrieve it's 
results from. Indexes are created with the scheduler. You can create more then one index. Choose here which index to use.</P>
<P><STRONG>Search through<BR></STRONG>By default all pages are searched. You can 
limit the search to certain page roots. Multiple choices are allowed.</P>
<P><STRONG>Only results created by<BR></STRONG>You can limit the results to 
items created by certain users. By default items from any user are returned.</P>
<P><STRONG>Only results in namespace<BR></STRONG>By default all namespaces are 
searched. You can limit the search to certain namespaces. An example of usage is 
to search only in products.</P>
<P><STRONG>Only results in language<BR></STRONG>If you have a multi-lingual 
site, you can use this option to limit the search results to a certain 
language.</P>
<P><STRONG>Only results of type<BR></STRONG>You can limit the search to certain 
types of content.</P>
<BLOCKQUOTE dir=ltr style="MARGIN-RIGHT: 0px">
<P align=left><EM>Discussion:</EM> Messages on the forums,&nbsp;discussions on 
articles or&nbsp;USS.<BR><EM>Help:</EM> Content in the online WebGUI help 
system<BR><EM>Page:</EM><STRONG> </STRONG>Page title and 
synopsis<BR><EM>Profile:</EM> User Profiles<BR><EM>Wobject: </EM>Wobject Title 
and Description<BR><EM>Wobject details: </EM>All other wobject data. For example 
FAQ question, Calendar item, etc.</P></BLOCKQUOTE>
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
used to highlight the corresponding words in the query.&nbsp;</P>|,

};

1;
