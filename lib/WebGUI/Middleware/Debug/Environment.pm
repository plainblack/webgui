package WebGUI::Middleware::Debug::Environment;
use 5.008;
use strict;
use warnings;
use parent qw(Plack::Middleware::Debug::Environment);
our $VERSION = '0.01';

sub run {
    my ($self, $env, $panel) = @_;

    my $filtered_env = { %$env };

    delete $filtered_env->{'plack.debug.panels'};
    $filtered_env->{'webgui.session'} &&= 'bless({ ... }, "WebGUI::Session")';

    $self->SUPER::run($filtered_env, $panel);
}

1;

