package WebGUI::i18n::English::Asset_FilePile;

our $I18N = {
	'file pile add/edit title' => {
		message => q|File Pile, Add/Edit|,
        	lastUpdated => 1111735119,
	},

	'file pile add/edit body' => {
                message => q|<P>File Pile Assets allow you to upload lots of files to your site all at once.  This is the only function that File Piles have.  If you want to display the files that have been uploaded, you'll need to use another Asset or Wobject.</P>

<P>Unlike most Assets, File Piles do not share the base set of Asset properties.  All File Piles
have the following properties:

<p>
<b>^International("886","Asset");</b><br>
Whether or not this asset will be hidden from the navigation menu and site maps.
</p>

<p>
<b>^International("940","Asset");</b><br>
Select yes to open this asset in a new window.
</p>

<p>
<b>^International("497","Asset");</b><br>
The date when users may begin viewing this page. Before this date only Content Managers with the rights to edit this page will see it.
</p>

<p>
<b>^International("498","Asset");</b><br>
The date when users will stop viewing this page. After this date only Content Managers with the rights to edit this page will see it.
</p>

<p>
<b>^International("108","Asset");</b><br>
The owner of a page is usually the person who created the page. This user always has full edit and viewing rights on the page.
</p>

<p>
<b>^International("872","Asset");</b><br>
Choose which group can view this page. If you want both visitors and registered users to be able to view the page then you should choose the "Everybody" group.
</p>

<p>
<b>^International("871","Asset");</b><br>
Choose the group that can edit this page. The group assigned editing rights can also always view the page.
</p>

<p>
<b>^International("upload files","Asset_FilePile");</b><br>
This is where files can be uploaded from your computer.
</p>

|,
		context => 'Describing file pile add/edit form specific fields',
		lastUpdated => 1111799160,
	},

	'add pile' => {
		message => q|Add a Pile of Files|,
		context => q|label for File Pile Admin Console|,
		lastUpdated => 1107387324,
	},

	'upload files' => {
		message => q|Upload Files|,
		context => q|label for File Pile asset form|,
		lastUpdated => 1107387247,
	},

};

1;
