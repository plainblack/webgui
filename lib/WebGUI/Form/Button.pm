package WebGUI::Form::Button;

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

Package WebGUI::Form::Button

=head1 DESCRIPTION

Creates a form button.

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

=head4 defaultValue

The default text to appear on the button. Defaults to an internationalized version of the word "save".

=cut

sub definition {
	my $class = shift;
	my $definition = shift || [];
	push(@{$definition}, {
		formName=>{
			defaultValue=>WebGUI::International::get("button","WebGUI")
			},
		defaultValue=>{
			defaultValue=>WebGUI::International::get(62,"WebGUI")
			},
		});
	return $class->SUPER::definition($definition);
}

#-------------------------------------------------------------------

=head2 toHtml ( )

Renders a button.

=cut

sub toHtml {
	my $self = shift;
 	my $value = $self->fixQuotes($self->get("value"));
	my $html = '<input type="button" ';
	$html .= 'name="'.$self->get("name").'" ' if ($self->get("name"));
	$html .= 'id="'.$self->{id}.'" ' unless ($self->{id} eq "_formId");
	$html .= 'value="'.$value.'" '.$self->get("extras").' />';
	return $html;
}

1;

