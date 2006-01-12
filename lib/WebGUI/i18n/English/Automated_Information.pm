package WebGUI::i18n::English::Automated_Information;

##This module must not be preloaded, since it requires that $session
##be populated when the module is use'ed.

use WebGUI::International;
my $i18n = WebGUI::International->new($session, 'Macros');

##Get list of all macros by namespace/module name
my $dir = join '/', $self->session->config->getWebguiRoot,"lib","WebGUI","Macro";
opendir (DIR,$dir) or $self->session->errorHandler->fatal("Can't open Macro directory: $dir!");
my @macros = map { s/Macro_//; s/\.pm//; $_; }
             grep { /\.pm$/ }
             readdir(DIR);  ##list of namespaces
closedir(DIR);

##Build list of enabled macros, by namespace by reversing session hash:
my %macros = reverse %{ $self->session->config->get("macros") };

my $macro_table =
        join "\n", 
        map { join '', '<tr><td>', $_, '</td><td>',
              ($macros{$_} ? ('&#94;', $macros{$_}, '();') : '&nbsp;'), 
              '</td></tr>' }
        @macros;

$macro_table =
        join("\n", 
         '<table border="1" cellpadding="3">',
        '<tr><th>',$i18n->get('macro name'),
        '</th><th>',
        $i18n->get('macro shortcut'),
        '</th></tr>',$macro_table,'</table>');

our $I18N = {
        'macro table' => {
                message => $macro_table,
                lastUpdated => 1112466408,
        }
};
1;
