package WebGUI::i18n::English::Asset_WikiPage;

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

        'add/edit title' => {
                message => q|Wiki Page, Add/Edit|,
                lastUpdated => 1165790228,
        },

        'add/edit body' => {
                message => q|The add/edit screen for this Asset is templated.  Fields seen by the user will not have hoverHelp.  Variables available for use in the template are listed below:|,
                lastUpdated => 1165790228,
        },

};

1;
