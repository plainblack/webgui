package WebGUI::Content::Setup;

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
use Digest::MD5;
use WebGUI::Asset;
use WebGUI::HTMLForm;
use WebGUI::International;
use WebGUI::Storage;
use WebGUI::VersionTag;
use WebGUI::Utility;
use WebGUI::Operation::Statistics;

=head1 NAME

Package WebGUI::Setup

=head1 DESCRIPTION

Initializes a new WebGUI install.

=head1 SYNOPSIS

 use WebGUI::Setup;
 WebGUI::Content::Setup::handler();

=head1 SUBROUTINES

These subroutines are available from this package:

=cut

#-------------------------------------------------------------------

=head2 handler ( session )

Handles a specialState: "init"

=head3 session

The current WebGUI::Session object.

=cut

sub handler {
    my $session = shift;
    my $form    = $session->form;
    unless ( $session->setting->get("specialState") eq "init" ) {
        return undef;
    }

    # Dispatch to the setup wizard
    my $wiz = WebGUI::Wizard::Setup->new( $session );
    return $wiz->dispatch;
} 

1;

