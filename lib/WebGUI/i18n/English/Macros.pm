package WebGUI::i18n::English::Macros;

use WebGUI::Session;
use WebGUI::International;

our $I18N = {

	'macro name' => {
		message => q|Macro Name|,
		lastUpdated => 1112591288
	},

	'macro shortcut' => {
		message => q|Macro Shortcut|,
		lastUpdated => 1112591289
	},

};

##Get list of all macros by namespace/module name
my $dir = join $session{os}{slash}, $session{config}{webguiRoot},"lib","WebGUI","Macro";
opendir (DIR,$dir) or WebGUI::ErrorHandler::fatal("Can't open Macro directory: $dir!");
my @macros = map { s/Macro_//; s/\.pm//; $_; }
             grep { /\.pm$/ }
             readdir(DIR);  ##list of namespaces
closedir(DIR);

##Build list of enabled macros, by namespace by reversing session hash:
my %macros = reverse %{ $session{config}{macros} };

$macro_table =
        join "\n", 
        map { join '', '<tr><td>', $_, '</td><td>',
              ($macros{$_} ? ('&#94;', $macros{$_}, '();') : '&nbsp;'), 
              '</td></tr>' }
        @macros;

$macro_table =
        join("\n", 
         '<table border="1" cellpadding="3">',
        '<tr><th>',WebGUI::International::get('macro name', 'Macros'),
        '</th><th>',
        WebGUI::International::get('macro shortcut', 'Macros'),
        '</th></tr>',$macro_table,'</table>');


$I18N = {

        %{ $I18N },

	'macros list title' => {
		message => q|Macros, List of Available|,
        	lastUpdated => 1112395935,
	},

	'macros list body' => {
                message => q|<P>The set of available Macros is defined in the WebGUI configuration file.  These Macros are available for use on your site:</P>|.$macro_table,
		context => 'Content for dynamically generated macro list',
		lastUpdated => 1112560683,
	},

	'macro enabled' => {
		message => q|This macro is enabled in the WebGUI configuration file and can be used on this site.|,
		lastUpdated => 1046656837,
	},

	'macro disabled' => {
		message => q|This macro is not enabled in the WebGUI configuration file and cannot be used on this site.|,
		lastUpdated => 1046656837,
	},

	'macros using title' => {
		message => q|Macros, Using|,
		lastUpdated => 1046656837
	},

	'macros using body' => {
		message => q|WebGUI macros are used to create dynamic content within otherwise static content. For instance, you may wish to show which user is logged in on every page, or you may wish to have a dynamically built menu or crumb trail. 
<p>

Macros always begin with a caret (&#94;) and follow with at least one other character and ended with a semicolon (;). Some macros can be extended/configured by taking the format of <b>&#94;x</b>("<i>config text</i>");.  When providing  multiple arguments to a macro, they should be separated by only commas:<br>
<b>&#94;x</b>(<i>"First argument",2</i>);
<p>

|,
		lastUpdated => 1101885876,
        },

};

1;
