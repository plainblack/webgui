package WebGUI::Form::Text;

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

Package WebGUI::Form::Text

=head1 DESCRIPTION

Creates a text input box form field.

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

Defaults to 255. Determines the maximum number of characters allowed in this field.

=head4 size

Defaults to the setting textBoxSize or 30 if that's not set. Specifies how big of a text box to display.

=head4 profileEnabled

Flag that tells the User Profile system that this is a valid form element in a User Profile

=cut

sub definition {
	my $class = shift;
	my $definition = shift || [];
	push(@{$definition}, {
		formName=>{
			defaultValue=> WebGUI::International::get("475","WebGUI")
			},
		maxlength=>{
			defaultValue=> 255
			},
		size=>{
			defaultValue=>$self->session->setting->get("textBoxSize") || 30
			},
		profileEnabled=>{
			defaultValue=>1
			},
		});
	return $class->SUPER::definition($definition);
}

#-------------------------------------------------------------------

=head2 toHtml ( )

Renders an input tag of type text.

=cut

sub toHtml {
	my $self = shift;
 	my $value = $self->fixMacros($self->fixQuotes($self->fixSpecialCharacters($self->get("value"))));
        return '<input id="'.$self->{id}.'" type="text" name="'.$self->get("name").'" value="'.$value.'" size="'.$self->get("size").'" maxlength="'.$self->get("maxlength").'" '.$self->get("extras").' />';
}

1;

