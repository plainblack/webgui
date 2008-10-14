package WebGUI::i18n::English::Asset_Image;
use strict;

our $I18N = {

        'assetName' => {
                message => q|Image|,
                context => q|label for Asset Manager, getName|,
                lastUpdated => 1128639970,
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

	'image size description' => {
		message => q|Current size of the image, width and height, in pixels|,
		context => q|hover help for Image asset form, image size field|,
		lastUpdated => 1130531739,
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

	'new width description' => {
		message => q|New Width|,
		context => q|Enter the new width for the Image in pixels.  If 0 is entered, a new width will be calculated using the height.|,
		lastUpdated => 1130538990
	},

	'new height' => {
		message => q|New Height|,
		context => q|label to resize the image|,
		lastUpdated => 1106765841
	},

	'new height description' => {
		message => q|New Height|,
		context => q|Enter the new height for the Image in pixels.  If 0 is entered, a new height will be calculated using the width.|,
		lastUpdated => 1130538987
	},

	'image template title' => {
		message => q|Image Template Variables|,
        lastUpdated => 1184820779,
	},

	'image template description' => {
		message => q|Image templates allow you to display information about the image, such as its thumbnail, filename or the image itself.|,
        lastUpdated => 1130440964,
	},

	'fileIcon' => {
		message => q|The icon which describes the type of file.|,
		lastUpdated => 1148952544,
	},

	'fileUrl' => {
		message => q|The URL to the file.|,
		lastUpdated => 1148952544,
	},

	'controls' => {
		message => q|An iconic toolbar for working with the file.|,
		lastUpdated => 1166827236,
	},

	'thumbnail variable' => {
		message => q|A URL to the thumbnail of the image;|,
		lastUpdated => 1148952544,
	},

	'thumbnailSize' => {
		message => q|An integer representing the length of the longest side |,
		lastUpdated => 1148952544,
	},

	'parameters variable' => {
		message => q|Any additional IMG tag parameters that were entered with the image was uploaded.|,
		lastUpdated => 1148952544,
	},

	'filename' => {
		message => q|The name of the image.|,
		lastUpdated => 1148952544,
	},

	'storageId' => {
		message => q|The internal storage ID used for the file.|,
		lastUpdated => 1148952544,
	},

	'title' => {
		message => q|The title set for the file when it was uploaded, or the filename if none was entered.|,
		lastUpdated => 1148952544,
	},

	'menuTitle' => {
		message => q|The menu title, displayed in navigations, set for the image when it was uploaded, or the filename if none was entered.|,
		lastUpdated => 1148952544,
	},

	'image template asset var title' => {
		message => q|Image Template, Asset Variables|,
        	lastUpdated => 1166827631,
	},

};

1;
