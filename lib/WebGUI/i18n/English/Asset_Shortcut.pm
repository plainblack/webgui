package WebGUI::i18n::English::Asset_Shortcut;

our $I18N = {

	'disable content lock' => {
		message => q|Disable content lock?|,
		lastUpdated => 0,
		context=> q|asset property|
	},

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

	'Resolve Multiples' => {
		message => q|Resolve Multiples?|,
		lastUpdated => 1127959325
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
		message => q|<p>With the Shortcut you can mirror an asset in another location. This is useful if you want to reuse the same content in multiple sections of your site.</p>

<p><b>NOTES:</b><br />
The shortcut is not available through the Add Content menu, but instead through the shortcut icon on each Asset's toolbar.
</p>
|,
		lastUpdated => 1130878635,
	},

        '85 description' => {
                message => q|Content for this shortcut.  This is normally not used, unless you opt to have the shortcut's
description replace the description of the original Asset.|,
                lastUpdated => 1119905806,
        },

        'shortcut template title description' => {
                message => q|Select a template from the list to display the Shortcut.|,
                lastUpdated => 1119905806,
        },

        'override asset template description' => {
                message => q|Select a template that can optionally override the original Asset template.|,
                lastUpdated => 1119905806,
        },

        '7 description' => {
                message => q|Set to "yes" to use the title of the shortcut instead of the original title of the asset.|,
                lastUpdated => 1119905806,
        },

        '8 description' => {
                message => q|Set to "yes" to use the display title setting of the shortcut instead of the original display title setting of the asset.|,
                lastUpdated => 1119905806,
        },

        '9 description' => {
                message => q|Set to "yes" to use the description of the shortcut instead of the original description of the asset.|,
                lastUpdated => 1119905806,
        },

        '1 description' => {
                message => q|Provides a link to the original Asset being mirrored.|,
                lastUpdated => 1119905806,
        },

        '10 description' => {
                message => q|Set to "yes" to use the override template of the shortcut instead of the original template of the asset.|,
                lastUpdated => 1119905806,
        },

        'Shortcut by alternate criteria description' => {
                message => q|Set to "yes" to enable selecting a asset based upon custom criteria. Metadata must be enabled for this option to function properly.|,
                lastUpdated => 1127927137,
        },

        'disable content lock description' => {
                message => q|By default if you proxy by alternate criteria the shortcut will lock on to a particular piece of content and show you only that piece of content until the end of your session. However, in some circumstances you may wish for this content to rotate. You can do that by disabling the content lock.|,
                lastUpdated => 1119905806,
        },

        'Resolve Multiples description' => {
                message => q|Sets the order to use when multiple assets are selected. Random means that if multiple assets match the shortcut criteria then the shortcut will select a random asset.<br>
Most Recent will select the most recent asset that match the shortcut criteria.|,
                lastUpdated => 1127959329,
        },

        'Criteria description' => {
                message => q|A statement to determinate what to mirror, in the form of "color = blue and weight != heavy". Multiple expressions may be joined with "and" and "or". <br>
A property or value must be quoted if it contains spaces. Feel free to use the criteria builder to build your statements.|,
                lastUpdated => 1119905806,
        },


	'greater than' => {
		message => q|greater than|,
		lastUpdated => 1053183804
	},

	'assetName' => {
		message => q|Shortcut|,
		lastUpdated => 1031514049
	},

	'9' => {
		message => q|Override description?|,
		lastUpdated => 1053183804
	},

	'Shortcut by alternate criteria' => {
		message => q|Shortcut by alternate criteria?|,
		lastUpdated => 1127927125
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

	'override asset template' => {
		message => q|Override Asset Template|,
		lastUpdated => 1119896310
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

	'The unique name of a user preference parameter you are inventing' => {
		message => q|The unique name of a user preference parameter you are inventing.|,
		lastUpdated => 1133619940,
	},


# -----------------------------------------------

	'Label for This Field.' => {
		message => q|Label for This Field.|,
		lastUpdated => 1133619940,
	},

	'Possible values for this Field.  Only applies to selectList and checkList.' => {
		message => q|Possible values for this Field.  Only applies to selectList and checkList.|,
		lastUpdated => 1133619940,
	},

	'Default Value for this field.' => {
		message => q|Default Value for this field.|,
		lastUpdated => 1133619940,
	},

	'Field' => {
		message => q|Field|,
		lastUpdated => 1133619940,
	},

	'shortcut template title' => {
		message => q|Shortcut Template|,
		lastUpdated => 1133619940,
	},

	'Hover Help Description for this Field' => {
		message => q|Hover Help (Description) for this Field.|,
		lastUpdated => 1133619940,
	},

	'Type of Field' => {
		message => q|Type of Field|,
		lastUpdated => 1133619940,
	},

	'Edit User Preference Field' => {
		message => q|Edit User Preference Field|,
		lastUpdated => 1133619940,
	},

};

1;
