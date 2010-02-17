package WebGUI::i18n::English::Asset_ZipArchive;
use strict;

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

     'template description' => {
         message => q|Choose a template to style and display the contents of the Zip Archive|,
         context => q|hover help for Zip Archive asset form|,
         lastUpdated => 1265822565,
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

	 'zip archive template title' => {
		message => q|Zip Archive, Template Variables|,
        	lastUpdated => 1184820890,
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

	'zip archive asset variables title' => {
		message => q|Zip Archive, Asset Template Variables|,
        	lastUpdated => 1109287565,
	 },

	'zip archive asset variables body' => {
                message => q|<p>The following variables are included by default in the Zip Archive Templates.  They may or may not be particularly useful:</p>
		|,
		context => q|Describing the zip archive template asset variables|,
		lastUpdated => 1148953449,
	},

	'showPage' => {
                message => q|The name of the file from the Zip Archive that will be displayed when this Asset is viewed.
		|,
		lastUpdated => 1166823840,
	},

	'templateId' => {
                message => q|The ID of the template used to display the contents of the Zip Archive.
		|,
		lastUpdated => 1166823840,
	},

	 'noInitialPage' => {
                message => q|Error:  No initial page specified.|,
		lastUpdated => 1169699552,
	},

	 'noInitialPage var' => {
                message => q|An internationalized label for an error when no initial page was specified.|,
		lastUpdated => 1169699552,
	},

	 'noFileSpecified' => {
                message => q|Error:  No file specified.|,
		lastUpdated => 1169699552,
	},

	 'noFileSpecified var' => {
                message => q|An internationalized label for an error when no file was specified.|,
		lastUpdated => 1169699552,
	},


};

1;
