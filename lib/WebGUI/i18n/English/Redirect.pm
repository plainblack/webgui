package WebGUI::i18n::English::Redirect;

our $I18N = {

	'redirect url' => {
		message => q|Redirect URL|,
        	lastUpdated => 1104719740,
		context => 'Default name of all redirects'
	},

	'redirect add/edit title' => {
		message => q|Page Redirect, Add/Edit|,
        	lastUpdated => 1104630516,
	},

	'redirect add/edit body' => {
		message => q|
<P>The Page Redirect Asset causes the user's browser to be redirected to another page. It does this if it is viewed standalone, as part of a Layout Asset, or proxied via a macro.</P>
<P><b>NOTE:</b> The redirection will be disabled while in admin mode in order to allow editing the properties of the page.</P>
<P>
<b>Redirect URL</b><br>
The URL where the user will be redirected.
</P>            |,
        	lastUpdated => 1104718231,
		context => 'Help text for redirects',
	},

};

1;
