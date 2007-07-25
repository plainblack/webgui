package WebGUI::i18n::English::Asset_Article;

our $I18N = {
	'attachments' => {
		message => q|Attachments|,
		lastUpdated => 0
		},

	'attachments help' => {
		message => q|Attach files and images directly to this Article. Please note that these files will not be accessible through the asset manager to other assets.|,
		lastUpdated => 0
		},

	'cache timeout' => {
		message => q|Cache Timeout|,
		lastUpdated => 0
		},

	'cache timeout help' => {
		message => q|Since all users will see this asset the same way, we can cache it for long periods of time to increase performance. How long should we cache it?|,
		lastUpdated => 1146455970
		},

	'cacheTimeout' => {
		message => q|The amount of time this article will be cached.|,
		lastUpdated => 1164841027
		},

	'templateId' => {
		message => q|The Id of the template used to display this Asset.|,
		lastUpdated => 1164841027
		},

	'storageId' => {
		message => q|The Id of the storage object for this Asset that is used to store any attachments.|,
		lastUpdated => 1164841027
		},

	'71' => {
		message => q|<p>Articles are the Swiss Army knife of WebGUI. Most pieces of static content can be added via the Article.  Articles are Wobjects, so they inherit the properties of both Wobjects and Assets.</p>

<p>NOTE: You can create a multi-paged article by placing the separator marker (&#94;-;) at various places through-out your article.  This works unless you are using a Make Page Printable style.</p>

|,
		lastUpdated => 1146514077,
	},

	'7' => {
		message => q|Link Title|,
		lastUpdated => 1031514049
	},

	'link title description' => {
		message => q|<p>If you wish to add a link to your article, enter the title of the link in this field.</p>
<p><i>Example:</i> Google</p>|,
		lastUpdated => 1146514089
	},


	'assetName' => {
		message => q|Article|,
		lastUpdated => 1128830974
	},

	'72' => {
		message => q|Article Template|,
		lastUpdated => 1038794871
	},

	'article template description' => {
		message => q|Select a template from the list to layout your Wobject.  Each Wobject
may only use templates for their own namespace.  For example, Articles
can only use templates from the "Article" namespace.  Layouts can only
use templates from the "page" namespace.|,
		lastUpdated => 1119066250
	},

	'article asset template variables title' => {
		message => q|Article Asset Template Variables|,
		lastUpdated => 1164841146
	},

	'article asset template variables body' => {
		message => q|Every asset provides a set of variables to most of its
templates based on the internal asset properties.  Some of these variables may
be useful, others may not.|,
		lastUpdated => 1164841201
	},

	'28' => {
		message => q|View Responses|,
		lastUpdated => 1031514049
	},

	'61' => {
		message => q|Article, Add/Edit|,
		lastUpdated => 1066583066
	},

	'12' => {
		message => q|Edit Article|,
		lastUpdated => 1031514049
	},

	'8' => {
		message => q|Link URL|,
		lastUpdated => 1031514049
	},

	'link url description' => {
		message => q|<p>If you added a link title, now add the URL (uniform resource locater) here.</p>
<p><i>Example:</i> http://www.google.com</p>|,
		lastUpdated => 1146508836
	},

	'new.template' => {
		message => q|Articles have the special ability to change their template so that you can allow users to see different views of the article. You do this by creating a link with a URL like this (replace 999 with the template Id you wish to use):

<p>
&lt;a href="&lt;tmpl_var new.template&gt;999"&gt;Read more...&lt;/a&gt;|,
		lastUpdated => 1148960553,
	},

	'description' => {
		message => q|The paginated description.|,
		lastUpdated => 1148960553,
	},

	'description.full' => {
		message => q|The full description without any pagination.|,
		lastUpdated => 1148960553,
	},

	'description.first.100words' => {
		message => q|The first 100 words in the description. Words are defined as characters separated by whitespace, so HTML entities and tags count as words.|,
		lastUpdated => 1148960553,
	},

	'description.first.75words' => {
		message => q|The first 75 words in the description. Words are defined as characters separated by whitespace, so HTML entities and tags count as words.|,
		lastUpdated => 1148960553,
	},

	'description.first.50words' => {
		message => q|The first 50 words in the description. Words are defined as characters separated by whitespace, so HTML entities and tags count as words.|,
		lastUpdated => 1148960553,
	},

	'description.first.25words' => {
		message => q|The first 25 words in the description. Words are defined as characters separated by whitespace, so HTML entities and tags count as words.|,
		lastUpdated => 1148960553,
	},

	'description.first.10words' => {
		message => q|The first 10 words in the description. Words are defined as characters separated by whitespace, so HTML entities and tags count as words.|,
		lastUpdated => 1148960553,
	},

	'description.first.paragraph' => {
		message => q|The first paragraph of the description. The first paragraph is determined by the first carriage return found in the text.|,
		lastUpdated => 1148960553,
	},

	'description.first.2paragraphs' => {
		message => q|The first two paragraphs of the description. A paragraph is determined by counting the carriage returns found in the text.|,
		lastUpdated => 1148960553,
	},

	'description.first.sentence' => {
		message => q|The first sentence in the description. A sentence is determined by counting the periods found in the text.|,
		lastUpdated => 1148960553,
	},

	'description.first.2sentences' => {
		message => q|The first two sentences in the description. A sentence is determined by counting the periods found in the text.|,
		lastUpdated => 1148960553,
	},

	'description.first.3sentences' => {
		message => q|The first three sentences in the description. A sentence is determined by counting the periods found in the text.|,
		lastUpdated => 1148960553,
	},

	'description.first.4sentences' => {
		message => q|The first four sentences in the description. A sentence is determined by counting the periods found in the text.|,
		lastUpdated => 1148960553,
	},

	'attachment.icon' => {
		message => q|The URL to the icon image for this attachment type.|,
		lastUpdated => 1148960553,
	},

	'attachment.name' => {
		message => q|The filename for this attachment.|,
		lastUpdated => 1148960553,
	},

	'attachment.url' => {
		message => q|The URL to download this attachment.|,
		lastUpdated => 1148960553,
	},

	'image.thumbnail' => {
		message => q|The URL to the thumbnail for the attached image.|,
		lastUpdated => 1148960553,
	},

	'image.url' => {
		message => q|The URL to the attached image.|,
		lastUpdated => 1148960553,
	},

	'attachment_loop' => {
		message => q|A loop containing all the attachments.|,
		lastUpdated => 1148960553,
	},

	'filename' => {
		message => q|	The name of the file.|,
		lastUpdated => 1148960553,
	},

	'url' => {
		message => q|	The url to download the file.|,
		lastUpdated => 1148960553,
	},

	'thumbnailUrl' => {
		message => q|	The url of the thumbnail of this file.|,
		lastUpdated => 1148960553,
	},

	'iconUrl' => {
		message => q|	The url to the file type icon of this file.|,
		lastUpdated => 1148960553,
	},

	'isImage' => {
		message => q|	A boolean indicating whether this is an image or not.|,
		lastUpdated => 1148960553,
	},

	'linkTitle' => {
		message => q|The title of the link added to the article.|,
		lastUpdated => 1148960553,
	},

	'linkURL' => {
		message => q|The URL for the link added to the article.|,
		lastUpdated => 1148960553,
	},

	'73' => {
		message => q|<p>The following template variables are available for article templates.</p>
|,
		lastUpdated => 1148960667
	},

};

1;
