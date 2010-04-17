package WebGUI::Content::Maintenance;

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

Package WebGUI::Content::Maintenance;

=head1 DESCRIPTION

A content handler that displays a maintenance page while upgrading.

=head1 SYNOPSIS

 use WebGUI::Content::Maintenance;
 my $output = WebGUI::Content::Maintenance::handler($session);

=head1 SUBROUTINES

These subroutines are available from this package:

=cut

#-------------------------------------------------------------------

=head2 handler ( session ) 

The content handler for this package.

=cut

sub handler {
    my $session = shift;
    if ($session->setting->get("specialState") eq "upgrading") {
        $session->http->sendHeader;
        open my $fh, '<', $session->config->get('maintenancePage');
        my $output = do { local $/; <$fh> };
        close $fh;
        return $output;
    }
    return undef;
}


1;

