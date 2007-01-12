package WebGUI::i18n::English::Macro_r_printable;

our $I18N = {

	'macroName' => {
		message => q|Make Page Printable|,
		lastUpdated => 1128919002,
	},

	'printable title' => {
		message => q|Make Page Printable Macro|,
		lastUpdated => 1112503983,
	},

	'printable.url' => {
		message => q|The URL to make the page printable.|,
		lastUpdated => 1149217459,
	},

	'printable.text' => {
		message => q|The translated label for the printable link, or the text that you supply to the macro.|,
		lastUpdated => 1149217459,
	},

	'printable body' => {
		message => q|
<p><b>&#94;r(<i>link text</i>);</b><br />
<b>&#94;r("",<i>custom style name</i>);</b><br />
<b>&#94;r("",<i>custom style id</i>,<i>custom template URL</i>);</b><br />
Creates a link to alter the style from a page to make it printable.
</p>

<p>The macro takes up to three arguments.  The first argument allows you to replace the default internationalized link text like this <b>&#94;r("Print Me!");</b>.  If this argument is the string "linkonly", then only the URL to make the page printable will be returned and nothing more.  If you wish to use the internationalized label but need to use multiple arguments to change the printable style or template, then use the empty string.
</p>

<p>Normally, the default style to make the page printable is the "Make Page Printable" style.  The second argument specifies that a different style than the default be used to make the page printable: <b>&#94;r("Print!","MyStyleTemplate0000007");</b>.  The style has to be specified by the ID, not the name or url of the style.
</p>

<p>The third argument allows a different template be used to generate the HTML code for presenting the link and text, by specifying the URL of the template.  The following variables are available in the template:</p>

<p><b>NOTES:</b><br />
<ul>
<li>The <i>.makePrintableLink</i> style sheet class is tied to the default template for this macro.</li>
<li>This Macro may only be nested inside other Macros if the "linkonly" option is used.</li>
</ul>
</p>

|,
		lastUpdated => 1168623000,
	},

	'53' => {
		message => q|Make Page Printable|,
		lastUpdated => 1031514049
	},
};

1;
