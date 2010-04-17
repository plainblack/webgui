package WebGUI::i18n::English::WebGUIProfile;
use strict;

our $I18N = {
	'787' => {
		message => q|Edit this profile field.|,
		lastUpdated => 1036964659
	},

	'469' => {
		message => q|Id|,
		lastUpdated => 1031514049
	},

	'470' => {
		message => q|Category Name|,
		lastUpdated => 1031514049
	},

    'category short name' => {
        message => q|Category Short Name|,
        lastUpdated => 1031514049
	},

    'category short name description' => {
        message => q|The short name of the this category.|,
        lastUpdated => 1122315199,
    },

	'475' => {
		message => q|Field Name|,
		lastUpdated => 1031514049
	},

	'472' => {
		message => q|Label|,
		lastUpdated => 1031514049
	},

	'486' => {
		message => q|Data Type|,
		lastUpdated => 1031514049
	},

	'487' => {
		message => q|Possible Values|,
		lastUpdated => 1031514049
	},

	'488' => {
		message => q|Default Value(s)|,
		lastUpdated => 1031514049
	},

	'790' => {
		message => q|Delete this profile category.|,
		lastUpdated => 1036964807
	},

    '475 description' => {
        message => q|The name of the field, used internally in the database.  Field names may not contain spaces.  Certain field names are reserved, such as "op", "func", "username", "shop", "karma", "status", "lastUpdated", "dateCreated".|,
        lastUpdated => 1264448486,
    },

        '472 description' => {
                message => q|A short, descriptive label displayed to the user.  This can be a call to WebGUI's
Internationalization system if labels need to be localized.|,
                lastUpdated => 1167193730,
        },

        '474 description' => {
                message => q|Should the user be required to fill out this field?  If this option is set to yes, then the field will automatically be set to be editable as well.|,
                lastUpdated => 1250537322,
        },

        '486 description' => {
                message => q|Choose the type of form element for this field.   This is also used
to validate any input that the user may supply.|,
                lastUpdated => 1122316558,
        },

        '487 description' => {
                message => q|<p>This area should only be used in with the following form fields:
<br /><br />
Checkbox List<br />
Combo Box<br />
Hidden List<br />
Radio List<br />
Select Box<br />
Select List<br />
<br><br>
None of the other profile fields should use the Possible Values field as it will be ignored.<br />
If you do enter a Possible Values list, it MUST be formatted as follows
<pre>
{
   "key1"=>"value1",
   "key2"=>"value2",
   "key3"=>"value3"
   ...
}
</pre><br />
Braces, quotes and all.  You simply replace "key1"/"value1" with your own name/value pairs.|,
                lastUpdated => 1132542146,
        },

        '488 description' => {
                message => q|<p>
				   This area should only be used if you have used the Possible Values area above which is to say that it should only be used in conjunction with:
<br />
Checkbox List<br />
Combo Box<br />
Hidden List<br />
Radio List<br />
Select Box<br />
Select List<br />
<br><br>
None of the other profile fields should use the Default Values field as it will be ignored.  If you do enter Default Values, they MUST directly reference one or more of your Possible Values keys as follows:
<pre>["key1","key2",...]</pre><br />
Brackets, quotes and all.<br /><br />
If you wish to set the Default Value for any other field.  Create the field without setting this area, then go into the Visitor's profile and save the value you'd like to display by default for the newly created field.  This will result in the desired result of having the default field set whenever you create a new user.
</p>|,
                lastUpdated => 1122316558,
        },

        '489 description' => {
                message => q|Select a category to place this field under.|,
                lastUpdated => 1122316558,
        },

	'492' => {
		message => q|Profile fields list|,
		lastUpdated => 1031514049
	},

	'466' => {
		message => q|Are you certain you wish to delete this category and all of its fields?|,
		lastUpdated => 1214599497,
	},

        '470 description' => {
                message => q|The name of the this category.|,
                lastUpdated => 1122315199,
        },

        '473 description' => {
                message => q|Should the category be visible to users?|,
                lastUpdated => 1122315199,
        },

        '473a description' => {
                message => q|Should the field be visible to users?|,
                lastUpdated => 1141667205,
        },

        '897 description' => {
                message => q|Should the category be editable by users?|,
                lastUpdated => 1122315199,
        },

        '897a description' => {
                message => q|Should the field be editable by users?|,
                lastUpdated => 1141667241,
        },

	'489' => {
		message => q|Profile Category|,
		lastUpdated => 1031514049
	},

	'471' => {
		message => q|Edit User Profile Field|,
		lastUpdated => 1031514049
	},

	'491' => {
		message => q|Add a profile field.|,
		lastUpdated => 1031514049
	},

	'467' => {
		message => q|Are you certain you wish to delete this field and all user data attached to it?|,
		lastUpdated => 1031514049
	},

	'897' => {
		message => q|Editable?|,
		context => q|Label for profile categories|,
		lastUpdated => 1050167573
	},

	'897a' => {
		message => q|Editable?|,
		context => q|Label for profile fields|,
		lastUpdated => 1141667261
	},

	'474' => {
		message => q|Required?|,
		lastUpdated => 1031514049
	},

	'789' => {
		message => q|Edit this profile category.|,
		lastUpdated => 1036964795
	},

	'490' => {
		message => q|Add a profile category.|,
		lastUpdated => 1031514049
	},

	'788' => {
		message => q|Delete this profile field.|,
		lastUpdated => 1036964681,
	},

	'473' => {
		message => q|Visible?|,
		lastUpdated => 1031514049,
		context => q|Label for visibility field for profile categories|,
	},

	'473a' => {
		message => q|Visible?|,
		lastUpdated => 1141667189,
		context => q|Label for visibility field for profile fields|,
	},

	'user profiling' => {
		message => q|User Profiling|,
		lastUpdated =>1092930637,
                context => q|Title of the user profile settings manager for the admin console.|
        },

	'topicName' => {
		message => q|User Profile|,
		lastUpdated => 1128920410,
	},

        'forceImageOnly label' => {
                message => q|Force Image Only Uploads|,
                lastUpdated => 1162945563
        },

        'forceImageOnly hoverHelp' => {
                message => "If set to yes, this form control will only allow image file types to be uploaded through it.",
                lastUpdated => 1162945563
        },

        'forceImageOnly description' => {
                message => "If your profile field requires uploading an Image, you will provided with an additional field that will only allow image file types are uploaded.",
                lastUpdated => 1165447428
        },

	'showAtRegistration label' => {
                message => "Show at Registration?",
                lastUpdated => 1164237018
        },

	'showAtRegistration hoverHelp' => {
                message => "Show an entry for this field at the registration screen for newly-registering users.  The field will not actually be required unless Required is also set.",
                lastUpdated => 1164237018
        },

	'requiredForPasswordRecovery label' => {
                message => "Required for password recovery?",
                lastUpdated => 1165401097
        },

	'requiredForPasswordRecovery hoverHelp' => {
                message => "Require users to enter this field for password recovery.  Only users that enter all such fields correctly and uniquely to them will be able to perform password recovery.",
                lastUpdated => 1165401097
    },

	'view profile template title' => {
        message => 'View Profile Template',
        lastUpdated => 1213326336,
    },

	'view profile template body' => {
        message => 'This template is used to show the user their User Profile.',
        lastUpdated => 1213326336,
    },

	'displayTitle' => {
        message => q|An internationalized title containing the user's name.|,
        context => q|Template variable for edit and view profile field|,
        lastUpdated => 1213326336,
    },

	'profile.elements' => {
        message => q|A loop containing all profile field elements.|,
        lastUpdated => 1213326336,
    },

    'profile.extras' => {
        message => q|Extra HTML for this field.|,
        lastUpdated => 1224631267,
    },

	'profile.category' => {
        message => q|The name of the current category.  This variable will only exist for the first profile field in each category.|,
        lastUpdated => 1213326336,
    },

	'profile.label' => {
        message => q|The label for this profile field.|,
        lastUpdated => 1213326336,
    },

	'profile.value' => {
        message => q|The value of this profile field.|,
        lastUpdated => 1213326336,
    },

	'profile.accountOptions' => {
        message => q|A loop containing options for other account actions, such as editing a profile, viewing a profile, changing your account, and so on.|,
        lastUpdated => 1213326336,
    },

	'account.options' => {
        message => q|A link to an account option with label.|,
        lastUpdated => 1213326336,
    },

	'edit profile template title' => {
        message => 'Edit Profile Template',
        lastUpdated => 1213326336,
    },

	'edit profile template body' => {
        message => 'This template builds a form for the user to edit their User Profile.',
        lastUpdated => 1213326336,
    },

	'profile.message' => {
        message => q|Messages from the system, in case of errors or further work on the user's part.|,
        context => q|Template variable for edit profile field|,
        lastUpdated => 1213326336,
    },

	'profile.form.header' => {
        message => q|HTML code to begin the form|,
        context => q|Template variable for edit profile field|,
        lastUpdated => 1213326336,
    },

	'profile.form.footer' => {
        message => q|HTML code to end the form|,
        context => q|Template variable for edit profile field|,
        lastUpdated => 1213326336,
    },

	'profile.form.hidden' => {
        message => q|HTML code for directing the form's action|,
        context => q|Template variable for edit profile field|,
        lastUpdated => 1213326336,
    },

	'profile.form.submit' => {
        message => q|A button to submit edits to the user's profile.|,
        context => q|Template variable for edit profile field|,
        lastUpdated => 1213326336,
    },

	'profile.form.cancel' => {
        message => q|A button to return the user to the last page they viewed without submitting any form data.|,
        context => q|Template variable for edit profile field|,
        lastUpdated => 1213326336,
    },

	'profile.form.elements' => {
        message => q|A loop containing all profile fields, sorted by category.|,
        context => q|Template variable for edit profile field|,
        lastUpdated => 1221580083,
    },

    'profile.form.extras' => {
        message => q|Extra HTML for this field.|,
        context => q|Template variable for edit profile field|,
        lastUpdated => 1224631267,
    },

	'profile.form.category' => {
        message => q|The name of this category.|,
        context => q|Template variable for edit profile field|,
        lastUpdated => 1221580083,
    },

	'profile.form.category.loop' => {
        message => q|A loop containing all fields in this category.|,
        context => q|Template variable for edit profile field|,
        lastUpdated => 1221580083,
    },

	'profile.form.element' => {
        message => q|The form element for this profile field.|,
        context => q|Template variable for edit profile field|,
        lastUpdated => 1221580083,
    },

	'profile.form.element.label' => {
        message => q|The label assigned to this profile field.|,
        context => q|Template variable for edit profile field|,
        lastUpdated => 1221580083,
    },

	'profile.form.element.subtext' => {
        message => q|If this profile field is a required profile field, then this will contain an asterisk "*".|,
        context => q|Template variable for edit profile field|,
        lastUpdated => 1221580083,
    },
    'profile field extras label' => {
        message => q|Extras|,
        lastUpdated => 1224620527,
    },
    'profile field extras hoverHelp' => {
        message => q|Extra HTML to include with this profile field.|,
        lastUpdated => 1224620527,
    },

    'default privacy setting label' => {
        message => q|Default Privacy Setting|,
        lastUpdated => 0,
        context => q|Label for a profile field property on the Edit User Profile Field screen.|,
    },

    'default privacy setting description' => {
        message => q|Select the default privacy setting for this profile field. This will be used when a new user is created.|,
        lastUpdated => 0,
        context => q|Description for a profile field property, used as hoverhelp on the Edit User Profile Field screen.|,
    },

};

1;
