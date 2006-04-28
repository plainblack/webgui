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

	'684' => {
		message => q|Template, Add/Edit|,
		lastUpdated => 1038890615
	},

	'639' => {
		message => q|<p>Templates allow you to customize the look and feel of your content on your site.  WebGUI comes with many existing templates that you can use as is or copy and modify to suit your individual needs.  Note that in many cases that you can change the look of default WebGUI templates through CSS.  The advantage to this is that the default templates are automatically updated when you upgrade WebGUI, where custom templates will have to be manually updated.</p>
<p>There are two ways to edit templates, via the Display tab of the Asset Edit screen or via the Asset Manager.  In either case, you will need to be an Admin or a Template Admin.
</p>

<p><b>Display tab of the Asset Edit screen</b><br/>
<ul>
<li>Turn on Admin mode.</li>
<li>Click on the Edit icon for an Asset.</li>
<li>Select the "Display" tab for the Asset.</li>
<li>Next to the template that the Asset uses will be two icons.</li>
	<dl>
	<dt>Edit</dt>
	<dd>This will allow you to edit the currently selected template.</dd>
	<dt>Manage</dt>
	<dd>This will take you to the Folder in the Asset Manager that contains this template.</dd>
	</dl>
</ul>
</p>

<p><b>Asset Manager</b><br/>
<ul>
<li>Turn on Admin mode.</li>
<li>Click on the "Assets" icon in the Admin bar.</li>
<li>In the crumb trail style navigation, click on "Root".</li>
<li>Then click on Asset titled, "Import Node".</li>
<li>Most default WebGUI templates are stored by type in folders inside the Template Folder.</li>
</ul>
</p>

<b>Template Name</b><br/>
Give this template a descriptive name so that you'll know what it is when you're applying a template to content.
<p/>
<b>NOTE:</b> You should never edit the default templates that come with WebGUI as they are subject to change with each new release. Instead, copy the template you wish to edit, and edit the copy.
|,
		lastUpdated => 1143755587
	},

        'namespace description' => {
                message => q|What type of template is this?
<p/>|,
                lastUpdated => 1119979645,
        },

        'show in forms description' => {
                message => q|Should this template be shown in the list of template from this namespace?
<p/>|,
                lastUpdated => 1119979645,
        },

        'template description' => {
                message => q|Create your template by using template commands and variables, macros, and HTML.
<p/>|,
                lastUpdated => 1119979645,
        },

        'parser' => {
                message => q|Template Type|,
                lastUpdated => 1119979645,
        },

        'parser description' => {
                message => q|If your configuration file lists multiple template engines, then select which type of template this is so that WebGUI can send it to the correct one.
<p/>|,
                lastUpdated => 1119979645,
        },

	'825' => {
		message => q|Template, Language|,
		lastUpdated => 1038865669
	},

	'826' => {
		message => q|<p>WebGUI has a powerful templating language built to give you maximum control over the layout of your content.</p>
<p><b>NOTES:</b><br />
Both the template language and template variables are case-insensitive.
</p>

<p>
<b>Variables</b><br />
Variables are the most basic of the template commands. They are used to position pieces of content.
In the examples below, please note that the words <i>foo</i> and <i>bar</i> are used as placeholders for the actual variable names that you'll use. They are not part of the template language.</p>

<p>
<i>Syntax:</i> &lt;tmpl_var foo&gt; or &lt;tmpl_var name="foo"&gt;
</p>

<p>
<i>Example:</i> &lt;tmpl_var name&gt;
</p>

<p>
<b>Conditions</b><br />
To programmers conditions are nothing new, but to designers they can often be confusing at first. Conditions are really just true or false questions, and if you think of them that way, you'll have no trouble at all.
</p>

<p>
<i>Syntax:</i> &lt;tmpl_if foo&gt; &lt;tmpl_else&gt; &lt;/tmpl_if&gt;<br />
<i>Syntax:</i> &lt;tmpl_unless foo&gt; &lt;tmpl_else&gt; &lt;/tmpl_unless&gt;
</p>

<p>
<i>Example:</i> &lt;tmpl_if isTrue&gt; It was true!&lt;tmpl_else&gt; It was false! &lt;/tmpl_if&gt;
</p>

<p>Truth or falsehood is determined by the following rules:
<ul>
<li><p>Variables not used in this template are false.</p></li>
<li><p>Variables which are undefined are false.</p></li>
<li><p>Variables which are empty are false.</p></li>
<li><p>Variables which are equal to zero are false.</p></li>
<li><p>All other variables are true.</p></li>
</ul></p>

<p><b>Loops</b><br />
Loops iterate over a list of data output for each pass in the loop. Loops are slightly more complicated to use than plain variables, but are considerably more powerful.
</p>

<p>
<i>Syntax:</i> &lt;tmpl_loop foo&gt; &lt;/tmpl_loop&gt;
</p>

<p>
<i>Example:</i> <br />
&lt;tmpl_loop users&gt; <br />
  &nbsp; Name: &lt;tmpl_var first_name&gt;&lt;br/&gt;<br />
&lt;/tmpl_loop&gt;
</p>

<p>
<b>Loop Conditions</b><br />
Loops come with special condition variables of their own. They are __FIRST__, __ODD__, __INNER__, and __LAST__.
</p>

<p>
<i>Examples:</i><br />
<pre>
   &lt;TMPL_LOOP FOO&gt;
      &lt;TMPL_IF __FIRST__&gt;
        This only outputs on the first pass.
      &lt;/TMPL_IF&gt;

      &lt;TMPL_IF __ODD__&gt;
        This outputs every other pass, on the odd passes.
      &lt;/TMPL_IF&gt;

      &lt;TMPL_UNLESS __ODD__&gt;
        This outputs every other pass, on the even passes.
      &lt;/TMPL_UNLESS&gt;

      &lt;TMPL_IF __INNER__&gt;
        This outputs on passes that are neither first nor last.
      &lt;/TMPL_IF&gt;

      &lt;TMPL_IF __LAST__&gt;
        This only outputs on the last pass.
      &lt;TMPL_IF&gt;
   &lt;/TMPL_LOOP&gt;
</pre>

</p>
<p><i>NOTE: This only documents WebGUI's default template language, HTML::Template.  If the Template Type
has been set to some other language you will need to consult the documentation for it.</i></p>.
|,
		lastUpdated =>1146243644,
	},

	'template variable title' => {
		message => q|Template Variables|,
		lastUpdated => 1130972019,
	},

	'template variable body' => {
		message => q|
<p><b>webgui.version</b><br />
The version of WebGUI on your site.
</p>

<p><b>webgui.status</b><br />
The release status for this version of WebGUI, stable, beta, gamma, etc.
</p>

<p><b>session.user.username</b><br />
The current user's username.
</p>

<p><b>session.user.firstDayOfWeek</b><br />
From the current user's profile, the day they selected to be the first day of the week.
</p>

<p><b>session.config.extrasurl</b><br />
From the WebGUI config, the URL for the extras directory.
</p>

<p><b>session.var.adminOn</b><br />
This variable will be true if the user is in Admin mode.
</p>

<p><b>session.setting.companyName</b><br />
From the WebGUI settings, the company name.
</p>

<p><b>session.setting.anonymousRegistration</b><br />
From the WebGUI settings, whether or not anonymous registration has been enabled.
</p>

<p>
<b>Session Form Variables</b><br />
Any form variables will be available in the template with this syntax:
</p>

<p>&lt;tmpl_var session.form.<i>variable</i>&gt;</p>

<p>If there is more than 1 value in a form variable, only the last will be returned</p>

<p><i>NOTE: The syntax for these variables is shown in WebGUI's default template language, HTML::Template.  If the Template Type
has been set to some other language you will need to consult the documentation for the appropriate syntax for its variables.</i></p>.

		|,
		lastUpdated => 1146243514,
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
		message => q|"<p>Choose a layout for this style:</p>"|,
		lastUpdated => 1146244520,
	},

	'style wizard help' => {
		message => q|<p>The Style Wizard can help you create simple CSS based page style templates for your website
with your choice of two layouts and navigation styles, and configurable colors.  To access the Style
Wizard edit a template in the "style" namespace.  A link to open the Style Wizard will
be on the right side of the page.</p>
<p>Creating a style template is a three step process:
<ol>
<li>Select one of the layouts.</li>
<li>Enter your site name, upload a logo and configure the colors.</li>
<li>Make customizations to the generated template.</li>
</p>
|,
		lastUpdated => 1146244520,
	},

};

1;
