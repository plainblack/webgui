package Plack::Middleware::Debug::Logger;

=head1 LEGAL

 -------------------------------------------------------------------
  WebGUI is Copyright 2001-2012 Plain Black Corporation.
 -------------------------------------------------------------------
  Please read the legal notices (docs/legal.txt) and the license
  (docs/license.txt) that came with this distribution before using
  this software.
 -------------------------------------------------------------------
  http://www.plainblack.com                     info@plainblack.com
 -------------------------------------------------------------------

=head1 NAME

Package Plack::Middleware::Debug::Logger

=head1 DESCRIPTION

This package is the interface to the WebGUI macro system.

=cut

use 5.008;
use strict;
use warnings;
use parent qw(Plack::Middleware::Debug::Base);
our $VERSION = '0.07';

=head2 run

Entry subroutine for the Debug logger.  Sets up $env->{'psgix.logger'} with a subref for
logging information to the Debug panel.

=head3 $env->{'psgix.logger'} 

The subroutine takes a hash of arguments:

=head4 level

The severity level of the message.

=head4 message

The message to log.

=cut

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

