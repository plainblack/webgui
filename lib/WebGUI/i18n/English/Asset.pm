package WebGUI::i18n::English::Asset;

our $I18N = {

	'change' => {
		message => q|Change recursively?|,
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
	
	'make package' => {
		message => q|Make package?|,
		lastUpdated => 1099344172,
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

<p>
<b>Extra Head Tags</b><br>
These tags will be added to the &lt;HEAD&gt; section of each page that the asset appears on.
</p>

<p>
<b>Make available as package?</b><br>
Many WebGUI tasks are very repetitive.  Automating such tasks in Webgui, such as
creating an Asset, or sets of Assets, is done by creating a package that can be reused
through the site.  Check yes if you want this Asset to be available as a package.
</p>

        |,
        context => q|Describing the form to add or edit an Asset.|,
        lastUpdated => 1106608067,
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

	'extra head tags' => {
		message => q|Extra HEAD tags|,
		context => q|label for Asset form|,
        	lastUpdated => 1106762071,
	},

	'create package' => {
		message => q|Make available as package?|,
		context => q|label for Asset form|,
        	lastUpdated => 1106762073,
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
		context => 'Help text for redirects',
	},

	'upload files' => {
		message => q|Upload Files|,
		context => q|label for File Pile asset form|,
		lastUpdated => 1107387247,
	},

	'add pile' => {
		message => q|Add a Pile of Files|,
		context => q|label for File Pile Admin Console|,
		lastUpdated => 1107387324,
	},

	'errorEmptyField' => {
		message => q|<p><b>Error: Field name may not be empty.</b></p>|,
		lastUpdated => 1089039511,
	},

	'Select...' => {
		message => q|Select...|,
		lastUpdated => 1089039511
	},

	'duplicateField' => {
		message => q|<p><b>Error: Fieldname "%field%" is already in use.</b></p>|,
		lastUpdated => 1089039511
	},

	'Metadata' => {
		message => q|Metadata|,
		lastUpdated => 1089039511
	},

	'Field name' => {
		message => q|Field name|,
		lastUpdated => 1089039511
	},

	'Enable Metadata ?' => {
		message => q|Enable Metadata ?|,
		lastUpdated => 1089039511
	},

	'Edit Metadata' => {
		message => q|Edit Metadata property|,
		lastUpdated => 1089039511
	},

	'Add new field' => {
		message => q|Add new metadata property|,
		lastUpdated => 1089039511
	},

	'Enable passive profiling ?' => {
		message => q|Enable passive profiling ?|,
		lastUpdated => 1089039511
	},

	'deleteConfirm' => {
		message => q|Are you certain you want to delete this Metadata property ?|,
		lastUpdated => 1089039511
	},

	'Field Id' => {
		message => q|Field Id|,
		lastUpdated => 1089039511
	},

	'Delete Metadata field' => {
		message => q|Delete Metadata property|,
		lastUpdated => 1089039511
	},

	'Illegal Warning' => {
		message => q|Enabling this feature is illegal in some countries, like Australia. In addition, some countries require you to add a warning to your site if you use this feature. Consult your local authorities for local laws. Plain Black Corporation is not responsible for your illegal activities, regardless of ignorance or malice.|,
		lastUpdated => 1089039511
	},

	'content profiling' => {
		message => q|Content Profiling|,
		lastUpdated => 1089039511,
		context => q|The title of the content profiling manager for the admin console.|
	},

	'metadata edit property body' => {
		message => q|
You may add as many Metadata properties to a Wobject as you like.<br>
<br>
<b>Field Name</b><br>
The name of this metadata property.It must be unique. <br>
It is advisable to use only letters (a-z), numbers (0-9) or underscores (_) for
the field names.
<p><b>Description<br>
</b>An optional description for this metadata property. This text is displayed
as mouseover text in the wobject properties tab.</p>
<p><b>Data Type<br>
</b>Choose the type of form element for this field.<b><br>
<br>
Possible Values<br>
</b>This field is used only for the Radio List and Select List data types. Enter
the values you wish to appear, one per line.</p>
|,
		lastUpdated => 1100232327
	},

        'metadata manage body' => {
                message => q|
<p>The content profiling system in WebGUI (also known as the metadata system) allows you to identify content. Metadata is
information about the content, and is defined in terms of property-value pairs.</p>
<p>Examples of metadata:</p>
<ul>
  <li>contenttype: sport</li>
  <li>adult content: no</li>
  <li>source: newspaper</li>
</ul>
<p>In the example <b>source: newspaper</b>, this metadata has a <i>property</i> named
<i>source</i> with a <i>value</i> of <i>newspaper</i>.</p>
<p>Metadata properties are defined globally, while Metadata values are set for
each wobject under the tab &quot;Metadata&quot; in the wobject properties.</p>
<p>Before you can use metadata in WebGUI, you'll have to switch the &quot;Enable Metadata
?&quot; setting to Yes in the Manage Settings menu.</p>
<p>Usage of metadata:</p>
<ul>
  <li><p><b>Passive Profiling</b><br>
    When passive profiling is switched on, every wobject viewed by a user will
    be logged.  The WebGUI scheduler summarizes the profiling information on a regular
    basis.
    This is basically content
    ranking based upon the user's Areas of Interest (AOI).<br>
    By default the summarizer runs once a day. However you can change that by
    setting: <b>passiveProfileInterval = &lt;number of seconds&gt;</b> in the
    WebGUI config file.</p>
  </li>
  <li><p><b>Areas of Interest Ranking</b><br>
    Metadata in combination with passive profiling produces AOI (Areas of
    Interest) information. You can retrieve the value of a metadata property
    with the &#94;AOIRank(); and &#AOIHits(); macros.</p>
  <li><p><b>Show content based upon criteria<br>
    </b>The Wobject Proxy allows you to select content based upon criteria like:<blockquote>
    contenttype = sport AND source != newspaper</blockquote>
    You can use the AOI macro's described above in the criteria, so you can
    present content based upon the users Areas of Interest. Example:<br>
    type = &#94;AOIRank(contenttype);</p></li>
</ul>|,
                context => q|Metadata help|,
                lastUpdated => 1099530955
        },

	'Metadata, Edit property' => {
		message => q|Metadata, Edit|,
		lastUpdated => 1089039511
	},

};

1;
