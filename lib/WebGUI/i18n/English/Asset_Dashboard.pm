package WebGUI::i18n::English::Asset_Dashboard;
use strict;

our $I18N = {
	'dashboard template field label' => {
		message => q|Dashboard Template|,
		lastUpdated => 1133619940
	},
	'dashboard template description' => {
		message => q|Choose a Dashboard/Portal Layout template.  The default is the <b>Three Column Layout</b>.|,
		lastUpdated => 1133619940
	},
	'assetName' => {
		message => q|Dashboard (beta)|,
		lastUpdated => 1133619940
	},
	'dashboard adminsGroupId description' => {
		message => q|Which group may administer this Dashboard: Add/Edit/Remove Available Dashlets, Preferences, and Templates|,
		lastUpdated => 1133619940
	},
	'dashboard adminsGroupId field label' => {
		message => q|Who can manage?|,
		lastUpdated => 1133619940
	},
	'dashboard usersGroupId field label' => {
		message => q|Who can personalize?|,
		lastUpdated => 1133619940
	},
	'dashboard usersGroupId description' => {
		message => q|The group whose users may save their personalizations/preferences to the site.  If someone is in the "Who can view?" group but not in this group, they can personalize the arrangement of the Dashlets (whose positions will be saved in cookies), but they will not be able to edit the preferences of any particular Dashlet.|,
		lastUpdated => 1133619940
	},
	'assets to hide' => {
		message => q|Assets To Hide.|,
		lastUpdated => 1118942468
	},

    'assets to hide description' => {
            message => q|This list contains one checkbox for each child Asset of the Page Layout.  Select the
checkbox for any Asset that you do not want displayed in the Page Layout Asset.
|,
            lastUpdated => 1119410080,
    },

    'hide new content list' => {
        message => q|Hide New Content List|,
        lastUpdated => 1230356526,
    },

    'Edit Dashlet' => {
        message => q|Edit Dashlet|,
        lastUpdated => 1230356526,
        context => q|A dashlet is an asset being displayed by the Dashboard.  It may not have a translation.|,
    },

    'Is static' => {
        message => q|Is static|,
        lastUpdated => 1230356526,
        context => q|Can it be moved, or rearranged?|,
    },

    'Is static help' => {
        message => q|Can this dashlet be moved around on the dashboard by users of the Dashboard?|,
        lastUpdated => 1230356526,
        context => q|Can it be moved, or rearranged?|,
    },

    'Is required' => {
        message => q|Is required|,
        lastUpdated => 1230356526,
        context => q|Can it be deleted from a dashboard by a user?|,
    },

    'Is required help' => {
        message => q|Can this dashlet be deleted from the dashboard by users of the Dashboard?|,
        lastUpdated => 1230356526,
        context => q|Can it be moved, or rearranged?|,
    },

    'Dashboard Template Variables' => {
        message => q|Dashboard Template Variables|,
        lastUpdated => 1230356526,
        context => q|Template variable help|,
    },

    'dragger.init' => {
        message => q|Javascript necessary to initialize the Dashboard.  It should be placed at the bottom of the template.|,
        lastUpdated => 1230356526,
        context => q|Template variable help|,
    },

    'fullUrl' => {
        message => q|The full URL to this Dashboard, including sitename and any gateway configuration.|,
        lastUpdated => 1230356526,
        context => q|Template variable help|,
    },

    'canEdit' => {
        message => q|A boolean which will be true if the current user can edit this Dashboard.|,
        lastUpdated => 1230356526,
        context => q|Template variable help|,
    },

    'positionN_loop' => {
        message => q|By default, there are four positions, numbered 1, 2, 3 and 4.  Each loop contains the list of assets that have been placed into it.  Position 1 is special, because it also contains any assets which have not been specifically placed by the user.|,
        lastUpdated => 1230356526,
        context => q|Template variable help|,
    },

    'id' => {
        message => q|Asset ID of the current dashlet.|,
        lastUpdated => 1230356526,
        context => q|Template variable help|,
    },

    'content' => {
        message => q|The dashlet's content|,
        lastUpdated => 1230356526,
        context => q|Template variable help|,
    },

    'dashletTitle' => {
        message => q|The title of the dashlet, the raw asset title.|,
        lastUpdated => 1230356526,
        context => q|Template variable help|,
    },

    'shortcutUrl' => {
        message => q|If this dashlet is a shortcut, the URL of the shortcut.|,
        lastUpdated => 1230356526,
        context => q|Template variable help|,
    },

    'dashletUrl' => {
        message => q|The URL to this dashlet.|,
        lastUpdated => 1230356526,
        context => q|Template variable help|,
    },

    'canDelete' => {
        message => q|A boolean that is true if the current user is in the group who can personalize the dashboard and if this dashlet is not set to be required.|,
        lastUpdated => 1230356526,
        context => q|Template variable help|,
    },

    'canMove' => {
        message => q|A boolean that is true if the current user is in the group who can personalize the dashboard and if this dashlet is not set to be static.|,
        lastUpdated => 1230356526,
        context => q|Template variable help|,
    },

    'canPersonalize' => {
        message => q|A boolean that is true if the current user is in the group who can personalize the dashboard.|,
        lastUpdated => 1230356526,
        context => q|Template variable help|,
    },

    'showReloadIcon' => {
        message => q|A boolean that is true if this dashlet is a shortcut, and the Show Reload Icon property is set to be true.|,
        lastUpdated => 1230356526,
        context => q|Template variable help|,
    },

    'canEditUserPrefs' => {
        message => q|A boolean that is true if the current user is in the Registered Users group, and the dashlet is a Shortcut, and the Shortcut has preferences that can be configured.|,
        lastUpdated => 1230356526,
        context => q|Template variable help|,
    },

    'dashboard asset template variables title' => {
        message => q|Dashboard Asset Template Variables|,
        lastUpdated => 1230356526,
        context => q|Template variable help|,
    },

    'templateId' => {
        message => q|The GUID of the template used to display the dashboard|,
        lastUpdated => 1230356526,
        context => q|Template variable help|,
    },

    'adminsGroupId' => {
        message => q|The GUID of the group that is allowed to set the default appearance of the dashboard for visitors.|,
        lastUpdated => 1230356526,
        context => q|Template variable help|,
    },

    'usersGroupId' => {
        message => q|The GUID of the group that is allowed to change the appearance of their own dashboard.|,
        lastUpdated => 1230356526,
        context => q|Template variable help|,
    },

    'isInitialized' => {
        message => q|A boolean which is true if this Dashboard has been initialized.  You really don't need to know more than that.|,
        lastUpdated => 1230356526,
        context => q|Template variable help|,
    },

    'Add New Content' => {
        message => q|Add New Content|,
        lastUpdated => 1230356526,
        context => q|i18n phrase for the view template|,
    },

    'editFormUrl' => {
        message => q|The URL to fetch the user overrides form for this dashlet, whether it is Shortcut based or a regular asset with overrides.|,
        lastUpdated => 1230356526,
        context => q|i18n phrase for the view template|,
    },

};

1;
