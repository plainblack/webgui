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
		message => q|The following variables are available in Folder Templates: |,
        	lastUpdated => 1146775736,
	},

	'addFile.url' => {
		message => q|The url for adding files to the Folder.|,
		lastupdated => 0,
		context => q|Template variable description.|
	},

	'addFile.label' => {
		message => q|The internationalized label for adding files to the Folder.|,
		lastupdated => 0,
		context => q|Template variable description.|
	},

	'subfolder_loop' => {
		message => q|A loop containing all Folder assets which are children of the Folder.  The order of the Folders will be determined by the Sort Alphabetically flag in the edit screen.|,
		lastupdated => 1167417470,
		context => q|Template variable description.|
	},

	'folder id' => {
		message => q|The assetId of the Folder.|,
		lastupdated => 0,
		context => q|Template variable description.|
	},

	'folder url' => {
		message => q|The url of the Folder.|,
		lastupdated => 0,
		context => q|Template variable description.|
	},

	'folder title' => {
		message => q|The title of the Folder.|,
		lastupdated => 0,
		context => q|Template variable description.|
	},

	'folder icon.small' => {
		message => q|The URL to a small icon of the appropriate type for this Asset.|,
		lastupdated => 0,
		context => q|Template variable description.|
	},

	'folder icon.big' => {
		message => q|The URL to a big icon of the appropriate type for this Asset.|,
		lastupdated => 0,
		context => q|Template variable description.|
	},

	'file_loop' => {
		message => q|A loop containing all non-Folder assets which are children of the Folder.  The order of the Folders will be determined by the Sort Alphabetically flag in the edit screen.|,
		lastupdated => 1167417468,
		context => q|Template variable description.|
	},

	'id' => {
		message => q|The assetId of the Asset.|,
		lastupdated => 0,
		context => q|Template variable description.|
	},

	'canView' => {
		message => q|A conditional indicating if the current user can view this Asset.|,
		lastupdated => 0,
		context => q|Template variable description.|
	},

	'title' => {
		message => q|The title of the Asset.|,
		lastupdated => 0,
		context => q|Template variable description.|
	},

	'synopsis' => {
		message => q|The synopsis of the Asset.|,
		lastupdated => 0,
		context => q|Template variable description.|
	},

	'size' => {
		message => q|The size of the Asset, formatted.|,
		lastupdated => 0,
		context => q|Template variable description.|
	},

	'date.epoch' => {
		message => q|The date the Asset was last updated, relative to the epoch.|,
		lastupdated => 0,
		context => q|Template variable description.|
	},

	'icon.small' => {
		message => q|A URL to a small icon that represents the Asset.|,
		lastupdated => 0,
		context => q|Template variable description.|
	},

	'icon.big' => {
		message => q|A URL to an icon that represents the Asset.|,
		lastupdated => 0,
		context => q|Template variable description.|
	},

	'type' => {
		message => q|The type, or the name, of this Asset, such as Post, Article, Collaboration System, etc.|,
		lastupdated => 1170365384,
		context => q|Template variable description.|
	},

	'url' => {
		message => q|The URL of the Asset.|,
		lastupdated => 0,
		context => q|Template variable description.|
	},

	'isImage' => {
		message => q|A conditional indicating if this Asset is an Image Asset.|,
		lastupdated => 0,
		context => q|Template variable description.|
	},

	'canEdit' => {
		message => q|A conditional indicating if this Asset can be edited by the current user.|,
		lastupdated => 0,
		context => q|Template variable description.|
	},

	'controls' => {
		message => q|The editing control bar for this child.|,
		lastupdated => 0,
		context => q|Template variable description.|
	},

	'isFile' => {
		message => q|A conditional indicating if this Asset is a File Asset.|,
		lastupdated => 0,
		context => q|Template variable description.|
	},

	'thumbnail.url' => {
		message => q|If this Asset is an Image, the URL to the thumbnail for it.|,
		lastupdated => 0,
		context => q|Template variable description.|
	},

	'file.url' => {
		message => q|If this Asset is a File Asset (File, Image or Zip Archive), the URL to the actual file for downloading.  Otherwise, this variable will be empty.|,
		lastupdated => 0,
		context => q|Template variable description.|
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

	'asset template variables title' => {
		message => q|Folder Asset Template Variables|,
		lastUpdated => 1167416930
	},

	'asset template variables body' => {
		message => q|Every asset provides a set of variables to most of its
templates based on the internal asset properties.  Some of these variables may
be useful, others may not.|,
		lastUpdated => 1167416933
	},

	'sortAlphabetically' => {
		message => q|A conditional that indicates that subfolders and files will be sorted alphabetically.|,
		lastUpdated => 1167416930
	},

	'templateId' => {
		message => q|The ID of the template used to display the Folder contents.|,
		lastUpdated => 1167416930
	},

	'visitorCacheTimeout' => {
		message => q|In seconds, how long output from this Asset will be cached.|,
		lastUpdated => 1167416930
	},

};

1;
