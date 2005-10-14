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
<b>&#94;Env()</b><br>
Can be used to display a web server environment variable on a page. The environment variables available on each server are different, but you can find out which ones your web server has by going to: http://www.yourwebguisite.com/env.pl
<p>

The macro should be specified like this &#94;Env("REMOTE_ADDR");
<p>

|,
		lastUpdated => 1112466919,
	},
};

1;
