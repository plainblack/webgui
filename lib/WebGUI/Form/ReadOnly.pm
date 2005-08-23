package WebGUI::Form::ReadOnly;

=head1 LEGAL

 -------------------------------------------------------------------
  WebGUI is Copyright 2001-2005 Plain Black Corporation.
 -------------------------------------------------------------------
  Please read the legal notices (docs/legal.txt) and the license
  (docs/license.txt) that came with this distribution before using
  this software.
 -------------------------------------------------------------------
  http://www.plainblack.com                     info@plainblack.com
 -------------------------------------------------------------------

=cut

use strict;
use base 'WebGUI::Form::Control';
use WebGUI::International;
use WebGUI::Session;

=head1 NAME

Package WebGUI::Form::ReadOnly

=head1 DESCRIPTION

Prints out the value directly with no form control.

=head1 SEE ALSO

This is a subclass of WebGUI::Form::Control.

=head1 METHODS 

The following methods are specifically available from this class. Check the superclass for additional methods.

=cut


#-------------------------------------------------------------------

=head2 getName ()

Returns the human readable name or type of this form control.

=cut

sub getName {
        return WebGUI::International::get("read only","WebGUI");
}



#-------------------------------------------------------------------

=head2 getValueFromPost ( )

Returns undef.

=cut

sub getValueFromPost {
	return undef;
}


#-------------------------------------------------------------------

=head2 toHtml ( )

Renders the value.

=cut

sub toHtml {
	my $self = shift;
	return $self->{value};
}

#-------------------------------------------------------------------

=head2 toHtmlAsHidden ( )

Outputs nothing.

=cut

sub toHtmlAsHidden {
	return undef;
}	


1;

