package WebGUI::i18n::English::Asset;

our $I18N = {

	'change' => {
		message => q|Change?|,
		lastUpdated => 1099344172,
		context => q|Used when editing an entire branch, and asks whether the user wants to change this field recursively.|
	},

	'assets' => {
		message => q|Assets|,
		lastUpdated => 1099344172,
		context => q|The title of the asset manager for the admin console.|
	},
	
	'properties' => {
		message => q|Properties|,
		lastUpdated => 1099344172,
		context => q|The name of the properties tab on the edit page.|
	},
	
	'asset id' => {
		message => q|Asset ID|,
		lastUpdated => 1099344172,
	},

        'asset fields body' => {
                message => q|
<P><B>Asset ID</B><BR>This is the unique identifier WebGUI uses to keep track of this Asset instance. Normal users should never need to be concerned with the Asset ID, but some advanced users may need to know it for things like SQL Reports. The Asset ID is not editable.</P>

<p>
<b>Title</b><br>
The title of the asset.  This should be descriptive, but not very long.  If left
blank, this will be set to "Untitled".
</p>
<P><I>Note:</I> You should always specify a title, even if the Asset template will not use it. In various places on the site, like the Page Tree, Clipboard and Trash, the <B>Title</B> is used to distinguish this Asset from others.</p>

<p>
<b>Menu Title</b><br>
A shorter title that will appear in navigation.  If left blank, this will default
to the <b>Title</b>.
</p>

<p>
<b>URL</b><br>
The URL for this asset.  It must be unique.  If this field is left blank, then
a URL will be made from the parent's URL and the <b>Menu Title</b>.
</p>

<p>
<b>Synopsis</b><br>
A short description of this Asset. 
</p>

<p>
<b>Hide from navigation?</b><br>
Whether or not this asset will be hidden from the navigation menu and site maps.
</p>

<p>
<b>Open in new window?</b><br>
Select yes to open this asset in a new window.
</p>

<p>
<b>Encrypt page?</b><br>
Should this page be served over SSL?
</p>

<p>
<b>Start Date</b><br>
The date when users may begin viewing this page. Before this date only Content Managers with the rights to edit this page will see it.
</p>

<p>
<b>End Date</b><br>
The date when users will stop viewing this page. After this date only Content Managers with the rights to edit this page will see it.
</p>

<p>
<b>Owner</b><br>
The owner of a page is usually the person who created the page. This user always has full edit and viewing rights on the page.
</p>
<p>
<b>NOTE:</b> The owner can only be changed by an administrator.
</p>

<p>
<b>Who can view?</b><br>
Choose which group can view this page. If you want both visitors and registered users to be able to view the page then you should choose the "Everybody" group.
</p>

<p>
<b>Who can edit?</b><br>
Choose the group that can edit this page. The group assigned editing rights can also always view the page.
</p>

        |,
        context => q|Describing the form to add or edit an Asset.|,
        lastUpdated => 1104622720,
  },

    'asset fields title' => {
        message => q|Common Asset Fields|,
        lastUpdated => 1100463645,
    },

    'asset macros title' => {
        message => q|Asset Macros|,
        lastUpdated => 1104544909,
    },

    'asset macros body' => {
        message => q|<P>These macros are used to access Assets on your site.</P>
<P><B>&#94;AssetProxy</B>();<BR>
<B>&#94;AssetProxy</B>(<i>Asset URL</i>);<BR>
This macro is used to render an Asset and display it inline according
to its template.  Any Asset can be displayed, including Navigations,
images, links to files for downloading, snippets or for displaying
content from another part of the site on this page.

<P><B>&#94;FileUrl</B>();<BR>
<B>&#94;FileUrl</B>(<i>Asset URL</i>);<BR>
This macro is used to return a filesystem URL to an Asset that isn't in the database (file, image, snippet) identified by its Asset URL.

<P><B>&#94;RandomAssetProxy</B>();<BR>
<B>&#94;RandomAssetProxy</B>(<i>Asset URL</i>);<BR>
This macro works similarly to the &#94;<B>AssetProxy</B>(); macro except instead of displaying the
Asset, it picks a random Asset from the descendents of the Asset whose URL is supplied as the
argument.
</p>
        |,
        lastUpdated => 1104545608,
    },

	'asset' => {
		message => q|Asset|,
        	lastUpdated => 1100463645,
		context => 'The default name of all assets.'
	},

	'snippet' => {
		message => q|Snippet|,
        	lastUpdated => 1104629663,
		context => 'Default name of all snippets'
	},

	'snippet add/edit title' => {
		message => q|Snippet, Add/Edit|,
        	lastUpdated => 1104630516,
	},

	'snippet add/edit body' => {
                message => q|<P>Snippets are bits of text that may be reused on your site. Thinks like java scripts, style sheets, flash animations, or even slogans are all great snippets. Best of all, if you need to change the text, you can change it in only one location.</P>

<P>Since Snippets are Assets, so they have all the properties that Assets do.</P>

<P><b>Snippet</b><br/>
This is the snippet.  Either type it in or copy and paste it into the form field.
|,
                context => 'Describing snippets and its sole field.',
        	lastUpdated => 1104630518,
	},

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
		context => 'Help text for redirects'
	},

};

1;
