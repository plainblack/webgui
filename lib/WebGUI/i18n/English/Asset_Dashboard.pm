package WebGUI::i18n::English::Asset_Dashboard;

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
	'dashboard template field label' => {
		message => q|Dashboard Template|,
		lastUpdated => 1133619940
	},

	'dashboard add/edit title' => {
		message => q|Dashboard Add/Edit|,
		lastUpdated => 1133619940
	},
	'dashboard add/edit body' => {
		message => q|<p>The dashboard is a container asset that acts like a portal.  When in Admin mode, the dashboard admin is actually editing the Visitor's (default) view.  When not in admin mode, the dashboard admin is editing their own personalized view.  Shortcuts are the main source of functionality for the Dashboard.  See the Shortcut add/edit documentation for details.</p><p><b>NOTE:</b> Due to limitations in Internet Explorer the dashboard does not work well with XHTML Strict compliance enabled. Therefore, your style templates for dashboard pages should not be XHTML Strict. The other way to get around this problem is to ensure that when using XHTML Strict compliance, make sure that you do not constrain the dashboard inside of a div tag with a width attached to it.</p>|,
		lastUpdated => 1165510892
	},
	'dashboard template field label' => {
		message => q|Dashboard Template|,
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

};

1;
