package WebGUI::i18n::English::Asset_SyndicatedContent;

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

	'61' => {
		lastUpdated => 1047855741,
		message => q|Syndicated Content, Add/Edit|
	},

	'71' => {
		lastUpdated => 1167193158,
		message => q|<p>Syndicated content is content that is pulled from another site using the RDF/RSS specification. This technology is often used to pull headlines from various news sites like <a href="http://www.cnn.com/">CNN</a> and  <a href="http://slashdot.org/">Slashdot</a>. It can, of course, be used for other things like sports scores, stock market info, etc.
</p>
<p>The Syndicated Content system also has the ability to "republish" its items as RSS 0.9, 0.91, 1.0 and 2.0 flavor feeds. This means you can aggregate a bunch of feeds together, filter on relevant keywords and then republish this aggregated feed, and the Syndicated Content wobject will take care of all the messy stuff for you. See the "Syndicated Content Template" help for additional information. 
</p>
<p>The Syndicated Content client is a Wobject and an Asset, so it has the properties of both.  It also has
these unique properties:
</p>
|
                   },

	'channel.title' => {
		message => q|The title of this piece of syndicated content. This will be the same as the title of the Syndicated Content object when you're creating an aggregate feed.|,
		lastUpdated => 1149567508,
	},

	'channel.description' => {
		message => q|A description of the content available through this channel. This will be the same as the description of the Syndicated Content object when you're creating an aggregate feed.|,
		lastUpdated => 1149567508,
	},

	'channel.link' => {
		message => q|A URL back to the originating site of this channel. This variable *will not* exist when you're creating an aggregate feed, because there's no single channel to link to.|,
		lastUpdated => 1149567508,
	},

	'rss.url' => {
		message => q|This is the URL to use to get the contents of this Syndicated Content wobject as an RSS 2.0 feed. Additionally, you can specify RSS versions via the following template variables:|,
		lastUpdated => 1149567508,
	},

	'rss.url.0.9' => {
		message => q|The contents of this wobject as an RSS 0.9 feed.|,
		lastUpdated => 1149567508,
	},

	'rss.url.0.91' => {
		message => q|The contents of this wobject as an RSS 0.91 feed.|,
		lastUpdated => 1149567508,
	},

	'rss.url.1.0' => {
		message => q|The contents of this wobject as an RSS 1.0 feed.|,
		lastUpdated => 1149567508,
	},

	'rss.url.2.0' => {
		message => q|The contents of this wobject as an RSS 2.0 feed.|,
		lastUpdated => 1149567508,
	},

	'item_loop' => {
		message => q|A loop containing the data from this channel.|,
		lastUpdated => 1149567508,
	},

	'site_title' => {
		message => q|The title of the RSS feed this item comes from|,
		lastUpdated => 1149567508,
	},

	'site_link' => {
		message => q|Link to the source RSS feed.|,
		lastUpdated => 1149567508,
	},

	'new_rss_site' => {
		message => q|A "boolean" variable (suitable for using in a &lt;tmpl_if&gt; tag) that indicates we've started outputting items from a source RSS feed different than the previous item. This is most useful when you're viewing feeds in "grouped" mode- it gives you a hook to output <b>site_title</b> and <b>site_link</b> at the right time.|,
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

           '73' => {
                     lastUpdated => 1149567527,
                     message => q|<p>The following are the template variables available to the Syndicated Content template:</p>

<p>Additionally, RSS feeds are transformed into HTML via XSLT stylesheets for "friendly" in-browser viewing. These XSLT stylesheets are stored in the WebGUI collateral system as snippets.
</p>
|,
	},

	'displayModeLabel' => {
		lastUpdated => 1047855526,
		message => q|Display Mode|
	},

	'displayModeSubtext' => {
		lastUpdated => 1047855526,
		message => q|<p>"Interleaved" means items from all feeds are lumped together, "Grouped by Feed" means items are grouped by the feed they came from. Either setting is fine if you're only bringing in a single feed.</p>|
	},

	'grouped' => {
		lastUpdated => 1047855526,
		message => q|Grouped by Feed|
	},

	'hasTermsLabel' => {
		lastUpdated => 1047855526,
		message => q|With any of these terms|
	},

	'interleaved' => {
		lastUpdated => 1047855526,
		message => q|Interleaved|
	},

	'rssTabName' => {
		lastUpdated => 1118417024,
		message => q|RSS|
	},

	'RSS Feed Title Suffix' => {
		lastUpdated => 1118417024,
		message => q|RSS 2.0 Feed|
	},

	'72 description' => {
                message => q|Select a template for this content.|,
                lastUpdated => 1119977659,
        },

        'displayModeLabel description' => {
                message => q|<p>If you're aggregating feeds, you can change the mode in which the items are displayed. "Grouped by Feed" means the items will be grouped together by the feeds they come from. "Interleaved" means the items will be mixed together in a "round-robin" fashion from all the feeds. If you're grouping your feeds, please look at <b>new_rss_site</b> "item_loop" template variables, it gives you a hook allowing you to output the feed title</p>|,
                lastUpdated => 1146799950,
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
<p>Currently, WebGUI can handle RSS versions .90, .91, 1.0, and 2.0. Atom feeds aren't supported for now. Probably other RSS-ish files would work too.
</p>
<p>To create an aggregate RSS feed (one that pulls information from multiple RSS feeds), include a list of URLs, one on each line, instead of a single URL.  Items will be sorted by the date WebGUI first received the story.</p>|,
                lastUpdated => 1168228049,
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

	'syndicated content asset template variables title' => {
		message => q|Syndicated Content Asset Template Variables|,
		lastUpdated => 1164841146
	},

	'syndicated content asset template variables body' => {
		message => q|Every asset provides a set of variables to most of its
templates based on the internal asset properties.  Some of these variables may
be useful, others may not.|,
		lastUpdated => 1164841201
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
