package WebGUI::i18n::English::Asset;

our $I18N = {
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

    'asset add/edit body' => {
        message => q|
<p>
<b>Title</b><br>
The title of the asset.  This should be descriptive, but not very long.
</p>

<p>
<b>Menu Title</b><br>
A shorter title that will appear in navigation.  If left blank, this will default
to the <b>Title</b>.
</p>

<p>
<b>URL</b><br>
The URL for this asset.
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
<b>Cache timeout</b><br>
How long should this asset be cached for someone who is logged in to WebGUI.
</p>

<p>
<b>Visitor cache timeout</b><br>
How long should this asset be cached for someone who a visitor to WebGUI.
</p>

<p>
<b>Synopsis</b><br>
A short description of an asset.  It is used in default meta tags, site maps and navigation.
</p>

        |,
        context => q|Describing the form to add or edit an Asset.|,
        lastUpdated => 1100462749,
    },

    'asset add/edit title' => {
        message => q|Asset, Add/Edit|,
        lastUpdated => 1100463645,
	},

};

1;
