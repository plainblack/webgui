package WebGUI::i18n::English::Asset_SyndicatedContent;
use strict;

our $I18N = {
	'process macros in rss url' => {
		message => q|Process Macros in RSS URLs|,
		lastUpdated => 0
	},
	'process macros in rss url description' => {
		message => q|Setting this to yes will allow you to use macros in your urls|,
		lastUpdated => 0
	},
	'cache timeout' => {
		message => q|Cache Timeout|,
		lastUpdated => 0
	},

	'cache timeout help' => {
		message => q|Since all users will see this asset the same way, we can cache it for long periods of time to increase performance. How long should we cache it?|,
		lastUpdated => 1146455937
	},

	'get syndicated content' => {
		lastUpdated => 0, 
		message => q|Get Syndicated Content|,
		context => q| the title of the get syndicated content workflow activity|
	},

	'1' => {
		lastUpdated => 1031514049,
		message => q|URL to RSS File|
	},

	'assetName' => {
		lastUpdated => 1128832427,
		message => q|Syndicated Content|
	},

	'3' => {
		lastUpdated => 1057208065,
		message => q|Maximum Number of Headlines|
	},

	'4' => {
		lastUpdated => 1031514049,
		message => q|Edit Syndicated Content|
	},

	'channel_title' => {
		message => q|The title of this piece of syndicated content. This variable will be populated by the first feed in a multi-feed list.|,
		lastUpdated => 0,
	},

	'channel_description' => {
		message => q|A description of the content available through this channel. This variable will be populated by the first feed in a multi-feed list.|,
		lastUpdated => 0,
	},

	'channel_link' => {
		message => q|A URL back to the originating site of this channel. This variable will be populated by the first feed in a multi-feed list.|,
		lastUpdated => 0,
	},

	'channel_date' => {
		message => q|The date this channel was updated. This variable will be populated by the first feed in a multi-feed list.|,
		lastUpdated => 0,
	},

	'channel_copyright' => {
		message => q|Copyright holder information. This variable will be populated by the first feed in a multi-feed list.|,
		lastUpdated => 0,
	},

	'channel_image_url' => {
		message => q|The URL of the image attached to this feed. This variable will be populated by the first feed in a multi-feed list.|,
		lastUpdated => 0,
	},

	'channel_image_title' => {
		message => q|The title of the image attached to this feed. This variable will be populated by the first feed in a multi-feed list.|,
		lastUpdated => 0,
	},

	'channel_image_description' => {
		message => q|The description of the image attached to this feed. This variable will be populated by the first feed in a multi-feed list.|,
		lastUpdated => 0,
	},

	'channel_image_link' => {
		message => q|The URL of the link that should wrap this feed's image. This variable will be populated by the first feed in a multi-feed list.|,
		lastUpdated => 0,
	},

	'channel_image_width' => {
		message => q|The width in pixels of this feed's image. This variable will be populated by the first feed in a multi-feed list.|,
		lastUpdated => 0,
	},

	'channel_image_height' => {
		message => q|The height in pixels of this feed's image. This variable will be populated by the first feed in a multi-feed list.|,
		lastUpdated => 0,
	},

	'rss_url' => {
		message => q|This is the URL to use to get the contents of this Syndicated Content asset as an RSS 2.0 feed. Additionally, you can specify RSS versions via the following template variables:|,
		lastUpdated => 0,
	},

	'rdf_url' => {
		message => q|The contents of this asset as an RDF/RSS 1.0 feed.|,
		lastUpdated => 0,
	},

	'atom_url' => {
		message => q|The contents of this asset as an Atom 0.3 feed.|,
		lastUpdated => 0,
	},

	'category' => {
		message => q|A category this item belongs to.|,
		lastUpdated => 0,
	},

	'date' => {
		message => q|The publication date for this item.|,
		lastUpdated => 0,
	},

	'author' => {
		message => q|The publisher of this item.|,
		lastUpdated => 0,
	},

	'guid' => {
		message => q|A unique id for this item.|,
		lastUpdated => 0,
	},

	'item_loop' => {
		message => q|A loop containing the data from this channel.|,
		lastUpdated => 1149567508,
	},

	'title' => {
		message => q|The title of a piece of content. If you're filtering on terms, this field will be inspected.|,
		lastUpdated => 1149567508,
	},

	'description' => {
		message => q|The description of the content. If you're filtering on terms, this field will be inspected as well.|,
		lastUpdated => 1149567508,
	},

	'link' => {
		message => q|A URL directly to the content of the item.|,
		lastUpdated => 1149567508,
	},

           '72' => {
                     lastUpdated => 1047855526,
                     message => q|Syndicated Content Template|
                   },

	'hasTermsLabel' => {
		lastUpdated => 1047855526,
		message => q|With any of these terms|
	},

	'rssTabName' => {
		lastUpdated => 1118417024,
		message => q|RSS|
	},

	'72 description' => {
                message => q|Select a template for this content.|,
                lastUpdated => 1119977659,
        },

        'hasTermsLabel description' => {
                message => q|<p>Enter terms (separated by commas) that you'd like to filter the feeds on. For instance, if you enter:</p>
<div class="helpIndent"><b>linux, windows development, blogs</b></div>
<p>The Syndicated Content web object will display items containing "linux", "windows development" or "blogs" (in the title or description of the item) from all the feeds you're aggregating together.</p>|,
                lastUpdated => 1119977659,
        },

        '1 description' => {
                message => q|<p>Provide the exact URL (starting with http://) to the syndicated content's RDF or RSS file. The syndicated content will be downloaded from this URL hourly.</p>
<p>You can find syndicated content at the following locations:
</p>
<div>
<ul>
<li><a href="http://www.newsisfree.com/">http://www.newsisfree.com</a></li>
<li><a href="http://www.syndic8.com/">http://www.syndic8.com</a></li>
<li><a href="http://www.voidstar.com/node.php?id=144">http://www.voidstar.com/node.php?id=144</a></li>
<li><a href="http://my.userland.com/">http://my.userland.com</a></li>
<li><a href="http://www.webreference.com/services/news/">http://www.webreference.com/services/news/</a></li>
<li><a href="http://w.moreover.com/">http://w.moreover.com/</a></li>
</ul>
</div>
<p>Currently, WebGUI can handle RSS versions .90, .91, 1.0, and 2.0; Atom .3 and 1.0. Probably other RSS-ish files would work too.
</p>
<p>To create an aggregate RSS feed (one that pulls information from multiple RSS feeds), include a list of URLs, one on each line, instead of a single URL.  Items will be sorted by the date WebGUI first received the story.</p>|,
                lastUpdated => 1225928949,
        },

	'3 description' => {
		message => q|Enter the maximum number of headlines that should be displayed.  Set to zero to allow any number of headlines.  Note that all headlines from all RSS URL's are still fetched, even if they are not displayed.|,
		lastUpdated => 1168228412,
	},

	'cacheTimeout' => {
		message => q|The amount of tie in seconds data from this Asset will be cached.|,
		lastUpdated => 1168227896,
	},

	'templateId' => {
		message => q|The ID of the template used to display this Asset.|,
		lastUpdated => 1168227896,
	},

	'rssUrl' => {
		message => q|A newline separated list of all RSS URLs.|,
		lastUpdated => 1168227896,
	},

	'processMacrosInRssUrl' => {
		message => q|A conditional that indicates whether or not this Asset was set to process Macros in the RSS Url field.|,
		lastUpdated => 1168227896,
	},

	'maxHeadlines' => {
		message => q|The maximum number of headlines that will be displayed.|,
		lastUpdated => 1168227896,
	},

	'displayMode' => {
		message => q|If the Asset was set to sort RSS headlines by the title of the originating RSS site, this will be the string "grouped".  Otherwise is will be "interleaved".|,
		context => q|Translator's note:  Do not translate the words in quotes, they are constants in the source code.|,
		lastUpdated => 1168227896,
	},

	'hasTerms' => {
		message => q|Terms used to filter RSS items.|,
		lastUpdated => 1168227896,
	},

    'sortItemsLabel' => {
        message => q{Sort feed items by date?},
    },

    'sortItemsLabel description' => {
        message => q{If enabled, items will be sorted by date.  If disabled, items will be left in the order they appear in the original feed.},
    },

	'syndicated content asset template variables title' => {
		message => q|Syndicated Content Asset Template Variables|,
		lastUpdated => 1164841146
	},

    'descriptionFirst100words' => {
        message => q{The first 100 words of the description.},
        lastUpdated => 0,
    },
    'descriptionFirst75words' => {
        message => q{The first 75 words of the description.},
        lastUpdated => 0,
    },
    'descriptionFirst50words' => {
        message => q{The first 50 words of the description.},
        lastUpdated => 0,
    },
    'descriptionFirst25words' => {
        message => q{The first 25 words of the description.},
        lastUpdated => 0,
    },
    'descriptionFirst10words' => {
        message => q{The first 10 words of the description.},
        lastUpdated => 0,
    },
    'descriptionFirst2paragraphs' => {
        message => q{The first 2 paragraphs of the description.},
        lastUpdated => 0,
    },
    'descriptionFirstParagraph' => {
        message => q{The first paragraph of the description.},
        lastUpdated => 0,
    },
    'descriptionFirst4sentences' => {
        message => q{The first 4 sentences of the description.},
        lastUpdated => 0,
    },
    'descriptionFirst3sentences' => {
        message => q{The first 3 sentences of the description.},
        lastUpdated => 0,
    },
    'descriptionFirst2sentences' => {
        message => q{The first 2 sentences of the description.},
        lastUpdated => 0,
    },
    'descriptionFirstSentence' => {
        message => q{The first sentence of the description.},
        lastUpdated => 0,
    },

};

1;
