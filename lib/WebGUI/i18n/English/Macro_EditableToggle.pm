package WebGUI::i18n::English::Macro_EditableToggle;

our $I18N = {

    'macroName' => {
        message => q|Editable Toggle|,
        lastUpdated => 1128838139,
    },

    'editable toggle title' => {
        message => q|Editable Toggle Macro|,
        lastUpdated => 1112466408,
    },

	'editable toggle body' => {
		message => q|

<b>&#94;EditableToggle; or &#94;EditableToggle();</b><br>
Exactly the same as AdminToggle, except that the toggle is only displayed if the user has the rights to edit the current Asset. This macro takes up to three parameters. The first is a label for "Turn Admin On", the second is a label for "Turn Admin Off", and the third is the name of a template in the Macro/EditableToggle namespace to replace the default template.
<p>
The following variables are available in the template:
<p/>
<b>toggle.url</b><br/>
The URL to activate or deactivate Admin mode.
<p/>
<b>toggle.text</b><br/>
The Internationalized label for turning on or off Admin (depending on the state of the macro), or the text that you supply to the macro.
<p/>

|,
		lastUpdated => 1134799755,
	},

	'516' => {
		message => q|Turn Admin On!|,
		lastUpdated => 1031514049
	},

	'517' => {
		message => q|Turn Admin Off!|,
		lastUpdated => 1031514049
	},
};

1;
