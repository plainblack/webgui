package WebGUI::Content::Wizard;

use strict;

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

=head1 NAME

Package WebGUI::Content::Wizard

=head1 DESCRIPTION

A content handler for WebGUI::Wizard modules.  Dispatches to WebGUI::Wizard after process form variables.

=head2 handler ( session ) 

The content handler for this package.

=cut

sub handler {
    my ( $session ) = @_;

    if ( $session->form->get('op') eq 'wizard' && $session->form->get('wizard_class') ) {
        my $class = $session->form->get('wizard_class');
        WebGUI::Pluggable::load($class);
        if ( $class->isa( 'WebGUI::Wizard' ) ) {
            my $wizard  = $class->new( $session );
            return $wizard->dispatch;
        }
        else {
            return "Sminternal Smerver Smerror";
        }
    }
}

1;
