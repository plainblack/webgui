package WebGUI::i18n::English::DataForm;

our $I18N = {
	1 => q|Data Form|,

	2 => q|Your email subject here|,

	3 => q|Thank you for your feedback!|,

	4 => q|Hidden|,

	5 => q|Displayed|,

	6 => q|Modifiable|,

	7 => q|Edit Data Form|,

	8 => q|Width|,

	10 => q|From|,

	11 => q|To|,

	12 => q|Cc|,

	13 => q|Bcc|,

	14 => q|Subject|,

	16 => q|Acknowledgement|,

	17 => q|Mail Sent|,

	18 => q|Go back!|,

	19 => q|Are you certain that you want to delete this field?|,

	20 => q|Edit Field|,

	21 => q|Field Name|,

	22 => q|Status|,

	23 => q|Type|,

	24 => q|Possible Values|,

	25 => q|Default Value(s)|,

	79 => q|Subtext|,

	61 => q|Data Form, Add/Edit|,

	62 => q|Data Form Fields, Add/Edit|,

	71 => q|This wobject creates a simple multipurpose data-entry form.
<br><br>

<b>Acknowledgement</b><br>
This message will be displayed to the user after they submit their data..
<p>

<b>Mail entries?</b></br>
If set to yes, some additional fields will be added to your form for dealing with email. These fields will then be used to email any date entered into the form to a person of your choice.
<p>
<b>NOTE:</b> The "To" field that is added as a result of setting this to yes can accept a standard email address, or a WebGUI username or a WebGUI group name.
<p>

<b>Template</b><br>
Choose a template for your form.
<p>

<b>Email Template</b><br>
Choose a template for the data that will be sent via email.
<p>

<b>Acknowlegement Template</b><br>
Choose a template that will be used to display the acknowlegement.
<p>

<b>List Template</b><br>
Choose a template that will be used to display the list of stored records in this Data Form.
<p>|,

	83 => q|The following template variables are available for Data Form templates.
<p/>

<b>acknowledgement</b><br>
The acknowledgement specified in the wobject's properties. This message should be displayed after a user submits data.
<p>
<b>export.tab.url</b><br>
Following this URL will export the data stored to this data form as a tab delimited file.
<p>

<b>export.tab.label</b><br>
The default label for the export.tab.url variable.
<p>

<b>entryList.url</b><br>
Following this URL will display a list of all the record entries in this data form.
<p>

<b>entryList.label</b><br>
The default label for the entryList.url variable.
<p>

<b>canEdit</b>
A conditional indicating whether the current user has the privileges to edit an existing entry or export the form's data.
<p>

<b>back.url</b><br>
A url that will take you back to the default page in the form.
<p>

<b>back.label</b><br>
The default label for the back.url variable.
<p>

<b>username</b>*<br>
The username of the user that submitted the data.
<p>

<b>userId</b>*<br>
The user id of the user that submitted the data.
<p>

<b>date</b>*<br>
The date that this data was submitted or last updated formatted as the user's preferred date/time format.
<p>


<b>epoch</b>*<br>
The date that this data was submitted or last updated formatted as an epoch date.
<p>

<b>ipAddress</b>*<br>
The IP address of the user that submitted the data.
<p>

<b>edit.url</b>*<br>
The URL to the page to edit this entry.
<p>

<b>error_loop</b>*<br>
A loop containing error information, for instance if someone doesn't fill out a required field.
<p>

<blockquote>

<b>error.message</b>*<br>
An error message indicating what the user might have done wrong.

</blockquote>

<b>addField.url</b><br>
The URL that content managers will visit to add a new field to the form.
<p>

<b>addField.label</b><br>
The default label for the addField.url variable.
<p>

<b>form.start</b><br>
The beginning of the form.
<p>

<b>field_loop</b><br>
A loop containing all of the field information.
<p>

<blockquote>

<b>field.form</b><br>
The form element for this field.
<p>

<b>field.name</b><br>
The name of this field.
<p>

<b>field.value</b><br>
The value of this field. If this is new data, then the default value will be used.
<p>

<b>field.label</b><br>
The text label for this field.
<p>

<b>field.isHidden</b><br>
A conditional indicating whether this field is supposed to be hidden. 
<p>

<b>field.isDisplayed</b><br>
A conditional indicating whether this field is supposed to be displayed. 
<p>

<b>field.isEditable</b><br>
A conditional indicating whether this field is editable. 
<p>

<b>field.isRequired</b><br>
A conditional indicating whether this field is required. 
<p>

<b>field.isMailField</b><br>
A conditional indicating whether this field is present only to facilitate sending an email. 
<p>


<b>field.subtext</b><br>
A description of the field so that users know what to put in the field.
<p>

<b>field.controls</b><br>
WebGUI's administrative controls for this field.
<p>

</blockquote>

<b>form.send</b><br>
A form button with the word "send" printed on it.
<p>

<b>form.save/b><br>
A form button with the word "save" printed on it.
<p>

<b>form.end</b><br>
The end of the form.
<p>

*Only available if the user has already submitted the form.|,

	72 => q|You may add as many additional fields to your Data Form as you like.
<br><br>

<b>Label</b><br>
This is an informative text label to let the user know what this field represents.
<p>

<b>Field Name</b><br>
The name of this field.  It must be unique among all of the other fields on your form.
<p>

<b>Subtext</b><br>
An extension of the label, this is a description of what should go in the field or optional instructions for the field.
<p>

<b>Status</b><br>
Hidden fields will not be visible to the user, but will be sent in the email.Displayed fields can be seen by the user but not modified. Modifiable fields can be filled in by the user. Required fields must be filled in by the user.
If you choose Hidden or Displayed, be sure to fill in a Default Value.
<p>

<b>Type</b><br>
Choose the type of form element for this field.  
<p>

<b>Width</b><br>
Set the number of characters wide this field will be.
<p>

<b>Height</b><br>
Set the number of characters tall this field will be. Only used on textarea and HTMLArea.
<p>

<b>Possible Values</b><br>
This field is used for the list types (like Checkbox List and Select List).  Enter the values you wish to appear, one per line.
<p>

<b>Default Value (optional)</b><br>
Enter the default value (if any) for the field.  For Yes/No fields, enter "yes" to select "Yes" and "no" to select "No".
<p>

|,

	80 => q|Email Template|,

	73 => q|Send|,

	27 => q|Height|,

	28 => q|Optional for text area and HTML area.|,

	100 => q|Are you certain that you want to delete this tab ?|,

	101 => q|Label|,

	84 => q|Export tab delimited.|,

	82 => q|Data Form Template|,

	81 => q|Acknowlegement Template|,

	77 => q|Label|,

	76 => q|Add a field.|,

	75 => q|Required|,

	74 => q|Mail data?|,

	85 => q|One per line.|,

	88 => q|Data Form List Template|,

	89 => q|The following variables are available to the Data Form List template:
<p>

<b>back.url</b><br>
The URL to go back to the Data Form data entry page.
<p>

<b>back.label</b><br>
The default label for the back.url.
<p>

<b>field_loop</b><br>
A loop containing information about the fields in this Data Form.
<p
<blockquote>

<b>field.name</b><br>
The web safe name of this field.
<p>

<b>field.label</b><br>
The human readable label for this field.
<p>

<b>field.id</b><br>
A unique identifier representing this field in the database.
<p>

<b>field.isMailField</b><br>
A conditional indicating whether this field exists for the mail subsystem of the data form.
<p>

<b>field.type</b><br>
The data type associated with this field.
<p>

</blockquote>

<b>record_loop</b><br>
A loop containing the record entries of this data form.
<p>

<blockquote>

<b>record.entryId</b><br>
A unique identifier for this record entry.
<p>

<b>record.ipAddress</b><br>
The IP Address of the user that submitted this record entry.
<p>

<b>record.edit.url</b><br>
The URL to edit this record.
<p>

<b>record.username</b><br>
The username of the person that submitted this record entry.
<p>

<b>record.userId</b><br>
The user id of the person that submitted this record entry.
<p>

<b>record.submissionDate.epoch</b><br>
The epoch datestamp for this record entry.
<p>

<b>record.submissionDate.human</b><br>
A human readable date stamp, based upon the user's preferences, for this record entry.
<p>

<b>record.data_loop</b><br>
A loop containing the data submitted by the user for each field in this data form.
<p>

<blockquote>

<b>record.data.value</b><br>
The value submitted by the user for this field in this record entry.
<p>

<b>record.data.name</b><br>
The web safe name of this field.
<p>

<b>record.data.label</b><br>
The human readable label for this field.
<p>

<b>record.data.isMailField</b><br>
A conditional indicating whether this field exists for the mail subsystem of the data form.
<p>

</blockquote>

</blockquote>|,

	87 => q|List Template|,

	86 => q|List all entries.|,

	29 => q|is required|,

	102 => q|Subtext|,

	106 => q|Tab Template|,

	105 => q|Add a Tab|,

	104 => q|Tab|,

	103 => q|Add new Tab|,

	90 => q|Delete this entry.|,

};

1;
