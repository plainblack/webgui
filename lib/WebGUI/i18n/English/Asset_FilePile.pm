package WebGUI::i18n::English::Asset_FilePile;

our $I18N = {
	'file pile add/edit title' => {
		message => q|File Pile, Add/Edit|,
        	lastUpdated => 1111735119,
	},

	'file pile add/edit body' => {
                message => q|<p>File Pile Assets allow you to upload lots of files to your site all at once.  This is the only function that File Piles have.  If you want to display the files that have been uploaded, you'll need to use another Asset or Wobject.</p>

<p>Unlike most Assets, File Piles do not share the base set of Asset properties.  All File Piles
have the following properties:</p>

|,
		context => 'Describing file pile add/edit form specific fields',
		lastUpdated => 1146630312,
	},

        '886 description' => {
                message => q|<p>Whether or not this asset will be hidden from the navigation menu and site maps.</p>|,
                lastUpdated => 1119214815,
        },

        '940 description' => {
                message => q|<p>Select yes to open this asset in a new window.
</p>|,
                lastUpdated => 1119214815,
        },

        '108 description' => {
                message => q|<p>The owner of a page is usually the person who created the page. This user always has full edit and viewing rights on the page.
</p>|,
                lastUpdated => 1119214815,
        },

        '872 description' => {
                message => q|<p>Choose which group can view this page. If you want both visitors and registered users to be able to view the page then you should choose the "Everybody" group.
</p>|,
                lastUpdated => 1119214815,
        },

        '871 description' => {
                message => q|<p>Choose the group that can edit this page. The group assigned editing rights can also always view the page.
</p>|,
                lastUpdated => 1119214815,
        },

        'upload files description' => {
                message => q|<p>This is where files can be uploaded from your computer.  You can upload to to 100 files at a time.  File sizes should not exceed 100MB in size.
</p>|,
                lastUpdated => 1139206282,
        },


	'add pile' => {
		message => q|Add a Pile of Files|,
		context => q|label for File Pile Admin Console|,
		lastUpdated => 1107387324,
	},

	'assetName' => {
		message => q|File Pile|,
		context => q|label for Asset Manager, getName|,
		lastUpdated => 1128639521,
	},

	'upload files' => {
		message => q|Upload Files|,
		context => q|label for File Pile asset form|,
		lastUpdated => 1107387247,
	},

        '886' => {
                   lastUpdated => 1044727952,
                   message => q|Hide from navigation?|
                 },

        '886 description' => {
                message => q|<p>Whether or not this asset will be hidden from the navigation menu and site maps.</p>|,
                lastUpdated => 1119149899,
        },

        '940' => {
                   lastUpdated => 1050438829,
                   message => q|Open in new window?|
                 },

        '940 description' => {
                message => q|<p>Select yes to open this asset in a new window.</p>|,
                lastUpdated => 1119149899,
        },

        '108' => {
                   lastUpdated => 1031514049,
                   message => q|Owner|
                 },

        '108 description' => {
                message => q|<p>The owner of a asset is usually the person who created the asset. This user always has full edit and viewing rights on the asset.
</p>
<p> <b>NOTE:</b> The owner can only be changed by an administrator.
</p>|,
                lastUpdated => 1119149899,
        },

        '872' => {
                   lastUpdated => 1044218038,
                   message => q|Who can view?|
                 },

        '872 description' => {
                message => q|<p>Choose which group can view this asset. If you want both visitors and registered users to be able to view the asset then you should choose the "Everybody" group.</p>|,
                lastUpdated => 1119149899,
        },

        '871' => {
                   lastUpdated => 1044218026,
                   message => q|Who can edit?|
                 },

        '871 description' => {
                message => q|<p>Choose the group that can edit this asset. The group assigned editing rights can also always view the asset.</p>|,
                lastUpdated => 1119149899,
        },
        
};

1;
