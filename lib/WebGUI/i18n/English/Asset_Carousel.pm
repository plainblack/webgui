package WebGUI::i18n::English::Asset_Carousel;  

use strict; 

our $I18N = { 
	'assetName' => { 
		message => q|Carousel|,
		lastUpdated => 0, 
		context => q|The name of this asset, used in the admin bar.|
	},

	'carousel template label' => {
		message => q|Carousel template|,
		lastUpdated => 0,
		context => q|Label of the carousel template field on the edit screen.|
	},

    'carousel template description' => {
        message => q|Select a template for this carousel.|,
        lastUpdated => 0,
        context => q|Description of the carousel template field, used as hover help.|
    },

    'payload label' => {
        message => q|Payload|,
        lastUpdated => 0,
        context => q|Label of the payload field on the edit screen.|
    },

    'payload description' => {
        message => q|Enter a javacript script tag, flash object html, etc to process this carousel's items.|,
        lastUpdated => 0,
        context => q|Description of the payload field, used as hover help.|
    },
};

1;
#vim:ft=perl
