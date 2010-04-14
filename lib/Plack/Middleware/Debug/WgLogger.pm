package Plack::Middleware::Debug::WgLogger;
use strict;
use parent qw(Plack::Middleware::Debug::Base);
our $VERSION = '0.07';

# This will be moved to the WebGUI::Middleware::Debug::WgLogger namespace
# once Plack::Middleware::Debug supports that

sub run {
    my ($self, $env, $panel) = @_;

    my $logger = $env->{'psgix.logger'};
    
    my $log_output = [];
    $env->{'psgix.logger'} = sub {
        my $args = shift;
        push @$log_output, $args->{level} => $args->{message};
        $logger && $logger->($args);
    };
    delete $env->{'webgui.session'}->{_errorHandler};

    return sub {
        my $res = shift;
        $panel->nav_subtitle(scalar @$log_output . " messages");
        $panel->content($self->render_list_pairs($log_output));
    };
}

sub panel_name { 'WebGUI Log' }

1;