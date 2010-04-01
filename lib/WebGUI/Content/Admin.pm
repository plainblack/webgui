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
            return $admin->www_view;
        }
    }

    return;
}


1;
#vim:ft=perl

__DATA__
