package WebGUI::Middleware::Maintenance;

=head1 LEGAL

 -------------------------------------------------------------------
  WebGUI is Copyright 2001-2009 Plain Black Corporation.
 -------------------------------------------------------------------
  Please read the legal notices (docs/legal.txt) and the license
  (docs/license.txt) that came with this distribution before using
  this software.
 -------------------------------------------------------------------
  http://www.plainblack.com                     info@plainblack.com
 -------------------------------------------------------------------

=cut

use strict;
use parent qw(Plack::Middleware);


=head1 NAME

Package WebGUI::Content::Maintenance;

=head1 DESCRIPTION

A content handler that displays a maintenance page while upgrading.

=head1 SYNOPSIS

    enable '+WebGUI::Middleware::Maintenance';

=head1 SUBROUTINES

These subroutines are available from this package:

=cut

#-------------------------------------------------------------------

=head2 handler ( session ) 

The content handler for this package.

=cut

sub call {
    my $self = shift;
    my $env  = shift;
    my $session = $env->{'webgui.session'};
    my $upgradeState = $session->setting->get('upgradeState');
    if ($upgradeState) {
        if ($upgradeState eq WebGUI->VERSION) {
            $session->setting->remove('upgradeState');
        }
        else {
            return [ 503, ['Content-Type' => 'text/plain'], [ 'Service Unavailable' ] ];
        }
    }
    return $self->app->($env);
}

1;

