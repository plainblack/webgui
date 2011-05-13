package WebGUI::i18n::English::Asset_Template;
use strict;

our $I18N = {
	'style wizard' => {
		message => q|Style Wizard|,
		context => q|Label for link to engage the style wizard.|,
		lastUpdated => 0,
	},

	'namespace' => {
		message => q|Namespace|,
		context => q|label for Template Add/Edit Form|,
		lastUpdated => 1107391021,
	},

	'show in forms' => {
		message => q|Show in Forms?|,
		context => q|label for Template Add/Edit Form|,
		lastUpdated => 1107391135,
	},

	'assetName' => {
		message => q|Template|,
		context => q|label for Template Add/Edit Form|,
		lastUpdated => 1128830570,
	},

	'edit template' => {
		message => q|Edit Template|,
		context => q|label for Template AdminConsole form|,
		lastUpdated => 1107391263,
	},

	'template error' => {
		message => q|There is a syntax error in this template, %s, %s, %s. Please correct.|,
		context => q|Error when executing template|,
		lastUpdated => 1254512327,
	},

        'namespace description' => {
                message => q|What type of template is this?|,
                lastUpdated => 1146455494,
        },

        'show in forms description' => {
                message => q|Should this template be shown in the list of templates from this namespace?|,
                lastUpdated => 1167193231,
        },

        'template description' => {
                message => q|Create your template by using template commands and variables, macros, and HTML.|,
                lastUpdated => 1146455505,
        },

        'parser' => {
                message => q|Template Type|,
                lastUpdated => 1119979645,
        },

        'parser description' => {
                message => q|If your configuration file lists multiple template engines, then select which type of template this is so that WebGUI can send it to the correct one.|,
                lastUpdated => 1146455514,
        },

	'template variable title' => {
		message => q|Template Variables|,
		lastUpdated => 1130972019,
	},

	'webgui.version' => {
		message => q|The version of WebGUI on your site.|,
		lastUpdated => 1148951191,
	},

	'webgui.status' => {
		message => q|The release status for this version of WebGUI (stable, beta, gamma, etc.)|,
		lastUpdated => 1165365906,
	},

	'session.user.username' => {
		message => q|The current user's username.|,
		lastUpdated => 1148951191,
	},

	'session.user.firstDayOfWeek' => {
		message => q|From the current user's profile, the day they selected to be the first day of the week.|,
		lastUpdated => 1148951191,
	},

	'session.config.extrasurl' => {
		message => q|From the WebGUI config, the URL for the extras directory.|,
		lastUpdated => 1148951191,
	},

	'session.var.adminOn' => {
		message => q|This variable will be true if the user is in Admin mode.|,
		lastUpdated => 1148951191,
	},

	'session.setting.companyName' => {
		message => q|From the WebGUI settings, the company name.|,
		lastUpdated => 1148951191,
	},

	'session.setting.anonymousRegistration' => {
		message => q|From the WebGUI settings, whether or not anonymous registration has been enabled.|,
		lastUpdated => 1148951191,
	},

	'session form variables' => {
		message => q|<b>Session Form Variables</b><br />
Any form variables will be available in the template with this syntax:<br/>
&lt;tmpl_var session.form.<i>variable</i>&gt;<br />
If there is more than 1 value in a form variable, only the last will be returned.|,
		lastUpdated => 1148951191,
	},

	'session scratch variables' => {
		message => q|<b>Session Scratch Variables</b><br />
Any scratch variables will be available in the template with this syntax:<br/>
&lt;tmpl_var session.scratch.<i>variable</i>&gt;<br />
|,
		lastUpdated => 1165343240,
	},

	'site name' => {
		message => q|Site Name|,
		lastUpdated => 1146244474,
		context => q|Label for the field to enter in the name of a web site in the Style Wizard|,
	},

	'site name description' => {
		message => q|The name of your website|,
		lastUpdated => 1146244474,
	},

	'heading' => {
		message => q|Heading|,
		lastUpdated => 1146244520,
		context => q|Label for the top part of a page|,
	},

	'menu' => {
		message => q|Menu|,
		lastUpdated => 1146244520,
		context => q|Label for part of a page where a navigation menu will be displayed.|,
	},

	'body content' => {
		message => q|Body content goes here.|,
		lastUpdated => 1146244520,
		context => q|Label for the part of a page that holds the content.|,
	},

	'logo' => {
		message => q|Logo|,
		lastUpdated => 1146244520,
		context => q|Label for the field to upload a graphical logo in the Style Wizard|,
	},

	'logo description' => {
		message => q|You can use this field to upload a graphical logo in your style.  The logo should be less than 200 pixels wide and 100 pixels tall.|,
		lastUpdated => 1146244520,
	},

	'logo subtext' => {
		message => q|<br />The logo should be less than 200 pixels wide and 100 pixels tall.|,
		context => q|subtext for the field to upload a graphical logo in the Style Wizard|,
		lastUpdated => 1146244520,
	},

	'page background color' => {
		message => q|Page Background Color|,
		lastUpdated => 1146244520,
	},

	'page background color description' => {
		message => q|The background color for the entire page.|,
		lastUpdated => 1146244520,
	},

	'header background color' => {
		message => q|Header Background Color|,
		lastUpdated => 1146244520,
	},

	'header background color description' => {
		message => q|The background color for the header or banner part of the page.|,
		lastUpdated => 1146244520,
	},

	'header text color' => {
		message => q|Header Text Color|,
		lastUpdated => 1146244520,
	},

	'header text color description' => {
		message => q|Color for text in the header.|,
		lastUpdated => 1146244520,
	},

	'body background color' => {
		message => q|Body Background Color|,
		lastUpdated => 1146244520,
	},

	'body background color description' => {
		message => q|The background color for the body of the page.|,
		lastUpdated => 1146244520,
	},

	'body text color' => {
		message => q|Body Text Color|,
		lastUpdated => 1146244520,
	},

	'body text color description' => {
		message => q|The color of text in the body.|,
		lastUpdated => 1146244520,
	},

	'menu background color' => {
		message => q|Menu Background Color|,
		lastUpdated => 1146244520,
	},

	'menu background color description' => {
		message => q|The background color for the menu part of the page.|,
		lastUpdated => 1146244520,
	},

	'link color' => {
		message => q|Link Color|,
		lastUpdated => 1146244520,
	},

	'link color description' => {
		message => q|The color of links on the page.  The default is blue.|,
		lastUpdated => 1146244520,
	},

	'visited link color' => {
		message => q|Visited Link Color|,
		lastUpdated => 1146244520,
	},

	'visited link color description' => {
		message => q|The color of visited links on the page.  The default is purple.|,
		lastUpdated => 1146244520,
	},

	'choose a layout' => {
		message => q|<p>Choose a layout for this style:</p>|,
		lastUpdated => 1146455484,
	},

	'plugin name' => {
		message => q|Parser Name|,
		lastUpdated => 1162087997,
	},

	'plugin enabled header' => {
		message => q|Enabled?|,
		lastUpdated => 1162088018,
	},

	'template parsers' => {
		message => q|Template Parsers|,
		lastUpdated => 1162088018,
	},

	'default parser' => {
		message => q|Default Parser|,
		lastUpdated => 1162088018,
	},

	'template parsers list title' => {
		message => q|List of Template Parsers|,
		lastUpdated => 1162088018,
	},

	'template parsers list body' => {
		message => q|<p>The following template parsers are installed on your site and may be enabled for use.</p>|,
		lastUpdated => 1162088018,
	},

    'warning default template' => {
        message     => q{You are attempting to edit a default template. Any changes you make to this template
                    may be lost when you next upgrade WebGUI. To be safe, you should make a duplicate of this template.},
        lastUpdated => 0,
        context     => q{Warning for users attempting to edit a default template},
    },

    'make duplicate label' => {
        message     => q{Duplicate this template and edit},
        lastUpdated => 0,
        context     => q{Label for URL to make a duplicate and open the duplicate's edit screen},
    },

    'attachment header index' => {
        message     => 'Index',
        lastUpdated => 1241192473,
        context     => q|header for the sequence number column for attachments|,
    },

    'attachment header type' => {
        message     => 'Type',
        lastUpdated => 1241192473,
        context     => q|header for the attachment types column|,
    },

    'attachment header url' => {
        message     => 'Url',
        lastUpdated => 1241192473,
        context     => q|header for the url column for attachments|,
    },

    'attachment header remove' => {
        message     => 'Remove',
        lastUpdated => 1241192473,
        context     => q|header for the remove button column for attachments|,
    },

	'attachment display label' => {
        message     => 'Attachments',
        lastUpdated => 1241192473,
        context     => q|field label for displaying existing attachments|,
     },
        
	'attachment add field label' => {
        message     => 'Add Attachments',
        lastUpdated => 1241192473,
        context     => q|field label for adding new attachments|,
     },

	'attachment add button' => {
        message     => 'Add', 
        lastUpdated => 1241192473,
        context     => q|button text for adding a new attachment|,
     },

    'usePacked label' => {
        message     => q{Use Packed Template},
        lastUpdated => 0,
        context     => q{Label for asset property},
    },

    'usePacked description' => {
        message     => q{Use the packed version of this template for faster downloads},
        lastUpdated => 0,
        context     => q{Description of asset property},
    },

    'css label' => {
        message     => "Stylesheet (CSS)",
        lastUpdated => 0,
        context     => 'Label for a CSS file attachment',
    },

    'js head label' => {
        message     => "JavaScript (head)",
        lastUpdated => 0,
        context     => "Label for a JS file attachment that goes in the <head> block",
    },

    'js body label' => {
        message     => "JavaScript (body)",
        lastUpdated => 0,
        context     => "Label for a JS file attachment that goes after all the content in the <body> block",
    },

    'template in trash' => {
        message     => q|Template in trash|,
        lastUpdated => 0,
    },

    'template in clipboard' => {
        message     => q|Template in clipboard|,
        lastUpdated => 0,
    },

    'Already attached!' => {
        message     => q|Already attached!|,
        lastUpdated => 0,
    },

    'No url!' => {
        message     => q|No url!|,
        lastUpdated => 0,
    },

    'field storageIdExample' => {
        message     => 'Example Image',
        lastUpdated => 0,
    },

    'field storageIdExample description' => {
        message     => 'An example image to show what the template looks like before the user selects it',
        lastUpdated => 0,
    },
    'Configure' => {
        message => 'Configure',
        lastUpdated => 1294247160,
    },
    'Fetch Variables' => {
        message => 'Fetch Variables',
        lastUpdated => 1294165643,
    },
    'Fetch Variables hoverHelp' => {
        message => 'Try to guess variables from a url that uses this template.',
        lastUpdated => 1294165643,
    },
    'Fetch' => {
        message => 'Fetch',
        lastUpdated => 1294165643,
    },
    'URL' => {
        message => 'URL',
        lastUpdated => 1294165643,
    },
    'URL hoverHelp' => {
        message => 'URL used by the fetch button.',
        lastUpdated => 1294165643,
    },
    'Plain Text?' => {
        message => 'Preview as Plain Text?',
        lastUpdated => 1294165643,
    },
    'Plain Text hoverHelp' => {
        message => 'If you mark yes, you will get a plain-text response (useful for seeing the raw output of a template). Otherwise, the output will be rendered as html.',
        lastUpdated => 1294165643,
    },
    'Preview' => {
        message => 'Preview',
        lastUpdated => 1294247388,
    },
    'Variables' => {
        message => 'Variables',
        lastUpdated => 1294165651,
    },
    'Variables hoverHelp' => {
        message => 'Variables used by the render button (in JSON).',
        lastUpdated => 1294165652,
    },
    'Configure Preview' => {
        message => 'Configure Preview',
        lastUpdated => 1294251507,
    },
};

1;
