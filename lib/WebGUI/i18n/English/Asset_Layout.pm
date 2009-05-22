package WebGUI::i18n::English::Asset_Layout;
use strict;

our $I18N = {
	'assetName' => {
		message => q|Page Layout|,
        	lastUpdated => 1128832065,
		context=>q|The name of the layout asset.|
	},

        'template description' => {
                message => q|Choose a template from the list to display the contents of the Page Layout Asset and
its children.|,
                lastUpdated => 1146455452,
        },

        'assets to hide description' => {
                message => q|This list contains one checkbox for each child Asset of the Page Layout.  Select the
checkbox for any Asset that you do not want displayed in the Page Layout Asset.
|,
                lastUpdated => 1119410080,
        },

	'layout template title' => {
		message => q|Page Layout Template|,
        	lastUpdated => 1109987374,
	},

	'showAdmin' => {
		message => q|A conditional showing if the current user has turned on Admin Mode and can edit this Asset.|,
		lastUpdated => 1148963207,
	},

	'dragger.icon' => {
		message => q|An icon that can be used to change the Asset's position with the mouse via a click and
drag interface.  If showAdmin is false, this variable is empty.|,
		lastUpdated => 1148963207,
	},

	'dragger.init' => {
		message => q|HTML and Javascript required to make the click and drag work. If showAdmin is false, this variable is empty.|,
		lastUpdated => 1148963207,
	},

	'position1_loop' => {
		message => q|Each position in the template has a loop which has the set of Assets
which are to be displayed inside of it.  Assets that have not been
specifically placed are put inside of position 1.|,
		lastUpdated => 1148963207,
	},

	'id' => {
		message => q|The Asset ID of the Asset.|,
		lastUpdated => 1148963207,
	},

	'content' => {
		message => q|The rendered content of the Asset.|,
		lastUpdated => 1148963207,
	},

	'isUncommitted' => {
		message => q|A boolean, whether or not this Asset is committed|,
		lastUpdated => 1208146216,
        context => q|Help variable in the position1_loop|,
	},

	'layout template body' => {
                message => q|<p>The following variables are available in Page Layout Templates:</p>
		|,
		context => 'Describing the file template variables',
		lastUpdated => 1148963247,
	},

	'assets to hide' => {
		message => q|Assets To Hide|,
		lastUpdated => 1227648416
	},

	'823' => {
		message => q|Go to the new page.|,
		lastUpdated => 1038706332
	},

	'847' => {
		message => q|Go back to the current page.|,
		lastUpdated => 1039587250
	},

	'layout asset template variables title' => {
		message => q|Layout Asset Template Variables|,
		lastUpdated => 1167425005
	},

	'layout asset template variables body' => {
		message => q|Every asset provides a set of variables to most of its
templates based on the internal asset properties.  Some of these variables may
be useful, others may not.|,
		lastUpdated => 1167425006
	},

	'templateId' => {
		message => q|The Id of the template used to display this Asset.|,
		lastUpdated => 1164841027
	},

	'assetsToHide' => {
		message => q|The asset ID's of all Assets that should not be displayed in this Asset, separated by Unix-style newline characters.|,
		lastUpdated => 1164841027
	},

	'contentPositions' => {
		message => q|A string representing the different places for assets to be displayed, and which assets go in which place in the correct order.|,
		lastUpdated => 1164841027
	},

	'templateId' => {
		message => q|The Id of the template used to display this Asset.|,
		lastUpdated => 1164841027
	},
	
	'asset order asc' => {
		message     => q|To the Bottom|,
		lastUpdated => 1164841027
	},
	
	'asset order desc' => {
		message     => q|To the Top|,
		lastUpdated => 1164841027
	},
	
	'asset order label' => {
		message     => q|Add New Assets|,
		lastUpdated => 1164841027
	},
	
	'asset order hoverHelp' => {
		message	    => q|Choose whether you'd like new or unpositioned assets added to the top or bottom of the first content position on the page.|,
		lastUpdated => 1210967539
	},

    'mobileTemplateId label' => {
        message => 'Mobile Template',
    },

    'mobileTemplateId description' => {
        message => 'Choose the template to use if viewing this Page Layout in a mobile browser.',
    },
};

1;
