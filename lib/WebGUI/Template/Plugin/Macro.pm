package WebGUI::Template::Plugin::Macro;

use base 'Template::Plugin';

sub new {
    my $config = ref($_[-1]) eq 'HASH' ? pop(@_) : { };
    my ($class, $context) = @_;

    my $session = $context->stash->{_session};

    my $subs = {};
    my $macros = $session->config->get("macros");
    for my $macro ( keys %$macros ) {
        my $package = "WebGUI::Macro::\u$macros->{macro}";
        my $process = $package->can('process');
        $subs->{$macro} = sub {
            $process->($session, @_);
        };
    }
    return $subs;
}

1;


