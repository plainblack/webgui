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

	'carousel slideWidth label' => {
		message => q|Carousel slide width|,
		lastUpdated => 0,
		context => q|Slide, one "frame" or "page" in the Carousel.|
	},

    'carousel slideWidth description' => {
        message => q|Width in pixels.  The Carousel will not automatically resize itself for content of various widths.  Setting this width will help it render properly.  If left with the default, 0, then the width of the Carousel is set by the width of the first element.|,
        lastUpdated => 0,
        context => q|Description of the carousel template field, used as hover help.|
    },

	'carousel slideHeight label' => {
		message => q|Carousel slide height|,
		lastUpdated => 0,
		context => q|Slide, one "frame" or "page" in the Carousel.|
	},

    'carousel slideHeight description' => {
        message => q|Height in pixels.  The Carousel will not automatically resize itself for content of various heights.  Setting this height will help it render properly.  If left with the default, 0, then the height of the Carousel is set by the height of the first element.|,
        lastUpdated => 1280253825,
        context => q|Description of the carousel template field, used as hover help.|
    },

    'slideWidth' => {
        message => q|The width set for each slide in the Carousel|,
        lastUpdated => 0,
        context => q|Description of the carousel template field, used as hover help.|
    },
    
    'delete' => {
        message     => q{Delete},
        lastUpdated => 0,
        context     => q{Label for button to delete an item from the carousel},
    },

    'slideHeight' => {
        message => q|The height set for each slide in the Carousel|,
        lastUpdated => 0,
        context => q|Description of the carousel template field, used as hover help.|
    },

    'items label' => {
        message => q|Items|,
        lastUpdated => 0,
        context => q|Label of the items field on the edit screen.|
    },

    'items description' => {
        message => q|Enter this carousel's items.|,
        lastUpdated => 0,
        context => q|Description of the items field, used as hover help.|
    },

    'id label' => {
        message => q|ID|,
        lastUpdated => 0,
        context => q|Label of the item ID field on the edit screen.|
    },

    'id description' => {
        message => q|Enter a unique ID for this carousel item.|,
        lastUpdated => 0,
        context => q|Description of the item ID field, used as hover help.|
    },

    'carousel template help title' => {
        message => q|Carousel Template Variables|,
        lastUpdated => 0,
        context => q|Title of a template help page.|
    },

    'item_loop' => {
        message => q|A loop containing this carousel's items.|,
        lastUpdated => 0,
        context => q|Description of the item_loop tmpl_loop for the template help.|
    },

    'itemId' => {
        message => q|This carousel item's id.|,
        lastUpdated => 0,
        context => q|Description of the itemId tmpl_var for the template help.|
    },

    'text' => {
        message => q|This carousel item's text.|,
        lastUpdated => 0,
        context => q|Description of the text tmpl_var for the template help.|
    },

    'sequenceNumber' => {
        message => q|This carousel item's sequenceNumber.|,
        lastUpdated => 0,
        context => q|Description of the sequenceNumber tmpl_var for the template help.|
    },

    'carousel autoPlay description' => {
        message     => q{Should this carousel automatically scroll through its items?},
        lastUpdated => 0,
        context     => 'Description of asset property',
    },

    'carousel autoPlay label' => {
        message     => q{Auto Play},
        lastUpdated => 0,
        context     => 'Label for asset property',
    },

    'carousel autoPlayInterval label' => {
        message     => q{Auto Play Interval},
        lastUpdated => 0,
        context     => 'Label for asset property',
    },

    'carousel autoPlayInterval description' => {
        message     => q{Length of time in seconds between carousel slides},
        lastUpdated => 0,
        context     => 'Description of asset property',
    },

    'rich editor description' => {
        message     => q{Choose a rich editor to use for entering content in each pane of the Carousel.  The new setting will take effect the next time the Carousel is edited.},
        lastUpdated => 0,
        context     => 'Description of asset property',
    },

};

1;
#vim:ft=perl
