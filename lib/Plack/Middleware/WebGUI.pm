package Plack::Middleware::WebGUI;
use strict;
use warnings;
use base qw/Plack::Middleware/;

__PACKAGE__->mk_accessors('root', 'config');

=head1 NAME

Plack::Middleware::WebGUI

=head1 DESCRIPTION

Plack Middleware that populates $env

In the future we might want to read the site.conf here and then cache it

=cut

sub call {
    my $self = shift;
    my $env  = shift;
    
    $env->{'wg.WEBGUI_ROOT'} = $self->root;
    $env->{'wg.WEBGUI_CONFIG'} = $self->config;

    $self->app->($env);
}

1;