package WebGUI::Help::Asset_RSSCapable;

our $HELP = {
	'rss capable' => {
		title => 'rss capable title',
		body => 'rss capable body',
		# use the following to inherit stuff other help entries
		isa => [
		],
		fields => [	#This array is used to list hover help for form fields.
                        {
                                title => 'rssEnabled label',
                                description => 'rssEnabled hoverHelp',
                                namespace => 'Asset_RSSCapable',
                        },
                        {
                                title => 'rssTemplateId label',
                                description => 'rssTemplateId hoverHelp',
                                namespace => 'Asset_RSSCapable',
                        },
		],
		variables => [
		],
		related => [  ##This lists other help articles that are related to this one
		],
	},

};

1;  ##All perl modules must return true
