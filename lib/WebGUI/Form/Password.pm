package WebGUI::Form::Password;

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

Package WebGUI::Form::Password

=head1 DESCRIPTION

Creates a password input box form field.

=head1 SEE ALSO

This is a subclass of WebGUI::Form::Control.

=head1 METHODS 

The following methods are specifically available from this class. Check the superclass for additional methods.

=cut

#-------------------------------------------------------------------

=head2 definition ( [ additionalTerms ] )

See the super class for additional details.

=head3 additionalTerms

The following additional parameters have been added via this sub class.

=head4 maxlength

Defaults to 35. Determines the maximum number of characters allowed in this field.

=head4 size

Defaults to 30. Specifies how big of a text box to display.

=cut

sub definition {
	my $class = shift;
	my $definition = shift || [];
	push(@{$definition}, {
		maxlength=>{
			defaultValue=>35
			},
		size=>{
			defaultValue=>30
			}
		});
	return $class->SUPER::definition($definition);
}


#-------------------------------------------------------------------

=head2 getName ()

Returns the human readable name or type of this form control.

=cut

sub getName {
        return WebGUI::International::get("51","WebGUI");
}



#-------------------------------------------------------------------

=head2 toHtml ( )

Renders an input tag of type password.

=cut

sub toHtml {
	my $self = shift;
	my $html = '<input type="password" name="'.$self->{name}.'" value="'.$self->fixQuotes($self->{value}).'" size="'.$self->{size}.'" id="'.$self->{id}.'" ';
	$html .= 'maxlength="'.$self->{maxLength}.'" ' if ($self->{maxLength});
	$html .= $self->{extras}.' />';
	return $html;
}


1;

