package WebGUI::i18n::English::File;

our $I18N = {
	'file add/edit title' => {
		message => q|File, Add/Edit|,
        	lastUpdated => 1106683494,
	},

	'file add/edit body' => {
                message => q|<P>File Assets are files on your site that are available for users to download. If you would like to have multiple files available, try using a FilePile Asset.</P>

<P>Since Files are Assets, so they have all the properties that Assets do.  Below are the properties that are specific to Image Assets:</P>

<P><b>New file to upload</b><br/>
Enter the path to a file, or use the "Browse" button to find a file on your local hard
drive that you would like to be uploaded.

<P><b>Current file</b><br/>
If this Asset already contains a file, a link to the file with its associated icon will be shown.

|,
		context => 'Describing file add/edit form specific fields',
		lastUpdated => 1106762796,
	},

	'current file' => {
		message => q|Current file|,
		context => q|label for File asset form|,
		lastUpdated => 1106762086
	},

	'new file' => {
		message => q|New file to upload|,
		context => q|label for File asset form|,
		lastUpdated => 1106762088
	},

};

1;
