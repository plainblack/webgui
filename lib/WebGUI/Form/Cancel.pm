package WebGUI::Form::Cancel;

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
use base 'WebGUI::Form::Button';
use WebGUI::International;

=head1 NAME

Package WebGUI::Form::Cancel

=head1 DESCRIPTION

Created a "Cancel" button that goes back in history or links to the referrer, depending.

=head1 SEE ALSO

This is a subclass of WebGUI::Form::Button.

=head1 METHODS 

The following methods are specifically available from this class. Check the superclass for additional methods.

=cut

sub new {

    my $package = shift;
    my $session = shift;

    # taken from WebGUI::TabForm so that it can be easily added to FormBuilder built forms
    my $i18n = WebGUI::International->new($session);

    my $cancelURL = $session->request->referer;
    my $cancelJS_fragment = $cancelURL ? sprintf("window.location.href='%s'", $cancelURL) : ' history.go(-1)';
    my $cancelJS  = q{
        if( window.parent && window.parent.admin && window.parent.admin.modalDialog ) {
            window.parent.admin.closeModalDialog();
        } else {
            $cancelJS_fragment;
        }
    };

    $package->SUPER::new( $session, 
        value  => ucfirst( $i18n->get('cancel') ), 
        extras => qq{onclick="javascript: $cancelJS" class="backwardButton"},
        @_,
    );

}

1;

