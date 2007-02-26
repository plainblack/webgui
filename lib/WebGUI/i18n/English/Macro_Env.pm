package WebGUI::i18n::English::Macro_Env;

our $I18N = {

    'macroName' => {
        message => q|Environment Variable|,
        lastUpdated => 1128838196,
    },

    'env title' => {
        message => q|Environment Variable Macro|,
        lastUpdated => 1128838196,
    },

	'env body' => {
		message => q|
<p><b>&#94;Env();</b><br />
Can be used to display a web server environment variable on a page. The environment variables available on each server are different.  Please consult the documentation for your server for a list of them.</p>

<p>The macro should be specified like this &#94;Env("REMOTE_ADDR");
</p>
<p>This Macro may be nested inside other Macros if the text returned does not contain commas or quotes.</p>

|,
		lastUpdated => 1172510936,
	},
};

1;
