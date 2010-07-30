package WebGUI::Content::Admin;

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

    if ( $session->form->get("op") eq "admin" ) {
        if ( $session->form->get("plugin") ) {
            # Load the requested plugin if necessary
            # Default page is "view"
            # Pass control to the right page
        }
        else {
            my $admin   = WebGUI::Admin->new( $session );
            my $method  = $session->form->get('method') || "view";

            if ( $admin->can( "www_" . $method ) ) {
                return $admin->can( "www_" . $method )->($admin);
            }
            else {
                return $admin->www_view;
            }
        }
    }

    if ( $session->form->get("op") eq "assetHelper" ) {
        # Load and run the requested asset helper www_ method
        my $class   = $session->form->get('className');
        WebGUI::Pluggable::load( $class );
        my $method  = $session->form->get('method') || "view";
        my $assetId = $session->form->get('assetId');
        my $asset   = WebGUI::Asset->newById( $session, $assetId );

        if ( $class->can( "www_" . $method ) ) {
            return $class->can( "www_" . $method )->( $class, $asset );
        }
    }

    return;
}


1;
#vim:ft=perl
