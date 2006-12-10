package WebGUI::Help::Asset_WikiMaster;

our $HELP = {
	'wiki master add/edit' => {
		title => 'add/edit title',
		body => 'add/edit body',
		isa => [
			{
				namespace => "Asset_Wobject",
				tag => "wobject add/edit"
			},
		],
		fields => [
                        {
                                title => 'groupToEditPages label',
                                description => 'groupToEditPages hoverHelp',
                                namespace => 'Asset_WikiMaster',
                        },
                        {
                                title => 'groupToAdminister label',
                                description => 'groupToAdminister hoverHelp',
                                namespace => 'Asset_WikiMaster',
                        },
                        {
                                title => 'richEditor label',
                                description => 'richEditor hoverHelp',
                                namespace => 'Asset_WikiMaster',
                        },
                        {
                                title => 'frontPageTemplateId label',
                                description => 'frontPageTemplateId hoverHelp',
                                namespace => 'Asset_WikiMaster',
                        },
                        {
                                title => 'pageTemplateId label',
                                description => 'pageTemplateId hoverHelp',
                                namespace => 'Asset_WikiMaster',
                        },
                        {
                                title => 'pageHistoryTemplateId label',
                                description => 'pageHistoryTemplateId hoverHelp',
                                namespace => 'Asset_WikiMaster',
                        },
                        {
                                title => 'mostPopularTemplateId label',
                                description => 'mostPopularTemplateId hoverHelp',
                                namespace => 'Asset_WikiMaster',
                        },
                        {
                                title => 'recentChangesTemplateId label',
                                description => 'recentChangesTemplateId hoverHelp',
                                namespace => 'Asset_WikiMaster',
                        },
                        {
                                title => 'searchTemplateId label',
                                description => 'searchTemplateId hoverHelp',
                                namespace => 'Asset_WikiMaster',
                        },
                        {
                                title => 'pageEditTemplateId label',
                                description => 'pageEditTemplateId hoverHelp',
                                namespace => 'Asset_WikiMaster',
                        },
                        {
                                title => 'recentChangesCount label',
                                description => 'recentChangesCount hoverHelp',
                                namespace => 'Asset_WikiMaster',
                        },
                        {
                                title => 'recentChangesCountFront label',
                                description => 'recentChangesCountFront hoverHelp',
                                namespace => 'Asset_WikiMaster',
                        },
                        {
                                title => 'mostPopularCountFront label',
                                description => 'mostPopularCountFront hoverHelp',
                                namespace => 'Asset_WikiMaster',
                        },
                        {
                                title => 'approval workflow',
                                description => 'approval workflow description',
                                namespace => 'Asset_WikiMaster',
                        },
                        {
                                title => 'thumbnail size',
                                description => 'thumbnail size help',
                                namespace => 'Asset_WikiMaster',
                        },
                        {
                                title => 'max image size',
                                description => 'max image size help',
                                namespace => 'Asset_WikiMaster',
                        },
		],
		related => [
			{
				tag => 'wobjects using',
				namespace => 'Asset_Wobject'
			},
		],
	},

};

1;
