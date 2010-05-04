package WebGUI::i18n::English::Asset_WikiMaster;
use strict;

our $I18N = {
    'allow attachments' => {
        lastUpdated => 0,
        message     => q|Allowed Attachments|,
        context     => "field label"
     },
    'allow attachments help' => {
        lastUpdated => 0,
        message     => q|The number of attachments that are allowed to be placed on each wiki page.|,
        context     => "Hover help for edit form.",
     },
 'assetName' => { lastUpdated => 1160157064, message => 'Wiki' },
 'asset description' => { lastUpdated => 1160157064, message => q|A wiki is a collaborative content publishing mechanism. Traditionally wiki's use the wiki markup language, but that's generally not much easier to deal with than HTML, so WebGUI's wiki instead just uses a rich editor to help users publish rich great looking content.| },

		mostPopularLabel => {message=>q|Most Popular|, lastUpdated=>0},
		recentChangesLabel => {message=>q|Recent Changes|, lastUpdated=>0},
		searchLabel=>{message=>q|Search|, lastUpdated=>0},	
		resultsLabel=>{message=>q|Results|, lastUpdated=>0},
		notWhatYouWantedLabel=>{message=>q|Didn't find what you were looking for?|, lastUpdated=>0},
		nothingFoundLabel=>{message=>q|Your search returned no results.|, lastUpdated=>0},
		addPageLabel=>{message=>q|Add a new page.|, lastUpdated=>0},
		wikiHomeLabel=>{message=>q|Wiki Home|, lastUpdated=>0},

	'restoreLabel' => {
		message => q|Restore|,
		lastUpdated => 0,
		context => q|label to restore the page back from the trash or clipboard|,
	},

	'filter code' => {
		message => q|Filter Code|,
		lastUpdated => 0,
		context => q|Label for edit wobject screen|,
	},

	'filter code description' => {
		message => q|Sets the level of HTML Filtering done on each Wiki entry|,
		lastUpdated => 0,
		context => q|Hover help for edit wobject screen|,
	},

	'top level keywords' => {
		message => q|Top Level Keywords|,
		lastUpdated => 0,
		context => q|Label for edit wobject screen|,
	},

	'top level keywords description' => {
		message => q|These keywords provide the root for the hierarchial keyword display.|,
		lastUpdated => 0,
		context => q|Hover help for edit wobject screen|,
	},

	'content filter' => {
		message => q|Use Content Filter?|,
		lastUpdated => 0,
		context => q|Label for edit wobject screen|,
	},
	
	'content filter description' => {
		message => q|Process the content of Wiki pages through the WebGUI Content Filtering system.  This can also be used to create custom markup symbols for inserting reusable content styling.|,
		lastUpdated => 0,
		context => q|Hover help for edit wobject screen|,
	},

	'wikiHomeLabel variable' => {
		message=>q|An internationalized label to go with wikiHomeUrl.|,
		lastUpdated=>1165816161,
	},

	'wikiHomeUrl' => {
		message=>q|A URL to take the user back to the Wiki front page.|,
		lastUpdated=>1165816166,
	},

        'approval workflow description' => {
                message => q|Choose a workflow to be executed on each page as it gets submitted.|,
                lastUpdated => 0,
        },

        'approval workflow' => {
                message => q|Approval Workflow|,
                lastUpdated => 0,
        },

        'approvalWorkflow' => {
                message => q|The Id of the Workflow used to approve pages in the Wiki.|,
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

	'maxImageSize' => {
		message => q|The size of the image attachments set for this Wiki.|,
		lastUpdated => 1165813764,
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

	'thumbnailSize' => {
		message => q|The size of the thumbnails set for this Wiki.|,
		lastUpdated => 1165813723,
		},

 'groupToEditPages hoverHelp' =>
 { lastUpdated => 1160157064, message => q|Choose a group of users who will be able to edit pages in this wiki instance.  They will not, by default, be able to delete pages or revisions, or edit protected pages.| },
 'groupToEditPages label' =>
 { lastUpdated => 1160157064, message => q|Who can edit pages?| },

	'groupToEditPages' => {
		message => q|The id of the group that can edit pages.|,
		lastUpdated => 1160157064,
	},

 'groupToAdminister hoverHelp' =>
 { lastUpdated => 1160157064, message => q|Choose a group of users who will be able to perform administrative actions on pages in this wiki instance; such actions include deletion of pages and page revisions, and protecting and unprotecting of pages.| },
 'groupToAdminister label' =>
 { lastUpdated => 1160157064, message => q|Who can administer?| },

	'groupToAdminister' => {
		message => q|The id of the group that is allowed to administer the Wiki or to edit pages.|,
		lastUpdated => 1160157064,
	},

 'richEditor hoverHelp' =>
 { lastUpdated => 1160157064, message => q|Which rich editor to use for editing pages in this wiki instance.| },
 'richEditor label' =>
 { lastUpdated => 1160157064, message => q|Rich Editor| },

	'richEditor' => {
		message => q|The id of the Rich Editor that will be used to edit Wiki pages.|,
		lastUpdated => 1160157064,
	},

 'byKeywordTemplateId hoverHelp' => { lastUpdated => 1160157064, message => q|Which template to use to display a
listing of pages that are related to a specific keyword?| },
 'byKeywordTemplateId label' => { lastUpdated => 1160157064, message => q|By Keyword Template| },

 'pageTemplateId hoverHelp' => { lastUpdated => 1160157064, message => q|Which template to use to display pages?| },
 'pageTemplateId label' => { lastUpdated => 1160157064, message => q|Page Template| },

	'pageTemplateId' => {
		message => q|The id of the template used to display the pages inside the Wiki.|,
		lastUpdated => 1160157064,
	},

 'pageEditTemplateId hoverHelp' => { lastUpdated => 1160157064, message => q|Which template to use to edit pages?| },
 'pageEditTemplateId label' => { lastUpdated => 1160157064, message => q|Page Edit Template| },

	'pageEditTemplateId' => {
		message => q|The id of the template that displays the screen for editing Wiki pages.|,
		lastUpdated => 1160157064,
	},

 'frontPageTemplateId hoverHelp' =>
 { lastUpdated => 1161031607, message => q|Which template to use for the front page.| },
 'frontPageTemplateId label' =>
 { lastUpdated => 1161031607, message => q|Front Page Template| },

	'frontPageTemplateId' => {
		message => q|The id of the template used to display the front page of the Wiki.|,
		lastUpdated => 1160157064,
	},

 'recentChangesTemplateId hoverHelp' => { lastUpdated => 1160157064, message => q|Which template to use for the recent changes display.| },
 'recentChangesTemplateId label' => { lastUpdated => 1160157064, message => q|Recent Changes Template| },

	'recentChangesTemplateId' => {
		message => q|The id of the template to display the list of recent changes to pages inside the Wiki.|,
		lastUpdated => 1160157064,
	},

 'mostPopularTemplateId hoverHelp' => { lastUpdated => 1160157064, message => q|Which template should be used to display the most popular listing?| },
 'mostPopularTemplateId label' => { lastUpdated => 1160157064, message => q|Most Popular Template| },

	'mostPopularTemplateId' => {
		message => q|The id of the template to display the list most popular pages inside the Wiki.|,
		lastUpdated => 1160157064,
	},

 'pageHistoryTemplateId hoverHelp' =>
 { lastUpdated => 1160505291, message => q|Which template to use for the page history display.| },
 'pageHistoryTemplateId label' =>
 { lastUpdated => 1160505291, message => q|Page History Template| },

	'pageHistoryTemplateId' => {
		message => q|The id of the template to display the list of all changes to any given page inside the Wiki.|,
		lastUpdated => 1160157064,
	},

 'searchTemplateId hoverHelp' =>
 { lastUpdated => 1161031607, message => q|Which template to use for search results.| },
 'searchTemplateId label' =>
 { lastUpdated => 1161031607, message => q|Search Template| },

	'searchTemplateId' => {
		message => q|The id of the template to display a page to search pages inside the Wiki.|,
		lastUpdated => 1160157064,
	},

 'recentChangesCount hoverHelp' => { lastUpdated => 1165813593, message => q|The Maximum number of changes to display on the recent changes page.| },
 'recentChangesCount label' => { lastUpdated => 1161031607, message => q|Recent Changes Count| },
 'recentChangesCountFront hoverHelp' => { lastUpdated => 1165813596, message => q|The maximum number of changes to display on the front page.| },
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

        'search box variables title' => {
                message => q|Wiki Master, Search Box Variables|,
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
                message => q|Wiki Master, Recent Changes Template Variables|,
                lastUpdated => 1184969334,
        },

        'recentChanges' => {
                message => q|This loop contains information about wiki pages that have been recently changed.  The number of recently changed pages is determined in the Wiki Add/Edit screen.|,
                lastUpdated => 1165790228,
        },

        'canAdminister' => {
                message => q|A boolean indicating whether the current user can administer the wiki.|,
                lastUpdated => 1165790228,
        },

        'recent changes title' => {
                message => q|The title of the recently changed page.|,
                lastUpdated => 1165790228,
        },

        'recent changes restore url' => {
                message => q|The url to restore this page back to viewing status from the clipboard/trash.|,
                lastUpdated => 1165790228,
        },

        'recent changes is available' => {
                message => q|A boolean indicating whether the page is available for viewing or in the trash/clipboard.|,
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
                message => q|Wiki Master, Most Popular Template Variables|,
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

        'front page template title' => {
                message => q|Wiki, Front Page Template Variables|,
                lastUpdated => 1184969362,
        },

        'description' => {
                message => q|The description for this Wiki, with any recognized titles or urls from pages in this Wiki automatically converted to links to those pages.  This template variable will override any other variables available in this template with the same name.|,
                lastUpdated => 1165814035,
        },

        'searchLabel variable' => {
                message => q|An internationalized label to go with searchUrl|,
                lastUpdated => 1165812138,
        },

        'searchUrl' => {
                message => q|A URL to take the user to the screen search pages in this Wiki.|,
                lastUpdated => 1165816007,
        },

        'mostPopularUrl' => {
                message => q|A URL to take the user to the screen where the most popular Wiki pages are listed.|,
                lastUpdated => 1165812138,
        },

        'mostPopularLabel variable' => {
                message => q|An internationalized label to go with mostPopularUrl.|,
                lastUpdated => 1165812138,
        },

        'recentChangesUrl' => {
                message => q|A URL to take the user to the screen where all changes to the the pages in this Wiki are listed.|,
                lastUpdated => 1165812138,
        },

        'recentChangesLabel variable' => {
                message => q|An internationalized label to go with recentChangesUrl.|,
                lastUpdated => 1165812138,
        },

        'wiki master asset variables title' => {
                message => q|Wiki Asset Variables.|,
                lastUpdated => 1165812138,
        },

        'most popular template title' => {
                message => q|Wiki Master, Most Popular Template|,
                lastUpdated => 1165812138,
        },

        'most popular template body' => {
                message => q|<p>These variables are available in the template for displaying the most popular pages in the Wiki.</p>|,
                lastUpdated => 1165812138,
        },

        'most popular title variable' => {
                message => q|An internationalized title for the Most Popular Template.|,
                lastUpdated => 1165812138,
        },

        'recent changes template title' => {
                message => q|Wiki Master, Recent Changes Template|,
                lastUpdated => 1165812138,
        },

        'recent changes template body' => {
                message => q|<p>These variables are available in the template for displaying the list of recent changes to pages in the Wiki.</p>|,
                lastUpdated => 1165816631,
        },

        'recent changes title' => {
                message => q|An internationalized title for the Recent Changes Template.|,
                lastUpdated => 1165790228,
        },

        'resultsLabel variable' => {
                message => q|An internationalized label for titling the results of the search.|,
                lastUpdated => 1165945210,
        },

        'notWhatYouWanted variable' => {
                message => q|An internationalized label for for asking the user if they did not find what they were looking for.|,
                lastUpdated => 1165945210,
        },

        'nothingFoundLabel variable' => {
                message => q|An internationalized label for telling the user that no results were found for their search.|,
                lastUpdated => 1165945210,
        },

        'addPageUrl' => {
                message => q|A URL to allow the user to add a page.|,
                lastUpdated => 1165945210,
        },

        'addPageLabel variable' => {
                message => q|An internationalized label to go with addPageUrl.|,
                lastUpdated => 1165945210,
        },

        'performSearch' => {
                message => q|The constant "1".|,
                lastUpdated => 1165945210,
        },

        'searchResults' => {
                message => q|A loop containing all the results of the users search.  The loop can be empty.|,
                lastUpdated => 1165945210,
        },

        'search url variable' => {
                message => q|The URL (with gateway) of a page returned in the search results.|,
                lastUpdated => 1165945210,
        },

        'search title variable' => {
                message => q|The title of a page returned in the search results.|,
                lastUpdated => 1165945210,
        },

        'search template title' => {
                message => q|Wiki Master, Search Template|,
                lastUpdated => 1165946012,
        },

        'search template body' => {
                message => q|<p>These variables are available in the template for displaying the search page in the Wiki.</p>|,
                lastUpdated => 1165946014,
        },

	'canAddPages' => {
		message => q|canAddPages Variable|,
		lastUpdated=>0,
	},

	'canAddPages variable' => {
		message => q|Boolean value that is true when the user is allowed to add and edit pages in the Wiki.|,
		lastUpdated=> 0,
	},

	'useContentFilter' => {
		message => q|Boolean value that is true when this Wiki has been set to filter content.|,
		lastUpdated=> 0,
	},

	'filterCode' => {
		message => q|Strings that indicate the level of content filtering.|,
		lastUpdated=> 0,
	},

    'asset not committed' => {
		message => q{<h1>Error!</h1><p>You need to commit this wiki before you can create a new wiki entry</p>},
        lastUpdated => 1166848379,
    },

    'help isSubscribed' => {
        message     => q{This variable is true if the user is subscribed to the entire wiki},
        lastUpdated => 0,
        context     => q{Help for template variable},
    },

    'help subscribeUrl' => {
        message     => q{The URL to subscribe to the entire wiki},
        lastUpdated => 0,
        context     => q{Help for template variable},
    },

    'help unsubscribeUrl' => {
        message     => q{The URL to unsubscribe from the entire wiki},
        lastUpdated => 0,
        context     => q{Help for template variable},
    },

    'subscribe' => {
        message     => q{Subscribe},
        lastUpdated => 0,
        context     => q{Label for link to subscribe to e-mail notifications},
    },

    'unsubscribe' => {
        message     => q{Unsubscribe},
        lastUpdated => 0,
        context     => q{Label for link to unsubscribe from e-mail notifications},
    },

    'keywords_loop' => {
        message     => q{A loop containing all the top level keywords, links to their keyword pages, and all sub pages below them.},
        lastUpdated => 0,
        context     => q{Help for template variable},
    },

    'keyword title' => {
        message     => q{The name of a keyword.},
        lastUpdated => 0,
        context     => q{Help for template variable},
    },

    'keyword url' => {
        message     => q{The URL to the keyword page for that keyword.  If no page exists, this variable will be empty.},
        lastUpdated => 0,
        context     => q{Help for template variable},
    },

    'keyword level' => {
        message     => q{The depth of this keyword.  Top-level keywords for the wiki are level 0.},
        lastUpdated => 0,
        context     => q{Help for template variable},
    },

    'indent_loop' => {
        message     => q{A loop that runs 1 time for each level.},
        lastUpdated => 0,
        context     => q{Help for template variable},
    },

    'keyword indent' => {
        message     => q{The loop iterator for the indent_loop.},
        lastUpdated => 0,
        context     => q{Help for template variable},
    },

    'by keyword template title' => {
        message     => q{Wiki By Keyword Template Variables},
        lastUpdated => 0,
        context     => q{Help for template variable},
    },

    'by keyword keyword' => {
        message     => q{The keyword that was requested.},
        lastUpdated => 0,
        context     => q{Help for template variable},
    },

    'by keyword pagesLoop' => {
        message     => q{A loop of pages that contain the requested keyword.},
        lastUpdated => 0,
        context     => q{Help for template variable},
    },

    'by keyword title' => {
        message     => q{The title of this page in the loop.},
        lastUpdated => 0,
        context     => q{Help for template variable},
    },

    'by keyword url' => {
        message     => q{The url of this page in the loop.},
        lastUpdated => 0,
        context     => q{Help for template variable},
    },

    'by keyword synopsis' => {
        message     => q{The synopsis of this page in the loop.},
        lastUpdated => 0,
        context     => q{Help for template variable},
    },

    'by keyword formHeader' => {
        message     => q{HTML code to start the form for entering in sub-keywords.  This will be empty unless the current user can administer this wiki},
        lastUpdated => 0,
        context     => q{Help for template variable},
    },

    'by keyword formFooter' => {
        message     => q{HTML code to end the form for entering in sub-keywords.  This will be empty unless the current user can administer this wiki},
        lastUpdated => 0,
        context     => q{Help for template variable},
    },

    'by keyword keywordForm' => {
        message     => q{HTML code for the field for entering in sub-keywords.  This will be empty unless the current user can administer this wiki},
        lastUpdated => 0,
        context     => q{Help for template variable},
    },

};

1;
