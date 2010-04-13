package WebGUI::i18n::English::Asset_WikiPage;
use strict;

our $I18N =
{
 'protectQuestionLabel' => { lastUpdated => 1160157064, message => 'Protect this page from editing?' },
 'titleLabel' => { lastUpdated => 1160157064, message => 'Title' },
 'contentLabel' => { lastUpdated => 1160157064, message => 'Content' },
 'attachmentLabel' => { lastUpdated => 1160157064, message => 'Attachment(s)' },
 'editing' => { lastUpdated => 1160157064, message => 'Editing' },
 'assetName' => { lastUpdated => 1160157064, message => 'Wiki Page' },
 'page received' => { lastUpdated => 1160157064, message => q|Your page has been received and is being processed so it can be added to the site. It will be available for further editing after being processed. Please be patient.| },
 'editLabel' => { lastUpdated => 1160157064, message => q|Edit| },
 'viewLabel' => { lastUpdated => 1160157064, message => q|View| },
 'historyLabel' => { lastUpdated => 1160425002, message => q|History| },
 'deleteLabel' => { lastUpdated => 1161121377, message => q|Delete| },

	'title' => {
		message => q|The title of this page.|,
		lastUpdated => 1161121377,
	},

        'formHeader' => {
                message => q|HTML code to start the form for the edit page form.|,
                lastUpdated => 1165790228,
        },

        'formTitle' => {
                message => q|HTML code for a form to enter or change the page title.|,
                lastUpdated => 1165790228,
        },

        'formContent' => {
                message => q|HTML code for a form to enter or change the content of the page.|,
                lastUpdated => 1166040566,
        },

        'formProtect' => {
                message => q|HTML code for a checkbutton to indicate whether or not the page should be protected.  Pages that
		are protected can only be edited by those with administrative privileges to the Wiki.|,
                lastUpdated => 1165790228,
        },

        'formSubmit' => {
                message => q|A submit button with an internationalized label to submit changes to the page.|,
                lastUpdated => 1165790228,
        },

        'formFooter' => {
                message => q|HTML code to end the form for the edit page form.|,
                lastUpdated => 1165790228,
        },

        'isNew' => {
                message => q|A boolean that is true if this wiki page is new.|,
                lastUpdated => 1165790228,
        },

        'canAdminister' => {
                message => q|A boolean that is true if the user is in the group that has administrative privileges to the Wiki holding this page.|,
                lastUpdated => 1165790228,
        },

        'deleteUrl' => {
                message => q|A URL to delete this page.|,
                lastUpdated => 1165790228,
        },

        'deleteLabel variable' => {
                message => q|An internationalized label to go with deleteUrl.|,
                lastUpdated => 1165790228,
        },

        'titleLabel variable' => {
                message => q|An internationalized label to go with formTitle.|,
                lastUpdated => 1165790228,
        },

        'contentLabel variable' => {
                message => q|An internationalized label to go with formContent.|,
                lastUpdated => 1165790228,
        },

        'protectQuestionLabel variable' => {
                message => q|An internationalized label to go with formProtect.|,
                lastUpdated => 1165790228,
        },

        'isProtected' => {
                message => q|A boolean that is true if this page currently is set to be protected.|,
                lastUpdated => 1165790228,
        },

        'locked' => {
                message => q|Locked|,
                lastUpdated => 1253139992,
        },

        'add/edit title' => {
                message => q|Wiki Page, Add/Edit Template|,
                lastUpdated => 1165790228,
        },

        'view title' => {
                message => q|Wiki Page, View Template|,
                lastUpdated => 1165790228,
        },

        'view body' => {
                message => q|Variables available for use in the template are listed below:|,
                lastUpdated => 1166047618,
        },

        'viewLabel variable' => {
                message => q|An internationalized label for viewing the content of a page.  Useful for tabbed interfaces to
		the Wiki Page.|,
                lastUpdated => 1166047913,
        },

        'editLabel variable' => {
                message => q|An internationalized label for editing the content of a page.  Useful for tabbed interfaces to
		the Wiki Page.|,
                lastUpdated => 1166047618,
        },

        'canEdit variable' => {
                message => q|A boolean that indicates whether the current user can edit a page, or not.|,
                lastUpdated => 1227501828,
        },

        'historyLabel variable' => {
                message => q|An internationalized label to go with historyUrl.|,
                lastUpdated => 1166047618,
        },

        'historyUrl' => {
                message => q|A URL to take the user to a screen with a history of edits and changes to this page.|,
                lastUpdated => 1166047618,
        },

	'wikiHomeLabel variable' => {
		message=>q|An internationalized label to go with wikiHomeUrl.|,
		lastUpdated=>1165816161,
	},

	'wikiHomeUrl' => {
		message=>q|A URL to take the user back to the Wiki front page.|,
		lastUpdated=>1165816166,
	},

        'recentChangesUrl' => {
                message => q|A URL to take the user to the screen where all changes to the the pages in this Wiki are listed.|,
                lastUpdated => 1165812138,
        },

        'recentChangesLabel' => {
                message => q|An internationalized label to go with recentChangesUrl.|,
                lastUpdated => 1165812138,
        },

        'mostPopularUrl' => {
                message => q|A URL to take the user to the screen where the most popular Wiki pages are listed.|,
                lastUpdated => 1165812138,
        },

        'mostPopularLabel variable' => {
                message => q|An internationalized label to go with mostPopularUrl.|,
                lastUpdated => 1165812138,
        },

        'searchLabel variable' => {
                message => q|An internationalized label to go with searchUrl|,
                lastUpdated => 1165812138,
        },

        'searchUrl' => {
                message => q|A URL to take the user to the screen search pages in this Wiki.|,
                lastUpdated => 1165816007,
        },

        'editContent' => {
                message => q|The rendered form for editing the content of this page.|,
                lastUpdated => 1165812138,
        },

        'content' => {
                message => q|The content of this page, with recognized titles and links changed into Wiki links.|,
                lastUpdated => 1166845905,
        },

        'vars title' => {
                message => q|WikiPage Template Asset Variables.|,
                lastUpdated => 1166845955,
        },

        'vars body' => {
                message => q|<p>These variables are available in the WikiPage template.  They are based on internal Asset variables and may or may not be useful.</p>|,
                lastUpdated => 1166845955,
        },

        'storageId' => {
                message => q|The Id of the object used to store attachments for this WikiPage.|,
                lastUpdated => 1166845955,
        },

        'content variable' => {
                message => q|The raw content of the WikiPage, with no titles or links processed.  You should never see the contents of this variable as it will be overridden in the template.|,
                lastUpdated => 1166846242,
        },

        'views' => {
                message => q|The number of times this WikiPage has been viewed.|,
                lastUpdated => 1166846242,
        },

        'actionTaken' => {
                message => q|The action taken to produce the current version of the WikiPage.  On a brand new page, this will be "Created".  Otherwise it will be "Edited".|,
                lastUpdated => 1166846242,
        },

        'actionTakenBy' => {
                message => q|The ID of the User who edited the page last.|,
                lastUpdated => 1166846434,
        },

        'history title' => {
                message => q|Wiki Page, Show History Template|,
                lastUpdated => 1166050472,
        },

        'history body' => {
                message => q|These variables are available for use in the template for displaying the history of edits and changes to a Wiki Page.|,
                lastUpdated => 1165812138,
        },

        'history toolbar' => {
                message => q|A toolbar with icons to delete, edit, or view revisions of this page.|,
                lastUpdated => 1165812138,
        },

        'history date' => {
                message => q|The date this revision of the page was committed.|,
                lastUpdated => 1165812138,
        },

        'history username' => {
                message => q|The name of the user who committed this page.|,
                lastUpdated => 1165812138,
        },

        'history actionTaken' => {
                message => q|The action that was taken in the revision, usually this will be "Edit".|,
                lastUpdated => 1165812138,
        },

        'history interval' => {
                message => q|How long ago the page was committed.|,
                lastUpdated => 1165812138,
        },

        'delete confirmation' => {
                message => q|Delete this revision?|,
                lastUpdated => 1166484508,
        },

        'delete page confirmation' => {
                message => q|Delete this wiki page?|,
                lastUpdated => 1169074288,
        },

        'deleteConfirmation' => {
                message => q|An internationalized message for confirming the deletion of a wiki page|,
                lastUpdated => 1169141075,
        },

    'help isSubscribed' => {
        message     => q{This variable is true if the user is subscribed to this wiki page},
        lastUpdated => 0,
        context     => q{Help for template variable},
    },

    'help subscribeUrl' => {
        message     => q{The URL to subscribe to this wiki page},
        lastUpdated => 0,
        context     => q{Help for template variable},
    },

    'help unsubscribeUrl' => {
        message     => q{The URL to unsubscribe from this wiki page},
        lastUpdated => 0,
        context     => q{Help for template variable},
    },

    'keywordsLoop' => {
        message     => q{A loop containing all keywords for this page is tagged with.},
        lastUpdated => 0,
        context     => q{Help for template variable},
    },

    'keyword title' => {
        message     => q{The name of this keyword.},
        lastUpdated => 0,
        context     => q{Help for template variable},
    },

    'keyword url' => {
        message     => q{The URL to view all pages tagged with this keyword.},
        lastUpdated => 0,
        context     => q{Help for template variable},
    },

    'help owner' => {
        message     => q{The username of the owner of the page},
        lastUpdated => 0,
        context     => q{Help for template variable},
    },

    'help subscription title' => {
        message     => q{Wiki Page Subscription E-mail},
        lastUpdated => 0,
        context     => 'Title for help page',
    },

    'help subscription body' => {
        message     => q{The template to send via e-mail to the people subscribed to the wiki},
        lastUpdated => 0,
        context     => 'Body text for help page',
    },

    'isFeatured label' => {
        message     => q{Feature this on the front page},
        lastUpdated => 0,
        context     => 'Label for asset property',
    },

    'isKeywordPage' => {
        message     => q{A boolean that is true if this page is a keyword page.},
        lastUpdated => 0,
        context     => 'template variable help',
    },

    'keyword_page_loop' => {
        message     => q{If this page is a keyword page, then this loop will contain a list of all pages tagged with this page's keyword.  The pagination variables will apply to the list of pages in this loop.  If this page is not a keyword page, the loop will be blank, and the pagination variables will not be present.},
        lastUpdated => 0,
        context     => 'template variable help',
    },

    'keyword page title' => {
        message     => q{The title of a page that has this keyword.},
        lastUpdated => 0,
        context     => 'template variable help',
    },

    'keyword page url' => {
        message     => q{The URL to a page that has this keyword.},
        lastUpdated => 0,
        context     => 'template variable help',
    },

};

1;
