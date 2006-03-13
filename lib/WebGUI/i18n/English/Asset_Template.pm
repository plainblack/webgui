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
		message => q|<b>Template Name</b><br/>
Give this template a descriptive name so that you'll know what it is when you're applying a template to content.
<p/>
<b>NOTE:</b> You should never edit the default templates that come with WebGUI as they are subject to change with each new release. Instead, copy the template you wish to edit, and edit the copy.
|,
		lastUpdated => 1119979659
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

</p>|,
		lastUpdated =>1130959765,
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

<p>
<b>Session Variables</b><br />
In addition to any variables defined in a given template, the session variables are made available to you with this syntax:
</p>

<p>&lt;tmpl_var session.<i>section</i>.<i>variable</i>&gt;</p>

<p>Some common, useful session variables are:</p>

<p><b>session.var.adminOn</b><br />
This variable will be true if the user is in Admin mode.
</p>

<p><b>session.var.userId</b><br />
The userId for the current user.
</p>

<p><b>session.user.username</b><br />
The current user's username.
</p>

<p><b>session.user.language</b><br />
The current user's preferred language (the default is English).
</p>

<p><b>session.user.karma</b><br />
The user's karma.
</p>

		|,
		lastUpdated => 1130978466,
	},

};

1;
