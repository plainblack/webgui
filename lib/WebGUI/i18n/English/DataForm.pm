package WebGUI::i18n::English::DataForm;

our $I18N = {
	'1' => {
		message => q|Data Form|,
		lastUpdated => 1052045252
	},

	'2' => {
		message => q|Your email subject here|,
		lastUpdated => 1031514049
	},

	'3' => {
		message => q|Thank you for your feedback!|,
		lastUpdated => 1031514049
	},

	'4' => {
		message => q|Hidden|,
		lastUpdated => 1031514049
	},

	'5' => {
		message => q|Displayed|,
		lastUpdated => 1031514049
	},

	'6' => {
		message => q|Modifiable|,
		lastUpdated => 1031514049
	},

	'7' => {
		message => q|Edit Data Form|,
		lastUpdated => 1052045309
	},

	'8' => {
		message => q|Width|,
		lastUpdated => 1031514049
	},

	'10' => {
		message => q|From|,
		lastUpdated => 1031514049
	},

	'11' => {
		message => q|To|,
		lastUpdated => 1052047848
	},

	'12' => {
		message => q|Cc|,
		lastUpdated => 1031514049
	},

	'13' => {
		message => q|Bcc|,
		lastUpdated => 1031514049
	},

	'14' => {
		message => q|Subject|,
		lastUpdated => 1031514049
	},

	'16' => {
		message => q|Acknowledgement|,
		lastUpdated => 1031514049
	},

	'17' => {
		message => q|Mail Sent|,
		lastUpdated => 1031514049
	},

	'18' => {
		message => q|Go back!|,
		lastUpdated => 1031514049
	},

	'19' => {
		message => q|Are you certain that you want to delete this field?|,
		lastUpdated => 1031514049
	},

	'20' => {
		message => q|Edit Field|,
		lastUpdated => 1031514049
	},

	'21' => {
		message => q|Field Name|,
		lastUpdated => 1031514049
	},

	'22' => {
		message => q|Status|,
		lastUpdated => 1031514049
	},

	'23' => {
		message => q|Type|,
		lastUpdated => 1031514049
	},

	'24' => {
		message => q|Possible Values|,
		lastUpdated => 1031514049
	},

	'25' => {
		message => q|Default Value(s)|,
		lastUpdated => 1053855043
	},

	'79' => {
		message => q|Subtext|,
		lastUpdated => 1051482497,
		context => q|A small piece of text under a form element. Gives extra description.|
	},

	'61' => {
		message => q|Data Form, Add/Edit|,
		lastUpdated => 1053885941
	},

	'62' => {
		message => q|Data Form Fields, Add/Edit|,
		lastUpdated => 1052047004
	},

	'71' => {
		message => q|This wobject creates a simple multipurpose data-entry form.
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
		lastUpdated => 1053885941
	},

	'83' => {
		message => q|The following template variables are available for Data Form templates.
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

<b>field.noloop.<i>fieldName</i>.<i>property</i></b><br>
Except from within the <b>field_loop</b> it's also possible to access all formfields directly. To accomplish this you should use these variables. Call them with field.noloop.<i>fieldName</i>.<i>property</i>, where fieldName is the name of the field (not the label) and property is anyone of the properties supplied by the <b>field_loop</b>. If you want the form tag of field 'name' you should use <tmpl_var field.noloop.name.form> anywhere in your template. If you want to know if the field is required use field.noloop.name.isRequired.
<p>

<b>form.send</b><br>
A form button with the word "send" printed on it.
<p>

<b>form.save</b><br>
A form button with the word "save" printed on it.
<p>

<b>form.end</b><br>
The end of the form.
<p>

*Only available if the user has already submitted the form.|,
		lastUpdated => 1090575731
	},

	'72' => {
		message => q|You may add as many additional fields to your Data Form as you like.
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

<b>Align vertical</b><br>
This property controls wheter radio- and checklists are layouted horizontally or vertically.
<p>

<b>Extras</b><br>
Here you can enter additional tag properties for the field tag. For instance 'class="myClass"'.
<p>

<b>Possible Values</b><br>
This field is used for the list types (like Checkbox List and Select List).  Enter the values you wish to appear, one per line.
<p>

<b>Default Value (optional)</b><br>
Enter the default value (if any) for the field.  For Yes/No fields, enter "yes" to select "Yes" and "no" to select "No".
<p>

|,
		lastUpdated => 1090575731
	},

	'80' => {
		message => q|Email Template|,
		lastUpdated => 1052044326,
		context => q|A template that will construct the email to be sent.|
	},

	'73' => {
		message => q|Send|,
		lastUpdated => 1039776778
	},

	'27' => {
		message => q|Height|,
		lastUpdated => 1045210016
	},

	'28' => {
		message => q|Optional for text area and HTML area.|,
		lastUpdated => 1052048005
	},

	'100' => {
		message => q|Are you certain that you want to delete this tab ?|,
		lastUpdated =>1052048005 
	},

	'101' => {
		message => q|Label|,
		lastUpdated => 1052048005
	},

	'84' => {
		message => q|Export tab delimited.|,
		lastUpdated => 1052088598,
		context => q|Save the data with tabs as separaters.|
	},

	'82' => {
		message => q|Data Form Template|,
		lastUpdated => 1053885798
	},

	'81' => {
		message => q|Acknowlegement Template|,
		lastUpdated => 1052064282,
		context => q|A template to display whatever data there is to display.|
	},

	'77' => {
		message => q|Label|,
		lastUpdated => 1051467316,
		context => q|The text in front of a form field. (Like "Context" or "Message".)|
	},

	'76' => {
		message => q|Add a field.|,
		lastUpdated => 1051464925,
		context => q|As in "Add a field element to this form."|
	},

	'75' => {
		message => q|Required|,
		lastUpdated => 1051463599,
		context => q|A field that cannot be blank.|
	},

	'74' => {
		message => q|Mail data?|,
		lastUpdated => 1051463006,
		context => q|As in, "Do you wish to email someone this data?"|
	},

	'85' => {
		message => q|One per line.|,
		lastUpdated => 1053855146,
		context => q|Telling the user to add one entry per line.|
	},

	'88' => {
		message => q|Data Form List Template|,
		lastUpdated => 1053885702
	},

	'89' => {
		message => q|The following variables are available to the Data Form List template:
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
		lastUpdated => 1053885702
	},

	'87' => {
		message => q|List Template|,
		lastUpdated => 1053884753,
		context => q|Prompt the user to select a template for the list view of the data form.|
	},

	'86' => {
		message => q|List all entries.|,
		lastUpdated => 1053882548,
		context => q|A label that links to  all Data Form entries made to date.|
	},

	'29' => {
		message => q|is required|,
		lastUpdated => 1031515049
	},

	'102' => {
		message => q|Subtext|,
		lastUpdated => 1052048005
	},

	'106' => {
		message => q|Tab Template|,
		lastUpdated => 1052048005
	},

	'105' => {
		message => q|Add a Tab|,
		lastUpdated => 1052048005
	},

	'104' => {
		message => q|Tab|,
		lastUpdated => 1052048005
	},

	'103' => {
		message => q|Add new Tab|,
		lastUpdated => 1052048005
	},

	'90' => {
		message => q|Delete this entry.|,
		lastUpdated => 1057208065
	},

	'editField-vertical-label' => {
		message => q|Align vertical|,
		lastUpdated => 1090575731
	},

	'editField-vertical-subtext' => {
		message => q|This property only affects radio- and checklists.|,
		lastUpdated => 1090575731
	},

	'editField-extras-label' => {
		message => q|Extras|,
		lastUpdated => 1090575731
	},

};

1;
