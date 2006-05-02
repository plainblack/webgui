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

	'printable body' => {
		message => q|

<p><b>&#94;r(<i>link text</i>)</b><br />
<b>&#94;r("",<i>custom style name</i>)</b><br />
<b>&#94;r("",<i>custom style name</i>,<i>custom template name</i>)</b><br />
Creates a link to alter the style from a page to make it printable.
</p>

<p>The macro takes up to three arguments.  The first argument allows you to replace the default internationalized link text like this <b>&#94;r("Print Me!");</b>.  If this argument is the string "linkonly", then only the URL to make the page printable will be returned and nothing more.  If you wish to use the internationalized label but need to use multiple arguments to change the printable style or template, then use the empty string.
</p>

<p>Normally, the default style to make the page printable is the "Make Page Printable" style.  The second argument specifies that a different style than the default be used to make the page printable: <b>&#94;r("Print!","WebGUI");</b>.
</p>

<p>The third argument allows a different template be used to generate the HTML code for presenting the link and text, by specifying the name of the template.  The following variables are available in the template:

<p><b>printable.url</b><br />
The URL to make the page printable.
</p>

<p><b>printable.text</b><br />
The translated label for the printable link, or the text that you supply to the macro.
</p>

<p><b>NOTES:</b>The <i>.makePrintableLink</i> style sheet class is tied to the default template for this macro.
</p>

|,
		lastUpdated => 1146608731,
	},

	'53' => {
		message => q|Make Page Printable|,
		lastUpdated => 1031514049
	},
};

1;
