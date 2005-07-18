package WebGUI::i18n::English::Asset_Image;

our $I18N = {

	'image add/edit title' => {
		message => q|Image, Add/Edit|,
        	lastUpdated => 1106762707,
	},

	'image add/edit body' => {
                message => q|<P>Image Assets are used to store images that you want displayed on your site.</P>

<P>Since Images are a subset of File Assets, they have the properties that all Assets do as well
as File Assets.  Below are the properties that are specific to Image Assets:</P>|,
		context => 'Describing image add/edit form specific fields',
		lastUpdated => 1119409764,
	},

        'image' => {
                message => q|Image|,
                context => q|label for Asset Manager, getName|,
                lastUpdated => 1121703104,
        },
                                                                                                                              
	'new file description' => {
		message => q|Enter the path to a file, or use the "Browse" button to find a file on your local hard drive that you would like to be uploaded.|,
		lastUpdated => 1119068745
	},

        'Thumbnail size description' => {
                message => q|A thumbnail of the Image will be created and available for use in
templates.  The longest side of the thumbnail will be set to this size
in pixels.  It defaults to the value from the sitewide setting.|,
                lastUpdated => 1119409747,
        },

        'Parameters description' => {
                message => q|This is a set of extra parameters to the &lt;IMG&gt; tag that is generated for
the image.  You can use this to set alignment or to set the text that is displayed
if the image cannot be displayed (such as to a text-only browser).|,
                lastUpdated => 1119409747,
        },

        'Thumbnail description' => {
                message => q|If an image is currently stored in the Asset,  then its thumbnail will be
shown here.|,
                lastUpdated => 1119409747,
        },


	'thumbnail size' => {
		message => q|Thumbnail Size|,
		context => q|label for Image asset form|,
		lastUpdated => 1106609855
	},

	'parameters' => {
		message => q|Parameters|,
		context => q|label for Image asset form|,
		lastUpdated => 1106609855,
	},

	'thumbnail' => {
		message => q|Thumbnail|,
		context => q|label for Image asset form|,
		lastUpdated => 1106765841
	},
	
	'image size' => {
		message => q|Image Size|,
		context => q|label for Image asset form|,
		lastUpdated => 1106765841
	},
	
	'image size' => {
		message => q|Image Size|,
		context => q|label for Image asset form|,
		lastUpdated => 1106765841
	},
	
	'edit image' => {
		message => q|Edit Image|,
		context => q|label to edit the image|,
		lastUpdated => 1106765841
	},
	
	'resize image' => {
		message => q|Resize Image|,
		context => q|label to resize the image|,
		lastUpdated => 1106765841
	},
	
	'new width' => {
		message => q|New Width|,
		context => q|label to resize the image|,
		lastUpdated => 1106765841
	},
	
	'new height' => {
		message => q|New Height|,
		context => q|label to resize the image|,
		lastUpdated => 1106765841
	},
	

};

1;
