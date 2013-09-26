package WebGUI::Content::Admin;

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
use WebGUI::Admin;
use WebGUI::Pluggable;


=head1 NAME

Package WebGUI::Content::Admin

=head1 DESCRIPTION

The WebGUI Admin Console

=head1 SUBROUTINES

These subroutines are available from this package:

=cut

#-------------------------------------------------------------------

=head2 handler ( session ) 

Handle every op=admin request

    1) Try to run the Admin Console plugin requested
    2) Show the Admin Console wrapper

=cut

sub handler {
    my ($session) = @_;

    return "" unless ($session->user->canUseAdminMode);

    if ( $session->form->get("op") eq "admin" ) {
        if ( $session->form->get("plugin") ) {
            my $id      = $session->form->get('id');
            my $props   = $session->config->get('adminConsole')->{ $id };

            if ( !$props ) {
                return "ERROR"; # die here
            }

            my $class   = $props->{ className };
            WebGUI::Pluggable::load( $class );
            my $method  = $session->form->get('method') || "view";

            if ( $class->can( "www_" . $method ) ) {
                return $class->can( "www_" . $method )->($session);
            }
            else {
                return "ERROR"; # die here
            }

        }
        else {
            my $admin   = WebGUI::Admin->new( $session );
            my $method  = $session->form->get('method') || "view";

            if ( $admin->can( "www_" . $method ) ) {
                return $admin->can( "www_" . $method )->($admin);
            }
            else {
                return "ERROR"; # die here
            }
        }
    }

    if ( $session->form->get("op") eq "assetHelper" ) {
        # Load and run the requested asset helper www_ method
        my $assetId = $session->form->get('assetId') or $session->log->fatal("no assetId passed to op=assetHelper");
        my $asset   = WebGUI::Asset->newById( $session, $assetId );

        my $helperId = $session->form->get('helperId');
        my $class = $asset->getHelpers->{ $helperId }->{ className };
        WebGUI::Pluggable::load( $class );
        my $helper = $class->new( id => $helperId, session => $session, asset => $asset );

        my $method  = $session->form->get('method') || "view";
        if ( $helper->can( "www_" . $method ) ) {
            return $helper->can( "www_" . $method )->( $helper );
        }
        else {
            $session->log->error( sprintf 'Invalid asset helper "%s" calling method "%s"', $helperId, $method );
        }
    }

    return;
}


1;
#vim:ft=perl
