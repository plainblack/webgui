package WebGUI::i18n::English::MetaData;

our $I18N = {
	'errorEmptyField' => {
		message => q|<p><b>Error: Field name may not be empty.</b></p>|,
		lastUpdated => 1089039511
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
You may add as many Metadata properties as you like.<br>
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
</b>This field is used for the list types (Radio List and Select List). Enter
the values you wish to appear, one per line.</p>
|,
		lastUpdated => 1089039511
	},

        'metadata manage body' => {
                message => q|
<p>The content profiling system in WebGUI (also known as the meta data system) allows you to identify content. Metadata is
information about the content, and is defined in terms of property-value pairs.</p>
<p>Examples of metadata:</p>
<ul>
  <li>contenttype: sport</li>
  <li>adult content: no</li>
  <li>source: newspaper</li>
</ul>
<p>In the example <b>source: newspaper</b> is <i>source</i> the <i>property</i>
and <i>newspaper</i> the <i>value</i>.</p>
<p>Metadata properties are defined globally, while Metadata values are set for
each wobject under the tab &quot;Metadata&quot; in the wobject properties.</p>
<p>Before you can use metadata, you'll have to switch the &quot;Enable Metadata
?&quot; setting to Yes.</p>
<p>Usage of metadata:</p>
<ul>
  <li><b>Passive Profiling</b><br>
    When passive profiling is switched on, every wobject viewed by a user will
    be logged.&nbsp;<br>
    The WebGUI scheduler summarizes the profiling information on a regular
    basis.&nbsp;<br>
    The metadata is used to generate the summary. This is basically content
    ranking based upon the user's Areas of Interest (AOI).<br>
    By default the summarizer runs once a day. However you can change that by
    setting: <b>passiveProfileInterval = &lt;number of seconds&gt; </b>in the
    WebGUI config file. <br>
  </li>
</ul>
<ul>
  <li><b>Areas of Interest Ranking<br>
    </b>Metadata in combination with passive profiling produces AOI (Areas of
    Interest) information. You can retrieve the value of a metadata property
    with the ^AOIRank macro:<br>
    <br>
    ^AOIRank(contenttype); <br>
    This would return the highest ranked contenttype for this user, such as
    &quot;sport&quot;.<br>
    <br>
    ^AOIRank(contenttype,2);<br>
    This would return the second highest ranked contenttype for this user.<br>
    <br>
    You can also retrieve the number of hits a particular AOI has gotten:<br>
    <br>
    ^AOIHits(contenttype,sport); <br>
    This would return 99 is this user has looked at content that was tagged
    &quot;contenttype = sport&quot; 99 times. </li>
</ul>
<ul>
  <li><b>Show content based upon criteria<br>
    </b>The Wobject Proxy allows you to select content based upon criteria like:<br>
    contenttype = sport AND source != newspaper<br>
    <br>
    You can use the AOI macro's described above in the criteria, so you can
    present content based upon the users Areas of Interest. Example:<br>
    type = ^AOIRank(contenttype);</li>
</ul>|,
                lastUpdated => 1099039511,
                context => q|Metadata help|
        },

	'Metadata, Edit property' => {
		message => q|Metadata, Edit|,
		lastUpdated => 1089039511
	},

};

1;
