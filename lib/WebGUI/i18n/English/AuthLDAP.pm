package WebGUI::i18n::English::AuthLDAP;

our $I18N = {
	'sync profiles to ldap' => {
		message => q|Sync Profiles To LDAP|,
		lastUpdated => 0,
		context => q|the title for the sync profiles workflow activity|
	},

	'account template' => {
		message => q|Account Template|,
		lastUpdated => 1078852969
	},

	'create account template' => {
		message => q|Create Account Template|,
		lastUpdated => 1078852969
	},

	'login template' => {
		message => q|Login Template|,
		lastUpdated => 1078852969
	},

	'display account template title' => {
		message => q|LDAP Authentication Display Account Template|,
		lastUpdated => 1078852969
	},

	'11' => {
		message => q|No connect DN specified for this user|,
		lastUpdated => 1071848383
	},

	'7' => {
		message => q|LDAP Identity Name|,
		lastUpdated => 1031514049
	},

	'2' => {
		message => q|Cannot connect to LDAP server.|,
		lastUpdated => 1031514049
	},

	'anon reg template title' => {
		message => q|LDAP Authentication Anonymous Registration Template|,
		lastUpdated => 1078855925
	},

	'1' => {
		message => q|LDAP Authentication Options|,
		lastUpdated => 1039450730
	},

	'auth login template body' => {
		message => q|<p>The following template variables are available for LDAP Authentication Login templates.
</p>

<p><b>login.form.header</b><br />
The required form elements that go at the top of the login page.
</p>

<p><b>login.form.hidden</b><br />
Hidden form fields required for form submission.
</p>

<p><b>login.form.footer</b><br />
The required form elements that go after the login page form.
</p>

<p><b>login.form.submit</b><br />
The default submit button for the login form.
</p>

<p><b>login.form.username</b><br />
Default username form field.
</p>

<p><b>login.form.username.label</b><br />
Default text for username form field.
</p>

<p><b>login.form.password</b><br />
Default password form field.
</p>

<p><b>login.form.password.label</b><br />
Default text for password form field.
</p>

<p><b>title</b><br />
Default page title.
</p>

<p><b>login.message</b><br />
Any message returned by the system.  Usually displays after the form is submitted.
</p>

<p><b>anonymousRegistration.isAllowed</b><br />
Flag indicating whether or not anonymous registrations are allowed.
</p>

<p><b>createAccount.url</b><br />
URL for the anonymous registration page.
</p>

<p><b>createAccount.label</b><br />
Default label for the anonymous registration link.
</p>

|,
		lastUpdated => 1101771743
	},

	'13' => {
		message => q|Invalid LDAP connection URL. Contact your administrator.|,
		lastUpdated => 1071849063
	},

	'ldapConnection' => {
		message => q|LDAP Connection|,
		lastUpdated => 1071849063
	},

	'ldapConnection description' => {
		message => q|Select one of the preconfigured LDAP connections to authenticate this user|,
		lastUpdated => 1120171999
	},

	'6' => {
		message => q|LDAP Identity (default)|,
		lastUpdated => 1031514049
	},

	'3' => {
		message => q|LDAP URL|,
		lastUpdated => 1031514049
	},

	'9' => {
		message => q|User RDN|,
		lastUpdated => 1053777552
	},

	'12' => {
		message => q|No LDAP Url Specified for this user|,
		lastUpdated => 1071848371
	},

	'8' => {
		message => q|LDAP Password Name|,
		lastUpdated => 1031514049
	},

	'4' => {
		message => q|Connect DN|,
		lastUpdated => 1031514049
	},

	'display account template body' => {
		message => q|<p>The following template variables are available for the LDAP Authentication Display Account templates.</p>

<p><b>account.form.karma</b><br />
A read only form property displaying the amount of karma a user has.  Karma is a configurable user setting that is turned off by default.
</p>

<p><b>account.form.karma.label</b><br />
Internationalized text label for the karma form value.
</p>

<p><b>account.options</b><br />
Links list of options which allow users to turn on Admin, view and edit profile, view the inbox, etc.
</p>

<p><b>displayTitle</b><br />
Page title.
</p>

<p><b>account.message</b><br />
Any message returned by the system.  Usually displays after the form is submitted.
</p>

|,
		lastUpdated => 1146804908
	},

	'10' => {
		message => q|Password (confirm)|,
		lastUpdated => 1071845113
	},

	'anon reg template body' => {
		message => q|<p>The following template variables are available for LDAP Authentication Anonymous Registration templates.</p>

<p><b>create.form.header</b><br />
The required form elements that go at the top of the anonymous registration page.
</p>

<p><b>create.form.hidden</b><br />
Hidden form fields required for form submittal.
</p>

<p><b>create.form.footer</b><br />
The required form elements that go after the anonymous registration page form. 
</p>

<p><b>create.form.submit</b><br />
The default submit button for the anonymous registration form.
</p>

<p><b>title</b><br />
Default page title.
</p>

<p><b>create.form.profile</b><br />
A loop containing visible and required profile fields for registration.
</p>

<div class="helpIndent">

<p><b>profile.formElement</b><br />
Form element for visible or required profile field.
</p>

<p><b>profile.formElement.label</b><br />
Default text label for profile form element.
</p>

</div>

<p><b>login.url</b><br />
URL for the login page.
</p>

<p><b>login.label</b><br />
Default text label for login page link.
</p>

<p><b>create.message</b><br />
Any message returned by the system.  Usually displays after the form is submitted.
</p>

<p><b>create.form.ldapId</b><br />
Default ldapId form field.
</p>

<p><b>create.form.ldapId.label</b><br />
Default text for ldapId form field.
</p>

<p><b>create.form.password</b><br />
Default password form field.
</p>

<p><b>create.form.password.label</b><br />
Default text for password form field.
</p>

|,
		lastUpdated => 1146804934
	},

	'5' => {
		message => q|LDAP URL (default)|,
		lastUpdated => 1031514049
	},

	'auth login template title' => {
		message => q|LDAP Authentication Login Template|,
		lastUpdated => 1078854953
	},

	'LDAPLink_0' => {
		message => q|success (0)|,
		lastUpdated => 1031514049
	},

	'LDAPLink_1' => {
		message => q|Operations Error (1)|,
		lastUpdated => 1078854953
	},

	'LDAPLink_2' => {
		message => q|Protocol Error (2)|,
		lastUpdated => 1078854953
	},

	'LDAPLink_3' => {
		message => q|Time Limit Exceeded (3)|,
		lastUpdated => 1078854953
	},

	'LDAPLink_4' => {
		message => q|Size Limit Exceeded (4)|,
		lastUpdated => 1078854953
	},

	'LDAPLink_5' => {
		message => q|Compare False (5)|,
		lastUpdated => 1078854953
	},

	'LDAPLink_6' => {
		message => q|Compare True (6)|,
		lastUpdated => 1078854953
	},

	'LDAPLink_7' => {
		message => q|Auth Method Not Supported (7)|,
		lastUpdated => 1078854953
	},

	'LDAPLink_8' => {
		message => q|Strong Auth Required (8)|,
		lastUpdated => 1078854953
	},

	'LDAPLink_10' => {
		message => q|Referral (10)|,
		lastUpdated => 1078854953
	},

	'LDAPLink_11' => {
		message => q|Admin Limit Exceeded (11)|,
		lastUpdated => 1078854953
	},

	'LDAPLink_12' => {
		message => q|Unavailable Critical Extension (12)|,
		lastUpdated => 1078854953
	},

	'LDAPLink_13' => {
		message => q|Confidentiality Required (13)|,
		lastUpdated => 1078854953
	},

	'LDAPLink_14' => {
		message => q|Sasl Bind In Progress (14)|,
		lastUpdated => 1078854953
	},

	'LDAPLink_15' => {
		message => q|No Such Attribute (16)|,
		lastUpdated => 1078854953
	},

	'LDAPLink_17' => {
		message => q|Undefined Attribute Type (17)|,
		lastUpdated => 1078854953
	},

	'LDAPLink_18' => {
		message => q|Inappropriate Matching (18)|,
		lastUpdated => 1078854953
	},

	'LDAPLink_19' => {
		message => q|Constraint Violation (19)|,
		lastUpdated => 1078854953
	},

	'LDAPLink_20' => {
		message => q|Attribute Or Value Exists (20)|,
		lastUpdated => 1078854953
	},

	'LDAPLink_21' => {
		message => q|Invalid Attribute Syntax (21)|,
		lastUpdated => 1078854953
	},

	'LDAPLink_32' => {
		message => q|No Such Object (32)|,
		lastUpdated => 1078854953
	},

	'LDAPLink_33' => {
		message => q|Alias Problem (33)|,
		lastUpdated => 1078854953
	},

	'LDAPLink_34' => {
		message => q|Invalid DN Syntax (34)|,
		lastUpdated => 1078854953
	},

	'LDAPLink_36' => {
		message => q|Alias Dereferencing Problem (36)|,
		lastUpdated => 1078854953
	},

	'LDAPLink_48' => {
		message => q|Inappropriate Authentication (48)|,
		lastUpdated => 1078854953
	},

	'LDAPLink_49' => {
		message => q|Invalid Credentials (49)|,
		lastUpdated => 1078854953
	},

	'LDAPLink_50' => {
		message => q|Insufficient Access Rights (50)|,
		lastUpdated => 1078854953
	},

	'LDAPLink_51' => {
		message => q|Busy (51)|,
		lastUpdated => 1078854953
	},

	'LDAPLink_52' => {
		message => q|Unavailable (52)|,
		lastUpdated => 1078854953
	},

	'LDAPLink_53' => {
		message => q|Unwilling To Perform (53)|,
		lastUpdated => 1078854953
	},

	'LDAPLink_54' => {
		message => q|Loop Detect (54)|,
		lastUpdated => 1078854953
	},

	'LDAPLink_64' => {
		message => q|Naming Violation (64)|,
		lastUpdated => 1078854953
	},

	'LDAPLink_65' => {
		message => q|Object Class Violation (65)|,
		lastUpdated => 1078854953
	},

	'LDAPLink_66' => {
		message => q|Not Allowed On Non Leaf (66)|,
		lastUpdated => 1078854953
	},

	'LDAPLink_67' => {
		message => q|Not Allowed On RDN (67)|,
		lastUpdated => 1078854953
	},

	'LDAPLink_68' => {
		message => q|Entry Already Exists (68)|,
		lastUpdated => 1078854953
	},

	'LDAPLink_69' => {
		message => q|Object Class Mods Prohibited (69)|,
		lastUpdated => 1078854953
	},

	'LDAPLink_71' => {
		message => q|Affects Multiple DSAs (71)|,
		lastUpdated => 1078854953
	},

	'LDAPLink_80' => {
		message => q|other (80)|,
		lastUpdated => 1078854953
	},

	'LDAPLink_100' => {
		message => q|No LDAP Url Specified|,
		lastUpdated => 1078854953
	},

	'LDAPLink_101' => {
		message => q|No Username Specified|,
		lastUpdated => 1078854953
	},

	'LDAPLink_102' => {
		message => q|No Identifier Specified|,
		lastUpdated => 1078854953
	},

	'LDAPLink_103' => {
		message => q|Cannot connect to LDAP server.|,
		lastUpdated => 1078854953
	},

	'LDAPLink_104' => {
		message => q|The account information you supplied is invalid. Either the account does not exist or the username/password combination was incorrect.|,
		lastUpdated => 1078854953
	},

	'LDAPLink_105' => {
		message => q|Invalid LDAP connection URL. Contact your administrator.|,
		lastUpdated => 1078854953
	},


	'LDAPLink_982' => {
		message => q|Add an ldap connection.|,
		lastUpdated => 1056151382
	},

	'LDAPLink_983' => {
		message => q|Edit this ldap connection.|,
		lastUpdated => 1056151382
	},

	'LDAPLink_984' => {
		message => q|Copy this ldap connection.|,
		lastUpdated => 1056151382
	},

	'LDAPLink_985' => {
		message => q|Delete this ldap connection.|,
		lastUpdated => 1056151382
	},

	'LDAPLink_986' => {
		message => q|Back to ldap connections.|,
		lastUpdated => 1056151382
	},

	'LDAPLink_988' => {
		message => q|Are you certain you wish to delete this ldap connection?|,
		lastUpdated => 1116151382
	},

	'LDAPLink_990' => {
		message => q|Edit LDAP Connection|,
		lastUpdated => 1056151382
	},

	'LDAPLink_991' => {
		message => q|LDAP Connection ID|,
		lastUpdated => 1056151382
	},

	'LDAPLink_992' => {
		message => q|Name|,
		lastUpdated => 1056151382
	},

	'LDAPLink_993' => {
		message => q|LDAP URL|,
		lastUpdated => 1056151382
	},

	'LDAPLink_994' => {
		message => q|Connect DN|,
		lastUpdated => 1056151382
	},

	'LDAPLink_995' => {
		message => q|Identifier|,
		lastUpdated => 1056151382
	},

        'LDAPLink_992 description' => {
                message => q|The name of this connection.  All LDAP connection names must be unique.|,
                lastUpdated => 1120164594,
        },

        'LDAPLink_993 description' => {
                message => q|The URL used to connect to the LDAP server.|,
                lastUpdated => 1120164594,
        },

        'LDAPLink_994 description' => {
                message => q|<p>DN = Distinguished Name. A DN is a unique path to a particular object within an LDAP
directory. In this case, the "Connect DN" is the DN that points to the user account
record. Usually that will look something like:</p>
<p>cn=Joe Shmoe,ou=people,dc=example,dc=com</p>|,
                lastUpdated => 1146630168,
        },

        'LDAPLink_995 description' => {
                message => q|The password for the LDAP connection|,
                lastUpdated => 1120164594,
        },

        '9 description' => {
                message => q|<p>RDN is a relative distinguished name. It means that we're looking at only part of the
path. In this case, the "User RDN" is the path to where user records can be found.
Usually the RDN looks something like:</p>
<p>ou=people,dc=example,dc=com</p>|,
                lastUpdated => 1146630220,
        },

        '6 description' => {
                message => q|The LDAP Identity is the unique identifier in the LDAP server that the user will be identified against. Often this field is <b>shortname</b>, which takes the form of first initial + last name. Example: jdoe. Therefore if you specify the LDAP identity to be <i>shortname</i> then Jon Doe would enter <i>jdoe</i> during the registration process.|,
                lastUpdated => 1120164594,
        },

        '7 description' => {
                message => q|The label used to describe the LDAP Identity to the user. For instance, some companies use an LDAP server for their proxy server users to authenticate against. In the documentation or training already provided to their users, the LDAP identity is known as their <i>Web Username</i>. So you could enter that label here for consistency.|,
                lastUpdated => 1120164594,
        },

        '8 description' => {
                message => q|Just as the LDAP Identity Name is a label, so is the LDAP Password Name. Use this label as you would LDAP Identity Name.|,
                lastUpdated => 1120164594,
        },

        '868 description' => {
                message => q|<p>Do you wish WebGUI to automatically send users a welcome message when they register for your site? 
</p>
<p>
<b>NOTE:</b> In addition to the message you specify below, the user's account information will be included in the message.</p>|,
                lastUpdated => 1120164594,
        },

        '869 description' => {
                message => q|Type the message that you'd like to be sent to users upon registration.|,
                lastUpdated => 1120164594,
        },

        'account template description' => {
                message => q|Template to be used to display a user's account.|,
                lastUpdated => 1120164594,
        },

        'create account template description' => {
                message => q|Template to be used to show the form for creating an account.|,
                lastUpdated => 1120164594,
        },

        'login template description' => {
                message => q|Template used to display login information to the user as an operation as opposed to inside of a page via a macro.|,
                lastUpdated => 1120164594,
        },

        'ldap connection add/edit body' => {
                message => q| |,
		lastUpdated => 1120164639,
	},

	'868' => {
		message => q|Send welcome message?|,
		lastUpdated => 1120164338
	},

	'869' => {
		message => q|Welcome Message|,
		lastUpdated => 1120164366
	},

	'LDAPLink_1075' => {
		message => q|LDAP Connection|,
		lastUpdated => 1070899134
	},

	'LDAPLink_1076' => {
		message => q|WebGUI LDAP Connection|,
		lastUpdated => 1070899134
	},

	'LDAPLink_1077' => {
		message => q|Connection Status|,
		lastUpdated => 1070899134
	},

	'LDAPLink_1078' => {
		message => q|Invalid|,
		lastUpdated => 1070899134
	},

	'LDAPLink_1079' => {
		message => q|Valid|,
		lastUpdated => 1070899134
	},

	'LDAPLink_ldapGroup' => {
		message => q|LDAP Group|,
		lastUpdated => 1116151382
	},

	'LDAPLink_ldapGroup description' => {
		message => q|Group membership can also be controlled via LDAP.  Provide the LDAP DN of a group to check users for.  Next, set either the LDAP Group Property or the LDAP Recursive Group Property.|,
		lastUpdated => 1120447990,
	},

	'LDAPLink_ldapGroupProperty' => {
		message => q|LDAP Group Property|,
		lastUpdated => 1116151382
	},

	'LDAPLink_ldapGroupProperty description' => {
		message => q|LDAP property to retrieve from the LDAP Group.  If both the LDAP Recursive Group Propery and LDAP Group Property are set, then the Recursive Group Property will be used.|,
		lastUpdated => 1120447986,
	},

	'LDAPLink_ldapRecursiveProperty' => {
		message => q|LDAP Recursive Group Property|,
		lastUpdated => 1116151382
	},

	'LDAPLink_ldapRecursiveProperty description' => {
		message => q|A property to recursively search the LDAP Group for.  If both the LDAP Recursive Group Propery and LDAP Group Property are set, then the Recursive Group Property will be used.|,
		lastUpdated => 1120447983,
	},

	'ldapconnections' => {
		message => q|LDAP Connections|,
		lastUpdated =>1092930637,
        context => q|Title of the ldap connection manager for the admin console.|
	},

	'topicName' => {
		message => q|LDAP Authentication|,
		lastUpdated => 1128919880
	},

};

1;
