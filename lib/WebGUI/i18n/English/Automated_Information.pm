package WebGUI::i18n::English::Automated_Information;

##This module must not be preloaded, since it requires that $session
##be populated when the module is use'ed.

use WebGUI::Session;
use WebGUI::International;

##Get list of all macros by namespace/module name
my $dir = join '/', $self->session->config->getWebguiRoot,"lib","WebGUI","Macro";
opendir (DIR,$dir) or $self->session->errorHandler->fatal("Can't open Macro directory: $dir!");
my @macros = map { s/Macro_//; s/\.pm//; $_; }
             grep { /\.pm$/ }
             readdir(DIR);  ##list of namespaces
closedir(DIR);

##Build list of enabled macros, by namespace by reversing session hash:
my %macros = reverse %{ $self->session->config->get("macros") };

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

our $I18N = {
        'macro table' => {
                message => $macro_table,
                lastUpdated => 1112466408,
        }
};
1;
