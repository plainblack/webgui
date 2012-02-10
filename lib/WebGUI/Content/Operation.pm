package WebGUI::Content::Operation;

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
use WebGUI::Operation;

=head1 NAME

Package WebGUI::Content::Operation

=head1 DESCRIPTION

A content handler that handles operations.

=head1 SYNOPSIS

 use WebGUI::Content::Operation;
 my $output = WebGUI::Content::Operation::handler($session);

=head1 SUBROUTINES

These subroutines are available from this package:

=cut

#-------------------------------------------------------------------

=head2 handler ( session ) 

The content handler for this package.

=cut

sub handler {
    my ($session) = @_;
    my $output = "";
    my $op = $session->form->process("op");
    if ($op) {
        $output = WebGUI::Operation::execute($session,$op);
    }
    return $output;
}

1;

