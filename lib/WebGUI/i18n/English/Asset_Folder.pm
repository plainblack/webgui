package WebGUI::i18n::English::Asset_Folder;

our $I18N = {

	'visitor cache timeout' => {
		message => q|Visitor Cache Timeout|,
		lastUpdated => 0
		},

	'visitor cache timeout help' => {
		message => q|Since all visitors will see this asset the same way, we can cache it to increase performance. How long should we cache it?<br /> <br /><b>UI Level: 8</b>|,
		lastUpdated => 0
		},

        '847' => {
                   message => qq|Go back to the current page.|,
                   lastUpdated => 1039587250,
                 },

        '823' => {
                   message => qq|Go to the new page.|,
                   lastUpdated => 1038706332,
                 },

	'folder add/edit title' => {
		message => q|Folder, Add/Edit|,
        	lastUpdated => 1106683494,
	},

	'folder add/edit body' => {
		message => q|<p>Folder Assets are used to display lists of Assets and subfolders just like a file browser in an operating system.</p>
<P>Folders are Wobjects, so they have all the same properties as Wobjects and Assets.  Folders also have these unique properties and functions:</p>

|,
        	lastUpdated => 1126238060,
	},

        'folder template description' => {
                message => q|This menu permits you to select a template to style the display of the Folder contents</p>|,
                lastUpdated => 1127278558,
        },

        'What Next description' => {
                message => q|After creating a new Folder, do you wish to go back to the original page where you created the Folder
to do you want to go to the new Folder?</p>|,
                lastUpdated => 1127959255,
        },

	'folder template title' => {
		message => q|Folder Template|,
        	lastUpdated => 1106683494,
	},

	'folder template body' => {
		message => q|The following variables are available in Folder Templates:
<p><b>subfolder_loop</b><br>
A loop containing all Folder assets which are children of the Folder.

<blockquote>

<p><b>id</b><br>
The assetId of the Folder.

<p><b>url</b><br>
The url of the Folder.

<p><b>title</b><br>
The title of the Folder.

<p><b>icon.small</b><br>
The URL to a small icon of the appropriate type for this Asset.

<p><b>icon.big</b><br>
The URL to a big icon of the appropriate type for this Asset.

</blockquote>

<p><b>file_loop</b><br>
A loop containing all non-Folder assets which are children of the Folder.

<blockquote>

<p><b>id</b><br>
The assetId of the Asset.

<p><b>canView</b><br>
A conditional indicating if the current user can view this Asset.

<p><b>title</b><br>
The title of the Asset.

<p><b>synopsis</b><br>
The synopsis of the Asset.

<p><b>size</b><br>
The size of the Asset, formatted.

<p><b>date.epoch</b><br>
The date the Asset was last updated, relative to the epoch.

<p><b>icon.small</b><br>
A URL to a small icon that represents the Asset.

<p><b>icon.big</b><br>
A URL to an icon that represents the Asset.

<p><b>type</b><br>
The type of this Asset.

<p><b>url</b><br>
The URL of the Asset.

<p><b>isImage</b><br>
A conditional indicating if this Asset is an Image Asset.

<p><b>canEdit</b><br>
A conditional indicating if this Asset can be edited by the current user.

<p><b>controls</b><br>
The editing control bar for this child

<p><b>isFile</b><br>
A conditional indicating if this Asset is a File Asset.

<p><b>thumbnail.url</b><br>
If this Asset is an Image, the URL to the thumbnail for it.

<p><b>file.url</b><br>
If this Asset is a File Asset (File, Image or Zip Archive), the URL to the actual file for downloading.  Otherwise,
this variable will be empty

</blockquote>
		|,
        	lastUpdated => 1121790331,
	},

	'assetName' => {
		message => q|Folder|,
		context => q|label for Asset Manager|,
		lastUpdated => 1121703567,
	},

};

1;
