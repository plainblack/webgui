package WebGUI::i18n::English::Article;

our $I18N = {
	'11' => {
		message => q|(Select "Yes" only if you aren't adding &lt;br&gt; manually.)|,
		lastUpdated => 1031514049
	},

	'71' => {
		message => q|Articles are the Swiss Army knife of WebGUI. Most pieces of static content can be added via the Article.
<br><br>

NOTE: You can create a multi-paged article by placing the separator macro (^-;) at various places through-out your article.  This works unless you are using a Make Page Printable style.

<p />
<b>Template</b><br/>
Select a template to layout your article.
<p />

<b>Image</b><br>
Choose an image (.jpg, .gif, .png) file from your hard drive. This file will be uploaded to the server and displayed in your article.
<br><br>


<b>Attachment</b><br>
If you wish to attach a word processor file, a zip file, or any other file for download by your users, then choose it from your hard drive.
<br><br>

<b>Link Title</b><br>
If you wish to add a link to your article, enter the title of the link in this field. 
<br><br>
<i>Example:</i> Google
<br><br>

<b>Link URL</b><br>
If you added a link title, now add the URL (uniform resource locater) here. 
<br><br>
<i>Example:</i> http://www.google.com

<br><br>

<b>Convert carriage returns?</b><br>
If you're publishing HTML there's generally no need to check this option, but if you aren't using HTML and you want a carriage return every place you hit your "Enter" key, then check this option.
<p>

<b>Allow discussion?</b><br>
Checking this box will enable responses to your article much like Articles on Slashdot.org by
adding a discussion board to the page.
<p>


|,
		lastUpdated => 1101771446
	},

	'7' => {
		message => q|Link Title|,
		lastUpdated => 1031514049
	},

	'22' => {
		message => q|Author|,
		lastUpdated => 1031514049
	},

	'1' => {
		message => q|Article|,
		lastUpdated => 1031514049
	},

	'72' => {
		message => q|Article Template|,
		lastUpdated => 1038794871
	},

	'23' => {
		message => q|Date|,
		lastUpdated => 1031514049
	},

	'13' => {
		message => q|Delete|,
		lastUpdated => 1031514049
	},

	'6' => {
		message => q|Image|,
		lastUpdated => 1031514049
	},

	'28' => {
		message => q|View Responses|,
		lastUpdated => 1031514049
	},

	'3' => {
		message => q|Start Date|,
		lastUpdated => 1031514049
	},

	'61' => {
		message => q|Article, Add/Edit|,
		lastUpdated => 1066583066
	},

	'9' => {
		message => q|Attachment|,
		lastUpdated => 1031514049
	},

	'12' => {
		message => q|Edit Article|,
		lastUpdated => 1031514049
	},

	'8' => {
		message => q|Link URL|,
		lastUpdated => 1031514049
	},

	'4' => {
		message => q|End Date|,
		lastUpdated => 1031514049
	},

	'73' => {
		message => q|The following template variables are available for article templates.
<p/>

<b>new.template</b><br>
Articles have the special ability to change their template so that you can allow users to see different views of the article. You do this by creating a link with a URL like this (replace 999 with the template Id you wish to use):<p>
&lt;a href="&lt;tmpl_var new.template&gt;999"&gt;Read more...&lt;/a&gt;
<p>
<b>description</b><br>
The paginated description.
<p>

<b>description.full</b><br>
The full description without any pagination.
<p>

<b>description.first.100words</b><br>
The first 100 words in the description. Words are defined as characters separated by whitespace, so HTML entities and tags count as words.
<p>

<b>description.first.75words</b><br>
The first 75 words in the description. Words are defined as characters separated by whitespace, so HTML entities and tags count as words.
<p>

<b>description.first.50words</b><br>
The first 50 words in the description. Words are defined as characters separated by whitespace, so HTML entities and tags count as words.
<p>

<b>description.first.25words</b><br>
The first 25 words in the description. Words are defined as characters separated by whitespace, so HTML entities and tags count as words.
<p>

<b>description.first.10words</b><br>
The first 10 words in the description. Words are defined as characters separated by whitespace, so HTML entities and tags count as words.
<p>

<b>description.first.paragraph</b><br>
The first paragraph of the description. The first paragraph is determined by the first carriage return found in the text.
<p>

<b>description.first.2paragraphs</b><br>
The first two paragraphs of the description. A paragraph is determined by counting the carriage returns found in the text.
<p>

<b>description.first.sentence</b><br>
The first sentence in the description. A sentence is determined by counting the periods found in the text.
<p>

<b>description.first.2sentences</b><br>
The first two sentences in the description. A sentence is determined by counting the periods found in the text.
<p>

<b>description.first.3sentences</b><br>
The first three sentences in the description. A sentence is determined by counting the periods found in the text.
<p>

<b>description.first.4sentences</b><br>
The first four sentences in the description. A sentence is determined by counting the periods found in the text.
<p>



<b>attachment.box</b><br/>
Outputs a standard WebGUI attachment box including icon, filename, and attachment indicator.
<p/>

<b>attachment.icon</b><br/>
The URL to the icon image for this attachment type.
<p/>

<b>attachment.name</b><br/>
The filename for this attachment.
<p/>

<b>attachment.url</b><br/>
The URL to download this attachment.
<p/>

<b>image.thumbnail</b><br/>
The URL to the thumbnail for the attached image.
<p/>

<b>image.url</b><br/>
The URL to the attached image.
<p/>

<b>linkTitle</b><br/>
The title of the link added to the article.
<p/>

<b>linkURL</b><br/>
The URL for the link added to the article.
<p/>

<b>post.label</b><br/>
The translated label to add a comment to this article.
<p/>

<b>post.URL</b><br/>
The URL to add a comment to this article.
<p/>

<b>replies.count</b><br/>
The number of comments attached to this article.
<p/>

<b>replies.label</b><br/>
The translated text indicating that you can view the replies.
<p/>

<b>replies.url</b><br/>
The URL to view the replies to this article.
<p/>

|,
		lastUpdated => 1096219144
	},

	'24' => {
		message => q|Post Response|,
		lastUpdated => 1031514049
	},

	'10' => {
		message => q|Convert carriage returns?|,
		lastUpdated => 1031514049
	},

};

1;
