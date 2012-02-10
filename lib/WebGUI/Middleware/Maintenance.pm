package WebGUI::Middleware::Maintenance;

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

=head2 call ( $env ) 

Interface method for this middleware.  It checks the settings for the special entry, upgradeState.
If this is set, then it returns an HTTP 503.  It will also clear the maintenance state when the
upgrade is complete.

=head3 $env

A Plack environment hash.  This is used to access the WebGUI Session object.

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

