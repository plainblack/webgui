package WebGUI::i18n::English::FileManager;

our $I18N = {
	1 => q|File Manager|,

	3 => q|Proceed to add file?|,

	5 => q|File Title|,

	6 => q|File|,

	7 => q|Group to Download|,

	8 => q|Brief Synopsis|,

	9 => q|Edit File Manager|,

	10 => q|Edit File|,

	11 => q|Add a new file.|,

	12 => q|Are you certain that you wish to delete this file?|,

	14 => q|File|,

	15 => q|Description|,

	16 => q|Date Uploaded|,

	17 => q|Alternate Version #1|,

	18 => q|Alternate Version #2|,

	19 => q|You have no files available.|,

	20 => q|Paginate After|,

	74 => q|Add a new file.|,

	61 => q|File Manager, Add/Edit|,

	71 => q|The File Manager is designed to help you manage file distribution on your site. It allows you to specify who may view/download files from your site.
<p>

<b>Template</b><br/>
Choose a layout for the file manager.
<p/>

<b>Paginate After</b><br>
How many files should be displayed before splitting the results into separate pages? In other words, how many files should be displayed per page?
<p>

<b>Proceed to add download?</b><br>
If you wish to start adding files to download right away, leave this checked.
<p>

|,

	72 => q|File, Add/Edit|,

	73 => q|<b>File Title</b><br>
The title that will be displayed for this file. If left blank the filename will be used.
<p>

<b>File</b><br>
Choose the file from your hard drive that you wish to upload.
<p>

<b>Alternate Version #1</b><br>
An alternate version of the file. For instance, if the file was a JPEG, perhaps the alternate version would be a TIFF or a BMP.
<p>

<b>Alternate Version #2</b><br>
An alternate version of the file. For instance, if the file was a JPEG, perhaps the alternate version would be a TIFF or a BMP.
<p>

<b>Brief Synopsis</b><br>
A short description of this file. Be sure to include keywords that users may try to search for.
<p>

<b>Group To Download</b><br>
Choose the group that may download this file.
<p>

<b>What's next?</b><br>
If you'd like to add another file after this one, then select "add a new file" otherwise select "go back to the page".
<p>
|,

	75 => q|File Manager Template|,

	76 => q|This is the list of template variables available in File Manager templates.
<p/>

<b>titleColumn.url</b><br/>
The URL to sort by the title.
<p/>

<b>titleColumn.label</b><br/>
The translated label for the title.
<p/>

<b>descriptionColumn.label</b><br/>
The translated label for the description.
<p/>

<b>descriptionColumn.url</b><br/>
The URL to sort by the description.
<p/>

<b>dateColumn.label</b><br/>
The translated label for the upload date.
<p/>

<b>dateColumn.url</b><br/>
The URL to sort by the date uploaded.
<p/>

<b>search.form</b><br/>
WebGUI's power search form.
<p/>

<b>search.url</b><br/>
The URL to toggle search mode on and off.
<p/>

<b>search.label</b><br/>
The translated label for the search link.
<p/>

<b>addfile.url</b><br/>
The URL to add a file to the file manager.
<p/>

<b>addfile.label</b><br/>
The translated label for the add file link.
<p/>

<b>file_loop</b><br/>
A loop containing the information about each file uploaded to this file manager.
<blockquote>
<b>file.canView</b><br/>
A condition as to whether the current user has the privileges to view this file.
<p/>
<b>file.controls</b><br/>
The WebGUI management controls for this file.
<p/>
<b>file.title</b><br/>
The title for this file.
<p/>
<b>file.version1.name</b><br/>
The filename for the first version of this file.
<p/>
<b>file.version1.url</b><br/>
The download URL for the first version of this file.
<p/>
<b>file.version1.icon</b><br/>
The URL to the icon for the file type of the first version of this file.
<p/>
<b>file.version1.size</b><br/>
The storage size of the first version of this file.
<p/>
<b>file.version1.type</b><br/>
The type (or file extension) of the first version of this file.
<p/>
<b>file.version1.thumbnail</b><br/>
The URL to the thumbnail for the first version of this file.
<p/>
<b>file.version1.isImage</b><br/>
A conditional indicating whether the first version of this file is an image or not.
<p/>
<b>file.version2.name</b><br/>
The filename for the second version of this file.
<p/>
<b>file.version2.url</b><br/>
The download URL for the second version of this file.
<p/>
<b>file.version2.icon</b><br/>
The URL to the icon for the file type of the second version of this file.
<p/>
<b>file.version2.size</b><br/>
The storage size of the second version of this file.
<p/>
<b>file.version2.type</b><br/>
The type (or file extension) of the second version of this file.
<p/>
<b>file.version2.thumbnail</b><br/>
The URL to the thumbnail for the second version of this file.
<p/>
<b>file.version2.isImage</b><br/>
A conditional indicating whether the second version of this file is an image or not.
<p/>
<b>file.version3.name</b><br/>
The filename for the third version of this file.
<p/>
<b>file.version3.url</b><br/>
The download URL for the third version of this file.
<p/>
<b>file.version3.icon</b><br/>
The URL to the icon for the file type of the third version of this file.
<p/>
<b>file.version3.size</b><br/>
The storage size of the third version of this file.
<p/>
<b>file.version3.type</b><br/>
The type (or file extension) of the third version of this file.
<p/>
<b>file.version3.thumbnail</b><br/>
The URL to the thumbnail for the third version of this file.
<p/>
<b>file.version3.isImage</b><br/>
A conditional indicating whether the third version of this file is an image or not.
<p/>
<b>file.description</b><br/>
The description of this file.
<p/>
<b>file.date</b><br/>
The date that this file was uploaded.
<p/>
<b>file.time</b><br/>
The time that this file was uploaded.
<p/>
</blockquote>
<p/>
<b>noresults.message</b><br/>
A translated message stating that this file manager has no files for this user to view.
<p/>
<b>noresults</b><br/>
A conditional indicating whether there are any files for this user to view.
<p/>

|,

};

1;
