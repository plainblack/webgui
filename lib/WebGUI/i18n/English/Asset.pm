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
<p>
<b>Title</b><br>
The title of the asset.  This should be descriptive, but not very long.  If left
blank, this will be set to "Untitled".
</p>

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
The date when users may begin viewing this page. Note that before this date only content managers with the rights to edit this page will see it.
</p>

<p>
<b>End Date</b><br>
The date when users will stop viewing this page. Note that after this date only content managers with the rights to edit this page will see it.
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
        lastUpdated => 1104621979,
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
	}

};

1;
