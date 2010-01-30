package WebGUI::i18n::English::Asset_File;
use strict;

our $I18N = {
	'cache timeout' => {
		message => q|Cache Timeout|,
		lastUpdated => 0
		},

	'cache timeout help' => {
		message => q|Since all users will see this asset the same way, we can cache it for long periods of time to increase performance. How long should we cache it?|,
		lastUpdated => 1146454555
		},

	'file add/edit title' => {
		message => q|File, Add/Edit|,
        	lastUpdated => 1106683494,
	},

	'file template title' => {
		message => q|File Template Variables|,
        lastUpdated => 1184820764,
	},

	'file template' => {
		message => q|File Template|,
        lastUpdated => 1264812976,
	},

	'fileSize' => {
		message => q|The size (in bytes/kilobytes/megabytes, etc) of the file.|,
		lastUpdated => 1148952092,
	},

	'fileIcon' => {
		message => q|The icon which describes the type of file.|,
		lastUpdated => 1148952092,
	},

	'fileUrl' => {
		message => q|The URL to the file.|,
		lastUpdated => 1148952092,
	},

	'controls' => {
		message => q|A toolbar for working with the file.|,
		lastUpdated => 1148952092,
	},

	'filename' => {
		message => q|The name of the file.|,
		lastUpdated => 1148952092,
	},

	'storageId' => {
		message => q|The internal storage ID used for the file.|,
		lastUpdated => 1148952092,
	},

	'title' => {
		message => q|The title set for the file when it was uploaded, or the filename if none was entered.|,
		lastUpdated => 1148952092,
	},

	'menuTitle' => {
		message => q|The menu title, displayed in navigations, set for the file when it was uploaded, or the filename if none was entered.|,
		lastUpdated => 1148952092,
	},

	'current file' => {
		message => q|Current file|,
		context => q|label for File asset form|,
		lastUpdated => 1106762086
	},

	'current file description' => {
		message => q|If this Asset already contains a file, a link to the file with its associated icon will be shown.|,
		lastUpdated => 1119068809
	},

	'new file' => {
		message => q|New file to upload|,
		context => q|label for File asset form|,
		lastUpdated => 1106762088
	},

        'assetName' => {
                message => q|File|,
                context => q|label for Asset Manager, getName|,
                lastUpdated => 1128640132,
        },

	'new file description' => {
		message => q|Enter the path to a file, or use the "Browse" button to find a file on your local hard drive that you would like to be upload.|,
		lastUpdated => 1165517718
	},

	'file template description' => {
		message => q|File templates allow you to display information about the file, such as its filename, size or an icon representing the file type.  In addition to the variables below, the File Asset template also has all the default Asset template variables. |,
        	lastUpdated => 1140196488,
	},

	'file template asset var title' => {
		message => q|File Template, Asset Variables|,
        	lastUpdated => 1130456105,
	},

	'cacheTimeout' => {
                message => q|The length of time set for the cache timeout.
		|,
		lastUpdated => 1166824158,
	},

	'filename var' => {
                message => q|The name of the file this Asset holds.  It does not include the path to the file.
		|,
		lastUpdated => 1166824158,
	},

	'storageId' => {
                message => q|The ID of the WebGUI storage element used to store the file.
		|,
		lastUpdated => 1166824158,
	},

	'templateId' => {
                message => q|The ID of the template used to display the file.
		|,
		lastUpdated => 1166824158,
	},

	'file not found' => {
		message => q|<!DOCTYPE HTML PUBLIC "-//IETF//DTD HTML 2.0//EN">
			     <HTML><HEAD>
			     <TITLE>404 Not Found</TITLE>
			     </HEAD><BODY>
			     <H1>Not Found</H1>
			     The requested URL %s was not found on this server.<P>
			     </BODY></HTML> 
			    |,
		lastUpdated => 0,
	},

};

1;
