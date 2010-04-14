package Plack::Middleware::Debug::Logger;
use 5.008;
use strict;
use warnings;
use parent qw(Plack::Middleware::Debug::Base);
our $VERSION = '0.07';

sub run {
    my ($self, $env, $panel) = @_;

    my $logger = $env->{'psgix.logger'};

    my $log_output = [];
    $env->{'psgix.logger'} = sub {
        my ($args) = @_;
        my $caller = (caller(1))[3] . '[' . (caller(0))[2] . '] ';
        my $message = $args->{message};
        push @$log_output, $args->{level} => $caller . $message;
        if ($logger) {
            goto $logger;
        }
    };

    return sub {
        my $res = shift;

        if ($logger) {
            $env->{'psgix.logger'} = $logger;
        }
        $panel->nav_subtitle(scalar @$log_output / 2 . ' messages');
        if (@$log_output) {
            $panel->content('<div style="white-space: pre">' . $self->render_list_pairs( $log_output ) . '</div>');
        }
    };
}

1;

