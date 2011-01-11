package WebGUI::i18n::English::Asset_DataForm;
use strict;

our $I18N = {
	'htmlAreaRichEditor' => {
		message => q|HTML Area Rich Editor|,
		lastUpdated => 0,
		context => 'label for HTMLArea field Rich Editor selector.',
	},

	'htmlAreaRichEditor description' => {
		message => q|Select the Rich Editor you want to use for HTML Area fields.  The Default Rich Editor is the one defined in the settings.|,
		lastUpdated => 0,
		context => 'hover help for HTMLArea field Rich Editor selector.',
	},

	'Use Default Rich Editor' => {
		message => q|Use Default Rich Editor|,
		lastUpdated => 0,
		context => q|Label in the edit screen.  Use the default Rich Editor, meaning to take the default used by the site.|,
	},

	'delete file' => {
		message => q|Delete Attached File|,
		lastUpdated => 0,
		context => 'label for link displayed to delete the contents of a file field on a form entry.',
	},

	'mail attachments' => {
		message => q|Mail Attachments?|,
		lastUpdated => 0,
		context => 'label for wobject property',
	},

	'mail attachments description' => {
		message => q|Must be used in conjunction with 'Mail Data'.  Setting to yes will cause all files submitted via the file field type to be mailed as attachments.|,
		lastUpdated => 1165511233,
		context => 'description of wobject property',
	},

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
	'confirm delete all' => {
		message => q|Are you sure you want to DELETE all of this Data Form\'s entries permanently?|,
		lastUpdated => 1031514049
	},
	'confirm delete one' => {
		message => q|Are you sure you want to DELETE this entry permanently?|,
		lastUpdated => 1031514049
	},
        '16 description' => {
                message => q|This message will be displayed to the user after they submit their data.|,
                lastUpdated => 1119071283,
        },

        '74 description' => {
                message => q|<p>If set to yes, some additional fields will be added to your form for dealing with email. These fields will then be used to email any data entered into the form to a person of your choice.  By default the new fields are "Hidden" so that
they can't be edited by the user.</p>
<p>
<b>NOTE:</b> The "To" field that is added as a result of setting this to yes can accept a standard email address, a WebGUI username or a WebGUI group name.  To send an email to more than one address, separate them by commas.</p>|,
                lastUpdated => 1146763307,
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
List view.  When List view is selected, no acknowledgment will be displayed
after data is entered in the form.|,
                lastUpdated => 1165511134,
        },

	'744' => {
		message => q|What next?|,
		lastUpdated => 1132354852
	},

        '744 description' => {
                message => q|After creating the Data Form, you can either begin to add fields to it
or return to the page where it was created.|,
                lastUpdated => 1165511258,
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
                message => q|Export the data from the Data Form in tab delineated format.|,
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
                message => q|Set the width of most fields in pixels.|,
                lastUpdated => 1153876300,
        },

        '27 description' => {
                message => q|Set the height of this field in pixels. Only used on Textareas and HTMLAreas.|,
                lastUpdated => 1153876588,
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
                message => q{This field is used for the list types (like Checkbox List and Select List).  Enter the values you wish to appear, one per line. If you want a different label for a value, seperate them with a | (pipe) character: value|label },
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

	'entryId' => {
		message => q|The ID of the current entry being viewed.  This variable is undefined
unless the user can edit the Data Form (<b>canEdit</b> it true).|,
		lastUpdated => 1149392054,
	},

	'form.start' => {
		message => q|The beginning of the form.|,
		lastUpdated => 1149392054,
	},

	'entryList.url' => {
		message => q|Following this URL will display a list of all the record entries in this data form.|,
		lastUpdated => 1149392054,
	},

	'entryList.label' => {
		message => q|The default label for the entryList.url variable.|,
		lastUpdated => 1149392054,
	},

	'delete.url' => {
		message => q|The URL to delete the current entry from the DataForm.|,
		lastUpdated => 1164913871,
	},

	'delete.label' => {
		message => q|The default label for the delete.url variable.|,
		lastUpdated => 1164913874,
	},

	'export.tab.url' => {
		message => q|Following this URL will export the data stored to this data form as a tab delimited file.|,
		lastUpdated => 1149392054,
	},

	'export.tab.label' => {
		message => q|The default label for the export.tab.url variable.|,
		lastUpdated => 1149392054,
	},

	'back.url' => {
		message => q|A url that will take you back to the default page in the form.|,
		lastUpdated => 1149392054,
	},

	'back.label' => {
		message => q|The default label for the back.url variable.|,
		lastUpdated => 1149392054,
	},

	'deleteAllEntries.url' => {
		message => q|A URL to allow the user to delete all entries in the DataForm.|,
		lastUpdated => 1150411936,
	},

	'deleteAllEntries.label' => {
		message => q|The default label for the deleteAllEntries.url variable|,
		lastUpdated => 1150411934,
	},

	'javascript.confirmation.deleteAll' => {
		message => q|Javascript for an internationalized confirmation popup for deleting all entries.|,
		lastUpdated => 1150411934,
	},

	'javascript.confirmation.deleteOne' => {
		message => q|Javascript for an internationalized confirmation popup for deleting one entry.|,
		lastUpdated => 1164913939,
	},

	'addField.url' => {
		message => q|The URL that content managers will visit to add a new field to the form.|,
		lastUpdated => 1149392054,
	},

	'addField.label' => {
		message => q|The default label for the addField.url variable.|,
		lastUpdated => 1149392054,
	},

	'addTab.url' => {
		message => q|The URL that content managers will visit to add a new tab to the form.|,
		lastUpdated => 1149392054,
	},

	'addTab.label' => {
		message => q|The default label for the addTab.url variable.|,
		lastUpdated => 1149392054,
	},

	'hasEntries' => {
		message => q|The number of entries in this DataForm.|,
		lastUpdated => 1149392054,
	},

	'canEdit' => {
		message => q|Code to enable tabs to work correctly.|,
		lastUpdated => 1149392054,
	},

	'tab.init' => {
		message => q|Code to enable tabs to work correctly.|,
		lastUpdated => 1149392054,
	},

	'username' => {
		message => q|The username of the user that submitted the data.|,
		lastUpdated => 1149392054,
	},

	'userId' => {
		message => q|The user id of the user that submitted the data.|,
		lastUpdated => 1149392054,
	},

	'date' => {
		message => q|The date that this data was submitted or last updated formatted as the user's preferred date/time format.|,
		lastUpdated => 1149392054,
	},

	'epoch' => {
		message => q|The date that this data was submitted or last updated formatted as an epoch date.|,
		lastUpdated => 1149392054,
	},

	'ipAddress' => {
		message => q|The IP address of the user that submitted the data.|,
		lastUpdated => 1149392054,
	},

	'edit.url' => {
		message => q|The URL to the page to edit this entry.|,
		lastUpdated => 1149392054,
	},

	'error_loop' => {
		message => q|A loop containing error information, for instance if someone doesn't fill out a required field.|,
		lastUpdated => 1149392054,
	},

	'error.message' => {
		message => q|An error message indicating what the user might have done wrong.|,
		lastUpdated => 1149392054,
	},

	'tab_loop' => {
		message => q|A loop containing information about tabs that may have been defined for this Data Form.|,
		lastUpdated => 1149392054,
	},

	'tab.start' => {
		message => q|Code to start the tab.|,
		lastUpdated => 1149392054,
	},

	'tab.sequence' => {
		message => q|A number indicating which tab this is (first, second, etc.).|,
		lastUpdated => 1149392054,
	},

	'tab.label' => {
		message => q|The label for this tab.|,
		lastUpdated => 1149392054,
	},

	'tab.tid' => {
		message => q|This tab's ID.|,
		lastUpdated => 1149392054,
	},

	'tab.subtext' => {
		message => q|A description of this tab that can explain more about the tab contents than the label.|,
		lastUpdated => 1165511090,
	},

	'tab.controls' => {
		message => q|Editing icons for this tab.|,
		lastUpdated => 1149392054,
	},

	'tab.field_loop' => {
		message => q|A loop containing all the fields for this tab.  See the <b>field_loop</b> description
below to see which template variables may be used inside this loop.|,
		lastUpdated => 1149392054,
	},

	'tab.field.form' => {
		message => q|The form element for this field.|,
		lastUpdated => 1149392054,
	},

	'tab.field.name' => {
		message => q|The name of this field.|,
		lastUpdated => 1149392054,
	},

	'tab.field.tid' => {
		message => q|The ID of the Tab that this field is in.|,
		lastUpdated => 1149392054,
	},

	'tab.field.value' => {
		message => q|The value of this field. If this is new data, then the default value will be used.|,
		lastUpdated => 1149392054,
	},

	'tab.field.label' => {
		message => q|The text label for this field.|,
		lastUpdated => 1149392054,
	},

	'tab.field.isHidden' => {
		message => q|A conditional indicating whether this field is supposed to be hidden. |,
		lastUpdated => 1149392054,
	},

	'tab.field.isDisplayed' => {
		message => q|A conditional indicating whether this field is supposed to be displayed. |,
		lastUpdated => 1149392054,
	},

	'tab.field.isRequired' => {
		message => q|A conditional indicating whether this field is required. |,
		lastUpdated => 1149392054,
	},

	'tab.field.isMailField' => {
		message => q|A conditional indicating whether this field is present only to facilitate sending an email. |,
		lastUpdated => 1149392054,
	},

	'tab.field.subtext' => {
		message => q|A description of the field so that users know what to put in the field.|,
		lastUpdated => 1149392054,
	},

	'tab.field.controls' => {
		message => q|WebGUI's administrative controls for editing this field.|,
		lastUpdated => 1149392054,
	},

	'tab.end' => {
		message => q|Code to end the tab.|,
		lastUpdated => 1149392054,
	},

	'field_loop' => {
		message => q|A loop containing all of the field information.  From outside the <b>field_loop</b> it's also possible to access all form fields directly. To accomplish this you should use these variables. Call them with <b>field.noloop.<i>fieldName</i>.<i>property</i></b>, where fieldName is the name of the field (not the label) and property is any one of the properties supplied by the <b>field_loop</b>. If you want the form tag of field 'name' you should use <b>field.noloop.name.form</b> anywhere in your template. If you want to know if the field is required use <b>field.noloop.name.isRequired</b>.|,
		lastUpdated => 1165511043,
	},

	'field.form' => {
		message => q|The form element for this field.|,
		lastUpdated => 1149392054,
	},

	'field.name' => {
		message => q|The name of this field.|,
		lastUpdated => 1149392054,
	},

	'field.tid' => {
		message => q|The ID of the Tab that this field is in.|,
		lastUpdated => 1149392054,
	},

	'field.inTab' => {
		message => q|A conditional indicating if the field is inside of a tab.|,
		lastUpdated => 1149392054,
	},

	'field.value' => {
		message => q|The value of this field. If this is new data, then the default value will be used.|,
		lastUpdated => 1149392054,
	},

	'field.label' => {
		message => q|The text label for this field.|,
		lastUpdated => 1149392054,
	},

	'field.isHidden' => {
		message => q|A conditional indicating whether this field is supposed to be hidden. |,
		lastUpdated => 1149392054,
	},

	'field.isDisplayed' => {
		message => q|A conditional indicating whether this field is supposed to be displayed. |,
		lastUpdated => 1149392054,
	},

	'field.isRequired' => {
		message => q|A conditional indicating whether this field is required. |,
		lastUpdated => 1149392054,
	},

	'field.isMailField' => {
		message => q|A conditional indicating whether this field is present only to facilitate sending an email. |,
		lastUpdated => 1149392054,
	},

	'field.subtext' => {
		message => q|A description of the field so that users know what to put in the field.|,
		lastUpdated => 1149392054,
	},

	'field.controls' => {
		message => q|WebGUI's administrative controls for editing this field.|,
		lastUpdated => 1149392054,
	},

	'form.send' => {
		message => q|A form button with the internationalized word "send" printed on it.|,
		lastUpdated => 1149392054,
	},

	'form.save' => {
		message => q|A form button to submit the form data.|,
		lastUpdated => 1149392054,
	},

	'form.end' => {
		message => q|The end of the form.|,
		lastUpdated => 1149392054,
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

	'field.id' => {
		message => q|A unique identifier representing this field in the database.|,
		lastUpdated => 1149392138,
	},

	'field.type' => {
		message => q|The data type associated with this field.|,
		lastUpdated => 1149392138,
	},

	'record_loop' => {
		message => q|A loop containing the record entries of this data form.|,
		lastUpdated => 1149392138,
	},

	'record.entryId' => {
		message => q|A unique identifier for this record entry.|,
		lastUpdated => 1149392138,
	},

	'record.ipAddress' => {
		message => q|The IP Address of the user that submitted this record entry.|,
		lastUpdated => 1149392138,
	},

	'record.edit.url' => {
		message => q|The URL to edit this record.|,
		lastUpdated => 1149392138,
	},

	'record.edit.icon' => {
		message => q|An icon and associated URL for editing this record.|,
		lastUpdated => 1149392138,
	},

	'record.delete.url' => {
		message => q|The URL to delete this record.|,
		lastUpdated => 1149392138,
	},

	'record.delete.icon' => {
		message => q|An icon and associated URL for deleting this record.|,
		lastUpdated => 1149392138,
	},

	'record.username' => {
		message => q|The username of the person that submitted this record entry.|,
		lastUpdated => 1149392138,
	},

	'record.userId' => {
		message => q|The user id of the person that submitted this record entry.|,
		lastUpdated => 1149392138,
	},

	'record.submissionDate.epoch' => {
		message => q|The epoch date stamp for this record entry.|,
		lastUpdated => 1149392138,
	},

	'record.submissionDate.human' => {
		message => q|A human readable date stamp, based upon the user's preferences, for this record entry.|,
		lastUpdated => 1149392138,
	},

	'record.data_loop' => {
		message => q|A loop containing the data submitted by the user for each field in this data form.|,
		lastUpdated => 1149392138,
	},

	'record.data.name' => {
		message => q|The web safe name of this field.|,
		lastUpdated => 1149392138,
	},

	'record.data.label' => {
		message => q|The human readable label for this field.|,
		lastUpdated => 1149392138,
	},

	'record.data.value' => {
		message => q|The value submitted by the user for this field in this record entry.|,
		lastUpdated => 1149392138,
	},

	'record.data.isMailField' => {
		message => q|A conditional indicating whether this field exists for the mail subsystem of the data form.|,
		lastUpdated => 1149392138,
	},

	'record_data_type' => {
		message => q|The data type associated with this field.|,
		lastUpdated => 1189713018,
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
        'defaultView var desc' => {
		 message => q|This will be true if the DataForm was configured to display the List view by default, instead of the Form.|,
		 lastUpdated => 1168535997,
        },
        'data form' => {
		 message => q|Data Form|,
		 lastUpdated => 1113435285,
        },
        'data list' => {
		 message => q|Data List|,
		 lastUpdated => 1113435295,
        },

        'templateId' => {
		 message => q|The ID of the template for displaying the form view of the DataForm.|,
		 lastUpdated => 1164910794,
        },

        'emailTemplateId' => {
		 message => q|The ID of the template for sending emails of user submitted data from the DataForm.|,
		 lastUpdated => 1164910794,
        },

        'acknowlegementTemplateId' => {
		 message => q|The ID of the template for displaying the acknowledgement to the user after they have submitted data to the DataForm.|,
		 lastUpdated => 1164910794,
        },

        'listTemplateId' => {
		 message => q|The ID of the template for displaying the list view of the DataForm.|,
		 lastUpdated => 1164910794,
        },

        'acknowledgement var desc' => {
		 message => q|The acknowledgement to display to the user after they have submitted data.|,
		 lastUpdated => 1164910794,
        },

        'mailData' => {
		 message => q|mailData will be true if the DataForm was configured to send emails.|,
		 lastUpdated => 1164910794,
        },

        'mailAttachments' => {
		 message => q|mailAttachments will be true if the DataForm was configured to email files submitted to the DataForm.|,
		 lastUpdated => 1164910794,
        },

        'groupToViewEntries' => {
		 message => q|The Group ID of the group set to view the list of all data submitted to the DataForm when it is in Form mode.|,
		 lastUpdated => 1164910794,
        },

        'canViewEntries' => {
            message     => 'This template variable is true when the current user is allowed to view the list of submitted DataForm entries.',
            lastUpdated => 0,
        },

        'data form asset template variables title' => {
		 message => q|DataForm Asset Template Variables|,
		 lastUpdated => 1164910794,
        },

        'data form asset template variables body' => {
		 message => q|Every asset provides a set of variables to most of its
templates based on the internal asset properties.  Some of these variables may
be useful, others may not.|,
		 lastUpdated => 1164910794,
        },

        'error captcha' => {
            message     => q{CAPTCHA entered incorrectly. Please try again.},
            lastUpdated => 0,
            context     => q{Error message for CAPTCHA "Verify Your Humanity" failure},
        },
        
        'template captcha label' => {
            message     => q{Verify Your Humanity},
            lastUpdated => 0,
            context     => q{Label for CAPTCHA field in data form},
        },

        'editForm useCaptcha label' => {
            message     => q{Use Captcha for Visitors?},
            lastUpdated => 0,
            context     => q{Label for asset property},
        },

        'editForm useCaptcha description' => {
            message     => q{If 'yes', the DataForm will require a CAPTCHA for Visitors. Registered users
                            will not see the CAPTCHA.},
            lastUpdated => 0,
            context     => q{Description of asset property},
        },

        'store data' => {
            message     => 'Store Data',
            lastUpdated => 0,
        },

        'store data description' => {
            message     => 'Whether to store submitted data',
            lastUpdated => 0,
        },

        'helpvar useCaptcha' => {
            message     => q{This variable is true when the CAPTCHA should be shown.},
            lastUpdated => 0,
            context     => q{Description of template variable},
        },

        'helpvar form.captcha' => {
            message     => q{The input field and image for the CAPTCHA},
            lastUpdated => 0,
            context     => q{Description of template variable},
        },

    'editForm workflowIdAddEntry label' => {
        message     => q{Add Entry Workflow},
        lastUpdated => 0,
        context     => q{Label for asset property},
    },

    'editForm workflowIdAddEntry description' => {
        message     => q{Workflow to be run when an entry is added to the DataForm},
        lastUpdated => 0,
        context     => q{Description of asset property},
    },

    'Entry ID' => {
        message     => q{Entry ID},
        lastUpdated => 1229910550,
        context     => q{Unique identifier for this entry.  i18n label for template},
    },

    'Submission Date' => {
        message     => q{Submission Date},
        lastUpdated => 1229910550,
        context     => q{The date that this entry was submitted to the site. i18n label for template},
    },

    'help record.noloop' => {
        message     => q{You can get any field's value in this record by name, ex: record.noloop.subject},
        lastUpdated => 0,
        context     => q{Help for template variable},
    },

    'add entry' => {
        message     => q{Add Entry},
        lastUpdated => 0,
        context     => q{Label for link to add a new entry to the dataform},
    },

};

1;
