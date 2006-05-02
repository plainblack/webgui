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

	'resize image title' => {
		message => q|Image, Resize|,
		context => q|Title for help entry|,
		lastUpdated => 1130532366,
	},

	'resize image body' => {
		message => q|<p>This allows you to grow, shrink or stretch images inside of WebGUI. Simply enter
		the new width and height in the form, press Submit and the image will be changed on the server.</p>
		<p>There is no undo or versioning for this task.  You may wish to download a copy of the image
		in case you make a mistake.</p>
		<p>If you know the new width or height, and do not want to calculate the other dimension, just enter 0
		in that field and WebGUI will calculate it for you.</p>|,
		lastUpdated => 1130531896,
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
		message => q|Image Template|,
        	lastUpdated => 1130440964,
	},

	'image template description' => {
		message => q|Image templates allow you to display information about the image, such as its thumbnail, filename or the image itself.|,
        	lastUpdated => 1130440964,
	},

	'image template body' => {
                message => q|<p>The following variables are available in Image Templates:</p>

<P><b>fileIcon</b><br />
The icon which describes the type of file.

<P><b>fileUrl</b><br />
The URL to the file.

<P><b>controls</b><br />
A toolbar for working with the file.

<P><b>thumbnail</b><br />
A URL to the thumbnail of the image;

<P><b>thumbnailSize</b><br />
An integer representing the length of the longest side 

<P><b>parameters</b><br />
Any additional IMG tag parameters that were entered with the image was uploaded.

<P><b>filename</b><br />
The name of the image.

<P><b>storageId</b><br />
The internal storage ID used for the file.

<P><b>title</b><br />
The title set for the file when it was uploaded, or the filename if none was entered.

<P><b>menuTitle</b><br />
The menu title, displayed in navigations, set for the image when it was uploaded, or the filename if none was entered.

		|,
		context => 'Describing the image template variables',
		lastUpdated => 1130456281,
	},

	

};

1;
