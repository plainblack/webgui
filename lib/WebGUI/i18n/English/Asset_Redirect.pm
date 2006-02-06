package WebGUI::i18n::English::Asset_Redirect;

our $I18N = {

        'what do you want to do with this redirect' => {
                message => q|What do you want to do with this redirect?|,
                lastUpdated => 0,
        },

        'go to the redirect url' => {
                message => q|Go to the redirect URL.|,
                lastUpdated => 0,
        },

        'edit the redirect properties' => {
                message => q|Edit the redirect properties.|,
                lastUpdated => 0,
        },

        'go to the redirect parent page' => {
                message => q|Go to the redirect's parent.|,
                lastUpdated => 0,
        },

	'redirect url' => {
		message => q|Redirect URL|,
        	lastUpdated => 1104719740,
		context => 'Default name of all redirects'
	},

	'redirect add/edit title' => {
		message => q|Redirect, Add/Edit|,
        	lastUpdated => 1104630516,
	},

	'redirect add/edit body' => {
		message => q|
<P>The Redirect Asset causes the user's browser to be redirected to
another page.   The new page can be part of your site, or it can be on
another site altogether.  The redirection happens when the Redirect
Assets own URL is accessed, either by a link from a page, or from a
Navigation, or if the Asset's URL is entered into the browser directly.
However, if it is viewed as an element of a Page Asset, or proxied via
a macro onto a page, then no redirection will take place.</P>

<P><b>NOTE:</b>The redirection will be disabled while in admin mode in order to
allow editing the properties of the Asset.</P>

|,
        	lastUpdated => 1139251653,
		context => q|Help text for redirects|,
	},

        'redirect url description' => {
                message => q|The URL where the user will be redirected.|,
                lastUpdated => 1119574089,
        },

        'self_referential' => {
                message => q|Redirect is self-referential|,
                lastUpdated => 1119574089,
        },

        'assetName' => {
                message => q|Redirect|,
                context => q|label for Asset Manager, getName|,
                lastUpdated => 1128829970,
        },

};

1;
