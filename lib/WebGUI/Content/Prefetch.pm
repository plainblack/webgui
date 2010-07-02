package WebGUI::Content::Prefetch;

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

Package WebGUI::Content::Prefetch

=head1 DESCRIPTION

A content handler that prevents prefetching browsers.

=head1 SYNOPSIS

 use WebGUI::Content::Prefetch;
 my $output = WebGUI::Content::Prefetch::handler($session);

=head1 SUBROUTINES

These subroutines are available from this package:

=cut

#-------------------------------------------------------------------

=head2 handler ( session ) 

The content handler for this package.

=cut

sub handler {
    my ($session) = @_;
    if ($session->request->env->{"HTTP_X_MOZ"} eq "prefetch") { # browser prefetch is a bad thing
        $session->http->setStatus(403);
    }
    return undef;
}

1;

