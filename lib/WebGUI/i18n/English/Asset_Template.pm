package WebGUI::i18n::English::Asset_Template;

our $I18N = {
	'head block' => {
		message => q|Head Block|,
		context => q|label for the get edit form where users should put things that go in the html head block|,
		lastUpdated => 0,
	},

	'head block description' => {
		message => q|Put meta tags, script tags, link tables, style sheets, and anything else here that you want to appear in the head block of the HTML document.|,
		context => q|hover help for the head block field|,
		lastUpdated => 0,
	},

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
		message => q|There is a syntax error in this template. Please correct.|,
		context => q|Error when executing template|,
		lastUpdated => 1107391368,
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

};

1;
