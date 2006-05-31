package WebGUI::i18n::English::Asset_ZipArchive;

our $I18N = {

	 'zip_error' => {
	   message => q|An error occurred while trying to unzip the archive.  Please check to make sure the file is not password protected and can be accessed by the operating system.|,
	   lastUpdated => 1119068809
	  },

	 'bad_archive' => {
		message => q|Not a valid archive.  Please use zip or tar archives to import files |,
		lastUpdated => 1119068809
	  },

	  'unzip_error' => {
		message => q|File could not be unzipped.  Please upload a valid archive|,
		lastUpdated => 1119068809
	  },

     'template label' => {
         message => q|Zip Archive Template|,
         context => q|label for Zip Archive asset form|,
         lastUpdated => 1121703035,
     },

	'show page' => {
		message => q|Initial Page|,
		context => q|label for Zip Archive asset form|,
		lastUpdated => 1106762088
	 },

	'assetName' => {
		message => q|Zip Archive|,
		context => q|label for Asset Manager, getName|,
		lastUpdated => 1121703035,
	},

	'show page description' => {
		message => q|Enter the name of the file which serves as the "base" file for this archive.  This is the page which will initially be served up|,
		lastUpdated => 1119068745
	 },

	 'za_error' => {
	 	message => q|This asset only accepts valid tar and zip files|,
		lastUpdated => 1119068745
	 },

	 'za_show_error' => {
	 	message => q|You must provide an initial page to direct users|,
		lastUpdated => 1119068745
	 },

	 'zip archive add/edit title' => {
	 	message => q|Zip Archive, Add/Edit|,
		lastUpdated => 1119068745   
	 },

	 'zip archive add/edit body' => {
         message => q|<p>Zip Archive Assets are assets on your site that are allow you to upload a zip archive (as either zip or tar) containing files that require collateral (static html pages with images or movies, etc) that you wish to display to your users outside of the WebGUI context, but retain WebGUI's file security.  The asset uzips the folder in a WebGUI storage location, and redirects the user to the initial page when the link provided is clicked</p>|,
		 lastUpdated => 1119068839,
	 },

	 'zip archive template title' => {
		message => q|Zip Archive, Template|,
        	lastUpdated => 1109287565,
	 },

	'controls' => {
		message => q|Asset controls for administrators.|,
		lastUpdated => 1148953404,
	},

	'error' => {
		message => q|Any errors reported during upload or unzip|,
		lastUpdated => 1148953404,
	},

	'fileUrl' => {
		message => q|URL to the initial file|,
		lastUpdated => 1148953404,
	},

	'fileIcon' => {
		message => q|Initial file file type icon|,
		lastUpdated => 1148953404,
	},


	 'zip archive template body' => {
                message => q|<p>The following variables are available in Zip Archive Templates:</p>
		|,
		context => q|Describing the zip archive template variables|,
		lastUpdated => 1148953449,
	},


};

1;
