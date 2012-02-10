package WebGUI::Form::Password;

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
use base 'WebGUI::Form::Control';
use WebGUI::International;

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
	my $session = shift;
	my $definition = shift || [];
	push(@{$definition}, {
		maxlength=>{
			defaultValue=>35
			},
		size=>{
			defaultValue=>30
			},
		});
        return $class->SUPER::definition($session, $definition);
}

#-------------------------------------------------------------------

=head2 getName ( session )

Returns the human readable name of this control.

=cut

sub getName {
    my ($self, $session) = @_;
    return WebGUI::International->new($session, 'WebGUI')->get('51');
}

#-------------------------------------------------------------------

=head2 getValueAsHtml ( )

Formats as ******.

=cut

sub getValueAsHtml {
    return '******';
}


#-------------------------------------------------------------------

=head2 isDynamicCompatible ( )

A class method that returns a boolean indicating whether this control is compatible with the DynamicField control.

=cut

sub isDynamicCompatible {
    return 1;
}

#-------------------------------------------------------------------

=head2 toHtml ( )

Renders an input tag of type password.

=cut

sub toHtml {
	my $self = shift;
	my $html = '<input type="password" name="'.$self->get("name").'" value="'.$self->fixQuotes($self->getOriginalValue).'" size="'.$self->get("size").'" id="'.$self->get('id').'" ';
	$html .= 'maxlength="'.$self->get("maxlength").'" ' if ($self->get("maxlength"));
	$html .= $self->get("extras").' />';
	return $html;
}


1;

