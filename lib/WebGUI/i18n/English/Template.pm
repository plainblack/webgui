package WebGUI::i18n::English::Template;

our $I18N = {
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

	'template' => {
		message => q|Template|,
		context => q|label for Template Add/Edit Form|,
		lastUpdated => 1107391162,
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

	'683' => {
		message => q|Templates, Manage|,
		lastUpdated => 1050430164
	},

	'638' => {
		message => q|Templates are used to affect how content is laid out in WebGUI. There are many templates that come with WebGUI, and using the template management system, you can add your own templates to the system to ensure that your site looks <b>exactly</b> how you want it to look. 
|,
		lastUpdated => 1050430164
	},

	'684' => {
		message => q|Template, Add/Edit|,
		lastUpdated => 1038890615
	},

	'639' => {
		message => q|<b>Template Name</b><br/>
Give this template a descriptive name so that you'll know what it is when you're applying a template to content.
<p/>

<b>Namespace</b><br/>
What type of template is this?
<p/>

<b>Template</b><br/>
Create your template by using template commands and variables, macros, and HTML.
<p/>

<b>NOTE:</b> You should never edit the default templates that come with WebGUI as they are subject to change with each new release. Instead, copy the template you wish to edit, and edit the copy.|,
		lastUpdated => 1038890615
	},

	'685' => {
		message => q|Template, Delete|,
		lastUpdated => 1038791020
	},

	'640' => {
		message => q|It is not a good idea to delete templates as you never know what kind of adverse affect it may have on your site (some content may still be using the template). 
<p>

|,
		lastUpdated => 1038791020
	},

	'825' => {
		message => q|Template, Language|,
		lastUpdated => 1038865669
	},

	'826' => {
		message => q|WebGUI has a powerful templating language built to give you maximum control over the layout of your content.
<p/><b>NOTES:</b><br/>
Both the template language and template variables are case-insensitive.
<p/>
<b>Session Variables</b><br/>
In addition to any variables defined in a given template, of the session variables are made available to you with this syntax:
<p>

&lt;tmpl_var session.<i>section</i>.<i>variable</i>&gt;

<p/>
In the examples below, please note that the words <i>foo</i> and <i>bar</i> are used as placeholders for the actual variable names that you'll use. They are not part of the template language.

<p/>
<b>Variables</b><br/>
Variables are the most basic of the template commands. They are used to position pieces of content.

<p/>
<i>Syntax:</i> &lt;tmpl_var foo&gt; or &lt;tmpl_var name="foo"&gt;
<p/>

<i>Example:</i> &lt;tmpl_var name&gt;
<p/>

<b>Conditions</b><br/>
To programmers conditions are nothing new, but to designers they can often be confusing at first. Conditions are really just true or false questions, and if you think of them that way, you'll have no trouble at all.
<p/>

<i>Syntax:</i> &lt;tmpl_if foo&gt; &lt;tmpl_else&gt; &lt;/tmpl_if&gt;
<br/>
<i>Syntax:</i> &lt;tmpl_unless foo&gt; &lt;tmpl_else&gt; &lt;/tmpl_unless&gt;
<p/>

<i>Example:</i> &lt;tmpl_if isTrue&gt; It was true!&lt;tmpl_else&gt; It was false! &lt;/tmpl_if&gt;
<p/>

<p>Truth or falsehood is determined by the following rules:
<ul>
<li><p>Variables not used in this template are false.</p></li>
<li><p>Variables which are undefined are false.</p></li>
<li><p>Variables which are empty are false.</p></li>
<li><p>Variables which are equal to zero are false.</p></li>
<li><p>All other variables are true.</p></li>
</ul></p>

<b>Loops</b><br/>
Loops iterate over a list of data output for each pass in the loop. Loops are slightly more complicated to use than plain variables, but are considerably more powerful.
<p/>

<i>Syntax:</i> &lt;tmpl_loop foo&gt; &lt;/tmpl_loop&gt;
<p/>

<i>Example:</i> <br/>
&lt;tmpl_loop users&gt; <br/>
  &nbsp; Name: &lt;tmpl_var first_name&gt;&lt;br/&gt;<br/>
&lt;/tmpl_loop&gt;
<p/>

<b>Loop Conditions</b><br/>
Loops come with special condition variables of their own. They are __FIRST__, __ODD__, __INNER__, and __LAST__.
<p/>

<i>Examples:</i><br/>
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

<p/>|,
		lastUpdated =>1106608811,
	},

};

1;
