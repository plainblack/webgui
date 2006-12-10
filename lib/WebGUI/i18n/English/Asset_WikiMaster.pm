package WebGUI::i18n::English::Asset_WikiMaster;

our $I18N =
{
 'assetName' =>
 { lastUpdated => 1160157064, message => 'Wiki' },

		mostPopularLabel => {message=>q|Most Popular|, lastUpdated=>0},
		recentChangesLabel => {message=>q|Recent Changes|, lastUpdated=>0},
		searchLabel=>{message=>q|Search|, lastUpdated=>0},	
		resultsLabel=>{message=>q|Results|, lastUpdated=>0},
		notWhatYouWanted=>{message=>q|Didn't find what you were looking for?|, lastUpdated=>0},
		nothingFoundLabel=>{message=>q|Your search returned no results.|, lastUpdated=>0},
		addPageLabel=>{message=>q|Add a new page.|, lastUpdated=>0},
		wikiHomeLabel=>{message=>q|Wiki Home|, lastUpdated=>0},

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

 'pageTemplateId hoverHelp' => { lastUpdated => 1160157064, message => q|Which template to use to display pages?| },
 'pageTemplateId label' => { lastUpdated => 1160157064, message => q|Page Template| },
 'pageEditTemplateId hoverHelp' => { lastUpdated => 1160157064, message => q|Which template to use to edit pages?| },
 'pageEditTemplateId label' => { lastUpdated => 1160157064, message => q|Page Edit Template| },

 'frontPageTemplateId hoverHelp' =>
 { lastUpdated => 1161031607, message => q|Which template to use for the front page.| },
 'frontPageTemplateId label' =>
 { lastUpdated => 1161031607, message => q|Front Page Template| },

 'recentChangesTemplateId hoverHelp' => { lastUpdated => 1160157064, message => q|Which template to use for the recent changes display.| },
 'recentChangesTemplateId label' => { lastUpdated => 1160157064, message => q|Recent Changes Template| },

 'mostPopularTemplateId hoverHelp' => { lastUpdated => 1160157064, message => q|Which template should be used to display the most popular listing?| },
 'mostPopularTemplateId label' => { lastUpdated => 1160157064, message => q|Most Popular Template| },

 'pageHistoryTemplateId hoverHelp' =>
 { lastUpdated => 1160505291, message => q|Which template to use for the page history display.| },
 'pageHistoryTemplateId label' =>
 { lastUpdated => 1160505291, message => q|Page History Template| },

 'searchTemplateId hoverHelp' =>
 { lastUpdated => 1161031607, message => q|Which template to use for search results.| },
 'searchTemplateId label' =>
 { lastUpdated => 1161031607, message => q|Search Template| },

 'recentChangesCount hoverHelp' => { lastUpdated => 1161031607, message => q|Maximum number of changes to display on the recent changes page.| },
 'recentChangesCount label' => { lastUpdated => 1161031607, message => q|Recent Changes Count| },
 'recentChangesCountFront hoverHelp' => { lastUpdated => 1161031607, message => q|Maximum number of changes to display on the front page.| },
 'recentChangesCountFront label' => { lastUpdated => 1161031607, message => q|Front Page Recent Changes Count| },

 'mostPopularCount hoverHelp' => { lastUpdated => 1161031607, message => q|Maximum number of popular page links to display on the most popular page.| },
 'mostPopularCount label' => { lastUpdated => 1161031607, message => q|Most Popular Count| },
 'mostPopularCountFront hoverHelp' => { lastUpdated => 1161031607, message => q|Maximum number of popular page links to display on the front page.| },
 'mostPopularCountFront label' => { lastUpdated => 1161031607, message => q|Front Page Most Popular Count| },

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

        'add/edit title' => {
                message => q|Wiki, Add/Edit|,
                lastUpdated => 1165732630,
        },

        'add/edit body' => {
                message => q|<p>The Wiki is very similar to the Collaboration System.  It manages Wiki Pages that are added to it.  These fields are available for configuring and customizing the Wiki.</p>|,
                lastUpdated => 1165732631,
        },

        'search box variables title' => {
                message => q|Wiki Master, Search Box Variables|,
                lastUpdated => 1165790228,
        },

        'search box variables body' => {
                message => q|<p>These variables are available in many Wiki templates for creating a search box.</p>|,
                lastUpdated => 1165790228,
        },

        'searchFormHeader' => {
                message => q|HTML code to start the form for the search box.|,
                lastUpdated => 1165790228,
        },

        'searchQuery' => {
                message => q|HTML code for a text box to enter in search terms.|,
                lastUpdated => 1165790228,
        },

        'searchSubmit' => {
                message => q|A submit button with an internationalized label to perform the search.|,
                lastUpdated => 1165790228,
        },

        'searchFormFooter' => {
                message => q|HTML code to end the form for the search box.|,
                lastUpdated => 1165790228,
        },

        'recent changes variables title' => {
                message => q|Wiki Master, Recent Changes Variables|,
                lastUpdated => 1165790228,
        },

        'recent changes variables body' => {
                message => q|<p>These variables are available in many Wiki templates for displaying links to recently changed wiki pages.</p>|,
                lastUpdated => 1165790228,
        },

        'recentChanges' => {
                message => q|This loop contains information about wiki pages that have been recently changed.  The number of recently changed pages is determined in the Wiki Add/Edit screen.|,
                lastUpdated => 1165790228,
        },

        'recent changes title' => {
                message => q|The title of the recently changed page.|,
                lastUpdated => 1165790228,
        },

        'recent changes url' => {
                message => q|The url of the recently changed page.|,
                lastUpdated => 1165790228,
        },

        'actionTaken' => {
                message => q|What happened to this recently changed page, typically this is either "Edited" or "Created".|,
                lastUpdated => 1165790228,
                context => q|The Edited and Created words in the message are internationalized.  Please translate them.|,
        },

        'recent changes username' => {
                message => q|The name of the user who changed the page, recently.|,
                lastUpdated => 1165790228,
        },

        'recent changes date' => {
                message => q|The date when the page was changed.|,
                lastUpdated => 1165790228,
        },

        'most popular variables title' => {
                message => q|Wiki Master, Most Popular Variables|,
                lastUpdated => 1165790228,
        },

        'most popular variables body' => {
                message => q|<p>These variables are available in many Wiki templates for displaying links to the wiki pages that are most popular.</p>|,
                lastUpdated => 1165790228,
        },

        'mostPopular' => {
                message => q|This loop contains information about wiki pages that are the most popular.  The number of pages displayed is determined in the Wiki Add/Edit screen.|,
                lastUpdated => 1165790228,
        },

        'most popular title' => {
                message => q|The title of a page from the set of most popular pages.|,
                lastUpdated => 1165790228,
        },

        'most popular url' => {
                message => q|The url of a page from the set of most popular pages.|,
                lastUpdated => 1165790228,
        },

};

1;
