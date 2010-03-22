package WebGUI::i18n::English::AuthWebGUI;
use strict;

our $I18N = {
	'token already used' => {
		message => q|This password recovery authentication token has already been used.|,
		lastUpdated => 0
    },
	'no registration hack' => {
		message => q|complete anonymous registration by calling createAccountSave directly from the URL.|,
		lastUpdated => 1078852836
	
	},

	'account template' => {
		message => q|Account Template|,
		lastUpdated => 1078852836
	},

	'account template help' => {
		message => q|Choose a template to style the screen that displays the user's account to them.|,
		lastUpdated => 1227210576
	},

	'create account template' => {
		message => q|Create Account Template|,
		lastUpdated => 1078852836
	},

	'create account template help' => {
		message => q|Select a template to display the screen where the user creates a user account for this site.|,
		lastUpdated => 1078852836,
	},

	'deactivate account template' => {
		message => q|Deactivate Account Template|,
		lastUpdated => 1269277147,
	},

	'deactivate account template help' => {
		message => q|Select a template to display the screen where the user deactivates their account.|,
		lastUpdated => 1269277148,
	},

	'expired password template' => {
		message => q|Expired Password Template|,
		lastUpdated => 1078852836
	},

	'expired password template help' => {
		message => q|Select a template to display the screen where the user enters a new password after their old one has expired.|,
		lastUpdated => 1227210712,
	},

	'login template' => {
		message => q|Login Template|,
		lastUpdated => 1078852836
	},

	'login template help' => {
		message => q|Select a template to display the screen where the user can log in.  This is different from any of the Macros that also display login forms to the user.|,
		lastUpdated => 1227210754,
	},

	'password recovery template' => {
		message => q|Password Recovery Template|,
		lastUpdated => 1078852836
	},

	'password recovery template help' => {
		message => q|Select a template to display the screen where the user can recover a lost password.|,
		lastUpdated => 1227210876,
	},

    'account activation template title' => {
        message => q|WebGUI Authentication Account Activation Mail Template|,
        lastUpdated => 1230600500,
        context => q|The title of the help page for the webgui auth account activition mail template.|,
    },

    'account deactivate account template title' => {
        message => q|WebGUI Authentication Deactivate Account Template|,
        lastUpdated => 1269279365,
        context => q|The title of the help page for the webgui auth account activition mail template.|,
    },

    'account activation template' => {
        message => q|Account Activation Mail Template|,
        lastUpdated => 1230600500,
        context => q|The label for the 'account activation template' field on the Authentication tab of the Settings screen.|,
    },

    'account activation template help' => {
        message => q|Select a template for the account activation mail that is sent to new users.|,
        lastUpdated => 1230600500,
        context => q|The description of the 'account activation template' field on the Authentication tab of the Settings screen, displayed as hoverhelp.|,
    },

    'activationUrl' => {
        message => q|The url to activate the newly created account.|,
        lastUpdated => 1230600500,
    },

    'welcome message template title' => {
        message => q|WebGUI Authentication Welcome Message Template|,
        lastUpdated => 0,
        context => q|The title of the help page for the webgui auth welcome message template.|,
    },

    'welcome message template' => {
        message => q|Welcome Message Template|,
        lastUpdated => 0,
        context => q|The label for the 'welcome message template' field on the Authentication tab of the Settings
screen.|,
    },

    'welcome message template help' => {
        message => q|Select a template for the welcome message that is sent to new users.|,
        lastUpdated => 0,
        context => q|The description of the 'welcome message template' field on the Authentication tab of the
Settings screen, displayed as hoverhelp.|,
    },

    'welcomeMessage' => {
        message => q|The welcome message as defined in the authentication settings.|,
        lastUpdated => 0,
        context => q|Description of the welcomeMessage tmpl_var for the template help.|,
    },

	'use captcha' => {
		message => q|Use captcha image?|,
		lastUpdated => 1078852836
	},

	'use captcha help' => {
		message => q|If set to yes, the user will be required to enter in text from a captcha as part of making an account.|,
		lastUpdated => 1078852836
	},

	'validate email' => {
		message => q|Validate email addresses?|,
		lastUpdated => 1078852836
	},

	'validate email help' => {
		message => q|Should WebGUI send an email to this person, independently of the welcome message, with a link to start their account?  Their account will not be activated until the link is visited, and unvalidated accounts will expire after a configurable timeout.  This timeout is set in a workflow.|,
		lastUpdated => 1078852836
	},

	'captcha label' => {
		message => q|Verify Your Humanity|,
		lastUpdated => 1078852836
	},

	'captcha failure' => {
		message => q|You need to type in the six characters you see in the image to prove that you are human.|,
		lastUpdated => 1078852836
	},

	'email address validation email subject' => {
		message => q|Account Activation|,
		lastUpdated => 1078852836
	},

	'email address validation email body' => {
		message => q|Welcome to our site. Please click on the link below to activate your account.|,
		lastUpdated => 1078852836
	},

	'check email for validation' => {
		message => q|Please check your email to activate your account.|,
		lastUpdated => 1078852836
	},

	'email validation confirmed' => {
		message => q|Thank you for activating your account.  You may now log in with your username and password.|,
		context => q|Message displayed to the user after they validate their email address.|,
		lastUpdated => 1230588145,
	},

	'display account template title' => {
		message => q|WebGUI Authentication Display Account Template|,
		lastUpdated => 1078852836
	},

	'display account template title' => {
		message => q|WebGUI Authentication Display Account Template|,
		lastUpdated => 1078852836
	},

	'11' => {
		message => q|New Password|,
		lastUpdated => 1071507924
	},

	'21' => {
		message => q|Allow User to Change Username?|,
		lastUpdated => 1076358688
	},

	'7' => {
		message => q|Passwords must have a minimum character length of|,
		lastUpdated => 1071507767
	},

	'17' => {
		message => q|Password Updated|,
		lastUpdated => 1071885563
	},

	'2' => {
		message => q|Password (confirm)|,
		lastUpdated => 1071507729
	},

	'anon reg template title' => {
		message => q|WebGUI Authentication Anonymous Registration Template|,
		lastUpdated => 1078856626
	},

	'22' => {
		message => q|There are no fields to update.|,
		lastUpdated => 1076361800
	},

	'1' => {
		message => q|WebGUI Authentication Options|,
		lastUpdated => 1071507721
	},

	'recoverFormUsername' => {
		message => q|Username form field for password recovery.|,
		lastUpdated => 1165440841,
	},

	'recoverFormUsernameLabel' => {
		message => q|Label for the username form field for password recovery.|,
		lastUpdated => 1165440841,
	},

	'title' => {
		message => q|Default page title.|,
		lastUpdated => 1164335682,
	},

	'subtitle' => {
		message => q|Special instructions for the form.  May not be defined in all types of password recovery templates.|,
		lastUpdated => 1227216717,
	},

	'login.message' => {
		message => q|Any message returned by the system.  Usually displays after the form is submitted.|,
		lastUpdated => 1149220294,
	},

	'anonymousRegistration.isAllowed' => {
		message => q|Flag indicating whether or not anonymous registrations are allowed.|,
		lastUpdated => 1149220294,
	},

	'createAccount.url' => {
		message => q|URL for the anonymous registration page|,
		lastUpdated => 1149220294,
	},

	'createAccount.label' => {
		message => q|Default label for the anonymous registration link.|,
		lastUpdated => 1149220294,
	},

	'recoverPassword.isAllowed' => {
		message => q|Flag indicating whether or not password recovery is enabled|,
		lastUpdated => 1149220294,
	},

	'recoverPassword.url' => {
		message => q|URL for the password recovery page.|,
		lastUpdated => 1149220294,
	},

	'recoverPassword.label' => {
		message => q|Default label for the password recovery link|,
		lastUpdated => 1149220294,
	},

	'18' => {
		message => q|Allow Users to Change Passwords?|,
		lastUpdated => 1076357595
	},

	'18 help' => {
		message => q|Are users allowed to change their own passwords?  Note, using this in conjunction with password timeouts can cause a lot of Admin work.|,
		lastUpdated => 1076357595,
	},

	'expired.form.header' => {
		message => q|The required form elements that go at the top of the password expiration page.|,
		lastUpdated => 1149220347,
	},

	'expired.form.hidden' => {
		message => q|Hidden form fields required for form submittal.|,
		lastUpdated => 1149220347,
	},

	'expired.form.footer' => {
		message => q|The required form elements that go after the password expiration page form. |,
		lastUpdated => 1149220347,
	},

	'expired.form.submit' => {
		message => q|The default submit button for the password expiration form.|,
		lastUpdated => 1149220347,
	},

	'displayTitle' => {
		message => q|Default page title.|,
		lastUpdated => 1149220347,
	},

	'expired.message' => {
		message => q|Any message returned by the system.  Usually displays after the form is submitted.|,
		lastUpdated => 1149220347,
	},

	'create.form.oldPassword' => {
		message => q|Default old password form field.|,
		lastUpdated => 1149220347,
	},

	'create.form.oldPassword.label' => {
		message => q|Default text for old password form field.|,
		lastUpdated => 1149220347,
	},

	'expired.form.password' => {
		message => q|Default password form field.|,
		lastUpdated => 1149220347,
	},

	'expired.form.password.label' => {
		message => q|Default text for password form field.|,
		lastUpdated => 1149220347,
	},

	'expired.form.passwordConfirm' => {
		message => q|Default password confirm form field.|,
		lastUpdated => 1149220347,
	},

	'expired.form.passwordConfirm.label' => {
		message => q|Default text for password confirm form field|,
		lastUpdated => 1149220347,
	},

	'16' => {
		message => q|Password Timeout|,
		lastUpdated => 1071885309
	},

	'16 help' => {
		message => q|The password timeout sets how long a password is good for.  After the timeout, the user will be required to enter in a new password.|,
		lastUpdated => 1227208974
	},

	'6' => {
		message => q|Allow Password Recovery?|,
		lastUpdated => 1071507760
	},

	'webguiPasswordRecovery hoverHelp' => {
		message => q|Select "Profile field" to permit users who know a particular combination of their profile fields to recover their passwords.  In order for this to take effect, at least one profile field must have its "Required for password recovery?" flag turned on.  It is highly advisable to pick several fields, as using only one field is usually very easy to break; remember that anyone who discovers all of those fields for a user can reset that user's password.  Select "Email" to permit users to have an email sent to them with a link that will let them reset their password.|,
		lastUpdated => 1187205604
	},

	'webguiPasswordRecoveryRequireUsername hoverHelp' => {
		message => q|Select "Yes" if you want users to also have to enter their username for password recovery.  Otherwise, they will be able to reset their password and log themselves in by knowing only the other profile fields that are enabled for password recovery, even if they have forgotten their username.|,
		lastUpdated => 1071507760
	},

	'recovery template title' => {
		message => q|WebGUI Authentication Password Recovery Template|,
		lastUpdated => 1078856556
	},

	'3' => {
		message => q|Your passwords did not match. Please try again.|,
		lastUpdated => 1071507737
	},

	'9' => {
		message => q|Expire passwords on user creation?|,
		lastUpdated => 1071507780
	},

	'9 help' => {
		message => q|This will immediately expire a user's password when their account is created.|,
		lastUpdated => 1227209117
	},

	'12' => {
		message => q|You may not use your old password as your new password|,
		lastUpdated => 1071507932
	},

	'recover.form.header' => {
		message => q|The required form elements that go at the top of the password recovery page.|,
		lastUpdated => 1149220395,
	},

	'recover.form.hidden' => {
		message => q|Hidden form fields required for form submission.|,
		lastUpdated => 1149220395,
	},

	'recover.form.footer' => {
		message => q|The required form elements that go after the password recovery page form.|,
		lastUpdated => 1149220395,
	},

	'recover.form.submit' => {
		message => q|The default submit button for the password recovery form. |,
		lastUpdated => 1149220395,
	},

	'login.form.email' => {
		message => q|Default email form field.|,
		lastUpdated => 1149220395,
	},

	'login.form.email.label' => {
		message => q|Default text for email form field|,
		lastUpdated => 1149220395,
	},

	'recover.message' => {
		message => q|Any message returned by the system.  Usually displays after the form is submitted.|,
		lastUpdated => 1149220395,
	},

	'login.url' => {
		message => q|URL for the login page.|,
		lastUpdated => 1149220395,
	},

	'login.label' => {
		message => q|Default text label for login page link.|,
		lastUpdated => 1149220395,
	},

	'recoverFormProfile' => {
		message => q|Loop over profile fields necessary for password recovery.|,
		lastUpdated => 1165440841,
	},

	'recoverFormProfile id' => {
		message => q|The ID of the profile field.|,
		lastUpdated => 1165440841,
	},

	'recoverFormProfile formElement' => {
		message => q|A form element for the profile field.|,
		lastUpdated => 1165440841,
	},

	'recoverFormProfile label' => {
		message => q|The label for the profile field.|,
		lastUpdated => 1165440841,
	},

	'20' => {
		message => q|Allow User to Change Password?|,
		lastUpdated => 1076358606
	},

	'14' => {
		message => q|Minimum password length|,
		lastUpdated => 1071507951
	},

	'15' => {
		message => q|Minimum Password Length|,
		lastUpdated => 1071885112
	},

	'15 help' => {
		message => q|The minimum length of passwords that users are required to use, in characters.|,
		lastUpdated => 1227208578
	},

	'8' => {
		message => q|Your Password Has Expired|,
		lastUpdated => 1071507773
	},

	'4' => {
		message => q|Your password cannot be blank.|,
		lastUpdated => 1071507744
	},

	'expired template title' => {
		message => q|WebGUI Authentication Password Expiration Template|,
		lastUpdated => 1078857230
	},

	'account.message' => {
		message => q|Any message returned by the system.  Usually displays after the form is submitted.|,
		lastUpdated => 1149220575,
	},

	'account.form.username' => {
		message => q|Default username form field.|,
		lastUpdated => 1149220575,
	},

	'account.form.username.label' => {
		message => q|Default text for username form field.|,
		lastUpdated => 1149220575,
	},

	'account.form.password' => {
		message => q|Default password form field.|,
		lastUpdated => 1149220575,
	},

	'account.form.password.label' => {
		message => q|Default text for password form field.|,
		lastUpdated => 1149220575,
	},

	'account.form.passwordConfirm' => {
		message => q|Default password confirm form field.|,
		lastUpdated => 1149220575,
	},

	'account.form.passwordConfirm.label' => {
		message => q|Default text for password confirm form field.|,
		lastUpdated => 1149220575,
	},

	'account.noform' => {
		message => q|Indicates whether or not the display account form has any visible fields.|,
		lastUpdated => 1149220575,
	},

	'account.nofields' => {
		message => q|Default display in the case that there are no form elements to display.|,
		lastUpdated => 1149220575,
	},

	'create.form.hidden' => {
		message => q|Hidden form fields required for form submittal.|,
		lastUpdated => 1149220721,
	},

	'create.message' => {
		message => q|Any message returned by the system.  Usually displays after the form is submitted.|,
		lastUpdated => 1149220721,
	},

	'create.form.username' => {
		message => q|Default username form field.|,
		lastUpdated => 1149220721,
	},

	'create.form.username.label' => {
		message => q|Default text for username form field.|,
		lastUpdated => 1149220721,
	},

	'create.form.password' => {
		message => q|Default password form field.|,
		lastUpdated => 1149220721,
	},

	'create.form.password.label' => {
		message => q|Default text for password form field.|,
		lastUpdated => 1149220721,
	},

	'create.form.passwordConfirm' => {
		message => q|Default password confirm form field.|,
		lastUpdated => 1149220721,
	},

	'create.form.passwordConfirm.label' => {
		message => q|Default text for password confirm form field.|,
		lastUpdated => 1149220721,
	},

	'19' => {
		message => q|Allow Users to Change Username?|,
		lastUpdated => 1076358029
	},

	'19 help' => {
		message => q|Are users allowed to change their username after creating their account?|,
		lastUpdated => 1227209885,
	},

	'10' => {
		message => q|Old Password|,
		lastUpdated => 1071507875
	},

	'login template title' => {
		message => q|WebGUI Authentication Login Template|,
		lastUpdated => 1078854830
	},

	'5' => {
		message => q|Your password cannot be "password".|,
		lastUpdated => 1071507752
	},

	'deactivate account template title' => {
		message => q|WebGUI Authentication Deactivate Account Template|,
		lastUpdated => 1164394401
	},

	'topicName' => {
		message => q|WebGUI Authentication|,
		lastUpdated => 1128919828,
	},

	'require username for password recovery' => {
		message => q|Require Username for Password Recovery?|,
		lastUpdated => 1165402566,
	},

	'password recovery no results' => {
		message => q|No users were found matching that profile data.  Please try again.|,
		lastUpdated => 1165402566,
	},

	'password recovery no username' => {
		message => q|Password recovery requires a username.|,
		lastUpdated => 1166244701,
	},

	'password recovery multiple results' => {
		message => q|Sorry, password recovery cannot be performed for this account.  Please contact an administrator.|,
		lastUpdated => 1165402566,
	},
	
    'error password requiredDigits' => {
        message         => q{Password must contain at least %s numeric characters.},
        lastUpdated     => 0,
    },

    'error password nonWordCharacters' => {
        message         => q{Password must contain at least %s non-word characters (such as '!', '@', or '$').},
        lastUpdated     => 0,
    },

    'error password requiredMixedCase' => {
        message         => q{Password must contain at least %s upper case characters and at least 
                             one lowercase character (mixed case)."},
        lastUpdated     => 0,
    },

    'setting webguiRequiredDigits' => {
        message         => q{Number of digits required in password},
        lastUpdated     => 0,
    },

    'setting webguiRequiredDigits help' => {
        message         => q{How many digits/numbers are required to be in the user's password?},
        lastUpdated     => 0,
    },

    'setting webguiNonWordCharacters' => {
        message         => q{Number of non-word characters required in password},
        lastUpdated     => 0,
    },

    'setting webguiNonWordCharacters help' => {
        message         => q{The number of non-word characters, such as punctuation, are required to be in the user's password.},
        lastUpdated     => 0,
    },

    'setting webguiRequiredMixedCase' => {
        message         => q{Number of upper-case characters required in password},
        lastUpdated     => 0,
    },

    'setting webguiRequiredMixedCase help' => {
        message         => q{This setting will require that the user have upper-case characters in their password.  It will not require that they have lower-case characters},
        lastUpdated     => 0,
    },

	'password recovery email label' => {
		message => q|Email Address|,
		lastUpdated => 1177127324,
	},

	'password recovery email hoverHelp' => {
		message => q|Enter your email address here|,
		lastUpdated => 1177127324,
	},
	
	'password recovery login label' => {
		message => q|Login Name|,
		lastUpdated => 1177127324,
	},

	'password recovery login hoverHelp' => {
		message => q|Enter your username here|,
		lastUpdated => 1177127324,
	},

	'new password label' => {
		message => q|New Password|,
		lastUpdated => 1177127324,
	},

	'new password help' => {
		message => q|Enter your new password here|,
		lastUpdated => 1177127324,
	},

	'new password verify' => {
		message => q|Verify New Password|,
		lastUpdated => 1177127324,
	},

	'new password verify help' => {
		message => q|Enter your password again to verify|,
		lastUpdated => 177127324,
	},

	'recover password not found' => {
		message => q|We have no record of a user matching the information you have given|,
		lastUpdated => 177127324,
	},

	'recover password email text1' => {
		message => q|We have received your request to change the password for |,
		lastUpdated => 1189780432,
	},
	
	'recover password email text2' => {
		message => q|Please use the link below to visit the site and change your password.|,
		lastUpdated => 1189780432,
	},

	'recover password email text3' => {
		message => q|If you did not request your password to be recovered, please contact the system administrator.|,
		lastUpdated => 177127324,
	},

	'recover password banner' => {
		message => q|Password Recovery|,
		lastUpdated => 177127324,
	},

	'email recover password finish message' => {
		message => q|An email has been sent with instructions for resetting your password.|,
		lastUpdated => 1223309904,
	},

	'email recover password start message' => {
		message => q|Enter either your email address or your login below to initiate the password recovery process.|,
		lastUpdated => 177127324,
	},

	'email password recovery end message' => {
		message => q|Enter a new password for your account below.|,
		lastUpdated => 177127324,
	},

    'setting passwordRecoveryType profile' => {
        message     => "Profile field",
        lastUpdated => 0,
    },

    'setting passwordRecoveryType email' => {
        message     => "E-mail address",
        lastUpdated => 0,
    },

    'setting passwordRecoveryType none' => {
        message     => "No",
        lastUpdated => 0,
    },

    'error passwordRecoveryType no profile fields required' => {
        message     => q{Cannot enable WebGUI authentication password recovery 
                        by profile field: There are no user profile fields required for password recovery.},
        lastUpdated => 0,
    },

    'password recovery disabled' => {
        message     => q{Your account has been disabled. You cannot recover your password until it is activated.},
        lastUpdated => 0,
        context     => q{Error message when a user tries to recover password for a disabled account},
    },

    'no email address' => {
        message     => q{There is no email address registered for this account.  Password recovery via email is not possible.},
        lastUpdated => 1229391388,
        context     => q{Error message when a user tries to recover password and they don't have an email address},
    },

    'newUser_username' => {
        message     => 'Username of registering user',
    },

    'newUser_password' => {
        message => q|The password for the newly created account.|,
        lastUpdated => 0,
        context => q|Description of the newUser_password tmpl_var for the template help.|,
    },

    'use email as username label' => {
        message     => 'Use Email Address as Username',
        lastUpdated => 0,
        context => q|Label of the webguiUseEmailAsUsername field on the Auth tab of the Edit Settings screen.|,
    },

    'use email as username description' => {
        message     => 'When this is set to Yes, the registration screen will not show a username field. Instead the submitted email address will automatically be used as username.',
        lastUpdated => 0,
        context => q|Description of the webguiUseEmailAsUsername field, used as hoverhelp on the Auth tab of the Edit Settings screen.|,
    },
};

1;
