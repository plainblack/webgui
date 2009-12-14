package WebGUI::i18n::English::WebGUI;
use strict;

our $I18N = {
	'ok' => {
		message => q|OK|,
		context => q|used by database link and other things to give a message to the user that a test passed|,
		lastUpdated => 0,
	},

	'is editable' => {
		message => q|Is Editable?|,
		context => q|group property|,
		lastUpdated => 0,
	},

	'show in forms' => {
		message => q|Show In Forms?|,
		context => q|group property|,
		lastUpdated => 0,
	},

	'is editable help' => {
		message => q|Should this group show up in the list of managable groups? Note, if you set this to 'No' then you will no longer be able to manage this group.|,
		context => q|group property|,
		lastUpdated => 0,
	},

	'show in forms help' => {
		message => q|Should this group show up in places where you can choose a group, such as privilege fields?|,
		context => q|group property|,
		lastUpdated => 0,
	},

	'run on admin create user' => {
		message => q|On Create User (Admin)|,
		context => q|field in trigger manager|,
		lastUpdated => 0,
	},

	'run on admin create user help' => {
		message => q|Run when an admin creates a user.|,
		context => q|help for field in trigger manager|,
		lastUpdated => 0,
	},

	'run on admin update user' => {
		message => q|On Update User (Admin)|,
		context => q|field in trigger manager|,
		lastUpdated => 0,
	},

	'run on admin update user help' => {
		message => q|Run when an admin updates a user.|,
		context => q|help for field in trigger manager|,
		lastUpdated => 0,
	},

	'skip commit comments' => {
		message => q|Skip commit comments?|,
		lastUpdated => 0,
	},

	'skip commit comments help' => {
		message => q|Do you wish to be prompted to add comments to your content commits?|,
		lastUpdated => 0,
	},

	'auto request commit' => {
		message => q|Automatically request commit?|,
		lastUpdated => 0,
	},

	'auto request commit help' => {
		message => q|Would you like the system to automatically request commits for you so that you don't have to
        remember to hit "Commit My Changes"? Note that when using this in conjunction with "Skip commit comments?"
        it effectively hides the whole versioning and workflow process from users.|,
		lastUpdated => 1218059129,
	},

	'select' => {
		message => q|Select|,
		lastUpdated => 0,
		context=>"form helpers"
	},

	'mail return path help' => {
		message => q|To what email address should undeliverable messages be sent?|,
		lastUpdated => 0,
		context=>"Settings hover help"
	},

	'mail return path' => {
		message => q|Return Path|,
		lastUpdated => 0,
		context=>"Settings"
	},

	'default version tag workflow help' => {
		message => q|Which workflow should be used by default when user's create their own version tags.|,
		lastUpdated => 0,
		context=>"Settings hover help"
	},

	'default version tag workflow' => {
		message => q|Default Version Tag Workflow|,
		lastUpdated => 0,
		context=>"Settings"
	},

	'trash workflow help' => {
		message => q|Which workflow to run when an asset is placed in the trash.|,
		lastUpdated => 1162242500,
		context=>"Settings hover help"
	},

	'trash workflow' => {
		message => q|Trash Workflow|,
		lastUpdated => 1162242500,
		context=>"Settings"
	},

	'purge workflow help' => {
		message => q|Which workflow to run when an asset is purged.|,
		lastUpdated => 1162242500,
		context=>"Settings hover help"
	},

	'purge workflow' => {
		message => q|Purge Workflow|,
		lastUpdated => 1162242500,
		context=>"Settings"
	},

	'changeUrl workflow help' => {
		message => q|Which workflow to run when an asset's URL is changed.|,
		lastUpdated => 1162348521,
		context=>"Settings hover help"
	},

	'changeUrl workflow' => {
		message => q|Change URL Workflow|,
		lastUpdated => 1162348521,
		context=>"Settings"
	},

	'expire groupings' => {
		message => q|Expire User Groupings|,
		lastUpdated => 0
	},

	'show performance indicators' => {
		message => q|Show performance indicators?|,
		lastUpdated => 0
	},

	'show performance indicators description' => {
		message => q|This will display the time (in seconds) it took to build each item on the page. It is useful for debugging performance problems.|,
		lastUpdated => 1127413010,
	},

	'debug ip description' => {
		message => q|This will limit debugging and/or performance output to a specific IP address or IP range. Enter the subnet that you want to be able to view debug output in CIDR format.  For example: 10.0.0.0/24.  Multiple CIDR addresses may be entered, separated by commas.|,
		lastUpdated => 1164055466
	},

	'debug ip' => {
		message => q|Debug IP|,
		lastUpdated => 0
	},

	'304' => {
		message => q|Language|,
		lastUpdated => 1031514049
	},

	'language help' => {
		message => q|Select the default language for users on the site.|,
		lastUpdated => 1258340387,
	},

	'559' => {
		message => q|On Create User (User)|,
		lastUpdated => 1185738895
	},

	'1049' => {
		message => q|Content Filter ID|,
		lastUpdated => 1066418840
	},

	'127' => {
		message => q|Company URL|,
		lastUpdated => 1031514049
	},

	'443' => {
		message => q|Home Information|,
		lastUpdated => 1031514049
	},

    'home info short' => {
		message => q|Home|,
		lastUpdated => 1031514049
	},

	'118' => {
		message => q|Anonymous Registration|,
		lastUpdated => 1031514049
	},

	'71' => {
		message => q|Recover password|,
		lastUpdated => 1031514049
	},

	'959' => {
		message => q|Empty system clipboard.|,
		lastUpdated => 1052850265
	},

	'882' => {
		message => q|Editor Mode|,
		lastUpdated => 1044705246
	},

	'358' => {
		message => q|Left Column|,
		lastUpdated => 1031514049
	},

	'331' => {
		message => q|Work State|,
		lastUpdated => 1031514049
	},

	'1050' => {
		message => q|Search For|,
		lastUpdated => 1066418903
	},

	'737' => {
		message => q|8 Master|,
		lastUpdated => 1033836698
	},

	'560' => {
		message => q|Approved|,
		lastUpdated => 1031514049
	},

	'84' => {
		message => q|Group Name|,
		lastUpdated => 1031514049
	},

	'437' => {
		message => q|Statistics|,
		lastUpdated => 1031514049,
                context => q|Title of the statistics viewer for the admin console.|
	},

    'required error' => {
		message => q{%s is required.},
		lastUpdated => 1031514049
	},

    'language not available error' => {
		message => q|%s is not available.  Please select another language|,
		lastUpdated => 1031514049
	},

	'451' => {
		message => q|is required.|,
		lastUpdated => 1031514049
	},

	'454' => {
		message => q|Last Updated|,
		lastUpdated => 1031514049
	},

	'1021' => {
		message => q|Rate Message|,
		lastUpdated => 1065356764
	},

	'978' => {
		message => q|User added successfully.|,
		lastUpdated => 1053804577
	},

	'728' => {
		message => q|Are you certain you wish to delete this file?|,
		lastUpdated => 1031514049
	},

	'float' => {
		message => q|Number (Decimal)|,
		lastUpdated => 1132097171
	},

	'948' => {
		message => q|Clipboard|,
		lastUpdated => 1099360884 
	},

	'378' => {
		message => q|User ID|,
		lastUpdated => 1031514049
	},

	'325' => {
		message => q|Home State|,
		lastUpdated => 1031514049
	},

	'889' => {
		message => q|Style Sheets, Tabs|,
		lastUpdated => 1046067380
	},

	'350' => {
		message => q|Completed|,
		lastUpdated => 1031514049
	},

	'572' => {
		message => q|Approve|,
		lastUpdated => 1031514049
	},

	'540' => {
		message => q|Karma Per Login|,
		lastUpdated => 1031514049
	},

	'58' => {
		message => q|I already have an account.|,
		lastUpdated => 1031514049
	},

	'527' => {
		message => q|Default Home Page|,
		lastUpdated => 1031514049
	},

	'431' => {
		message => q|IP Address|,
		lastUpdated => 1031514049
	},

	'861' => {
		message => q|Profile Privacy Setting|,
		lastUpdated => 1043879954
	},

	'337' => {
		message => q|Homepage URL|,
		lastUpdated => 1031514049
	},

	'340' => {
		message => q|Female|,
		lastUpdated => 1031514049
	},

	'76' => {
		message => q|That email address is not in our databases.|,
		lastUpdated => 1031514049
	},

	'311' => {
		message => q|Allow home information?|,
		lastUpdated => 1031514049
	},

	'62' => {
		message => q|save|,
		lastUpdated => 1031514049
	},

	'982' => {
		message => q|Add a database link.|,
		lastUpdated => 1056151382
	},

	'139' => {
		message => q|No|,
		lastUpdated => 1031514049
	},

	'859' => {
		message => q|Signature|,
		lastUpdated => 1043879866
	},

	'show all fields' => {
		message => q|Show all fields|,
		lastUpdated => 1141184463
	},

	'show my fields' => {
		message => q|Show fields my UI level allows|,
		lastUpdated => 1141184463
	},

	'739' => {
		message => q|UI Level|,
		lastUpdated => 1033832377
	},

	'992' => {
		message => q|Title|,
		lastUpdated => 1056151382
	},

	'418' => {
		message => q|Filter Content|,
		lastUpdated => 1046604931
	},

	'418 description' => {
		message => q|Choose the level of HTML filtering you wish to apply to the proxied content.|,
		lastUpdated => 1046604931
	},

	'706' => {
		message => q|Hour(s)|,
		lastUpdated => 1031514049
	},

	'168' => {
		message => q|Edit User|,
		lastUpdated => 1031514049
	},

	'135' => {
		message => q|SMTP Server|,
		lastUpdated => 1031514049
	},

	'14' => {
		message => q|View pending submissions.|,
		lastUpdated => 1031514049
	},

	'348' => {
		message => q|Name|,
		lastUpdated => 1031514049
	},

	'145' => {
		message => q|WebGUI Build Version|,
		lastUpdated => 1031514049
	},

	'993' => {
		message => q|DSN|,
		lastUpdated => 1056151382
	},

	'364' => {
		message => q|Search|,
		lastUpdated => 1031514049
	},

	'950' => {
		message => q|Empty clipboard.|,
		lastUpdated => 1052850265
	},

	'509' => {
		message => q|Discussion Layout|,
		lastUpdated => 1031514049
	},

	'160' => {
		message => q|Date Submitted|,
		lastUpdated => 1031514049
	},

	'976' => {
		message => q|Add Users|,
		lastUpdated => 1053800614
	},

	'8' => {
		message => q|View page not found.|,
		lastUpdated => 1031514049
	},

	'367' => {
		message => q|Expire Offset|,
		lastUpdated => 1044126611
	},

	'43' => {
		message => q|Are you certain that you wish to delete this content?|,
		lastUpdated => 1031514049
	},

	'485' => {
		message => q|Boolean (Checkbox)|,
		lastUpdated => 1031514049
	},

	'486' => {
		message => q|List|,
		lastUpdated => 1133087205
	},

	'487' => {
		message => q|Select Box|,
		lastUpdated => 1133087205
	},

	'391' => {
		message => q|Delete attached file.|,
		lastUpdated => 1031514049
	},

	'392' => {
		message => q|Delete this file?|,
		lastUpdated => 1131831533,
	},

	'743' => {
		message => q|You must specify a valid email address in order to attempt to recover your password.|,
		lastUpdated => 1035246389
	},

	'523' => {
		message => q|Notification|,
		lastUpdated => 1031514049
	},

	'943' => {
		message => q|Checkbox|,
		lastUpdated => 1051464272
	},

	'460' => {
		message => q|Time Offset|,
		lastUpdated => 1031514049
	},

	'119' => {
		message => q|Authentication Method (default)|,
		lastUpdated => 1031514049
	},

	'453' => {
		message => q|Date Created|,
		lastUpdated => 1031514049
	},

	'324' => {
		message => q|Home City|,
		lastUpdated => 1031514049
	},

	'244' => {
		message => q|Author|,
		lastUpdated => 1031514049
	},

	'351' => {
		message => q|Message|,
		lastUpdated => 1031514049
	},

	'61' => {
		message => q|Update Account Information|,
		lastUpdated => 1031514049
	},

	'430' => {
		message => q|Last Page View|,
		lastUpdated => 1031514049
	},

	'379' => {
		message => q|Group ID|,
		lastUpdated => 1031514049
	},

	'1035' => {
		message => q|Notification Template|,
		lastUpdated => 1066034661
	},

	'452' => {
		message => q|Please wait...|,
		lastUpdated => 1031514049
	},

	'342' => {
		message => q|Edit account information.|,
		lastUpdated => 1031514049
	},

	'862' => {
		message => q|This user's profile is not public.|,
		lastUpdated => 1043881275
	},

	'480' => {
		message => q|Email Address|,
		lastUpdated => 1031514049
	},

	'341' => {
		message => q|Edit profile.|,
		lastUpdated => 1031514049
	},

	'438' => {
		message => q|Your Name|,
		lastUpdated => 1031514049
	},

	'107' => {
		message => q|Security|,
		lastUpdated => 1031514049
	},

	'87' => {
		message => q|Edit Group|,
		lastUpdated => 1031514049
	},

    'demographic info short' => {
		message => q|Demographic|,
        lastUpdated => 1031514049
	},

	'77' => {
		message => q|That account name is already in use by another member of this site. Please try a different username. The following are some suggestions:<br />
%sToo<br />
%s2<br />
%s_%d<br />|,
		lastUpdated => 1217216725
	},

	'444' => {
		message => q|Demographic Information|,
		lastUpdated => 1031514049
	},

	'39' => {
		message => q|You do not have sufficient privileges to access this page.|,
		lastUpdated => 1031514049
	},

	'64' => {
		message => q|Log out.|,
		lastUpdated => 1031514049
	},

	'558' => {
		message => q|Edit User's Karma|,
		lastUpdated => 1031514049
	},

        '556 description' => {
                message => q|How much karma should be added or subtracted from the user's karma?|,
                lastUpdated => 1120768600,
        },

        '557 description' => {
                message => q|The reason why the user's karma has been changed.|,
                lastUpdated => 1120768600,
        },

	'12' => {
		message => q|Turn admin off.|,
		lastUpdated => 1031514049
	},

	'881' => {
		message => q|None|,
		lastUpdated => 1044705162
	},

	'312' => {
		message => q|Allow business information?|,
		lastUpdated => 1031514049
	},

	'45' => {
		message => q|No, I made a mistake.|,
		lastUpdated => 1031514049
	},

	'507' => {
		message => q|Edit Template|,
		lastUpdated => 1031514049
	},

	'405' => {
		message => q|Last Page|,
		lastUpdated => 1031514049
	},

	'1084' => {
		message => q|Use the default toolbar for my language|,
		lastUpdated => 1161300438,
	},

	'370' => {
		message => q|Edit Grouping|,
		lastUpdated => 1031514049
	},

        '50 description' => {
                message => q|The name of the user.|,
                lastUpdated => 1122088999,
        },

        '50 setup description' => {
                message => q|The username for your admin account.  Defaults to Admin|,
                lastUpdated => 1122610919,
        },

        '84 description groupings' => {
                message => q|The name of the group.|,
                lastUpdated => 1122088999,
        },

        '369 description' => {
                message => q|When the user's membership in the group expires.|,
                lastUpdated => 1122088999,
        },

        '977 description' => {
                message => q|Set this to yes to make this user a group admin.  Group admins have the ability
to add or remove users from their groups.
		|,
                lastUpdated => 1132359856,
        },


	'309' => {
		message => q|Allow real name?|,
		lastUpdated => 1031514049
	},

	'734' => {
		message => q|5 Adept|,
		lastUpdated => 1033836678
	},

	'1' => {
		message => q|Add content...|,
		lastUpdated => 1031514049
	},

	'144' => {
		message => q|View statistics.|,
		lastUpdated => 1031514049
	},

	'965' => {
		message => q|Everyone's Trash|,
		lastUpdated => 1207859652
	},

	'824' => {
		message => q|Email Footer|,
		lastUpdated => 1038708558
	},

	'661' => {
		message => q|File Settings, Edit|,
		lastUpdated => 1031514049
	},

	'1075' => {
		message => q|Database Link|,
		lastUpdated => 1056151382
	},

	'1075 description' => {
		message => q|Select one of these databases to run your query against.|,
		lastUpdated => 1119840669,
	},

	'381' => {
		message => q|WebGUI received a malformed request and was unable to continue. Proprietary characters being passed through a form typically cause this. Please feel free to hit your back button and try again.|,
		lastUpdated => 1031514049
	},

	'581' => {
		message => q|Add New Value|,
		lastUpdated => 1031514049
	},

	'496' => {
		message => q|Editor To Use|,
		lastUpdated => 1031514049
	},

	'605' => {
		message => q|Add Groups|,
		lastUpdated => 1031514049
	},

	'813' => {
		message => q|Groups In This Group|,
		lastUpdated => 1037583186
	},

	'42' => {
		message => q|Please Confirm|,
		lastUpdated => 1031514049
	},

	'1073' => {
		message => q|Style Template|,
		lastUpdated => 1070027660
	},

	'436' => {
		message => q|Kill Session|,
		lastUpdated => 1031514049
	},

	'816' => {
		message => q|Status|,
		lastUpdated => 1038431169
	},

	'51' => {
		message => q|Password|,
		lastUpdated => 1031514049
	},

	'51 description' => {
		message => q|The password for the admin account.  Do not forget to change this from the default!|,
		lastUpdated => 1122611044
	},

	'password clear text' => {
		message => q|Displayed in clear text so you can ensure you have typed it correctly.|,
		lastUpdated => 1127405564
	},

	'456' => {
		message => q|Back to user list.|,
		lastUpdated => 1031514049
	},

	'975' => {
		message => q|Users can remove themselves?|,
		lastUpdated => 1053778962
	},

	'493' => {
		message => q|Back to site.|,
		lastUpdated => 1031514049
	},

	'445' => {
		message => q|Preferences|,
		lastUpdated => 1031514049
	},

    'preferences short' => {
 		message => q|Preferences|,
 		lastUpdated => 1031514049
 	},

	'1026' => {
		message => q|Allow rich edit?|,
		lastUpdated => 1065966219
	},

	'329' => {
		message => q|Work Address|,
		lastUpdated => 1031514049
	},

	'161' => {
		message => q|Submitted By|,
		lastUpdated => 1031514049
	},

	'582' => {
		message => q|Leave Blank|,
		lastUpdated => 1031514049
	},

	'746' => {
		message => q|Toolbar Icon Set|,
		lastUpdated => 1036046598
	},

	'400' => {
		message => q|Prevent Proxy Caching|,
		lastUpdated => 1031514049
	},

	'744' => {
		message => q|What next?|,
		lastUpdated => 1035864828
	},

	'1011' => {
		message => q|Code|,
		lastUpdated => 1060433339
	},

	'557' => {
		message => q|Description|,
		lastUpdated => 1031514049
	},

	'700' => {
		message => q|Day(s)|,
		lastUpdated => 1031514049
	},

	'475' => {
		message => q|Text|,
		lastUpdated => 1031514049
	},

	'441' => {
		message => q|Email To Pager Gateway|,
		lastUpdated => 1031514049
	},

	'868' => {
		message => q|Send welcome message?|,
		lastUpdated => 1044138691
	},

	'868 help' => {
		message => q|Should the user be sent an email when their account is created?|,
		lastUpdated => 1227209376
	},

	'990' => {
		message => q|Edit Database Link|,
		lastUpdated => 1056151382
	},

	'349' => {
		message => q|Latest version available|,
		lastUpdated => 1031514049
	},

	'983' => {
		message => q|Edit this database link.|,
		lastUpdated => 1056151382
	},

	'138' => {
		message => q|Yes|,
		lastUpdated => 1031514049
	},

	'751' => {
		message => q|Become this user.|,
		lastUpdated => 1036864905
	},

	'view profile' => {
		message => q|View user's profile.|,
		context => q|Label for a URL to view the profile for the user. Used in Operation/User.pm|,
		lastUpdated => 1239926712
	},

	'60' => {
		message => q|Are you certain you want to deactivate your account. If you proceed your account information will be lost permanently.|,
		lastUpdated => 1031514049
	},

	'724' => {
		message => q|Your username cannot begin or end with spaces or tabs.|,
		lastUpdated => 1129431859
	},

    'username no html' => {
        message => q|Your username cannot contain HTML or WebGUI Macros.|,
        lastUpdated => 1203059016,
    },

	'432' => {
		message => q|Expires|,
		lastUpdated => 1031514049
	},

	'body.content' => {
		message => q|The the content on the current page.|,
		lastUpdated => 1149182155,
	},

	'head.tags' => {
		message => q|Tags that WebGUI automatically generates for you so that caching works the way it should, search engines can find you better, and other useful automated functionality. This should go in the &lt;head&gt; &lt;/head&gt; section of your style.
<br />
<br />NOTE: This is for backwards-compatibility only. You should use 'head_attachments' and 'body_attachments' now.
<br />
<br />We suggest using something like this in the &lt;title&gt; &lt;/title&gt; portion of your style:
<br />
<br />&#94;PageTitle(); - &#94;c();
<br />
<br />That particular example will help you get good ranking on search engines.|,
		lastUpdated => 1225222473,
	},

    'head_attachments' => {
        message     => q{Tags that belong only in the &lt;head&gt; of the document. If you use this, you must use body_attachments and must not use head.tags.},
        lastUpdated => 0,
        context     => 'description of template variable',
    },

    'body_attachments' => {
        message     => q{Tags that can be placed right before the end of the &lt;body&gt; to speed up page load times. If you use this, you must use head_attachments and must not use head.tags.},
        lastUpdated => 0,
        context     => 'description of template variable',
    },


	'860' => {
		message => q|Make email address public?|,
		lastUpdated => 1043879942
	},

	'346' => {
		message => q|This user is no longer a member of our site. We have no further information about this user.|,
		lastUpdated => 1031514049
	},

	'333' => {
		message => q|Work Country|,
		lastUpdated => 1031514049
	},

	'323' => {
		message => q|Home Address|,
		lastUpdated => 1031514049
	},

	'856' => {
		message => q|You have no account properties to edit at this time.|,
		lastUpdated => 1040340432
	},

	'69' => {
		message => q|Please contact your system administrator for assistance.|,
		lastUpdated => 1031514049
	},

	'756' => {
		message => q|Back to group list.|,
		lastUpdated => 1036867726
	},

	'446' => {
		message => q|Work Web Site|,
		lastUpdated => 1031514049
	},

	'352' => {
		message => q|Date|,
		lastUpdated => 1142991266
	},

	'1006' => {
		message => q|Encrypt Login?|,
		lastUpdated => 1057208065
	},

	'126' => {
		message => q|Company Email Address|,
		lastUpdated => 1031514049
	},

	'426' => {
		message => q|Login History|,
		lastUpdated => 1031514049,
                context => q|Title of the login history viewer for the admin console.|
	},

	'369' => {
		message => q|Expire Date|,
		lastUpdated => 1031514049
	},

	'483' => {
		message => q|Yes or No|,
		lastUpdated => 1031514049
	},

	'810' => {
		message => q|send|,
		lastUpdated => 1037579743
	},

	'372' => {
		message => q|Edit User's Groups|,
		lastUpdated => 1031514049
	},

	'574' => {
		message => q|Deny|,
		lastUpdated => 1031514049
	},

	'170' => {
		message => q|search|,
		lastUpdated => 1031514049
	},

	'428' => {
		message => q|User (ID)|,
		lastUpdated => 1031514049
	},

	'977' => {
		message => q|Is group admin?|,
		lastUpdated => 1053803387
	},

	'99' => {
		message => q|Title|,
		lastUpdated => 1031514049
	},

	'526' => {
		message => q|Remove JavaScript and negate macros.|,
		lastUpdated => 1047838780
	},

	'removeLabel' => {
		message => q|remove|,
		lastUpdated => 1116450882
	},

	'72' => {
		message => q|recover|,
		lastUpdated => 1031514049
	},

	'566' => {
		message => q|Edit Timeout|,
		lastUpdated => 1031514049
	},

	'806' => {
		message => q|Delete this group.|,
		lastUpdated => 1037579396
	},

	'869' => {
		message => q|Welcome Message|,
		lastUpdated => 1044138730,
	},

	'869 help' => {
		message => q|This message will be part of the email sent to a user when they create an account on this WebGUI site.|,
		lastUpdated => 1227209607,
	},

	'533' => {
		message => q|<b>without</b> the words|,
		lastUpdated => 1031514049
	},

	'359' => {
		message => q|Right Column|,
		lastUpdated => 1031514049
	},

	'108' => {
		message => q|Owner|,
		lastUpdated => 1031514049
	},

        '992 description' => {
                message => q|A title for the database link.|,
                lastUpdated => 1122070396,
        },

        '993 description' => {
                message => q|<p><b>D</b>ata <b>S</b>ource <b>N</b>ame is the unique identifier that Perl uses to describe the location of your database. It takes the format of</p>
<div class="helpIndent">DBI:[driver]:[database name]:[host].</div>
<p><i>Example:</i> DBI:mysql:WebGUI:localhost</p>
<p>
Here are some examples for other databases.</p>
<div>
<dl>
<dt><a href="http://search.cpan.org/perldoc?DBD::Oracle#CONNECTING_TO_ORACLE">Oracle</a>:</dt>
<dd>DBI:Oracle:SID<br />
DBD::Oracle must be installed.<br />
You must be using mod_perl and configure <b>PerlSetEnv ORACLE_HOME /home/oracle/product/8.1.7</b> in httpd.conf. Without setting ORACLE_HOME, you can connect using DBI:Oracle:host=myhost.com;sid=SID
</dd>
<dt><a href="http://search.cpan.org/perldoc?DBD::PgPP#THE_DBI_CLASS">PostgreSQL</a>:</dt>
<dd>DBI:PgPP:dbname=DBNAME[;host=hOST]<br />
DBD::PgPP must be installed.
</dd>
<dt><a href="http://search.cpan.org/perldoc?DBD::Sybase#Specifying_other_connection_specific_parameters">Sybase</a>:</dt>
<dd>DBI:Sybase:[server=SERVERNAME][database=DATABASE]<br />
DBD::Sybase must be installed.<br />
You must be using mod_perl and configure <b>PerlSetEnv SYBASE /opt/sybase/11.0.2</b> in httpd.conf.
</dd>
</dl></div>|,
                lastUpdated => 1221362751,
        },

        '994 description' => {
                message => q|The username you use to connect to the DSN.|,
                lastUpdated => 1122070396,
        },

        '995 description' => {
                message => q|The password you use to connect to the DSN.|,
                lastUpdated => 1122070396,
        },

	'556' => {
		message => q|Amount|,
		lastUpdated => 1031514049
	},

	'462' => {
		message => q|Time Format|,
		lastUpdated => 1031514049
	},

	'232' => {
		message => q|no subject|,
		lastUpdated => 1031514049
	},

	'477' => {
		message => q|HTML Area|,
		lastUpdated => 1031514049
	},

	'815' => {
		message => q|The file you tried to upload is too large.|,
		lastUpdated => 1038023800
	},

	'142' => {
		message => q|Session Timeout|,
		lastUpdated => 1031514049
	},

	'330' => {
		message => q|Work City|,
		lastUpdated => 1031514049
	},

	'991' => {
		message => q|Database Link ID|,
		lastUpdated => 1056151382
	},

	'991 description' => {
		message => q|A unique identifier for this database link used internally by WebGUI.|,
		lastUpdated => 1133810998
	},

	'167' => {
		message => q|Are you certain you want to delete this user? Be warned that all this user's information will be lost permanently if you choose to proceed.|,
		lastUpdated => 1031514049
	},

	'360' => {
		message => q|One Over Three|,
		lastUpdated => 1031514049
	},

	'514' => {
		message => q|Views|,
		lastUpdated => 1031514049
	},

	'725' => {
		message => q|Your username cannot be blank.|,
		lastUpdated => 1031879612
	},

	'50' => {
		message => q|Username|,
		lastUpdated => 1031514049
	},

	'476' => {
		message => q|Text Area|,
		lastUpdated => 1031514049
	},

	'1076' => {
		message => q|WebGUI Database|,
		lastUpdated => 1070899134
	},

	'510' => {
		message => q|Flat|,
		lastUpdated => 1031514049
	},

	'1077' => {
		message => q|The function you are attempting to call is not available for this authentication module|,
		lastUpdated => 1067951805
	},

	'449' => {
		message => q|Miscellaneous Information|,
		lastUpdated => 1031514049
	},

    'misc info short' => {
		message => q|Miscellaneous|,
		lastUpdated => 1031514049
	},

	'967' => {
		message => q|Empty everyone's trash.|,
		lastUpdated => 1208022779
	},

	'322' => {
		message => q|Pager|,
		lastUpdated => 1031514049
	},

	'353' => {
		message => q|You have no messages in your Inbox at this time.|,
		lastUpdated => 1031514049
	},

	'575' => {
		message => q|Edit|,
		lastUpdated => 1031514049
	},

	'984' => {
		message => q|Copy this database link.|,
		lastUpdated => 1056151382
	},

	'1039' => {
		message => q|Back|,
		lastUpdated => 1066073289
	},

	'1005' => {
		message => q|SQL Query|,
		lastUpdated => 1057208065
	},

	'40' => {
		message => q|Vital Component|,
		lastUpdated => 1031514049
	},

	'310' => {
		message => q|Allow extra contact information?|,
		lastUpdated => 1031514049
	},

	'699' => {
		message => q|First Day Of Week|,
		lastUpdated => 1031514049
	},

	'818' => {
		message => q|Deactivated|,
		lastUpdated => 1038431300
	},

	'130' => {
		message => q|Maximum Attachment Size|,
		lastUpdated => 1031514049
	},

	'543' => {
		message => q|Add a new image group.|,
		lastUpdated => 1031514049
	},

	'941' => {
		message => q|Checkbox List|,
		lastUpdated => 1051464113
	},

	'354' => {
		message => q|View Inbox.|,
		lastUpdated => 1031514049
	},

	'461' => {
		message => q|Date Format|,
		lastUpdated => 1031514049
	},

	'583' => {
		message => q|Max Image Size|,
		lastUpdated => 1031514049
	},

	'951' => {
		message => q|Are you certain that you wish to empty the clipboard to the trash?|,
		lastUpdated => 1052850265
	},

	'85' => {
		message => q|Description|,
		lastUpdated => 1031514049
	},

	'809' => {
		message => q|Email Group|,
		lastUpdated => 1037579611
	},

        '811 description' => {
                message => q|Who the email is from.|,
                lastUpdated => 1122093200,
        },

        '229 description' => {
                message => q|The subject of the email.|,
                lastUpdated => 1122093200,
        },

        '230 description' => {
                message => q|The message that will be sent to all members of the group.  The message will be
sent in HTML format. No attachments can be included.|,
                lastUpdated => 1122093200,
        },

	'332' => {
		message => q|Work Zip Code|,
		lastUpdated => 1031514049
	},

	'9' => {
		message => q|View clipboard.|,
		lastUpdated => 1031514049
	},

	'425' => {
		message => q|Active Sessions|,
		lastUpdated => 1031514049,
                context => q|Title of the active sessions manager for the admin console.|
	},

	'745' => {
		message => q|Go back to the page.|,
		lastUpdated => 1035872437
	},

	'736' => {
		message => q|7 Expert|,
		lastUpdated => 1033836692
	},

	'539' => {
		message => q|Enable Karma?|,
		lastUpdated => 1031514049
	},

	'90' => {
		message => q|Add new group.|,
		lastUpdated => 1031514049
	},

	'565' => {
		message => q|Who can moderate?|,
		lastUpdated => 1031514049
	},

	'1004' => {
		message => q|Cache groups for how long?|,
		lastUpdated => 1057208065
	},

	'891' => {
		message => q|Only negate macros.|,
		lastUpdated => 1047838859
	},

	'1045' => {
		message => q|Nested|,
		lastUpdated => 1066405110
	},

	'532' => {
		message => q|with <b>at least one</b> of the words|,
		lastUpdated => 1031514049
	},

	'730' => {
		message => q|1 Novice|,
		lastUpdated => 1033836642
	},

	'1069' => {
		message => q|Host To Use|,
		lastUpdated => 1066641432
	},

	'57' => {
		message => q|This is only necessary if you wish to use features that require Email.|,
		lastUpdated => 1031514049
	},

	'368' => {
		message => q|Add a new group to this user.|,
		lastUpdated => 1031514049
	},

	'872' => {
		message => q|Who can view?|,
		lastUpdated => 1044218038
	},

	'316' => {
		message => q|Last Name|,
		lastUpdated => 1031514049
	},

	'163' => {
		message => q|Add User|,
		lastUpdated => 1031514049
	},

	'994' => {
		message => q|Database User|,
		lastUpdated => 1056151382
	},

	'395' => {
		message => q|Add a new image.|,
		lastUpdated => 1031514049
	},

	'89' => {
		message => q|Groups|,
		lastUpdated => 1031514049,
                context => q|Title of the group manager for the admin console.|
	},

	'175' => {
		message => q|Process macros?|,
		lastUpdated => 1031514049
	},

	'988' => {
		message => q|Are you certain you wish to delete this database link?|,
		lastUpdated => 1116151382
	},

	'35' => {
		message => q|Administrative Function|,
		lastUpdated => 1031514049
	},

	'347' => {
		message => q|View Profile For|,
		lastUpdated => 1031514049
	},

	'434' => {
		message => q|Status|,
		lastUpdated => 1031514049
	},

	'93' => {
		message => q|Help|,
		lastUpdated => 1031514049
	},

	'865' => {
		message => q|Notify user about expiration?|,
		lastUpdated => 1044126938
	},

	'442' => {
		message => q|Work Information|,
		lastUpdated => 1031514049
	},

    'work info short' => {
		message => q|Work|,
 		lastUpdated => 1031514049
 	},

	'429' => {
		message => q|Login Time|,
		lastUpdated => 1031514049
	},

	'886' => {
		message => q|Hide from navigation?|,
		lastUpdated => 1044727952
	},

	'73' => {
		message => q|Log in.|,
		lastUpdated => 1031514049
	},

	'67' => {
		message => q|Create a new account.|,
		lastUpdated => 1031514049
	},

	'812' => {
		message => q|Your message has been sent.|,
		lastUpdated => 1037580328
	},

	'794' => {
		message => q|Packages|,
		lastUpdated => 1036971944
	},


	'327' => {
		message => q|Home Country|,
		lastUpdated => 1031514049
	},

	'320' => {
		message => q|<a href="http://messenger.yahoo.com/">Yahoo! Messenger</a> Id|,
		lastUpdated => 1031514049
	},

	'944' => {
		message => q|Zip Code|,
		lastUpdated => 1051962797
	},

	'732' => {
		message => q|3 Rookie|,
		lastUpdated => 1033836660
	},

	'811' => {
		message => q|From|,
		lastUpdated => 1037580145
	},

        '84 description' => {
                message => q|<p>A name for the group. It is best if the name is descriptive so you know what it is at a glance.
</p>|,
                lastUpdated => 1120448672,
        },

        '85 description' => {
                message => q|<p>A longer description of the group so that other admins and content managers (or you if you forget) will know what the purpose of this group is.
</p>|,
                lastUpdated => 1120448672,
        },

        '367 description' => {
                message => q|<p>The amount of time that a user will belong to this group before s/he is expired (or removed) from it. This is very useful for membership sites where users have certain privileges for a specific period of time. 
</p>
<p><b>NOTE:</b> This can be overridden on a per-user basis.
</p>|,
                lastUpdated => 1120448672,
        },

        '865 description' => {
                message => q|<p>Set this value to yes if you want WebGUI to contact the user when they are about to be expired from the group.
</p>|,
                lastUpdated => 1120448672,
        },

        '864 description' => {
                message => q|<p>The difference in the number of days from the expiration to the notification. You may set this to any valid integer. For instance, set this to "0" if you wish the notification to be sent on the same day that the grouping expires. Set it to "-7" if you want the notification to go out 7 days <b>before</b> the grouping expires. Set it to "7" if you wish the notification to be sent 7 days after the expiration.
</p>|,
                lastUpdated => 1120448672,
        },

        '866 description' => {
                message => q|<p>Type the message you wish to be sent to the user telling them about the expiration.
</p>|,
                lastUpdated => 1120448672,
        },

        '863 description' => {
                message => q|<p>The difference in the number of days from the expiration to the grouping being deleted from the system. You may set this to any valid integer. For instance, set this to "0" if you wish the grouping to be deleted on the same day that the grouping expires. Set it to "-7" if you want the grouping to be deleted 7 days <b>before</b> the grouping expires. Set it to "7" if you wish the grouping to be deleted 7 days after the expiration.
</p>|,
                lastUpdated => 1120448672,
        },

        '538 description' => {
                message => q|<p>If you've enabled Karma, then you'll be able to set this value. Karma Threshold is the amount of karma a user must have to be considered part of this group.
</p>|,
                lastUpdated => 1120448672,
        },

        '857 description' => {
                message => q|<p>Specify IP addresses in CIDR format.  Multiple addresses can be entered if they are separated by commas.  Spaces, tabs and carriage returns and newlines will be ignored.
</p>
<p>
<i>IP Mask Example:</i> 10.0.0.32/27, 192.168.0.1/30
</p>|,
                lastUpdated => 1139955354,
        },

        '945 description' => {
                message => q|<p>A user can be dynamically bound to a group by a scratch variable in their session. Scratch variables can be set programatically, or via the web. To set a scratch variable via the web, tack the following on to the end of any URL:
</p>
<p><i>?op=setScratch&amp;scratchName=somename&amp;scratchValue=somevalue</i>
</p>
<p>Having done that, when a user clicks on that link they will have a scratch variable added to their session with a name of "www_somename" and a value of "somevalue". The "www_" is prefixed to prevent web requests from overwriting scratch variables that were set programatically.
</p>
<p>To set a scratch filter simply add a line to the scratch filter field that looks like:
</p>
<p><i>www_somename=somevalue</i>
</p>
<p>Multiple filters can be set by joining name and value pairs with a semicolon:
</p>
<p><i>www_somename=somevalue;otherName=otherValue</i>
</p>

|,
                lastUpdated => 1144345050,
        },

        '974 description' => {
                message => q|<p>Do you wish to let users add themselves to this group? See the GroupAdd macro for more info.
</p>|,
                lastUpdated => 1120448672,
        },

        '975 description' => {
                message => q|<p>Do you wish to let users remove themselves from this group? See the GroupDelete macro for more info.
</p>|,
                lastUpdated => 1120448672,
        },

        '1075 description' => {
                message => q|<p>If you'd like to have this group validate users using an external database, choose the database link to use.
</p>|,
                lastUpdated => 1120448672,
        },

        '1005 description' => {
                message => q|<p>Many organizations have external databases that map users to groups; for example an HR database might map Employee ID to Health Care Plan.  To validate users against an external database, you need to construct an SQL statement that will return the list of WebGUI userIds for users in the group.  You may use macros in this query to access data in a user's WebGUI profile, such as Employee ID.  Here is an example that checks a user against a fictional HR database.  This assumes you have created an additional WebGUI profile field called employeeId.</p>
<p>
select userId from employees, health_plans, empl_plan_map<br />
where employees.employee_id = &#94;User("employeeId");<br />
and health_plans.plan_name = 'HMO 1'<br />
and employees.employee_id = empl_plan_map.employee_id<br />
and health_plans.health_plan_id = empl_plan_mp.health_plan_id<br />
</p>
<p>
This group could then be named "Employees in HMO 1", and would allow you to restrict any page or wobject to only those users who are part of this health plan in the external database.
</p>|,
                lastUpdated => 1165517843,
        },

        '1004 description' => {
                message => q|<p>Large sites using external group data will be making many calls to the external database.  To help reduce the load, you may select how long you'd like to cache the results of the external database query within the WebGUI database.  More advanced background caching may be included in a future version of WebGUI.</p>|,
                lastUpdated => 1120448672,
        },


	'361' => {
		message => q|Three Over One|,
		lastUpdated => 1031514049
	},

	'465' => {
		message => q|Text Box Size|,
		lastUpdated => 1031514049
	},

	'contains' => {
		message => q|Contains|,
		lastUpdated => 1089039511
	},

	'819' => {
		message => q|Self-Deactivated|,
		lastUpdated => 1038431323
	},

	'970' => {
		message => q|set time|,
		lastUpdated => 1053278089
	},

	'858' => {
		message => q|Alias|,
		lastUpdated => 1043879848
	},

	'104' => {
		message => q|URL|,
		lastUpdated => 1031514049,
		context => q|asset property|
	},

	'104 description' => {
		message => q|Enter a URL for your link|,
		lastUpdated => 1121298520,
	},

	'target' => {
		message => q|Target|,
		lastUpdated => 1118936724,
		context => q|form helper, rich edit page tree|
	},

	'target description' => {
		message => q|Choose whether the link, when clicked, will open in the same window or open in another one|,
		lastUpdated => 1121298550,
	},

	'done' => {
		message => q|Done|,
		lastUpdated => 1118936724,
		context => q|form helper, rich edit page tree|
	},

	'link in same window' => {
		message => q|Open link in same window.|,
		lastUpdated => 1118936724,
		context => q|form helper, rich edit page tree|
	},

	'link in new window' => {
		message => q|Open link in new window.|,
		lastUpdated => 1118936724,
		context => q|form helper, rich edit page tree|
	},

	'link enter alert' => {
		message => q|You must enter a link URL.|,
		lastUpdated => 1118936724,
		context => q|form helper, rich edit page tree|
	},

	'412' => {
		message => q|Summary|,
		lastUpdated => 1031514049
	},

	'954' => {
		message => q|Manage system clipboard.|,
		lastUpdated => 1052850265
	},

	'314' => {
		message => q|First Name|,
		lastUpdated => 1031514049
	},

	'985' => {
		message => q|Delete this database link.|,
		lastUpdated => 1056151382
	},

	'971' => {
		message => q|Time|,
		lastUpdated => 1053278208
	},

	'754' => {
		message => q|Manage the users in this group.|,
		lastUpdated => 1036866994
	},

	'355' => {
		message => q|Default|,
		lastUpdated => 1031514049
	},

	'847' => {
		message => q|Go back to the current page.|,
		lastUpdated => 1039587250
	},

	'159' => {
		message => q|Inbox|,
		lastUpdated => 1031514049
	},

	'553' => {
		message => q|Status|,
		lastUpdated => 1031514049
	},

	'704' => {
		message => q|Second(s)|,
		lastUpdated => 1031514049
	},

	'326' => {
		message => q|Home Zip Code|,
		lastUpdated => 1031514049
	},

	'555' => {
		message => q|Edit this user's karma.|,
		lastUpdated => 1031514049
	},

	'1017' => {
		message => q|Last Reply|,
		lastUpdated => 1031514049
	},

	'37' => {
		message => q|Permission Denied!|,
		lastUpdated => 1031514049
	},

	'335' => {
		message => q|Gender|,
		lastUpdated => 1031514049
	},

	'1029' => {
		message => q|Edited at|,
		lastUpdated => 1047842180
	},

	'538' => {
		message => q|Karma Threshold|,
		lastUpdated => 1031514049
	},

	'554' => {
		message => q|Take Action|,
		lastUpdated => 1031514049
	},

	'starts with' => {
		message => q|Starts With|,
		lastUpdated => 1089039511
	},

	'552' => {
		message => q|Pending|,
		lastUpdated => 1031514049
	},

	'880' => {
		message => q|Last Resort Editor|,
		lastUpdated => 1044705137
	},

	'433' => {
		message => q|User Agent|,
		lastUpdated => 1031514049
	},

	'74' => {
		message => q|Account Information|,
		lastUpdated => 1031514049
	},

	'240' => {
		message => q|Message ID:|,
		lastUpdated => 1031514049
	},

	'334' => {
		message => q|Work Phone|,
		lastUpdated => 1031514049
	},

	'986' => {
		message => q|Back to database links.|,
		lastUpdated => 1056151382
	},

	'440' => {
		message => q|Contact Information|,
		lastUpdated => 1031514049
	},

    'contact info short' => {
		message => q|Contact Info|,
		lastUpdated => 1031514049
	},

	'230' => {
		message => q|Message|,
		lastUpdated => 1031514049
	},

	'1008' => {
		message => q|Mixed Text and HTML|,
		lastUpdated => 1060433234
	},

	'1027' => {
		message => q|Use content filters?|,
		lastUpdated => 1099434667
	},

	'871' => {
		message => q|Who can edit?|,
		lastUpdated => 1044218026
	},

	'1044' => {
		message => q|Search Template|,
		lastUpdated => 1066394621
	},

	'1072' => {
		message => q|The email address is already in use. Please use a different email address.|,
		lastUpdated => 1068703399
	},

	'827' => {
		message => q|Wobject Template|,
		lastUpdated => 1052046436
	},

	'91' => {
		message => q|Previous Page|,
		lastUpdated => 1031514049
	},

	'pagination.firstPage' => {
		message => q|A link to the first page in the paginator.|,
		lastUpdated => 1149182026,
	},

	'pagination.firstPageUrl' => {
		message => q|The url component of pagination.firstPage broken out.|,
		lastUpdated => 1149182026,
	},

	'pagination.firstPageText' => {
		message => q|The text component of pagination.firstPage broken out.|,
		lastUpdated => 1149182026,
	},

	'pagination.isFirstPage' => {
		message => q|A boolean indicating whether the current page is the first page.|,
		lastUpdated => 1149182026,
	},

	'pagination.lastPage' => {
		message => q|A link to the last page in the paginator.|,
		lastUpdated => 1149182026,
	},

	'pagination.lastPageUrl' => {
		message => q|The url component of pagination.lastPage broken out.|,
		lastUpdated => 1149182026,
	},

	'pagination.lastPageText' => {
		message => q|The text component of pagination.lastPage broken out.|,
		lastUpdated => 1149182026,
	},

	'pagination.isLastPage' => {
		message => q|A boolean indicating whether the current page is the last page.|,
		lastUpdated => 1149182026,
	},

	'pagination.nextPage' => {
		message => q|A link to the next page in the paginator relative to the current page.|,
		lastUpdated => 1149182026,
	},

	'pagination.nextPageUrl' => {
		message => q|The url component of pagination.nextPage broken out.|,
		lastUpdated => 1149182026,
	},

	'pagination.nextPageText' => {
		message => q|The text component of pagination.nextPage broken out.|,
		lastUpdated => 1149182026,
	},

	'pagination.previousPage' => {
		message => q|A link to the previous page in the paginator relative to the current page.|,
		lastUpdated => 1149182026,
	},

	'pagination.previousPageUrl' => {
		message => q|The url component of pagination.previousPage broken out.|,
		lastUpdated => 1149182026,
	},

	'pagination.previousPageText' => {
		message => q|The text component of pagination.previousPage broken out.|,
		lastUpdated => 1149182026,
	},

	'pagination.pageNumber' => {
		message => q|The current page number.|,
		lastUpdated => 1149182026,
	},

	'pagination.pageCount' => {
		message => q|The total number of pages.|,
		lastUpdated => 1149182026,
	},

	'pagination.pageCount.isMultiple' => {
		message => q|A boolean indicating whether there is more than one page.|,
		lastUpdated => 1149182026,
	},

	'pagination.pageList' => {
		message => q|A list of links to every page in the paginator.|,
		lastUpdated => 1149182026,
	},

	'pagination.pageLoop' => {
		message => q|Same as pagination.pageList except broken into individual elements.|,
		lastUpdated => 1149182026,
	},

	'pagination.url' => {
		message => q|The URL of a page in the page loop.|,
		lastUpdated => 1168370951,
	},

	'pagination.text' => {
		message => q|The number of a page in the page loop.|,
		lastUpdated => 1168464885,
	},

	'pagination.range' => {
		message => q|Displays the range of available pages, in a start - end format.|,
		lastUpdated => 1220541683,
	},

	'pagination.activePage' => {
		message => q|A boolean which will be true if the this page in the pageLoop is the currently viewed page.|,
		lastUpdated => 1227493265,
	},

	'pagination.pageList.upTo20' => {
		message => q|A list of links to the 20 nearest in the paginator relative to the current page. So if you're on page 60, you'll see links for 50-70.|,
		lastUpdated => 1149182026,
	},

	'pagination.pageLoop.upTo20' => {
		message => q|Same as pagination.pageList.upTo20 except broken into individual elements.|,
		lastUpdated => 1149182026,
	},

	'pagination.pageList.upTo10' => {
		message => q|A list of links to the 10 nearest in the paginator relative to the current page. So if you're on page 20, you'll see links for 15-25.|,
		lastUpdated => 1149182026,
	},

	'pagination.pageLoop.upTo10' => {
		message => q|Same as pagination.pageList.upTo10 except broken into individual elements.|,
		lastUpdated => 1149182026,
	},

	'701' => {
		message => q|Week(s)|,
		lastUpdated => 1031514049
	},

	'820' => {
		message => q|Your account is not activated. Therefore you cannot log in until it's activated, which only can be done by the admin.|,
		lastUpdated => 1038431645
	},

	'174' => {
		message => q|Display the title?|,
		lastUpdated => 1031514049
	},

	'481' => {
		message => q|Telephone Number|,
		lastUpdated => 1031514049
	},

	'867' => {
		message => q|Loss of Privilege|,
		lastUpdated => 1044133143
	},

	'422' => {
		message => q|<h1>Login Failed</h1><p>The information supplied does not match the account.</p>|,
		lastUpdated => 1031514049
	},

	'817' => {
		message => q|Active|,
		lastUpdated => 1038431287
	},

	'563' => {
		message => q|Default Status|,
		lastUpdated => 1031514049
	},

	'731' => {
		message => q|2 Trained|,
		lastUpdated => 1033836651
	},

	'41' => {
		message => q|You're attempting to remove a vital component of the WebGUI system. If you were allowed to continue WebGUI may cease to function.|,
		lastUpdated => 1031514049
	},

	'52' => {
		message => q|login|,
		lastUpdated => 1031514049
	},

	'750' => {
		message => q|Delete this user.|,
		lastUpdated => 1036864742
	},

	'229' => {
		message => q|Subject|,
		lastUpdated => 1031514049
	},

	'866' => {
		message => q|Expire Notification Message|,
		lastUpdated => 1101775465,
	},

	'768' => {
		message => q|Name|,
		lastUpdated => 1036892946
	},

	'68' => {
		message => q|The account information you supplied is invalid. Either the account does not exist or the username/password combination was incorrect.|,
		lastUpdated => 1031514049
	},

	'315' => {
		message => q|Middle Name|,
		lastUpdated => 1031514049
	},

	'893' => {
		message => q|Wobject Properties|,
		lastUpdated => 1046638419
	},

	'338' => {
		message => q|Edit Profile|,
		lastUpdated => 1031514049
	},

	'576' => {
		message => q|Delete|,
		lastUpdated => 1031514049
	},

	'738' => {
		message => q|9 Guru|,
		lastUpdated => 1033836704
	},

	'870' => {
		message => q|Welcome|,
		lastUpdated => 1044139461
	},

	'484' => {
		message => q|Select List|,
		lastUpdated => 1031514049
	},

	'1078' => {
		message => q|There is already a user of this system with the email address you've entered.  
        Please re-complete the form and press "Save" if you still wish to create this user|,
		lastUpdated => 1067951807
	},

	'328' => {
		message => q|Home Phone|,
		lastUpdated => 1031514049
	},

	'1085' => {
		message => q|Pagination Template Variables|,
		lastUpdated => 1078243385
	},

	'363' => {
		message => q|Page Template Position|,
		lastUpdated => 1034736999
	},

	'1051' => {
		message => q|Replace With|,
		lastUpdated => 1066418940
	},

	'733' => {
		message => q|4 Skilled|,
		lastUpdated => 1033836668
	},

	'562' => {
		message => q|Pending|,
		lastUpdated => 1031514049
	},

	'36' => {
		message => q|You must be an administrator to perform this function. Please contact one of your administrators. |,
		lastUpdated => 1058092984
	},

	'748' => {
		message => q|User Count|,
		lastUpdated => 1036553016
	},

	'362' => {
		message => q|SideBySide|,
		lastUpdated => 1031514049
	},

	'439' => {
		message => q|Personal Information|,
		lastUpdated => 1031514049
	},

    'personal info short' => {
		message => q|Personal|,
 		lastUpdated => 1031514049
 	},

	'317' => {
		message => q|<a href="http://www.icq.com">ICQ</a> UIN|,
		lastUpdated => 1031514049
	},

	'169' => {
		message => q|Add a new user.|,
		lastUpdated => 1031514049
	},

	'411' => {
		message => q|Menu Title|,
		lastUpdated => 1031514049
	},

	'705' => {
		message => q|Minute(s)|,
		lastUpdated => 1031514049
	},

	'478' => {
		message => q|URL|,
		lastUpdated => 1031514049
	},

	'942' => {
		message => q|Radio List|,
		lastUpdated => 1051464141
	},

	'955' => {
		message => q|System Clipboard|,
		lastUpdated => 1099360884
	},

	'407' => {
		message => q|Click here to register.|,
		lastUpdated => 1031514049
	},

	'537' => {
		message => q|Karma|,
		lastUpdated => 1031514049
	},

	'125' => {
		message => q|Company Name|,
		lastUpdated => 1031514049
	},

	'44' => {
		message => q|Yes, I'm sure.|,
		lastUpdated => 1031514049
	},

	'1007' => {
		message => q|Content Type|,
		lastUpdated => 1060432032
	},

	'95' => {
		message => q|Help Index|,
		lastUpdated => 1031514049
	},

	'313' => {
		message => q|Allow miscellaneous information?|,
		lastUpdated => 1031514049
	},

	'551' => {
		message => q|Notice|,
		lastUpdated => 1031514049
	},

	'529' => {
		message => q|results per page|,
		lastUpdated => 1066492301
	},

	'753' => {
		message => q|Edit this group.|,
		lastUpdated => 1036866979
	},

	'343' => {
		message => q|View profile.|,
		lastUpdated => 1031514049
	},

	'504' => {
		message => q|Template|,
		lastUpdated => 1031514049
	},

	'987' => {
		message => q|Delete Database Link|,
		lastUpdated => 1056151382
	},

	'857' => {
		message => q|IP Address|,
		lastUpdated => 1043878310
	},

	'1010' => {
		message => q|Text|,
		lastUpdated => 1060433369
	},

	'707' => {
		message => q|Show debugging?|,
		lastUpdated => 1031514049
	},

	'964' => {
		message => q|Manage system trash.|,
		lastUpdated => 1052850265
	},

	'65' => {
		message => q|Please deactivate my account permanently.|,
		lastUpdated => 1031514049
	},

	'81' => {
		message => q|Account updated successfully!|,
		lastUpdated => 1031514049
	},

	'321' => {
		message => q|Cell Phone|,
		lastUpdated => 1031514049
	},

	'86' => {
		message => q|Are you certain you wish to delete this group? Beware that deleting a group is permanent and will remove all privileges associated with this group.|,
		lastUpdated => 1031514049
	},

	'792' => {
		message => q|Templates|,
		lastUpdated => 1036971696
	},

	'823' => {
		message => q|Go to the new page.|,
		lastUpdated => 1038706332
	},

	'371' => {
		message => q|Add Grouping|,
		lastUpdated => 1031514049
	},

	'1079' => {
		message => q|Printable Style|,
		lastUpdated => 1073152790
	},

	'729' => {
		message => q|0 Beginner|,
		lastUpdated => 1033836631
	},

	'2' => {
		message => q|Page|,
		lastUpdated => 1031514049
	},

	'435' => {
		message => q|Session Signature|,
		lastUpdated => 1031514049
	},

	'808' => {
		message => q|Email this group.|,
		lastUpdated => 1037579487
	},

	'885' => {
		message => q|Allow users to deactivate their account?|,
		lastUpdated => 1044708760
	},

	'884' => {
		message => q|Pop Up|,
		lastUpdated => 1044705337
	},

	'147' => {
		message => q|Assets|,
		lastUpdated => 1091514049
	},

	'339' => {
		message => q|Male|,
		lastUpdated => 1031514049
	},

	'1046' => {
		message => q|Archived|,
		lastUpdated => 1066406723
	},

	'863' => {
		message => q|Delete Offset|,
		lastUpdated => 1044126633
	},

	'531' => {
		message => q|with the <b>exact phrase</b>|,
		lastUpdated => 1031514049
	},

	'345' => {
		message => q|Not A Member|,
		lastUpdated => 1031514049
	},

	'319' => {
		message => q|<a href="http://messenger.msn.com/">MSN Messenger</a> Id|,
		lastUpdated => 1149003146
	},

	'1052' => {
		message => q|Edit Content Filter|,
		lastUpdated => 1066418983
	},

        '1050 description' => {
                message => q|A string to search for.  All punctuation will be escaped.|,
                lastUpdated => 1121052295,
        },

        '1051 description' => {
                message => q|What you want the string to be replaced with.|,
                lastUpdated => 1121052295,
        },

	'735' => {
		message => q|6 Professional|,
		lastUpdated => 1033836686
	},

	'404' => {
		message => q|First Page|,
		lastUpdated => 1031514049
	},

	'1043' => {
		message => q|Archive After|,
		lastUpdated => 1066394455
	},

	'974' => {
		message => q|Users can add themselves?|,
		lastUpdated => 1053778912
	},

	'420' => {
		message => q|Remove nothing.|,
		lastUpdated => 1046637549
	},

	'702' => {
		message => q|Month(s)|,
		lastUpdated => 1031514049
	},

	'952' => {
		message => q|Clipboard Date|,
		lastUpdated => 1052850265
	},

	'1071' => {
		message => q|Env HTTP Host|,
		lastUpdated => 1066641511
	},

	'561' => {
		message => q|Denied|,
		lastUpdated => 1031514049
	},

	'357' => {
		message => q|News|,
		lastUpdated => 1031514049
	},

	'63' => {
		message => q|Turn admin on.|,
		lastUpdated => 1031514049
	},

	'455' => {
		message => q|Edit User's Profile|,
		lastUpdated => 1031514049
	},

	'80' => {
		message => q|Account created successfully!|,
		lastUpdated => 1031514049
	},

	'336' => {
		message => q|Birth Date|,
		lastUpdated => 1031514049
	},

	'457' => {
		message => q|Edit this user.|,
		lastUpdated => 1099014049
	},

	'821' => {
		message => q|Any|,
		lastUpdated => 1038432387
	},

	'ends with' => {
		message => q|Ends With|,
		lastUpdated => 1089039511
	},

	'92' => {
		message => q|Next Page|,
		lastUpdated => 1031514049
	},

	'879' => {
		message => q|Classic Editor (Internet Explorer 5+)|,
		lastUpdated => 1044705103
	},

    'class name' => {
        message => q|Class Name|,
        lastUpdated => 0,
        context=> 'Form Type Name, as in "Object Class Name"',
    },

    'SubscriptionGroup formName' => {
        message => q|Subscription Group|,
        lastUpdated => 0,
        context=> 'form field type',
    },

    'SelectRichEditor formName' => {
        message => q|Choose Rich Editor|,
        lastUpdated => 0,
        context=> 'form field type',
    },

    'fieldType' => {
        message => q|Field Type|,
        lastUpdated => 0,
        context=> 'form field type',
    },

    'slider' => {
        message => q|Slider|,
        lastUpdated => 0,
        context=> 'form field type that has a slide selector',
    },

	'980' => {
		message => q|Empty this folder.|,
		lastUpdated => 1055908341
	},

	'10' => {
		message => q|Manage my trash.|,
		lastUpdated =>1211131614 
	},

	'958' => {
		message => q|<p>The clipboard is a special system location to which content may be temporarily cut or copied.  Items in the clipboard may then be pasted to a new location.</p>

<p>The clipboard contents may be managed individually. You may delete or paste an item by selecting the appropriate icon.  You may also empty the entire contents of the clipboard to the trash by choosing the Empty clipboard menu option.</p>

<p>The clipboard will only show Assets that you placed there or that are under your current version tag.</p>

<p>If you are an Admin, you may access the System Clipboard, which will display all Assets by any user which are committed
or are under your current version tag.</p>

<p><b>Title</b><br />The name of the item in the clipboard.  You may view the item by selecting the title.</p>

<p><b>Type</b><br />The type of content.  For instance, a Page, Article, EventsCalendar, etc.</p>

<p><b>Clipboard Date</b><br />The date and time the item was added to the clipboard.</p>

<p><b>Previous Location</b><br />The location where the item was previously found.  You may view the previous location by selecting the location.</p>

<p><b>Username</b><br />The username of the individual who placed the item in the clipboard.  This optional field is only visible in shared clipboard environments or when an administrator is managing the system clipboard.</p>|,

		lastUpdated => 1173117114,
	},

	'419' => {
		message => q|Remove everything but the text.|,
		lastUpdated => 1046637533
	},

	'995' => {
		message => q|Database Password|,
		lastUpdated => 1056151382
	},

	'837' => {
		message => q|Folder, Add/Edit|,
		lastUpdated => 1038871918
	},

	'149' => {
		message => q|Users|,
		lastUpdated => 1031514049,
                context => q|Title of the user manager for the admin console.|
	},

	'406' => {
		message => q|Thumbnail Size|,
		lastUpdated => 1031514049
	},

	'482' => {
		message => q|Number (Integer)|,
		lastUpdated => 1031514049
	},

	'949' => {
		message => q|Manage clipboard.|,
		lastUpdated => 1052850265
	},

	'56' => {
		message => q|Email Address|,
		lastUpdated => 1031514049
	},

	'56 description' => {
		message => q|The email address for the admin.  It can be used to send administrative notices.|,
		lastUpdated => 1031514049
	},

	'499' => {
		message => q|Wobject ID|,
		lastUpdated => 1031514049
	},

	'530' => {
		message => q|with <b>all</b> the words|,
		lastUpdated => 1031514049
	},

	'66' => {
		message => q|Log In|,
		lastUpdated => 1031514049
	},

	'54' => {
		message => q|Create Account|,
		lastUpdated => 1031514049
	},

	'1030' => {
		message => q|by|,
		lastUpdated => 1047842270
	},

	'70' => {
		message => q|Error|,
		lastUpdated => 1031514049
	},

	'1047' => {
		message => q|Add a content filter.|,
		lastUpdated => 1066418669
	},

	'88' => {
		message => q|Users In Group|,
		lastUpdated => 1031514049
	},

	'1009' => {
		message => q|HTML|,
		lastUpdated => 1060433286
	},

	'141' => {
		message => q|Not Found Page|,
		lastUpdated => 1031514049
	},

	'403' => {
		message => q|Prefer not to say.|,
		lastUpdated => 1031514049
	},

	'883' => {
		message => q|Inline (when supported)|,
		lastUpdated => 1044705322
	},

	'134' => {
		message => q|Recover Password Message|,
		lastUpdated => 1031514049
	},

	'75' => {
		message => q|Your account information has been sent to your email address.|,
		lastUpdated => 1031514049
	},

	'848' => {
		message => q|There is a syntax error in this template. Please correct.|,
		lastUpdated => 1039892202
	},

	'59' => {
		message => q|I forgot my password.|,
		lastUpdated => 1031514049
	},

	'421' => {
		message => q|Remove everything except basic formating.|,
		lastUpdated => 1046611728
	},

	'450' => {
		message => q|Work Name (Company Name)|,
		lastUpdated => 1031514049
	},

	'1070' => {
		message => q|Config Sitename|,
		lastUpdated => 1066641473
	},

	'703' => {
		message => q|Year(s)|,
		lastUpdated => 1031514049
	},

	'864' => {
		message => q|Expire Notification Offset|,
		lastUpdated => 1044126838
	},

	'1016' => {
		message => q|Replies|,
		lastUpdated => 1031514049
	},

	'url extension' => {
		message => q|URL Extension|,
		lastUpdated => 1089039511
	},

	'318' => {
		message => q|<a href="http://www.aim.com/">AIM</a> Id|,
		lastUpdated => 1234829971,
	},

	'972' => {
		message => q|Date and Time|,
		lastUpdated => 1053278234
	},

	'105' => {
		message => q|Display|,
		lastUpdated => 1046638916
	},

	'146' => {
		message => q|Active Sessions|,
		lastUpdated => 1031514049
	},

	'38' => {
		message => q|You do not have sufficient privileges to perform this operation. Please ^a(log in with an account); that has sufficient privileges before attempting this operation.|,
		lastUpdated => 1031514049
	},

	'asset locked' => {
		message => q|This Asset is locked for editing under a version tag different from the one that you are using.|,
		lastUpdated => 1177706405
	},

	'bare insufficient' => {
		message => q|You do not have sufficient privileges to perform this operation. Please log in with an account that has sufficient privileges before attempting this operation.|,
		lastUpdated => 1169790230
	},

	'164' => {
		message => q|Authentication Method|,
		lastUpdated => 1031514049
	},

	'807' => {
		message => q|Manage the groups in this group.|,
		lastUpdated => 1037579473
	},

	'945' => {
		message => q|Scratch Filter|,
		lastUpdated => 1052560369
	},

	'tinymce' => {
                message => q|TinyMCE (IE, mozilla)|,
                lastUpdated =>1092748557,
                context => q|option for Rich Editor in profile|
        },

	'color' => {
		message => q|Color|,
		lastUpdated =>0,
                context => q|Field type name|
        },

	'combobox' => {
		message => q|Combo Box|,
		lastUpdated =>0,
                context => q|Field type name|
        },

	'fieldtype' => {
		message => q|Field Type|,
		lastUpdated =>0,
                context => q|Field type name|
        },

	'hidden list' => {
		message => q|Hidden List|,
		lastUpdated =>0,
                context => q|Field type name|
        },

	'hidden' => {
		message => q|Hidden|,
		lastUpdated =>0,
                context => q|Field type name|
        },

	'interval' => {
		message => q|Interval|,
		lastUpdated =>0,
                context => q|Field type name|
        },

	'group' => {
		message => q|Group|,
		lastUpdated =>0,
                context => q|Field type name|
        },

	'file' => {
		message => q|File|,
		lastUpdated =>0,
                context => q|Field type name|
        },

	'image' => {
		message => q|Image|,
		lastUpdated =>0,
                context => q|Field type name|
        },

	'codearea' => {
		message => q|Code Area|,
		lastUpdated =>0,
                context => q|Field type name|
        },

	'radio' => {
		message => q|Radio Button|,
		lastUpdated =>0,
                context => q|Field type name|
        },

	'read only' => {
		message => q|Read Only|,
		lastUpdated =>0,
                context => q|Field type name|
        },

    'submit' => {
        message => q|Submit|,
        lastUpdated =>1140589512,
        context => q|Field type name and button label|
    },

	'button' => {
		message => q|Button|,
		lastUpdated =>0,
                context => q|Field type name|
        },

	'cancel' => {
		message => q|cancel|,
		lastUpdated =>1092930637,
                context => q|Label of the cancel button|
        },

	'trash' => {
		message => q|Trash|,
		lastUpdated =>1211131614,
        context => q|Title of the trash manager for the admin console.|
        },

	'databases' => {
		message => q|Databases|,
		lastUpdated =>1092930637,
                context => q|Title of the database manager for the admin console.|
        },

	'packages' => {
		message => q|Packages|,
		lastUpdated =>1092930637,
                context => q|Title of the package manager for the admin console.|
        },

	'help' => {
		message => q|Template Help|,
		lastUpdated =>1092930637,
        context => q|Title of the help index for the admin console.|
        },

	'content filters' => {
		message => q|Content Filters|,
		lastUpdated =>1092930637,
                context => q|Title of the content filters manager for the admin console.|
        },

	'user profiling' => {
		message => q|User Profiling|,
		lastUpdated =>1092930637,
                context => q|Title of the user profile settings manager for the admin console.|
        },

	'page statistics' => {
		message => q|Page Statistics|,
		lastUpdated =>1092930637,
                context => q|Title of the page statistics viewer for the admin console.|
        },

	'user' => {
		message => q|User|,
		lastUpdated =>1092930637,
                context => q|Title of a tab in the global settings.|
        },

	'content' => {
		message => q|Content|,
		lastUpdated =>1092930637,
                context => q|Title of a tab in the global settings.|
        },

	'ui' => {
		message => q|UI|,
		lastUpdated =>1092930637,
                context => q|Title of a tab in the global settings.|
        },

	'messaging' => {
		message => q|Messaging|,
		lastUpdated =>1092930637,
                context => q|Title of a tab in the global settings.|
        },

	'authentication' => {
		message => q|Authentication|,
		lastUpdated =>1092930637,
                context => q|Title of a tab in the global settings.|
        },

    'company' => {
        message => q|Company|,
        lastUpdated =>1092930637,
        context => q|Title of a tab in the global settings.|
    },

	'misc' => {
		message => q|Miscellaneous|,
		lastUpdated =>1092930637,
                context => q|Title of a tab in the global settings.|
        },

	'user function style' => {
		message => q|User Function Style|,
		lastUpdated =>1118453709,
        },

	'admin console template' => {
		message => q|Admin Console Template|,
		lastUpdated =>1118453709,
        },

	'admin console template variables' => {
		message => q|Admin Console Template Variables|,
		lastUpdated =>1247528069,
    },

	'formHeader' => {
		message => q|HTML code to start a form.|,
		lastUpdated =>1247529885,
    },

	'formFooter' => {
		message => q|HTML code to end a form.|,
		lastUpdated =>1247529885,
    },

	'application_loop' => {
		message => q|A loop containing all admin applications.|,
		lastUpdated =>1247529885,
    },

	'application.workarea' => {
		message => q|The rendered application screen.|,
		lastUpdated =>1247529885,
    },

	'application.title' => {
		message => q|The title of the application.|,
		lastUpdated =>1247529885,
    },

	'application.icon' => {
		message => q|The URL to this application's icon.|,
		lastUpdated =>1247529885,
    },

	'application.icon.small' => {
		message => q|The URL to this application's icon, the small version.|,
		lastUpdated =>1247529885,
    },

	'application.canUse' => {
		message => q|A boolean that will be true if the current user can use this application, based on group privileges and uiLevel.|,
		lastUpdated =>1247529885,
    },

	'application.url' => {
		message => q|The URL to this screen.|,
		lastUpdated =>1247529885,
    },

	'backtosite.label' => {
		message => q|An internationalized label for the link that returns the user back to the website from the Admin Console.|,
		lastUpdated =>1247529885,
    },

	'backtosite.url' => {
		message => q|The URL for the link to take the user back to the website, from the Admin Console.|,
		lastUpdated =>1247529885,
    },

	'toggle.on.label' => {
		message => q|An internationalized label for the link that displays the Admin console.|,
		lastUpdated =>1247529885,
    },

	'toggle.off.label' => {
		message => q|An internationalized label for the link that hides the Admin console.|,
		lastUpdated =>1247529885,
    },

	'submenu_loop' => {
		message => q|A loop contains a set of links for the submenu panel.|,
		lastUpdated =>1247529885,
    },

	'submenu.label' => {
		message => q|A label for the link.|,
		lastUpdated =>1247529885,
    },

	'submenu.url' => {
		message => q|The URL for the link.|,
		lastUpdated =>1247529885,
    },

	'submenu.extras' => {
		message => q|Any extra parameters for the link, like javascript for a confirmation.|,
		lastUpdated =>1247529885,
    },

	'console.title' => {
		message => q|The admin console's title.|,
		lastUpdated =>1247529885,
    },

	'console.icon' => {
		message => q|The admin console's icon.|,
		lastUpdated =>1247529885,
    },

	'console.canUse' => {
		message => q|A boolean that will be true if the current user can use the admin console, based on group privileges and uiLevel.|,
		lastUpdated =>1247529885,
    },

	'console.url' => {
		message => q|The URL to the admin console.|,
		lastUpdated =>1247529885,
    },

	'help.url' => {
		message => q|The URL to view the help associated with this application, if any.|,
		lastUpdated =>1247529885,
    },

	'versionTags' => {
		message => q|A loop containing information about open version tags.|,
		lastUpdated =>1247529885,
    },

	'versionTags.title' => {
		message => q|The title of this version tag.|,
		lastUpdated =>1247529885,
    },

	'versionTags.url' => {
		message => q|If this version tag is the current tag for the user, then this link will be to commit the tag.  Otherwise, it will be to make this tag the current tag for the user.|,
		lastUpdated =>1247529885,
    },

	'versionTags.icon' => {
		message => q|If this tag is the current tag for the user, this will contain the URL to a small version of the version tags admin console icon.|,
		lastUpdated =>1248190349,
    },

	'settings' => {
		message => q|Settings|,
		lastUpdated =>1092930637,
        context => q|Title of the settings manager for the admin console.|
    },

        '125 description' => {
                message => q|The name of your company. It will appear on all emails and anywhere you use the Company Name style macro.|,
                lastUpdated => 1120239343,
        },

        '126 description' => {
                message => q|A general email address at your company. This is the address that all automated messages will come from. It can also be used via Company Email Address style macro.|,
                lastUpdated => 1120239343,
        },

        '127 description' => {
                message => q|The primary URL of your company. This will appear on all automated emails sent from the WebGUI system. It is also available via the Company URL style macro.|,
                lastUpdated => 1120239343,
        },

        '527 description' => {
                message => q|Some really small sites don't have a home page, but instead like to use one of their internal pages like "About Us" or "Company Information" as their home page. For that reason, you can set the default page of your site to any page in the site. That page will be the one people go to if they type in just your URL http://www.mywebguisite.com, or if they click on the Home link generated by an AssetProxy of a Navigation Asset. |,
                lastUpdated => 1120239343,
        },

        '141 description' => {
                message => q|If a page that a user requests is not found in the system, the user can either be redirected to the home page or to an error page where they can attempt to find what they were looking for. You decide which is better for your users. |,
                lastUpdated => 1120239343,
        },

        'url extension description' => {
                message => q|<p>Add an extension such as "html", "php", or "asp" to each new page URL as it is created.
</p>
<p><b>NOTE:</b> Do NOT include the dot "." in this. So the field should look like "html" not ".html".
</p>|,
                lastUpdated => 1120239343,
        },

        '130 description' => {
                message => q|The size (in kilobytes) of the maximum allowable attachment to be uploaded to your system. Due to the nature of the HTTP Protocol, 100MB is the largest practical file size you can expect to upload via WebGUI's web interface. |,
                lastUpdated => 1120239343,
        },

        '583 description' => {
                message => q|If images are uploaded to your system that are bigger than the max image size, then they will be resized to the max image size. The max image size is measured in pixels and will use the size of the longest side of the image to determine if the limit has been reached. |,
                lastUpdated => 1120239343,
        },

        '406 description' => {
                message => q|When images are uploaded to your system, they will automatically have thumbnails generated at the size specified here (unless overridden on a case-by-case basis). Thumbnail size is measured in pixels. |,
                lastUpdated => 1120239343,
        },

        'Enable Metadata description' => {
                message => q|This enables the metadata tab on Assets so that metadata can be entered
and tracked by WebGUI.|,
                lastUpdated => 1120239343,
        },

        'default rich editor description' => {
                message => q|<p>This is the rich editor configuration that will be used by default when a rich editor is needed. This can be overridden in certain applications such as the Collaboration System.</p>|,
                lastUpdated => 1120239343,
        },

        '465 description' => {
                message => q|How many characters can be displayed at once in text boxes on the site. |,
                lastUpdated => 1120239343,
        },

        'user function style description' => {
                message => q|Defines which style to be used to style WebGUI operations (profile editing, message log, etc.) when they are available to a user.  Only templates which have been committed are allowed.|,
                lastUpdated => 1192735786,
        },

        'admin console template description' => {
                message => q|The style to be used by the Admin Console.|,
                lastUpdated => 1120239343,
        },

        '135 description' => {
                message => q|<p>This is the address of your local mail server. It is needed for all features that use the Internet email system (such as password recovery).</p>
<p>Optionally, if you are running a sendmail server on the same machine as WebGUI, you can also specify a path to your sendmail executable. On most Linux systems this can be found at "/usr/lib/sendmail".</p>|,
                lastUpdated => 1120239343,
        },

        '824 description' => {
                message => q|This footer will be processed for macros and attached to every email sent from this WebGUI instance.|,
                lastUpdated => 1146455404,
        },

        '400 description' => {
                message => q|Some companies have proxy servers that cause problems with WebGUI. If you're experiencing problems with WebGUI, and you have a proxy server, you may want to set this setting to <i>Yes</i>. Beware that WebGUI's URLs will not be as user-friendly after this feature is turned on.|,
                lastUpdated => 1120239343,
        },

        '707 description' => {
                message => q|Show debugging information in WebGUI's output. This is primarily useful for WebGUI developers, but can also be interesting for Administrators trying to troubleshoot a problem.|,
                lastUpdated => 1120239343,
        },

        '1069 description' => {
                message => q|Select which host to use by default when generating URLs. Config Sitename will use the "sitename" variable from your config file. And Env HTTP Host will use the "HTTP_HOST" environment variable provided by the web server.|,
                lastUpdated => 1120239343,
        },

        '118 description' => {
                message => q|Do you wish visitors to your site to be able to register themselves?|,
                lastUpdated => 1120239343,
        },

        '559 description' => {
                message => q|If there is a workflow chosen here, it will be executed each time a user registers anonymously.|,
                lastUpdated => 1141956483,
        },

        '539 description' => {
                message => q|Should karma be enabled?|,
                lastUpdated => 1120239343,
        },

        '540 description' => {
                message => q|The amount of karma a user should be given when they log in. This only takes affect if karma is enabled.|,
                lastUpdated => 1120239343,
        },

        '142 description' => {
                message => q|The amount of time that a user session remains active (before needing to log in again). This timeout is reset each time a user views a page. Therefore if you set the timeout for 8 hours, a user would have to log in again if s/he hadn't visited the site for 8 hours.|,
                lastUpdated => 1120239343,
        },

        '885 description' => {
                message => q|Do you wish to provide your users with a means to deactivate their account without your intervention?|,
                lastUpdated => 1120239343,
        },

        '1006 description' => {
                message => q|Should the system use the HTTPS protocol for the login form?|,
                lastUpdated => 1227291454,
        },

        '164 description' => {
                message => q|<p>Set the default authentication method for new accounts.  The two available options by default are WebGUI and LDAP. WebGUI authentication means that the users will authenticate against the username and password stored in the WebGUI database. LDAP authentication means that users will authenticate against an external LDAP server.  Other methods can be provided by writing a custom authentication plug-in.</p>
<p><i>NOTES:</i>
</p>
<p>Authentication settings can be customized on a per user basis.
</p>
<p>Depending upon what authentication modules you have installed in your system you'll see any number of options after this point.</p>|,
                lastUpdated => 1146799413,
        },


	'Enable passive profiling' => {
		message => q|Enable passive profiling?|,
		lastUpdated => 1089039511
	},

    'Enable passive profiling description' => {
        message => q|Used in conjunction with Metadata, this keeps a record of every wobject viewed by
a user.|,
        lastUpdated => 1167189802,
    },

	'Illegal Warning' => {
		message => q|Enabling this feature is illegal in some countries, like Australia. In addition, some countries require you to add a warning to your site if you use this feature. Consult your local authorities for local laws. Plain Black Corporation is not responsible for your illegal activities, regardless of ignorance or malice.|,
		lastUpdated => 1089039511
	},

	'default rich editor' => {
		message => q|Default Rich Editor|,
		lastUpdated => 1118941685,
	},

    'account settings tab' => {
		message => q|Account|,
		lastUpdated => 1098327046,
		context => q|Tab label for the account settings in WebGUI Settings.|
	},

	'account' => {
		message => q|Account|,
		lastUpdated => 1098327046,
		context => q|Tab label for the user's account in the user manager.|
	},

	'profile' => {
		message => q|Profile|,
		lastUpdated => 1098327046,
		context => q|Tab label for the user's profile in the user manager.|
	},

	'manage cache'  => {
                message => q|Cache|,
                lastUpdated => 1031514049
        },
	'cache type' => {
                message => q|Cache type|,
                lastUpdated => 1031514049
        },
	'cache statistics' => {
                message => q|Cache Statistics|,
                lastUpdated => 1031514049
        },
	'clear cache' => {
                message => q|Clear Cache|,
                lastUpdated => 1031514049
        },

	'Enable Metadata' => {
		message => q|Enable Metadata?|,
		lastUpdated => 1089039511
	},

	'groups to add' => {
		message => q|GROUPS TO ADD|,
		lastUpdated => 1118861810
	},

	'groups to delete' => {
		message => q|GROUPS TO DELETE|,
		lastUpdated => 1118861810
	},

	'help index' => {
		message => q|Help Index|,
		lastUpdated => 1252424721
	},

	'help toc' => {
		message => q|Table of Contents|,
		lastUpdated => 1128552846
	},

	'help contents' => {
		message => q|Help Contents|,
		lastUpdated => 1128553296
	},

	'topicName' => {
		message => q|WebGUI|,
		lastUpdated => 1128919994,
	},

	'photo' => {
		message => q|Photo|,
		lastUpdated => 1131246503,
	},

	'avatar' => {
		message => q|Avatar|,
		lastUpdated => 1131246512,
	},

	'unknown user' => {
		message => q|unknown user|,
		lastUpdated => 1135205716,
	},

	'allowed keywords' => {
		message => q|Allowed keywords|,
		lastUpdated => 0,
	},

	'allowed keywords description' => {
		message => q|You can enter the statements that are allowed for this databaselink. A safe (read-only) choice is SELECT, DESCRIBE and SHOW. The different keywords should be separated from each other by whitespace.|,
		lastUpdated => 1165511447,
	},

    'allow access from macros' => {
        message => q|Allow access from Macro's|,
        lastUpdated => 0,
    },

    'allow access from macros help' => {
        message => q|Are macros allowed to access this DatabaseLink?|,
        lastUpdated => 1185397688,
    },

    'additional parameters' => {
        message => q|Additional database parameters|,
        lastUpdated => 1185397688,
    },

    'additional parameters help' => {
        message => q|<p>Specify additional parameters for your database connection.  Use 1 per line, and separate the name of the parameter from the value with an equal sign, like this: </p>
<p>LongReadLen=1024<br />
LongTruncOk=1</p>
|,
        lastUpdated => 1185397688,
    },

	'preview' => {
		message => q|Preview|,
		context => q|alternate image text displayed when a thumbnail cannot be found for an image.  The image is being previewed.|,
		lastUpdated => 1141434351,
	},

	'image manager' => {
		message => q|Image Manager|,
		context => q|alternate text when an icon cannot be found in the Rich Editor image manager thumbnail display form.|,
		lastUpdated => 1141434353,
	},

	'insert a link' => {
		message => q|Insert A Link|,
		lastUpdated => 1141963447,
	},

	'link settings' => {
		message => q|Link Settings|,
		lastUpdated => 1141963463,
	},

	'choose an asset' => {
		message => q|Choose an Asset|,
		lastUpdated => 1141963463,
	},

	'webgui' => {
		message => q|WebGUI|,
		lastUpdated => 1141963573,
		context => q|Test key for International macro test.  DO NOT TRANSLATE|,
	},

	'pages' => {
		message => q|Pages|,
		lastUpdated => 1141963573,
	},

	'hex slider' => {
		message => q|Hex slider|,
		lastUpdated => 0,
	},

	'int slider' => {
		message => q|Int slider|,
		lastUpdated => 0,
	},

	'select slider' => {
		message => q|Select slider|,
		lastUpdated => 0,
	},

	'hexadecimal' => {
		message => q|Hexadecimal|,
		lastUpdated => 0,
	},

	'country' => {
		message => q|Country|,
		lastUpdated => 0,
	},

	'noldaplink' => {
		message => q|No LDAP Connection|,
		lastUpdated => 0,
	},

	'no ldap link for auth' => {
		message => q|Unable to create your account because no LDAP connection has been defined for this site.|,
        context => 'Error message in createAccount screen when no LDAP connection is defined.',
		lastUpdated => 1229376071,
	},

	'no ldap logins' => {
		message => q|Unable to log you in because no LDAP link has been defined for this site.|,
        context => 'Error message for login when no LDAP connection is defined.',
		lastUpdated => 1229376071,
	},

	'Select State' => {
		message => q|Select State|,
		lastUpdated => 1161388472,
	},

	'invite a friend' => {
		message => q|Invite a friend|,
		lastUpdated => 1181019679,
	},

	'user invitations email exists' => {
		message => q|Email exists message|,
		lastUpdated => 1181277915
	},

    'user invitations email exists description' => {
        message => q|This is the message displayed to users who try to invite someone whose email address already exists in the system.|,
        lastUpdated => 1181277914,
    },

	'user email template' => {
		message => q|User Invitation Email Template|,
		lastUpdated => 1181969396
	},

    'user email template description' => {
        message => q|The template used to build the email invitation to the user.|,
        lastUpdated => 1181969398,
    },

	'user profile view template' => {
		message => q|User Profile Viewing Template|,
		lastUpdated => 1213323171,
	},

    'user profile view template description' => {
        message => q|The template used to show the user their user profile.|,
        lastUpdated => 1216588139,
    },

	'user profile edit template' => {
		message => q|User Profile Editing Template|,
		lastUpdated => 1213323171,
	},

    'user profile edit template description' => {
        message => q|The template used to build a form so the user can edit their user profile.|,
        lastUpdated => 1216588137,
    },

    'send private message' => {
		message => q|Send Private Message|,
		lastUpdated => 1181019679,
	},

    'private message title' => {
		message => q|Send Private Message|,
		lastUpdated => 1181019679,
	},

    'private message no self error' => {
		message => q|You may not send private messages to yourself.|,
		lastUpdated => 1181019679,
	},

    'private message no user' => {
    	message => q|You have not selected a user to send a private message to|,
		lastUpdated => 1181019679,
    },

    'private message to label' => {
    	message => q|To|,
		lastUpdated => 1181019679,
    },

    'private message from label' => {
    	message => q|From|,
		lastUpdated => 1181019679,
    },

    'private message subject label' => {
    	message => q|Subject|,
		lastUpdated => 1181019679,
    },

    'private message message label' => {
    	message => q|Message|,
		lastUpdated => 1181019679,
    },

    'private message submit label' => {
    	message => q|Submit|,
		lastUpdated => 1181019679,
    },

    'private message error' => {
    	message => q|Message Error|,
		lastUpdated => 1181019679,
    },

    'private message blocked error' => {
        message => q|This user does not wish to receive private messages.|,
		lastUpdated => 1181019679,
    },

    'private message sent' => {
        message => q|Your private message has been sent.|,
		lastUpdated => 1181019679,
    },

    'private message status unread' => {
        message => q|Unread|,
		lastUpdated => 1181019679,
    },

    'private message status replied' => {
        message => q|Replied|,
		lastUpdated => 1181019679,
    },

    'private message status read' => {
        message => q|Read|,
		lastUpdated => 1181019679,
    },

    'inbox message status active' => {
        message => q|Active|,
		lastUpdated => 1181019679,    
    },

    'private message prev label' => {
        message => q|Previous|,
		lastUpdated => 1181019679,
    },

    'private message next label' => {
        message => q|Next|,
		lastUpdated => 1181019679,
    },

    'allow private messages label' => {
        message => q|Private Message Options|,
		lastUpdated => 1181019679,
    },

    'user profile field private message allow label' => {
        message => q|Public|,
		lastUpdated => 1181019679,
    },

    'user profile field private message friends only label' => {
        message => q|Friends Only|,
		lastUpdated => 1181019679,
    },

    'user profile field private message allow none label' => {
        message => q|Private|,
		lastUpdated => 1181019679,
    },

    'private message from label' => {
        message => q|From|,
		lastUpdated => 1181019679,
    },

    'private message date label' => {
        message => q|Date|,
		lastUpdated => 1181019679,
    },

    'private message reply title' => {
        message => q|Reply to Message|,
		lastUpdated => 1181019679,
    },

    'private message unread display message' => {
        message => q|%s unread messages|,
		lastUpdated => 1181019679,
    },

    'private message delete text' => {
        message => q|delete|,
		lastUpdated => 1181019679,
    },

    'view inbox template' => {
		message => q|Inbox Template|,
		lastUpdated => 1181019679,
	},

    'view inbox template description' => {
		message => q|Choose a template for displaying the inbox|,
		lastUpdated => 1181019679,
	},

    'view inbox message template' => {
		message => q|Inbox Message Template|,
		lastUpdated => 1181019679,
	},

    'view inbox message template description' => {
		message => q|Choose a template for displaying messages in the inbox|,
		lastUpdated => 1181019679,
	},

    'send private message template' => {
		message => q|Send Private Message Template|,
		lastUpdated => 1181019679,
	},

    'send private message template description' => {
		message => q|Choose a template for sending private messages|,
		lastUpdated => 1181019679,
	},

    'editSettings error occurred' => {
        message     => q{The following errors occurred while trying to save settings.},
        lastUpdated => 0,
    },

    'editSettings done' => {
        message     => "Settings saved!",
        lastUpdated => 0,
    },

    'deactivateAccount success' => {
        message     => q{%s has been deactivated},
        lastUpdated => 0,
    },

    'permissions'   => {
        message     => q{Permissions},
        lastUpdated => 0,
        context     => q{The label for the Permissions tab of the Settings Admin panel},
    },

    'settings groupIdAdminActiveSessions label' => {
        message     => q{Active Sessions},
        lastUpdated => 0,
    },
    'settings groupIdAdminActiveSessions hoverHelp' => {
        message     => q{Group to view and expire active sessions.},
        lastUpdated => 0,
    },

    'settings groupIdAdminAdSpace label' => {
        message     => q{AdSpace},
        lastUpdated => 0,
    },
    'settings groupIdAdminAdSpace hoverHelp' => {
        message     => q{Group to manage advertising.},
        lastUpdated => 0,
    },


    'settings groupIdAdminCache label' => {
        message     => q{Cache},
        lastUpdated => 0,
    },
    'settings groupIdAdminCache hoverHelp' => {
        message     => q{Group to view and flush cache.},
        lastUpdated => 0,
    },


    'settings groupIdAdminClipboard label' => {
        message     => q{Clipboard},
        lastUpdated => 0,
    },
    'settings groupIdAdminClipboard hoverHelp' => {
        message     => q{Group to manage the system clipboard.},
        lastUpdated => 0,
    },


    'settings groupIdAdminCron label' => {
        message     => q{Cron},
        lastUpdated => 0,
    },
    'settings groupIdAdminCron hoverHelp' => {
        message     => q{Group to manage scheduled workflows.},
        lastUpdated => 0,
    },


    'settings groupIdAdminDatabaseLink label' => {
        message     => q{Database Link},
        lastUpdated => 0,
    },
    'settings groupIdAdminDatabaseLink hoverHelp' => {
        message     => q{Group to manage database links.},
        lastUpdated => 0,
    },


    'settings groupIdAdminFriends label' => {
        message     => q{Friends},
        lastUpdated => 0,
    },
    'settings groupIdAdminFriends hoverHelp' => {
        message     => q{Group to manage friends.},
        lastUpdated => 0,
    },

    'settings groupIdAdminGraphics label' => {
        message     => q{Graphics},
        lastUpdated => 0,
    },
    'settings groupIdAdminGraphics hoverHelp' => {
        message     => q{Group to manage fonts and palettes.},
        lastUpdated => 0,
    },


    'settings groupIdAdminGroup label' => {
        message     => q{Groups},
        lastUpdated => 0,
    },
    'settings groupIdAdminGroup hoverHelp' => {
        message     => q{Group to manage all groups.},
        lastUpdated => 0,
    },

    'settings groupIdAdminFilePump label' => {
        message     => q{File Pump},
        lastUpdated => 0,
    },
    'settings groupIdAdminFilePump hoverHelp' => {
        message     => q{Group to access and manage File Pump bundles.},
        lastUpdated => 0,
    },


    'settings groupIdAdminGroupAdmin label' => {
        message     => q{Groups (limited)},
        lastUpdated => 0,
    },
    'settings groupIdAdminGroupAdmin hoverHelp' => {
        message     => q{Group to manage groups that user is administrator of.},
        lastUpdated => 0,
    },

    'settings groupIdAdminHistory label' => {
        message     => q{Asset History},
        lastUpdated => 0,
    },
    'settings groupIdAdminHistory hoverHelp' => {
        message     => q{Group allowed to access the Asset History Browser.},
        lastUpdated => 0,
    },


    'settings groupIdAdminHelp label' => {
        message     => q{Help},
        lastUpdated => 0,
    },
    'settings groupIdAdminHelp hoverHelp' => {
        message     => q{Group that can view help.},
        lastUpdated => 0,
    },


    'settings groupIdAdminLDAPLink label' => {
        message     => q{LDAP},
        lastUpdated => 0,
    },
    'settings groupIdAdminLDAPLink hoverHelp' => {
        message     => q{Group to manage LDAP links.},
        lastUpdated => 0,
    },


    'settings groupIdAdminLoginHistory label' => {
        message     => q{Login History},
        lastUpdated => 0,
    },
    'settings groupIdAdminLoginHistory hoverHelp' => {
        message     => q{Group to view login history.},
        lastUpdated => 0,
    },


    'settings groupIdAdminProfileSettings label' => {
        message     => q{User Profiling},
        lastUpdated => 0,
    },
    'settings groupIdAdminProfileSettings hoverHelp' => {
        message     => q{Group to manage user profile fields.},
        lastUpdated => 0,
    },


    'settings groupIdAdminReplacements label' => {
        message     => q{Content Filters},
        lastUpdated => 0,
    },
    'settings groupIdAdminReplacements hoverHelp' => {
        message     => q{Group to manage content filters.},
        lastUpdated => 0,
    },


    'settings groupIdAdminSpectre label' => {
        message     => q{Spectre},
        lastUpdated => 0,
    },
    'settings groupIdAdminSpectre hoverHelp' => {
        message     => q{Group to view Spectre status},
        lastUpdated => 0,
    },


    'settings groupIdAdminStatistics label' => {
        message     => q{Statistics},
        lastUpdated => 0,
    },
    'settings groupIdAdminStatistics hoverHelp' => {
        message     => q{Group to view statistics},
        lastUpdated => 0,
    },

    'settings groupIdAdminTrash label' => {
        message     => q{Trash},
        lastUpdated => 0,
    },
    'settings groupIdAdminTrash hoverHelp' => {
        message     => q{Group to manage the system trash.},
        lastUpdated => 0,
    },

    'settings groupIdAdminUser label' => {
        message     => q{Users},
        lastUpdated => 0,
    },
    'settings groupIdAdminUser hoverHelp' => {
        message     => q{Group to manage users. Can add and edit users.},
        lastUpdated => 0,
    },


    'settings groupIdAdminUserAdd label' => {
        message     => q{Users (add only)},
        lastUpdated => 0,
    },
    'settings groupIdAdminUserAdd hoverHelp' => {
        message     => q{Group that can only add new users.},
        lastUpdated => 0,
    },


    'settings groupIdAdminVersionTag label' => {
        message     => q{Version Tags},
        lastUpdated => 0,
    },
    'settings groupIdAdminVersionTag hoverHelp' => {
        message     => q{Group to manage version tags},
        lastUpdated => 0,
    },


    'settings groupIdAdminWorkflow label' => {
        message     => q{Workflow},
        lastUpdated => 0,
    },
    'settings groupIdAdminWorkflow hoverHelp' => {
        message     => q{Group to manage workflows},
        lastUpdated => 0,
    },


    'settings groupIdAdminWorkflowRun label' => {
        message     => q{Workflow (run)},
        lastUpdated => 0,
    },
    'settings groupIdAdminWorkflowRun hoverHelp' => {
        message     => q{Group that is allowed to run workflows from the admin console.},
        lastUpdated => 0,
    },

    'external help' => {
        message     => q{<p>For more help, visit the <a href="http://wiki.webgui.org/">WebGUI Community Wiki</a>.</p>},
        lastUpdated => 0,
    },

    'user profile field friend availability' => {
        message     => q{Are you available to be added as a Friend?},
        lastUpdated => 1185856549,
    },

    'account options template variables' => {
        message     => q{Account Options Template Variables},
        lastUpdated => 1193196209,
    },

    'account.options' => {
        message     => q{A loop containing options for different user account access links.},
        lastUpdated => 1193196211,
    },

    'options.display' => {
        message     => q{A full HTML link, with internationalized label, for an individual account options, such as editing a profile, viewing a profile, accessing the user's inbox, and so on.},
        lastUpdated => 1193196211,
    },

    'high user count' => {
        message     => q{<p>There are over 250 users. Please use the search to find users.</p>},
        lastUpdated => 1193196211,
    },

    'high group count' => {
        message     => q{<p>There are over 250 groups. Please use the search to find a group.</p>},
        lastUpdated => 1193196211,
    },

    'SelectRichEditor formName' => {
        message     => q{Rich Editor},
        lastUpdated => 1202274234,
    },

    'SubscriptionGroup formName' => {
        message     => q{Subscription Group},
        lastUpdated => 1202274234,
    },

    'Attachments formName' => {
        message     => q{Attachments},
        lastUpdated => 1202274234,
    },

        'redirectAfterLoginUrl label' => {
            message     => q{Redirect After Login Url},
            lastUpdated => 0,
            context     => q{Label for site setting},
        },

        'showMessageOnLogin description' => {
            message     => q{Users will be redirected to this url after logging in.},
            lastUpdated => 0,
            context     => q{Description for site setting},
        },

        'showMessageOnLogin label' => {
            message     => q{Show Message On Login?},
            lastUpdated => 0,
            context     => q{Label for site setting},
        },

        'showMessageOnLogin description' => {
            message     => q{If yes, show a message after a user logs in.},
            lastUpdated => 0,
            context     => q{Description for site setting},
        },

        'showMessageOnLoginTimes label' => {
            message     => q{Show Message Number of Times},
            lastUpdated => 0,
            context     => q{Label for site setting},
        },

        'showMessageOnLoginTimes description' => {
            message     => q{The number of times a user sees the message, one per login},
            lastUpdated => 0,
            context     => q{Description for site setting},
        },

        'showMessageOnLoginReset label' => {
            message     => q{Reset All Users Number of Times Seen},
            lastUpdated => 0,
            context     => q{Label for site setting},
        },

        'showMessageOnLoginReset description' => {
            message     => q{If "yes", will force all users to see the login message again},
            lastUpdated => 0,
            context     => q{Description for site setting},
        },

        'showMessageOnLoginBody label' => {
            message     => q{Message on Login Body},
            lastUpdated => 0,
            context     => q{Label for site setting},
        },

        'showMessageOnLoginBody description' => {
            message     => q{The body of the message to show on login. Macros are allowed.},
            lastUpdated => 0,
            context     => q{Description for site setting},
        },

    'site starter title' => {
        message     => q{Site Starter},
        lastUpdated => 0,
        context     => q{Title for the site starter screen.},
    },

    'site starter body' => {
        message     => q{Do you wish to use the WebGUI Site Starter, which will lead you through options to create a custom look and feel for your site, and set up some basic content areas?},
        lastUpdated => 0,
        context     => q{Body for the site starter screen.},
    },

    'no thanks' => {
        message     => q{No, thanks},
        lastUpdated => 0,
        context     => q{Option in site starter to not run it},
    },

    'yes please' => {
        message     => q{Yes, please},
        lastUpdated => 0,
        context     => q{Option in site starter to run the site starter},
    },

    'logo' => {
        message     => q{Logo},
        lastUpdated => 0,
        context     => q{Label for the Logo upload field in the site starter.},
    },

    'upload logo' => {
        message     => q{Upload Your Logo},
        lastUpdated => 0,
        context     => q{Title for the Logo upload screen in the site starter.},
    },

    'style designer' => {
        message     => q{Style Designer},
        lastUpdated => 0,
        context     => q{Title for the style designer screen in the site starter.},
    },

    'save' => {
        message     => q{Save},
        lastUpdated => 0,
        context     => q{General purpose, similar to submit.},
    },

    'company information' => {
        message     => q{Company Information},
        lastUpdated => 0,
        context     => q{Title for the company information screen in the site starter.},
    },

    'admin account' => {
        message     => q{Admin Account},
        lastUpdated => 0,
        context     => q{Title for the company information screen in the site starter.},
    },

    'All Rights Reserved' => {
        message     => q{All Rights Reserved},
        lastUpdated => 0,
        context     => q{Template label for automatically created Page layouts during Site Setup.},
    },

    'Contact Us' => {
        message     => q{All Contact Us},
        lastUpdated => 0,
        context     => q{Template label for automatically created Page layouts during Site Setup.},
    },

    'Initial Pages' => {
        message     => q{Initial Pages},
        lastUpdated => 0,
        context     => q{Header for the Site Setup screen},
    },

    'Forums' => {
        message     => q{Initial Pages},
        lastUpdated => 0,
        context     => q{Label for the Site Setup screen},
    },

    'About Us' => {
        message     => q{About Us},
        lastUpdated => 0,
        context     => q{Label for the Site Setup screen},
    },

    'Put your about us content here.' => {
        message     => q{Put your about us content here.},
        lastUpdated => 0,
        context     => q{Default content for the Site Setup screen},
    },

    'One forum name per line' => {
        message     => q{One forum name per line},
        lastUpdated => 0,
        context     => q{Instructions for the names of forums in the Site Setup screen},
    },

    'Support' => {
        message     => q{Support},
        lastUpdated => 0,
        context     => q{Default name of a forum in the Site Setup screen},
    },

    'General Discussion' => {
        message     => q{General Discussion},
        lastUpdated => 0,
        context     => q{Default name of a forum in the Site Setup screen},
    },

    'Discuss your ideas and get help from our community.' => {
        message     => q{Discuss your ideas and get help from our community.},
        lastUpdated => 0,
        context     => q{Default description of a message board in the Site Setup screen},
    },

    'All the news you need to know.' => {
        message     => q{All the news you need to know.},
        lastUpdated => 0,
        context     => q{Default description of a message board in the Site Setup screen},
    },

    'Welcome to our wiki. Here you can help us keep information up to date.' => {
        message     => q{Welcome to our wiki. Here you can help us keep information up to date.},
        lastUpdated => 0,
        context     => q{Default description of a wiki in the Site Setup screen},
    },

    'Check out what is going on.' => {
        message     => q{Check out what is going on.},
        lastUpdated => 0,
        context     => q{Default description of a calendar in the Site Setup screen},
    },

    'Your Email Address' => {
        message     => q{Your Email Address},
        lastUpdated => 0,
        context     => q{Default description of a calendar in the Site Setup screen},
    },

    'Tell us how we can assist you.' => {
        message     => q{Tell us how we can assist you.},
        lastUpdated => 0,
        context     => q{Subtext for the comments field in the Contact Us page of the Site Setup screen},
    },

    'We welcome your feedback.' => {
        message     => q{We welcome your feedback.},
        lastUpdated => 0,
        context     => q{Default description of the Contact Us page of the Site Setup screen},
    },

    'Thanks for for your interest in ^c;. We will review your message shortly.' => {
        message     => q{Thanks for for your interest in ^c;. We will review your message shortly.},
        lastUpdated => 0,
        context     => q{Default acknowledgement of the Contact Us page of the Site Setup screen},
    },

    'Cannot find what you are looking for? Try our search.' => {
        message     => q{Cannot find what you are looking for? Try our search.},
        lastUpdated => 0,
        context     => q{Default description of the Search page of the Site Setup screen},
    },

    'WebGUI Initial Configuration' => {
        message     => q{WebGUI Initial Configuration},
        lastUpdated => 0,
        context     => q{Main page title for the Site Setup screen},
    },

    'My Style' => {
        message     => q{My Style},
        lastUpdated => 0,
        context     => q{Title of the template created by the Site Setup screen},
    },

    'WebGUI password recovery' => {
        message     => q{Password recovery},
        lastUpdated => 0,
        context     => q{Subject of the email that is sent for password recovery},
    },

    'session length' => {
        message     => q{Session Length},
        lastUpdated => 0,
        context     => q{The length the session has been alive},
    },

    "time recorded" => {
        message     => q{Time Recorded (excludes active sessions)},
        lastUpdated => 0,
        context     => q{Column heading for the total logged in time for the user},
    },

    'Show when online?' => {
        message     => q{Show when online?},
        lastUpdated => 0,
        context     => q{Label for the user profile field used by the UsersOnline macro},
    },

        #Support for versionTagMode.
        'version tag mode' => {
            message => q{Version tag mode},
            lastUpdated => 0,
            context     => q{Label for the settings screen},
        },

        'version tag mode help' => {
            message => q{Determine version tag behaviour.
<ul>
<li>Multiple version tags per user: each user can have multiple open version tags.</li>
<li>Single version tag per user: each user only has one open version tag. Existing open version tag is reclaimed automatically.</li>
<li>One site-wide version tag: users work on one site-wide version tag.</li>
<li>Commit automatically: version tags are committed automatically.</li>
</ul>

Users may override this setting in their profile.
},
            lastUpdated => 0,
            context     => q{Hover help for the settings screen},
        },

        'versionTagMode multiPerUser' => {
            message => q{Multiple version tags per user},
            lastUpdated => 0,
            context     => q{Entry for version tag settings},
        },

        'versionTagMode singlePerUser' => {
            message => q{Single version tag per user},
            lastUpdated => 0,
            context     => q{Entry for version tag settings},
        },

        'versionTagMode siteWide' => {
            message => q{One site-wide version tag},
            lastUpdated => 0,
            context     => q{Entry for version tag settings},
        },

        'versionTagMode autoCommit' => {
            message => q{Commit automatically},
            lastUpdated => 0,
            context     => q{Entry for version tag settings},
        },

        'versionTagMode inherited' => {
            message => q{Inherit from site settings},
            lastUpdated => 0,
            context     => q{Entry for version tag settings},
        },

        '< prev' => {
            message => q{< prev},
            lastUpdated => 1226704984,
            context     => q{i18n label for YUI paginator},
        },

        'next >' => {
            message => q{next >},
            lastUpdated => 1226704984,
            context     => q{i18n label for YUI paginator},
        },

        'profile privacy settings' =>  {
            message     => q{Privacy Settings},
            lastUpdated => 1226706547,
            context     => q{i18n label for time duration in WebGUI::DateTime},
        },

        'read more' => {
            message => q|Read More|,
            lastUpdated => 1229013268,
            context => q|Template label.  Used to indicate that a shortened version of the content is currently displayed and that more can be read by clicking a link.|
        },

        'For' => {
            message => q|For|,
            lastUpdated => 1230269893,
        },

        'rss' => {
            message => q|RSS|,
            lastUpdated => 1230584702,
            context => q|Abbreviation for Really Simple Syndication, and other similar terms.|,
        },

        'Upload an attachment' => {
            message => q|Upload an attachment|,
            context => q|Label in the Attachments form control.|,
            lastUpdated => 1230930518,
        },

        'Upload attachments here. Copy and paste attachments into the editor.' => {
            message => q|Upload attachments here. Copy and paste attachments into the editor.|,
            context => q|Label in the Attachments form control.|,
            lastUpdated => 1230930518,
        },

        'use recaptcha' => {
            message     => q{Use reCAPTCHA?},
            lastUpdated => 0,
        },
        'use recaptcha description' => {
            message     => q{reCAPTCHA is a free CAPTCHA service that helps to digitize books.  It requires a key set generated for your domain, available from <a href="http://recaptcha.net/">http://recaptcha.net/</a>.},
            lastUpdated => 0,
        },

        'recaptcha private key' => {
            message     => 'reCAPTCHA Private Key',
            lastUpdated => 0,
        },
        'recaptcha public key' => {
            message     => 'reCAPTCHA Public Key',
            lastUpdated => 0,
        },

	'Ad Space control name' => {
		message => q|Ad Space|,
		lastUpdated => 0,
		context => q|name for the Ad Space control|
	},

    'global head tags label' => {
        message     => 'Global Head Tags',
        lastUpdated => 0,
        context     => "Label for setting",
    },
    'global head tags description' => { 
        message     => '<head> tags for every page on the site (including admin pages)',
        lastUpdated => 0,
        context     => 'Description of setting',
    },

 	'sms gateway' => {
 		message => q|SMS Gateway|,
 		context => q|email to SMS/text email address for this site.|,
 		lastUpdated => 1235685248,
 	},

 	'sms gateway help' => {
 		message => q|The email address that this site would use to send an SMS message.|,
 		lastUpdated => 1235695517,
 	},
 	
 	'sms gateway subject' => {
 		message => q|SMS Gateway Subject|,
 		context => q|Subject to use for the SMS Gateway for this site.|,
 		lastUpdated => 0,
 	},

 	'sms gateway subject help' => {
 		message => q|The email subject to pass to the SMS Gateway (typically used for SMS Gateway authorization).|,
 		lastUpdated => 0,
 	},
 
    'Select One' => {
        message => q|Select One|,
        context => q|Label in dropdown lists, indicating that the user should use the list to select 1 entry.  It is implied that if nothing is chosen, that nothing will happen.|,
        lastUpdated => 1239057119,
    },

    'mobile style label' => {
        message => 'Use Mobile Style',
    },
    'mobile style description' => {
        message => q{Enables displaying using a mobile style template and mobile page layout template.  When enabled, the alternate templates are used when the browser's user agent string matches the list set in the config file.},
    },

    'receive inbox emails' => {
        message => q|Receive inbox notifications as email?|,
        context => q|Label in profile field|,
        lastUpdated => 1242438242,
    },

    'receive inbox sms' => {
        message => q|Receive inbox notifications as SMS?|,
        context => q|Label in profile field|,
        lastUpdated => 1242438244,
    },

    'activate user' => {
        message => 'Activate User',
        lastUpdated => 0,
    },

    'deactivate user' => {
        message => 'Deactivate User',
        lastUpdated => 0,
    },

    'delete user' => {
        message => 'Delete User',
        lastUpdated => 0,
    },

    'Working...' => {
        message => 'Working...',
        lastUpdated => 0,
    },

    'csrfToken' => {
        message => 'CSRF Token',
        lastUpdated => 0,
        context => 'CSRF = Cross Site Request Forgery, token is a piece of identification',
    },

    'Clear' => {
        message => 'Clear',
        lastUpdated => 0,
        context => 'To empty or wipe-out, similar to erase.',
    },

    'Comments' => {
        message => 'Comments',
        lastUpdated => 0,
    },

    'timezone help' => {
        message => 'Set up the default time zone for the site.',
        lastUpdated => 0,
    },

    'Maximum cache timeout' => {
        message => 'Maximum cache timeout',
        lastUpdated => 0,
    },

    'Maximum cache timeout description' => {
        message => 'This timeout will override the content check that is done before generating a page.  It can help with caching problems for macros and Navigations.  Setting it to 0 will disable the timeout.  A setting of several hours is recommended.',
        lastUpdated => 0,
    },

    'Loading...' => {
        message => 'Loading...',
        lastUpdated => 0,
        context => 'Message shown to the user when data is being loaded, typically via AJAX, like in the Survey.'
    },

};

1;
