package WebGUI::Form::Password;

=head1 LEGAL

 -------------------------------------------------------------------
  WebGUI is Copyright 2001-2006 Plain Black Corporation.
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

=head4 profileEnabled

Flag that tells the User Profile system that this is a valid form element in a User Profile

=cut

sub definition {
	my $class = shift;
	my $session = shift;
	my $definition = shift || [];
	my $i18n = WebGUI::International->new($session);
	push(@{$definition}, {
		formName=>{
			defaultValue=>$i18n->get("51")
			},
		maxlength=>{
			defaultValue=>35
			},
		size=>{
			defaultValue=>30
			},
		profileEnabled=>{
			defaultValue=>1
			},
		});
        return $class->SUPER::definition($session, $definition);
}

#-------------------------------------------------------------------

=head2 toHtml ( )

Renders an input tag of type password.

=cut

sub toHtml {
	my $self = shift;
	my $html = '<input type="password" name="'.$self->get("name").'" value="'.$self->fixQuotes($self->get("value")).'" size="'.$self->get("size").'" id="'.$self->{id}.'" ';
	$html .= 'maxlength="'.$self->get("maxLength").'" ' if ($self->get("maxLength"));
	$html .= $self->get("extras").' />';
	return $html;
}


1;

