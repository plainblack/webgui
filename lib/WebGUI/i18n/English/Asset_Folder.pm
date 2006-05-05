package WebGUI::i18n::English::Asset_Folder;

our $I18N = {

	'sort alphabetically' => {
		message => q|Sort alphabetically?|,
		lastUpdated => 0
		},

	'sort alphabetically help' => {
		message => q|Do you want to sort the items in this folder alphabetically? If you select no then it will sort according to rank.|,
		lastUpdated => 0
		},

	'visitor cache timeout' => {
		message => q|Visitor Cache Timeout|,
		lastUpdated => 0
		},

	'visitor cache timeout help' => {
		message => q|Since all visitors will see this asset the same way, we can cache it to increase performance. How long should we cache it?|,
		lastUpdated => 1146454627
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
<p>Folders are Wobjects, so they have all the same properties as Wobjects and Assets.  Folders also have these unique properties and functions:</p>

|,
		lastUpdated => 1126238060,
	},

        'folder template description' => {
                message => q|<p>This menu permits you to select a template to style the display of the Folder contents</p>|,
                lastUpdated => 1146797271,
        },

        'What Next description' => {
                message => q|<p>After creating a new Folder, do you wish to go back to the original page where you created the Folder
to do you want to go to the new Folder?</p>|,
                lastUpdated => 1146797272,
        },

	'folder template title' => {
		message => q|Folder Template|,
        	lastUpdated => 1106683494,
	},

	'folder template body' => {
		message => q|<p>The following variables are available in Folder Templates:</p>

<p><b>addFile.url</b><br />
The url for adding files to the Folder.</p>

<p><b>addFile.label</b><br />
The internationalized label for adding files to the Folder.</p>

<p><b>subfolder_loop</b><br />
A loop containing all Folder assets which are children of the Folder.</p>

<blockquote>

<p><b>id</b><br />
The assetId of the Folder.</p>

<p><b>url</b><br />
The url of the Folder.</p>

<p><b>title</b><br />
The title of the Folder.</p>

<p><b>icon.small</b><br />
The URL to a small icon of the appropriate type for this Asset.</p>

<p><b>icon.big</b><br />
The URL to a big icon of the appropriate type for this Asset.</p>

</blockquote>

<p><b>file_loop</b><br />
A loop containing all non-Folder assets which are children of the Folder.</p>

<blockquote>

<p><b>id</b><br />
The assetId of the Asset.</p>

<p><b>canView</b><br />
A conditional indicating if the current user can view this Asset.</p>

<p><b>title</b><br />
The title of the Asset.</p>

<p><b>synopsis</b><br />
The synopsis of the Asset.</p>

<p><b>size</b><br />
The size of the Asset, formatted.</p>

<p><b>date.epoch</b><br />
The date the Asset was last updated, relative to the epoch.</p>

<p><b>icon.small</b><br />
A URL to a small icon that represents the Asset.</p>

<p><b>icon.big</b><br />
A URL to an icon that represents the Asset.</p>

<p><b>type</b><br />
The type of this Asset.</p>

<p><b>url</b><br />
The URL of the Asset.</p>

<p><b>isImage</b><br />
A conditional indicating if this Asset is an Image Asset.</p>

<p><b>canEdit</b><br />
A conditional indicating if this Asset can be edited by the current user.</p>

<p><b>controls</b><br />
The editing control bar for this child</p>

<p><b>isFile</b><br />
A conditional indicating if this Asset is a File Asset.</p>

<p><b>thumbnail.url</b><br />
If this Asset is an Image, the URL to the thumbnail for it.</p>

<p><b>file.url</b><br />
If this Asset is a File Asset (File, Image or Zip Archive), the URL to the actual file for downloading.  Otherwise,
this variable will be empty</p>

</blockquote>
		|,
        	lastUpdated => 1146775736,
	},

	'assetName' => {
		message => q|Folder|,
		context => q|label for Asset Manager|,
		lastUpdated => 1121703567,
	},

	'add file label' => {
		message => q|Add files.|,
		lastUpdated => 1146649269,
	},
};

1;
