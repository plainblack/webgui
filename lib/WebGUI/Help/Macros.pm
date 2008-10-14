package WebGUI::Help::Macros;
use strict;
use Module::Find qw(findsubmod);

our $HELP = {

    'macros list' => {
        title => 'macros list title',
        body  => sub {
            my $session = shift;
            my @macroModules = findsubmod 'WebGUI::Macro';
            my @macros = map { /^WebGUI::Macro::(.*)/; $1 } @macroModules;

            ##Build list of enabled macros, by namespace, by reversing session hash:
            my %configMacros = %{ $session->config->get("macros") };
            #my %macros = reverse %{ $session->config->get("macros") };
            my %macros;
            while (my ($alias, $macroName) = each %configMacros) {
                $alias = '&#94;'. $alias . '();';
                if (exists $macros{$macroName}) {
                    $macros{$macroName} .= '<br/>' . $alias;
                }
                else {
                    $macros{$macroName} = $alias;
                }
            }

            my $i18n = WebGUI::International->new( $session, 'Macros' );
            my $yes  = $i18n->get( 138,                      'WebGUI' );
            my $no   = $i18n->get( 139,                      'WebGUI' );
            my $macro_table = join "\n", map {
                join '', '<tr><td>', $_, '</td><td>', ( $macros{$_} ? $yes : $no ), '</td><td>',
                    ( $macros{$_} ? $macros{$_} : '&nbsp;' ), '</td></tr>'
            } @macros;

            $macro_table = join( "\n",
                $i18n->get('macros list body'), '<table border="1" cellpadding="3">',
                '<tr><th>',                     $i18n->get('macro name'),
                '</th><th>',                    $i18n->get('macro enabled header'),
                '</th><th>',                    $i18n->get('macro shortcut'),
                '</th></tr>',                   $macro_table,
                '</table>' );
        },
        fields  => [],
        related => [],
    },

};

1;
