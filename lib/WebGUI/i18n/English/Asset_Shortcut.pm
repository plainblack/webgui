package WebGUI::i18n::English::Asset_Shortcut;

our $I18N = {

	'85' => {
		message => q|Description|,
		lastUpdated => 1031514049
	},

	'Criteria' => {
		message => q|Criteria|,
		lastUpdated => 1053183804
	},

	'Random' => {
		message => q|Random|,
		lastUpdated => 1053183804
	},

	'Resolve Multiples?' => {
		message => q|Resolve Multiples?|,
		lastUpdated => 1053183804
	},

	'7' => {
		message => q|Override title?|,
		lastUpdated => 1053183682
	},

	'isnt' => {
		message => q|isn't|,
		lastUpdated => 1053183804
	},

	'is' => {
		message => q|is|,
		lastUpdated => 1053183804
	},

	'2' => {
		message => q|Edit Shortcut|,
		lastUpdated => 1031514049
	},

	'equal to' => {
		message => q|equal to|,
		lastUpdated => 1053183804
	},

	'1' => {
		message => q|Asset to Mirror|,
		lastUpdated => 1031514049
	},

	'6' => {
		message => q|With the shortcut you can mirror an asset. This is useful if you want to reuse the same content in multiple sections of your site.
<p>

<b>NOTE:</b> The shortcut is not available through the Add Content menu, but instead through the shortcut icon on each Asset's toolbar.
<p>

<b>Asset to Mirror</b><br>
Provides a link to the original asset being mirrored.
<p>

<b>Override title?</b><br>
Set to "yes" to use the title of the shortcut instead of the original title of the asset.
<p>

<b>Override description?</b><br>
Set to "yes" to use the description of the shortcut instead of the original description of the asset.
<p>

<b>Override display title?</b><br>
Set to "yes" to use the display title setting of the shortcut instead of the original display title setting of the asset.
<p>

<b>Override template?</b><br>
Set to "yes" to use the template of the shortcut of the original template of the asset.
<p>

<b>Shortcut by alternate criteria?</b><br>
Set to "yes" to enable selecting a asset based upon custom criteria. Metadata must be enabled for this option to function properly.
<p>

<b>Resolve Multiples?</b><br>
Sets the order to use when multiple assets are selected. Random means that if multiple assets match the shortcut criteria then the shortcut will select a random asset.<br>
Most Recent will select the most recent asset that match the shortcut criteria.
<p>

<b>Criteria</b><br>
A statement to determinate what to mirror, in the form of "color = blue and weight != heavy". Multiple expressions may be joined with "and" and "or". <br>
A property or value must be quoted if it contains spaces. Feel free to use the criteria builder to build your statements.
<p>
<b>NOTE:</b> Shortcut will automatically add a template variable to the asset it's mirroring called 'originalURL'. You can use that to link to the original content that's being mirrored.
<p>
|,
		lastUpdated => 1109561313,
	},

	'greater than' => {
		message => q|greater than|,
		lastUpdated => 1053183804
	},

	'3' => {
		message => q|Shortcut|,
		lastUpdated => 1031514049
	},

	'9' => {
		message => q|Override description?|,
		lastUpdated => 1053183804
	},

	'Shortcut by alternate criteria?' => {
		message => q|Shortcut by alternate criteria?|,
		lastUpdated => 1053183804
	},

	'not equal to' => {
		message => q|not equal to|,
		lastUpdated => 1053183804
	},

	'less than' => {
		message => q|less than|,
		lastUpdated => 1053183804
	},

	'8' => {
		message => q|Override display title?|,
		lastUpdated => 1053183719
	},

	'AND' => {
		message => q|AND|,
		lastUpdated => 1053183804
	},

	'4' => {
		message => q|Asset mirroring failed. Perhaps the original asset has been deleted.|,
		lastUpdated => 1031514049
	},

	'Most Recent' => {
		message => q|Most Recent|,
		lastUpdated => 1053183804
	},

	'10' => {
		message => q|Override template?|,
		lastUpdated => 1053183837
	},

	'OR' => {
		message => q|OR|,
		lastUpdated => 1053183804
	},

	'5' => {
		message => q|Shortcut, Add/Edit|,
		lastUpdated => 1031514049
	},

	'shortcut template title' => {
		message => q|Shortcut Template|,
		lastUpdated => 1109525763,
	},

	'shortcut template body' => {
		message => q|<p>These variables are available in Shortcut Templates:</p>
<p><b>shortcut.content</b><br>
The content from the mirrored Asset.  If any overrides were enabled in the Shortcut then the override content will be used instead of the content from the mirrored Asset.</p>
<p><b>originalURL</b><br>
The URL to the Asset being mirrored by this Shortcut.</p>
<p><b>isShortcut</b><br>
A boolean indicating that this Asset is a Shortcut.  This can be used in conjuction with another boolean for Admin mode to quickly show Content Managers that this is a Shortcut Asset.</p>
<p><b>shortcut.label</b><br>
The word "Shortcut".</p>
                |,
		lastUpdated => 1109525761,
	},

};

1;
