package WebGUI::i18n::English::Asset_DataForm;

our $I18N = {
        'group to view entries' => {
                message => q|Group To View DataForm Entries|,
                lastUpdated => 1057208065
        },
        
        'group to view entries description' => {
                message => q|Members of this group will have the ability to view data submitted to this DataForm Asset.|,
                lastUpdated => 1057208065
        },
        
	'90' => {
		message => q|Delete this entry.|,
		lastUpdated => 1057208065
	},

	'91' => {
		message => q|Delete all entries.|,
		lastUpdated => 1110780333,
	},

	'21' => {
		message => q|Field Name|,
		lastUpdated => 1031514049
	},

	'71' => {
		message => q|This Asset creates a simple multipurpose data-entry and
                display form.
  You
can add additional fields to the DataForm, create multiple tabs, use the DataForm
as a web form to email gateway, or easily create tables on your website with it.

<p>The Data Form Wobject is special in that some of the controls for it
are only available from the template.  Be sure to read the documentation
for the Data Form Template and to include the variables that enable those
functions.

<p> Dataforms are Wobjects, so they inherit the properties of both Wobjects and Assets.  They also have these unique properties:
|,
		lastUpdated => 1119071111,
	},

        '16 description' => {
                message => q|This message will be displayed to the user after they submit their data.|,
                lastUpdated => 1119071283,
        },

        '74 description' => {
                message => q|If set to yes, some additional fields will be added to your form for dealing with email. These fields will then be used to email any data entered into the form to a person of your choice.  By default the new fields are "Hidden" so that
they can't be edited by the user.
<p>
<b>NOTE:</b> The "To" field that is added as a result of setting this to yes can accept a standard email address, or a WebGUI username or a WebGUI group name.  To send an email to more than one address, separate them by commas.|,
                lastUpdated => 1119071283,
        },


        '82 description' => {
                message => q|Choose a template for your form.|,
                lastUpdated => 1132354153,
        },

        '80 description' => {
                message => q|Choose a template for the data that will be sent via email.|,
                lastUpdated => 1119071072,
        },

        '81 description' => {
                message => q|Choose a template that will be used to display the acknowledgment.|,
                lastUpdated => 1119071072,
        },

        '87 description' => {
                message => q|Choose a template that will be used to display the list of stored records in this Data Form.|,
                lastUpdated => 1119071072,
        },

        'defaultView description' => {
                message => q|Select the default view for the Data Form, either Form view (the default) or
List view.  When List view is selected, no acknowledgement will be displayed
after data is entered in the form.|,
                lastUpdated => 1119071072,
        },

	'744' => {
		message => q|What next?|,
		lastUpdated => 1132354852
	},

        '744 description' => {
                message => q|After creating the Data Form, you can either begin to add fields to it
or return to the page where the it was created.|,
                lastUpdated => 1132354848,
        },

        '76 description' => {
                message => q|Add a field to a Data Form.|,
                lastUpdated => 1119071072,
        },

        '105 description' => {
                message => q|Add a tab to a Data Form.|,
                lastUpdated => 1119071072,
        },

        '86 description' => {
                message => q|List all data that has been entered into the Data Form.|,
                lastUpdated => 1119071072,
        },

        '76 description' => {
                message => q|Export the data from the Data Form in tab deliniated format.|,
                lastUpdated => 1119071072,
        },


	'editField vertical label' => {
		message => q|Align vertical|,
		lastUpdated => 1127958354
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

	'assetName' => {
		message => q|Data Form|,
		lastUpdated => 1128831089
	},

	'88' => {
		message => q|Data Form List Template|,
		lastUpdated => 1053885702
	},

	'18' => {
		message => q|Go back!|,
		lastUpdated => 1031514049
	},

	'go to form' => {
		message => q|Go to form|,
		lastUpdated => 1113423537
	},

	'72' => {
		message => q|<p>You may add as many additional fields to your Data Form as you like.<p>|,
		lastUpdated => 1119156650,
	},

        '104 description' => {
                message => q|When the form has multiple tabs, defines which tab of the form that the
field is displayed in.  Otherwise, all fields are displayed on the same
page.|,
                lastUpdated => 1119156590,
        },

        '77 description' => {
                message => q|This is an informative text label to let the user know what this field represents.|,
                lastUpdated => 1119156590,
        },

        '79 description' => {
                message => q|An extension of the label, this is additional information such as a description of what should go in the field or optional instructions for the field.|,
                lastUpdated => 1133811301,
        },

        '21 description' => {
                message => q|The name of this field.  It must be unique among all of the other fields on your form.|,
                lastUpdated => 1119156590,
        },

        '22 description' => {
                message => q|Hidden fields will not be visible to the user, but will be sent in the email. Displayed fields can be seen by the user but not modified. Modifiable fields can be filled in by the user. Required fields must be filled in by the user.
If you choose Hidden or Displayed, be sure to fill in a Default Value.|,
                lastUpdated => 1119156590,
        },

        '23 description' => {
                message => q|Choose the type of form element for this field.   This is also used
to validate any input that the user may supply.|,
                lastUpdated => 1119156590,
        },

        '8 description' => {
                message => q|Set the number of characters wide this form field will be.|,
                lastUpdated => 1119156590,
        },

        '27 description' => {
                message => q|Set the number of characters tall this form field will be. Only used on textareas and HTMLAreas.|,
                lastUpdated => 1119156590,
        },

        'editField vertical label description' => {
                message => q|This property controls whether radio buttons and checklists are laid out horizontally or vertically.|,
                lastUpdated => 1127958365,
        },

        'editField extras label description' => {
                message => q|Here you can enter additional tag properties for the field tag. For instance 'class="myClass"'.|,
                lastUpdated => 1127958371,
        },

        '24 description' => {
                message => q|This field is used for the list types (like Checkbox List and Select List).  Enter the values you wish to appear, one per line.|,
                lastUpdated => 1119156590,
        },

        '25 description' => {
                message => q|Enter the default value (if any) for the field.  For Yes/No fields, enter "yes" to select "Yes" and "no" to select "No".|,
                lastUpdated => 1119156590,
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
* : Only available if the user has already submitted the form.<p/>
! : This variable is required for the Data Form to function correctly.<p/>

<b>canEdit</b>
A conditional indicating whether the current user has the privileges to edit this Data Form.
<p>

<b>entryId</b>
The ID of the current entry being viewed.  This variable is undefined
unless the user can edit the Data Form (<b>canEdit</b> it true).
<p>

<b>form.start</b> !<br>
The beginning of the form.
<p>

<b>entryList.url</b><br>
Following this URL will display a list of all the record entries in this data form.
<p>

<b>entryList.label</b><br>
The default label for the entryList.url variable.
<p>

<b>export.tab.url</b><br>
Following this URL will export the data stored to this data form as a tab delimited file.
<p>

<b>export.tab.label</b><br>
The default label for the export.tab.url variable.
<p>

<b>back.url</b><br>
A url that will take you back to the default page in the form.
<p>

<b>back.label</b><br>
The default label for the back.url variable.
<p>

<b>addField.url</b><br>
The URL that content managers will visit to add a new field to the form.
<p>

<b>addField.label</b><br>
The default label for the addField.url variable.
<p>

<b>addTab.url</b><br>
The URL that content managers will visit to add a new tab to the form.
<p>

<b>addTab.label</b><br>
The default label for the addTab.url variable.
<p>

<b>tab.init</b>!<br>
Code to enable tabs to work correctly.
<p>

<b>username</b> *<br>
The username of the user that submitted the data.
<p>

<b>userId</b> *<br>
The user id of the user that submitted the data.
<p>

<b>date</b> *<br>
The date that this data was submitted or last updated formatted as the user's preferred date/time format.
<p>

<b>epoch</b> *<br>
The date that this data was submitted or last updated formatted as an epoch date.
<p>

<b>ipAddress</b> *<br>
The IP address of the user that submitted the data.
<p>

<b>edit.url</b> *<br>
The URL to the page to edit this entry.
<p>

<b>error_loop</b> *<br>
A loop containing error information, for instance if someone doesn't fill out a required field.
<p>

<blockquote>

<b>error.message</b> *<br>
An error message indicating what the user might have done wrong.

</blockquote>

<b>tab_loop</b><br>
A loop containing information about tabs that may have been defined for this Data Form.
<p>

<blockquote>

<b>tab.start</b> !<br>
Code to start the tab.
<p>

<b>tab.sequence</b><br>
A number indicating which tab this is (first, second, etc.).
<p>

<b>tab.label</b><br>
The label for this tab.
<p>

<b>tab.tid</b><br>
This tab's ID.
<p>

<b>tab.subtext</b><br>
A description of this tab that can explain more the tab contents than the label.
<p>

<b>tab.controls</b> !<br>
Editing icons for this tab.
<p>

<b>tab.field_loop</b> !<br>
A loop containing all the fields for this tab.  See the <b>field_loop</b> description
below to see which template variables may be used inside this loop.
<p>

<blockquote>

<b>tab.field.form</b> !<br>
The form element for this field.
<p>

<b>tab.field.name</b><br>
The name of this field.
<p>

<b>tab.field.tid</b><br>
The ID of the Tab that this field is in.
<p>

<b>tab.field.value</b><br>
The value of this field. If this is new data, then the default value will be used.
<p>

<b>tab.field.label</b><br>
The text label for this field.
<p>

<b>tab.field.isHidden</b><br>
A conditional indicating whether this field is supposed to be hidden. 
<p>

<b>tab.field.isDisplayed</b><br>
A conditional indicating whether this field is supposed to be displayed. 
<p>

<b>tab.field.isRequired</b><br>
A conditional indicating whether this field is required. 
<p>

<b>tab.field.isMailField</b><br>
A conditional indicating whether this field is present only to facilitate sending an email. 
<p>

<b>tab.field.subtext</b><br>
A description of the field so that users know what to put in the field.
<p>

<b>tab.field.controls</b><br>
WebGUI's administrative controls for editing this field.
<p>

</blockquote>

<b>tab.end</b> !<br>
Code to end the tab.
<p>

</blockquote>

<b>field_loop</b><br>
A loop containing all of the field information.
<p>

<blockquote>

<b>field.form</b> !<br>
The form element for this field.
<p>

<b>field.name</b><br>
The name of this field.
<p>

<b>field.tid</b><br>
The ID of the Tab that this field is in.
<p>

<b>field.inTab</b><br>
A conditional indicating if the field is inside of a tab.
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
WebGUI's administrative controls for editing this field.
<p>

</blockquote>

<b>field.noloop.<i>fieldName</i>.<i>property</i></b><br>
From outside the <b>field_loop</b> it's also possible to access all form fields directly. To accomplish this you should use these variables. Call them with <b>field.noloop.<i>fieldName</i>.<i>property</i></b>, where fieldName is the name of the field (not the label) and property is anyone of the properties supplied by the <b>field_loop</b>. If you want the form tag of field 'name' you should use <b>field.noloop.name.form</b> anywhere in your template. If you want to know if the field is required use <b>field.noloop.name.isRequired</b>.
<p>

<b>form.send</b> !<br>
A form button with the internationalized word "send" printed on it.
<p>

<b>form.save</b> !<br>
A form button to submit the form data.
<p>

<b>form.end</b> !<br>
The end of the form.
<p>

|,
		lastUpdated => 1110613373,
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

	'102' => {
		message => q|Edit Tab|,
		lastUpdated => 1137974142
	},

	'103' => {
		message => q|Add new Tab|,
		lastUpdated => 1052048005
	},

	'editField extras label' => {
		message => q|Extras|,
		lastUpdated => 1127958376
	},

	'editField vertical subtext' => {
		message => q|This property only affects radio- and checklists.|,
		lastUpdated => 1127958381
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

<b>record.edit.icon</b><br>
An icon and associated URL for editing this record.
<p>

<b>record.delete.url</b><br>
The URL to delete this record.
<p>

<b>record.delete.icon</b><br>
An icon and associated URL for deleting this record.
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
		lastUpdated => 1113368156,
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
	'Field Position description' => {
		message =>q|This allows you to set the position of the field directly, as opposed to using the field editing icons|,
		lastUpdated=>1133821586,
	},
	'Delete entry confirmation' => {
                message => q|Are you certain that you wish to delete this data entry?|,
                lastUpdated => 1095701013,
        },
        '745' => {
		 message => q|Go back to the page.|,
		 lastUpdated => 1035872437,
        },
        'defaultView' => {
		 message => q|Default view|,
		 lastUpdated => 1112929856,
        },
        'data form' => {
		 message => q|Data Form|,
		 lastUpdated => 1113435285,
        },
        'data list' => {
		 message => q|Data List|,
		 lastUpdated => 1113435295,
        },

};

1;
