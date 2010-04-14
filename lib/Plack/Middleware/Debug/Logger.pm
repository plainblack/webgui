package Plack::Middleware::Debug::Logger;
use 5.008;
use strict;
use warnings;
use parent qw(Plack::Middleware::Debug::Base);
use Sub::Uplevel ();
our $VERSION = '0.07';

sub run {
    my ($self, $env, $panel) = @_;

    my $wrap_logger = $env->{'psgix.logger'};
    my %output;
    $env->{'psgix.logger'} = sub {
        my ($args) = @_;
        my $caller = (caller(1))[3] . '[' . (caller(0))[2] . '] ';
        my $message = $args->{message};
        $message =~ s/\n\s*/\n        /msxg;
        $message =~ s/\n?\z/\n/msx;
        $output{lc $args->{level}} ||= '';
        $output{lc $args->{level}} .= $caller . $message;
        if ($wrap_logger) {
            Sub::Uplevel::uplevel 1, $wrap_logger, @_;
        }
    };

    return sub {
        my $res = shift;

        if ($wrap_logger) {
            $env->{'psgix.logger'} = $wrap_logger;
        }
        my $content = '';
        for my $level ( qw(info debug warn error fatal) ) {
            if ($output{$level}) {
                $content .= "<h1 style=\"font-size: 125%\">\u$level</h1>";
                $content .= '<div style="white-space: pre">' . $self->render_lines($output{$level}) . '</div>';
            }
        }
        $panel->content($content);
    };
}

1;

