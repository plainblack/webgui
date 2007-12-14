package WebGUI::Content::Upgrading;

=head1 LEGAL

 -------------------------------------------------------------------
  WebGUI is Copyright 2001-2007 Plain Black Corporation.
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

Package WebGUI::Content::Upgrading

=head1 DESCRIPTION

A content handler that displays a maintenance page when in a special upgrade state.

=head1 SYNOPSIS

 use WebGUI::Content::Upgrading;
 my $output = WebGUI::Content::Upgrading::handler($session);

=head1 SUBROUTINES

These subroutines are available from this package:

=cut

#-------------------------------------------------------------------

=head2 handler ( session ) 

The content handler for this package.

=cut

sub handler {
    my ($session) = @_;
    if ($session->setting->get("specialState") eq "upgrading") {
        my $output = "";
        $session->http->sendHeader;
        open(my $FILE,"<",$session->config->getWebguiRoot."/docs/maintenance.html");
        while (<$FILE>) {
            $session->output->print($_);
        }
        close($FILE);
        return "none";
    }
    return;
}

1;

