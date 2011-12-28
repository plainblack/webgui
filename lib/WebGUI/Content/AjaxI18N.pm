package WebGUI::Content::AjaxI18N;

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
use JSON ();

=head1 NAME

Package WebGUI::Content::AjaxI18N

=head1 DESCRIPTION

A content handler to get i18n data using the WebGUI.i18n JavaScript object.

=head1 SYNOPSIS

 use WebGUI::Content::AjaxI18N
 my $output = WebGUI::Content::AjaxI18N::handler($session);

=head1 SUBROUTINES

These subroutines are available from this package:

=cut

#-------------------------------------------------------------------

=head2 handler ( session ) 

The content handler for this package.

=cut

sub handler {
    my ( $session ) = @_;
    # Only handle op=ajaxGetI18N
    return undef unless ( $session->form->get( "op" ) eq "ajaxGetI18N" );

    my $response    = {};
    my $json        = $session->form->get( "request" );
    my $namespaces  = eval { JSON->new->decode( $json ) };
    unless ($@) {
        my $i18n        = WebGUI::International->new( $session );

        for my $ns ( keys %{ $namespaces } ) {
            for my $key ( @{ $namespaces->{ $ns } } ) {
                $response->{ $ns }->{ $key }    = $i18n->get( $key, $ns );
            }
        }
    }
    else {
        $session->log->warn("User ".$session->user->username." tried to execute ajaxGetI18n but could not decode JSON string: $json");
    }
    $session->response->content_type( "application/json" );
    return JSON->new->encode( $response );
}


1;

