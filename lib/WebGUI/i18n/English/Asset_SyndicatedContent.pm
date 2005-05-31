package WebGUI::i18n::English::Asset_SyndicatedContent;

our $I18N = {
	'3' => {
		message => q|Maximum Number of Headlines|,
		lastUpdated => 1057208065
	},

	'71' => {
		message => q|Syndicated content is content that is pulled from another site using the RDF/RSS specification. This technology is often used to pull headlines from various news sites like <a href="http://www.cnn.com/">CNN</a> and  <a href="http://slashdot.org/">Slashdot</a>. It can, of course, be used for other things like sports scores, stock market info, etc.
<p>
This Syndicated Content client is a Wobject and an Asset, so it has the properties of both.  It also has
these unique properties:
<p>

<b>URL to RSS file</b><br>
Provide the exact URL (starting with http://) to the syndicated content's RDF or RSS file. The syndicated content will be downloaded from this URL hourly.
<br><br>
You can find syndicated content at the following locations:
</p><ul>
<li><a href="http://www.newsisfree.com/">http://www.newsisfree.com</a>
</li><li><a href="http://www.syndic8.com/">http://www.syndic8.com</a>
</li><li><a href="http://www.voidstar.com/node.php?id=144">http://www.voidstar.com/node.php?id=144</a>
</li><li><a href="http://my.userland.com/">http://my.userland.com</a>
</li><li><a href="http://www.webreference.com/services/news/">http://www.webreference.com/services/news/</a>
</li><li><a href="http://w.moreover.com/">http://w.moreover.com/</a>
</li></ul>

<p>

To create an aggregate RSS feed, include a list of space separated URLs instead of a single URL.  For an aggregate feed, the system will display an equal number of headlines from each source, sorted by the date the system first received the story.<p>

<b>Template</b><br>
Select a template for this content.
<p><b>Maximum Headlines</b><br>
Enter the maximum number of headlines that should be displayed.  For an aggregate feed, the system will display an equal number of headlines from each source, even if doing so requires displaying more than the requested maximum number of headlines.  Set to zero to allow any number of headlines.
<p>|,
		lastUpdated => 1110070203,
	},

	'61' => {
		message => q|Syndicated Content, Add/Edit|,
		lastUpdated => 1047855741
	},

	'2' => {
		message => q|Syndicated Content|,
		lastUpdated => 1031514049
	},

	'1' => {
		message => q|URL to RSS File|,
		lastUpdated => 1031514049
	},

	'4' => {
		message => q|Edit Syndicated Content|,
		lastUpdated => 1031514049
	},

	'72' => {
		message => q|Syndicated Content Template|,
		lastUpdated => 1047855526
	},

	'73' => {
		message => q|The following are the template variables available to the Syndicated Content template.

<p>

<b>channel.title</b><br>
The title of this piece of syndicated content.
<p>

<b>channel.description</b><br>
A description of the content available through this channel.
<p>

<b>channel.link</b><br>
A URL back to the originating site of this channel.
<p>

<b>item_loop</b><br>
A loop containing the data from this channel.

<blockquote>

<b>title</b><br>
The title of a piece of content.
<p>

<b>description</b><br>
The description of the content.
<p>

<b>link</b>
A URL directly to the original content.

</blockquote>|,
		lastUpdated => 1047855526
	},

};

1;
