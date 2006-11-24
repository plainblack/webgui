package WebGUI::i18n::English::AuthLDAP;

our $I18N = {
        'global recursive filter label' => {
		   message => q|LDAP Recursive Group Filter|,
		   lastUpdate => 1160517240
    },
		'global recursive filter label description' => {
		   message => q|Enter any number of strings by which to filter out anything in your recursive LDAP group that is not a group, delimited by newlines.  An object matching any one of these strings will not be searched recursively.  This is a performance setting which can help speed up the group search in the case where your groups and group members are both part of the same attribute used for groups of groups within LDAP.  For example, if both users and groups are stored in the "member" attribute and users always contain the string o= while groups contain the string cn=, you might add o= as a filter in order to skip over users and only search recursively within groups.  This setting will be applied to each LDAP group with recursive group settings.  Optionally, you may choose to apply this setting to individual groups; in that case, the individual group setting will override the global setting.|,
		   lastUpdate => 1160517240
    },
	    'LDAPLink_ldapRecursiveFilter' => {
		   message => q|LDAP Recursive Group Filter|,
		   lastUpdate => 1160517240
	},
	    'LDAPLink_ldapRecursiveFilterDescription' => {
		   message => q|Enter any number of strings by which to filter out anything in your recursive LDAP group that is not a group.  An object matching any of these strings will not be searched recursively. This is a performance setting which can help speed up the group search in the case where your groups and group members are both part of the same attribute used for groups of groups within LDAP.  For example, if both users and groups are stored in the "member" attribute and users always contain the string o= while groups contain the string cn=, you might add o= as a filter in order to skip over users and only search recursively within groups.  This setting will be applied to only this group, and will override any global filter you may have set for the LDAP connection chosen.|,
		   lastUpdate => 1160517240
	},
		'ldap link name blank' => {
		message => q|The LDAP Link Name field cannot be blank.|,
		lastUpdated => 0,
		context => q|error message|
	},
        'ldap url blank' => {
		message => q|The LDAP URL field cannot be blank.|,
		lastUpdated => 0,
		context => q|error message|
	},
        'ldap user rdn blank' => {
		message => q|The LDAP User RDN field cannot be blank.|,
		lastUpdated => 0,
		context => q|error message|
	},
        'ldap identity blank' => {
		message => q|The LDAP Identity field cannot be blank.|,
		lastUpdated => 0,
		context => q|error message|
	},
        'ldap identity name blank' => {
		message => q|The LDAP Identity Name field cannot be blank.|,
		lastUpdated => 0,
		context => q|error message|
	},
        'ldap password name blank' => {
		message => q|The LDAP Password Name field cannot be blank.|,
		lastUpdated => 0,
		context => q|error message|
	},
        'ldap url malformed' => {
		message => q|Malformed LDAP URL.  LDAP URLs must include the protocol, i.e., ldap://hostname/|,
		lastUpdated => 0,
		context => q|error message|
	},
        'error label' => {
		message => q|Error|,
		lastUpdated => 0,
		context => q|label in front of error message displayed to the user so they know it's an error|
	},
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

	'login.message' => {
		message => q|Any message returned by the system.  Usually displays after the form is submitted.|,
		lastUpdated => 1149219946,
	},

	'auth login template body' => {
		message => q|<p>The following template variables are available for LDAP Authentication Login templates.
</p>
|,
		lastUpdated => 1149220017
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

	'account.form.karma' => {
		message => q|A read only form property displaying the amount of karma a user has.  Karma is a configurable user setting that is turned off by default.|,
		lastUpdated => 1149219846,
	},

	'account.form.karma.label' => {
		message => q|Internationalized text label for the karma form value.|,
		lastUpdated => 1149219846,
	},

	'account.options' => {
		message => q|Links list of options which allow users to turn on Admin, view and edit profile, view the inbox, etc.|,
		lastUpdated => 1149219846,
	},

	'displayTitle' => {
		message => q|Page title.|,
		lastUpdated => 1149219846,
	},

	'account.message' => {
		message => q|Any message returned by the system.  Usually displays after the form is submitted.|,
		lastUpdated => 1149219846,
	},

	'display account template body' => {
		message => q|<p>The following template variables are available for the LDAP Authentication Display Account templates.</p>
|,
		lastUpdated => 1149219877
	},

	'10' => {
		message => q|Password (confirm)|,
		lastUpdated => 1071845113
	},

	'create.form.hidden' => {
		message => q|Hidden form fields required for form submittal.|,
		lastUpdated => 1149219898,
	},

	'title' => {
		message => q|Default page title.|,
		lastUpdated => 1149219898,
	},

	'create.message' => {
		message => q|Any message returned by the system.  Usually displays after the form is submitted.|,
		lastUpdated => 1149219898,
	},

	'create.form.ldapId' => {
		message => q|Default ldapId form field.|,
		lastUpdated => 1149219898,
	},

	'create.form.ldapId.label' => {
		message => q|Default text for ldapId form field.|,
		lastUpdated => 1149219898,
	},

	'create.form.ldapConnection' => {
		message => q|Form field containing a drop-down list to choose which LDAP connection to use to authenticate.|,
		lastUpdated => 1164405945,
	},

	'create.form.ldapConnection.label' => {
		message => q|Internationalized label for the drop-down list <b>create.form.ldapConnection</b>|,
		lastUpdated => 1164405947,
	},

	'create.form.ldapId.label' => {
		message => q|Default text for ldapId form field.|,
		lastUpdated => 1149219898,
	},

	'create.form.password' => {
		message => q|Default password form field.|,
		lastUpdated => 1149219898,
	},

	'create.form.password.label' => {
		message => q|Default text for password form field.|,
		lastUpdated => 1149219898,
	},

	'anon reg template body' => {
		message => q|<p>The following template variables are available for LDAP Authentication Anonymous Registration templates.</p>
|,
		lastUpdated => 1149219931
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

	'LDAPLink_70' => {
		message => q|The results of the request are too large (69)|,
		lastUpdated => 1147799577
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

	'deactivate account template title' => {
		message => q|LDAP Authentication Deactivate Account Template|,
		lastUpdated => 1164406538
	},

	'deactivate account template body' => {
		message => q|<p>The following template variables are available for the LDAP Authentication Deactivate account templates. 
</p>
|,
		lastUpdated => 1164406540
	},

	'topicName' => {
		message => q|LDAP Authentication|,
		lastUpdated => 1128919880
	},

};

1;
