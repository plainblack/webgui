package WebGUI::i18n::English::Asset_RSSCapable;

our $I18N =
{
 'rssEnabled label' => { message => 'Enable RSS', lastUpdate => 1162487361 },
 'rssEnabled hoverHelp' => { message => q|Whether or not to enable the RSS feed for this asset.  If enabled, an RSS From Parent asset will be created and managed as an extra child for this purpose.  If not enabled, no such child will be created and the existing one will be deleted.|, lastUpdate => 1162487361 },
 'rssTemplateId label' => { message => 'RSS Template', lastUpdate => 1162487361 },
 'rssTemplateId hoverHelp' => { message => q|The template to use for the RSS feed of this asset.|, lastUpdate => 1162487361 },

	'rss capable title' => {
		message => q|RSS Capable|,
		lastUpdated => 1162956598
	},

	'rss capable body' => {
		message => q|<p>This Asset is used to enable other Assets to make their own RSS feeds using the RSSFromParent Asset.  As a content manager or admin, you will probably never directly use this Asset.</p>|,
		lastUpdated => 1162956563
	},

 'assetName' => { message => 'RSS Capable', lastUpdate => 1162487361 },
};

1;
