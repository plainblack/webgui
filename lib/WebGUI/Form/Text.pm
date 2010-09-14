package WebGUI::Form::Text;

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
use base 'WebGUI::Form::Control';
use WebGUI::International;

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

=cut

sub definition {
	my $class = shift;
	my $session = shift;
	my $definition = shift || [];
	push(@{$definition}, {
		maxlength=>{
			defaultValue=> 255
			},
		size=>{
			defaultValue=>$session->setting->get("textBoxSize") || 30
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
    return WebGUI::International->new($session, 'WebGUI')->get('475');
}

#-------------------------------------------------------------------

=head2 getValue ( [ value ] )

Retrieves a value from a form GET or POST and returns it. If the value comes back as undef, this method will return the defaultValue instead.  Strip newlines/carriage returns from the value.

=head3 value

An optional value to process, instead of POST input.

=cut

sub getValue {
	my $self = shift;
    my $value = $self->SUPER::getValue(@_);
    $value =~ tr/\r\n//d;
    return $value;
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

Renders an input tag of type text.

=cut

sub toHtml {
	my $self = shift;
    $self->headTags();
 	my $value = $self->fixMacros($self->fixQuotes($self->fixSpecialCharacters(scalar $self->getOriginalValue)));
        return '<input id="'.$self->get('id').'" type="text" name="'.$self->get("name").'" value="'.$value.'" size="'.$self->get("size").'" maxlength="'.$self->get("maxlength").'" '.$self->get("extras").' />';
}

1;

