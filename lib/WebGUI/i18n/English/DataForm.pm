package WebGUI::i18n::English::DataForm;

our $I18N = {
	'90' => {
		message => q|Delete this entry.|,
		lastUpdated => 1057208065
	},

	'21' => {
		message => q|Field Name|,
		lastUpdated => 1031514049
	},

	'71' => {
		message => q|This wobject creates a simple multipurpose data-entry form.
  You
can add additional fields to the DataForm, create multiple tabs, or use the DataForm
as a web form to email gateway.
<p> Dataforms are Wobjects, so they inherit the properties of both Wobjects and Assets.  They also have these unique properties:
<p>
<b>^International("16","DataForm");</b><br>
This message will be displayed to the user after they submit their data..

<p>
<b>^International("74","DataForm");</b></br>
If set to yes, some additional fields will be added to your form for dealing with email. These fields will then be used to email any data entered into the form to a person of your choice.  By default the new fields are "Hidden" so that
they can't be edited by the user.
<p>
<b>NOTE:</b> The "To" field that is added as a result of setting this to yes can accept a standard email address, or a WebGUI username or a WebGUI group name.

<p>
<b>^International("913","WebGUI");</b><br>
Choose a template for your form.

<p>
<b>^International("81","DataForm");</b><br>
Choose a template for the data that will be sent via email.

<p>
<b>^International("81","DataForm");</b><br>
Choose a template that will be used to display the acknowledgment.

<p>
<b>^International("87","DataForm");</b><br>
Choose a template that will be used to display the list of stored records in this Data Form.

<p>
<b>^International("744","DataForm");</b><br>
After creating the Data Form, you may either begin to add fields to it
or to return to the page where the it was created.

<p>The Data Form Wobject is special in that some of the controls for it
are only available from the template.  Be sure to read the documentation
for the Data Form Template and to include the variables that enable these
functions:

<p>
<b>^International("76","DataForm");</b><br>
Add a field to a Data Form.

<p>
<b>^International("105","DataForm");</b><br>
Add a tab to a Data Form.

<p>
<b>^International("86","DataForm");</b><br>
List all data that has been entered into the Data Form.

<p>
<b>^International("76","DataForm");</b><br>
Export the data from the Data Form in tab deliniated format.

|,
		lastUpdated => 1110514269,
	},

	'editField-vertical-label' => {
		message => q|Align vertical|,
		lastUpdated => 1090575731
	},

	'102' => {
		message => q|Subtext|,
		lastUpdated => 1052048005
	},

	'7' => {
		message => q|Edit Data Form|,
		lastUpdated => 1052045309
	},

	'80' => {
		message => q|Email Template|,
		lastUpdated => 1052044326
	},

	'17' => {
		message => q|Mail Sent|,
		lastUpdated => 1031514049
	},

	'2' => {
		message => q|Your email subject here|,
		lastUpdated => 1031514049
	},

	'1' => {
		message => q|Data Form|,
		lastUpdated => 1052045252
	},

	'88' => {
		message => q|Data Form List Template|,
		lastUpdated => 1053885702
	},

	'18' => {
		message => q|Go back!|,
		lastUpdated => 1031514049
	},

	'72' => {
		message => q|<p>You may add as many additional fields to your Data Form as you like.

<p>
<b>^International("104","DataForm");</b><br>
When the form has multiple tabs, defines which tab of the form that the
field is displayed in.  Otherwise, all fields are displayed on the same
page.

<p>
<b>^International("77","DataForm");</b><br>
This is an informative text label to let the user know what this field represents.

<p>
<b>^International("102","DataForm");</b><br>
An extension of the label, this is a description of what should go in the field or optional instructions for the field.

<p>
<b>^International("21","DataForm");</b><br>
The name of this field.  It must be unique among all of the other fields on your form.

<p>
<b>^International("22","DataForm");</b><br>
Hidden fields will not be visible to the user, but will be sent in the email. Displayed fields can be seen by the user but not modified. Modifiable fields can be filled in by the user. Required fields must be filled in by the user.
If you choose Hidden or Displayed, be sure to fill in a Default Value.

<p>
<b>^International("23","DataForm");</b><br>
Choose the type of form element for this field.   This is also used
to validate any input that the user may supply.

<p>
<b>^International("8","DataForm");</b><br>
Set the number of characters wide this form field will be.

<p>
<b>^International("27","DataForm");</b><br>
Set the number of characters tall this form field will be. Only used on textareas and HTMLAreas.

<p>
<b>^International("editField-vertical-label","DataForm");</b><br>
This property controls whether radio buttons and checklists are laid out horizontally or vertically.

<p>
<b>^International("editField-extras-label","DataForm");</b><br>
Here you can enter additional tag properties for the field tag. For instance 'class="myClass"'.

<p>
<b>^International("24","DataForm");</b><br>
This field is used for the list types (like Checkbox List and Select List).  Enter the values you wish to appear, one per line.

<p>
<b>^International("25","DataForm");</b><br>
Enter the default value (if any) for the field.  For Yes/No fields, enter "yes" to select "Yes" and "no" to select "No".
<p>

|,
		lastUpdated => 1110514660,
	},

	'16' => {
		message => q|Acknowledgment|,
		lastUpdated => 1101772851,
	},

	'100' => {
		message => q|Are you certain that you want to delete this tab ?|,
		lastUpdated => 1052048005
	},

	'82' => {
		message => q|Data Form Template|,
		lastUpdated => 1053885798
	},

	'74' => {
		message => q|Mail data?|,
		lastUpdated => 1051463006
	},

	'84' => {
		message => q|Export tab delimited.|,
		lastUpdated => 1052088598
	},

	'27' => {
		message => q|Height|,
		lastUpdated => 1045210016
	},

	'25' => {
		message => q|Default Value(s)|,
		lastUpdated => 1053855043
	},

	'28' => {
		message => q|Optional for text area and HTML area.|,
		lastUpdated => 1052048005
	},

	'75' => {
		message => q|Required|,
		lastUpdated => 1051463599
	},

	'83' => {
		message => q|The following template variables are available for Data Form templates.
<p/>

<b>acknowledgment</b><br>
The acknowledgment specified in the wobject's properties. This message should be displayed after a user submits data.
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
From outside the <b>field_loop</b> it's also possible to access all form fields directly. To accomplish this you should use these variables. Call them with <b>field.noloop.<i>fieldName</i>.<i>property</i></b>, where fieldName is the name of the field (not the label) and property is anyone of the properties supplied by the <b>field_loop</b>. If you want the form tag of field 'name' you should use <b>field.noloop.name.form</b> anywhere in your template. If you want to know if the field is required use <b>field.noloop.name.isRequired</b>.
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
		lastUpdated => 1101772868
	},

	'61' => {
		message => q|Data Form, Add/Edit|,
		lastUpdated => 1053885941
	},

	'20' => {
		message => q|Edit Field|,
		lastUpdated => 1031514049
	},

	'14' => {
		message => q|Subject|,
		lastUpdated => 1031514049
	},

	'103' => {
		message => q|Add new Tab|,
		lastUpdated => 1052048005
	},

	'editField-extras-label' => {
		message => q|Extras|,
		lastUpdated => 1090575731
	},

	'editField-vertical-subtext' => {
		message => q|This property only affects radio- and checklists.|,
		lastUpdated => 1090575731
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

<b>record.data.name</b><br>
The web safe name of this field.
<p>

<b>record.data.label</b><br>
The human readable label for this field.
<p>

<b>record.data.value</b><br>
The value submitted by the user for this field in this record entry.
<p>

<b>record.data.isMailField</b><br>
A conditional indicating whether this field exists for the mail subsystem of the data form.
<p>

</blockquote>

</blockquote>|,
		lastUpdated => 1098856416
	},

	'24' => {
		message => q|Possible Values|,
		lastUpdated => 1031514049
	},

	'10' => {
		message => q|From|,
		lastUpdated => 1031514049
	},

	'104' => {
		message => q|Tab|,
		lastUpdated => 1052048005
	},

	'11' => {
		message => q|To|,
		lastUpdated => 1052047848
	},

	'79' => {
		message => q|Subtext|,
		lastUpdated => 1051482497
	},

	'22' => {
		message => q|Status|,
		lastUpdated => 1031514049
	},

	'87' => {
		message => q|List Template|,
		lastUpdated => 1053884753
	},

	'77' => {
		message => q|Label|,
		lastUpdated => 1051467316
	},

	'106' => {
		message => q|Tab Template|,
		lastUpdated => 1052048005
	},

	'13' => {
		message => q|Bcc|,
		lastUpdated => 1031514049
	},

	'23' => {
		message => q|Type|,
		lastUpdated => 1031514049
	},

	'105' => {
		message => q|Add a Tab|,
		lastUpdated => 1052048005
	},

	'29' => {
		message => q|is required|,
		lastUpdated => 1031515049
	},

	'6' => {
		message => q|Modifiable|,
		lastUpdated => 1031514049
	},

	'85' => {
		message => q|One per line.|,
		lastUpdated => 1053855146
	},

	'3' => {
		message => q|Thank you for your feedback!|,
		lastUpdated => 1031514049
	},

	'12' => {
		message => q|Cc|,
		lastUpdated => 1031514049
	},

	'81' => {
		message => q|Acknowledgment Template|,
		lastUpdated => 1101772875
	},

	'8' => {
		message => q|Width|,
		lastUpdated => 1031514049
	},

	'4' => {
		message => q|Hidden|,
		lastUpdated => 1031514049
	},

	'101' => {
		message => q|Label|,
		lastUpdated => 1052048005
	},

	'73' => {
		message => q|Send|,
		lastUpdated => 1039776778
	},

	'86' => {
		message => q|List all entries.|,
		lastUpdated => 1053882548
	},

	'76' => {
		message => q|Add a field.|,
		lastUpdated => 1051464925
	},

	'19' => {
		message => q|Are you certain that you want to delete this field?|,
		lastUpdated => 1031514049
	},

	'62' => {
		message => q|Data Form Fields, Add/Edit|,
		lastUpdated => 1052047004
	},

	'5' => {
		message => q|Displayed|,
		lastUpdated => 1031514049,
	},
	'no tab' =>{
		message =>q|No Tab|,
		lastUpdated=>1095701013,
		context=>q|Tells the user that there is no tab to set the field to.|,
		},
	'Field Position' => {
		message =>q|Field Position|,
		lastUpdated=>1095701013,
	},
	'Delete entry confirmation' => {
                message => q|Are you certain that you wish to delete this data entry?|,
                lastUpdated => 1095701013,
        },
        '745' => {
		 message => q|Go back to the page.|,
		 lastUpdated => 1035872437,
        }

};

1;
