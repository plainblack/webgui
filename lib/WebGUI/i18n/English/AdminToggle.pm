package WebGUI::i18n::English::AdminToggle;

our $I18N = {

    'admin toggle title' => {
        message => q|Admin Text Macro|,
        lastUpdated => 1112466408,
    },

	'admin toggle body' => {
		message => q|

<b>&#94;AdminToggle; or &#94;AdminToggle();</b><br>
Places a link on the page which is only visible to content managers and administrators. The link toggles on/off admin mode. You can optionally specify other messages to display like this: &#94;AdminToggle("Edit On","Edit Off"); This macro optionally takes a third parameter that allows you to specify an alternate template name in the Macro/AdminToggle namespace.
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
		lastUpdated => 1112466919,
	},
};

1;
