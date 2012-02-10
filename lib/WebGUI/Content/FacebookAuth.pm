package WebGUI::Content::FacebookAuth;

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
use WebGUI::Auth::Facebook;

=head1 NAME

Package WebGUI::Content::FacebookAuth;

=head1 DESCRIPTION

Because is Facebook is dumb, and changed their API to no longer use query parameters, this module exists to handle the auth postback.

=head1 SUBROUTINES

These subroutines are available from this package:

=cut

#-------------------------------------------------------------------

=head2 handler ( session ) 

The content handler for this package.

=cut

sub handler {
    my ($session) = @_;
    if ($session->scratch->get('waiting_for_facebook_auth_postback')) {
 	$session->scratch->delete('waiting_for_facebook_auth_postback');
        WebGUI::Auth::Facebook->new($session)->www_callback;
    }
    return undef;
}

1;
#vim:ft=perl
