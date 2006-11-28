package WebGUI::i18n::English::Asset_WikiMaster;

our $I18N =
{
 'assetName' =>
 { lastUpdated => 1160157064, message => 'Wiki' },

        'approval workflow description' => {
                message => q|Choose a workflow to be executed on each page as it gets submitted.|,
                lastUpdated => 0,
        },

        'approval workflow' => {
                message => q|Approval Workflow|,
                lastUpdated => 0,
        },

	'max image size' => {
		message => q|Maximum Image Size|,
		lastUpdated => 0,
		context => q|field label for image on display tab|
		},

	'max image size help' => {
		message => q|Set the size of the image attachments for this Wiki. If you set it to 0 then the default size set in the master settings will be used. Also, changing this setting does not retroactively change the size of images already in the Wiki. You'll have to re-save each page to get the size to change.|,
		lastUpdated => 0,
		context => q|help for display setting label|
		},

	'thumbnail size' => {
		message => q|Thumbnail Size|,
		lastUpdated => 0,
		context => q|field label for thumbnails on display tab|
		},

	'thumbnail size help' => {
		message => q|Set the size of the thumbnails for this Wiki. If you set it to 0 then the default size set in the master settings will be used. Also, changing this setting does not retroactively change the size of thumbnails already in the Wiki. You'll have to re-save each page to get the size to change.|,
		lastUpdated => 0,
		context => q|help for display setting label|
		},

 'groupToEditPages hoverHelp' =>
 { lastUpdated => 1160157064, message => q|Choose a group of users who will be able to edit pages in this wiki instance.  They will not, by default, be able to delete pages or revisions, or edit protected pages.| },
 'groupToEditPages label' =>
 { lastUpdated => 1160157064, message => q|Who can edit pages?| },

 'groupToAdminister hoverHelp' =>
 { lastUpdated => 1160157064, message => q|Choose a group of users who will be able to perform administrative actions on pages in this wiki instance; such actions include deletion of pages and page revisions, and protecting and unprotecting of pages.| },
 'groupToAdminister label' =>
 { lastUpdated => 1160157064, message => q|Who can administer?| },

 'richEditor hoverHelp' =>
 { lastUpdated => 1160157064, message => q|Which rich editor to use for editing pages in this wiki instance.| },
 'richEditor label' =>
 { lastUpdated => 1160157064, message => q|Rich Editor| },

 'pageTemplateId hoverHelp' =>
 { lastUpdated => 1160157064, message => q|Which template to use to display pages.| },
 'pageTemplateId label' =>
 { lastUpdated => 1160157064, message => q|Page Template| },

 'frontPageTemplateId hoverHelp' =>
 { lastUpdated => 1161031607, message => q|Which template to use for the front page.| },
 'frontPageTemplateId label' =>
 { lastUpdated => 1161031607, message => q|Front Page Template| },

 'recentChangesTemplateId hoverHelp' =>
 { lastUpdated => 1160157064, message => q|Which template to use for the recent changes display.| },
 'recentChangesTemplateId label' =>
 { lastUpdated => 1160157064, message => q|Recent Changes Template| },

 'pageHistoryTemplateId hoverHelp' =>
 { lastUpdated => 1160505291, message => q|Which template to use for the page history display.| },
 'pageHistoryTemplateId label' =>
 { lastUpdated => 1160505291, message => q|Page History Template| },

 'searchTemplateId hoverHelp' =>
 { lastUpdated => 1161031607, message => q|Which template to use for search results.| },
 'searchTemplateId label' =>
 { lastUpdated => 1161031607, message => q|Search Template| },

 'recentChangesCount hoverHelp' =>
 { lastUpdated => 1161031607, message => q|Maximum number of changes to display on the recent changes page.| },
 'recentChangesCount label' =>
 { lastUpdated => 1161031607, message => q|Recent Changes Count| },
 'recentChangesCountFront hoverHelp' =>
 { lastUpdated => 1161031607, message => q|Maximum number of changes to display on the front page.| },
 'recentChangesCountFront label' =>
 { lastUpdated => 1161031607, message => q|Front Page Recent Changes Count| },

 'func addPage link text' =>
 { lastUpdated => 1160157064, message => q|Add a new page| },
 'func listPages link text' =>
 { lastUpdated => 1160417517, message => q|List all pages| },
 'func recentChanges link text' =>
 { lastUpdated => 1160768887, message => q|Show recent changes| },
 'func view link text' =>
 { lastUpdated => 1161031607, message => q|Back to front page| },
 'func search link text' =>
 { lastUpdated => 1161118304, message => q|Search within pages| },
 'listPages title' =>
 { lastUpdated => 1160417517, message => q|List of pages| },

 'actionN edited' =>
 { lastUpdated => 1160505291, message => q|Edited| },
 'actionN trashed' =>
 { lastUpdated => 1160505291, message => q|Deleted| },
 'actionN protected' =>
 { lastUpdated => 1160505291, message => q|Protected| },
 'actionN unprotected' =>
 { lastUpdated => 1160505291, message => q|Unprotected| },
 'actionN created' =>
 { lastUpdated => 1160505291, message => q|Created| },

 'recentChanges title' =>
 { lastUpdated => 1161116593, message => q|Recent changes| },
 'search submit' =>
 { lastUpdated => 1161031607, message => q|Search| },
 'search title' =>
 { lastUpdated => 1161031607, message => q|Search| },
};

1;
