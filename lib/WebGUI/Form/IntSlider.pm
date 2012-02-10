package WebGUI::Form::IntSlider;

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
use base 'WebGUI::Form::Slider';
use WebGUI::International;

=head1 NAME

Package WebGUI::Form::IntSlider

=head1 DESCRIPTION

Creates a slider control that controls integer values.

=head1 SEE ALSO

This is a subclass of WebGUI::Form::Slider.

=head1 METHODS 

The following methods are specifically available from this class. Check the superclass for additional methods.

=cut

#-------------------------------------------------------------------

=head2 definition ( [ additionalTerms ] )

See the super class for additional details.

=head3 additionalTerms

The following additional parameters have been added via this sub class.

=head4 size

The length of the input box.

=cut

sub definition {
	my $class = shift;
	my $session = shift;
	my $definition = shift || [];
	push(@{$definition}, {
		size=>{
			defaultValue=> "3",
			},
		});
        return $class->SUPER::definition($session, $definition);
}

#-------------------------------------------------------------------

=head2  getDatabaseFieldType ( )

Returns "BIGINT".

=cut 

sub getDatabaseFieldType {
    return "BIGINT";
}

#-------------------------------------------------------------------

=head2 getInputElement ( )

Returns the form element used for manual input.

=cut

sub getInputElement {
	my $self = shift;

    $self->session->log->warn("int slider value: ". $self->getSliderValue);
	return WebGUI::Form::Integer($self->session, {
		name	=> $self->get('name'),
		value	=> $self->getSliderValue(),
		size	=> $self->get('size'),
		id	=> 'view-'.$self->get('id'),
	});
}

#-------------------------------------------------------------------

=head2 getName ( session )

Returns the human readable name of this control.

=cut

sub getName {
    my ($self, $session) = @_;
    return WebGUI::International->new($session, 'WebGUI')->get('int slider');
}

#-------------------------------------------------------------------

=head2 getOnChangeInputElement ( )

Returns the javascript code to update the slider and other form elements on a
change of the imput element.

=cut

sub getOnChangeInputElement {
	my $self = shift;
	
	return $self->getSliderVariable.'.setValue(parseInt(this.value));'.
		$self->getDisplayVariable.'.innerHTML = this.value;';
}

#-------------------------------------------------------------------

=head2 getOnChangeSlider ( )

Returns the javascript code to update the form on a change of slider position.

=cut

sub getOnChangeSlider {
	my $self = shift;
	
	return $self->getInputVariable.'.value = this.getValue();'.
		$self->getDisplayVariable.'.innerHTML = this.getValue();';
}

#-------------------------------------------------------------------

=head2 getValue ( [ value ] )

Retrieves a value from a form GET or POST and returns it. If the value comes back as undef, this method will return the defaultValue instead.  Strip newlines/carriage returns from the value.

=head2 value

A value to process instead of POST input.

=cut

sub getValue {
	my $self = shift;
	my @args = @_;

	my $properties = {
		name	=> $self->get('name'),
		value	=> $self->get('value'),
		size	=> $self->get('size'),
		id	=> 'view-'.$self->get('id'),
	};

	return WebGUI::Form::Integer->new($self->session, $properties)->getValue(@args);
}

#-------------------------------------------------------------------

=head2 isDynamicCompatible ( )

A class method that returns a boolean indicating whether this control is compatible with the DynamicField control.

=cut

sub isDynamicCompatible {
    return 1;
}

1;

