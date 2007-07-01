package WebGUI::Form::SelectSlider;

=head1 LEGAL

 -------------------------------------------------------------------
  WebGUI is Copyright 2001-2007 Plain Black Corporation.
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
use WebGUI::Form::SelectList;
use WebGUI::International;

=head1 NAME

Package WebGUI::Form::HexSlider

=head1 DESCRIPTION

Creates a slider control that controls hex values, as in the red, gree, blue values for HTML colors.

=head1 SEE ALSO

This is a subclass of WebGUI::Form::Control.

=head1 METHODS 

The following methods are specifically available from this class. Check the superclass for additional methods.

=cut

sub definition {
	my $class = shift;
	my $session = shift;
	my $definition = shift || [];
	my $i18n = WebGUI::International->new($session);
	push(@{$definition}, {
		formName=>{
			defaultValue=> $i18n->get("select slider")
			},
		options =>{
			defaultValue=>{},
			},
		value	=>{
			defaultValue=>[],
		},
		profileEnabled=>{
			defaultValue=>1
			},
        dbDataType  => {
            defaultValue => "TEXT",
        },
		});
        return $class->SUPER::definition($session, $definition);
}

#-------------------------------------------------------------------

=head2 getDisplayValue ( )

Returns the value that should be displayed initially.

=cut

sub getDisplayValue {
	my $self = shift;

	return $self->get('options')->{$self->get('value')->[0]};
}

#-------------------------------------------------------------------

=head2 getInputElement ( )

Returns the form element used for manual input.

=cut

sub getInputElement {
	my $self = shift;

	return WebGUI::Form::selectList($self->session, {
		-name	=> $self->get('name'),
		-value	=> $self->get('value'),
		-options=> $self->get('options'),
		-id	=> 'view-'.$self->get('id'),
		-size	=> 1,
	});
}

#-------------------------------------------------------------------

=head2 getOnChangeInputElement ( )

Returns the javascript code to update the slider and other form elements on a
change of the imput element.

=cut

sub getOnChangeInputElement {
	my $self = shift;
	
	return 
		$self->getSliderVariable.'.setValue(this.selectedIndex);'.
		$self->getDisplayVariable.'.innerHTML = this.options[this.selectedIndex].text;';
}

#-------------------------------------------------------------------

=head2 getOnChangeSlider ( )

Returns the javascript code to update the form on a change of slider position.

=cut

sub getOnChangeSlider {
	my $self = shift;
	
	return 
		$self->getInputVariable.'.selectedIndex = this.getValue();'.
		$self->getDisplayVariable.'.innerHTML = '.$self->getInputVariable.'.options[this.getValue()].text;';
}

#-------------------------------------------------------------------

=head2 getSliderMaximum ( )

Returns the maximum value the slider can be set to in slider units.

=cut

sub getSliderMaximum {
	my $self = shift;

	return scalar(keys %{$self->get('options')}) - 1;
}

#-------------------------------------------------------------------

=head2 getSliderMinimum ( )

Returns the minimum value the slider can be set to in slider units.

=cut

sub getSliderMinimum {
	my $self = shift;

	return '0';
}

#-------------------------------------------------------------------

=head2 getSliderValue ( )

Returns the initial position of the slider in slider units.

=cut

sub getSliderValue {
	my $self = shift;

	my @keys = keys %{$self->get('options')};
	for (my $i = 0; $i < @keys; $i++) {
		return $i if $keys[$i] eq $self->get('value')->[0];
	}

	return undef;
}

#-------------------------------------------------------------------

=head2 getValueFromPost ( [ value ] )

Retrieves a value from a form GET or POST and returns it. If the value comes
back as undef, this method will return the defaultValue instead. Strip
newlines/carriage returns from the value.

=head2 value

A value to process instead of POST input.

=cut

sub getValueFromPost {
	my $self = shift;
	my @args = @_;

	my $properties =  {
		-name	=> $self->get('name'),
		-value	=> $self->get('value'),
		-options=> $self->get('options'),
		-id	=> 'view-'.$self->get('id'),
		-size	=> 1,
	};

	return WebGUI::Form::SelectList->new($self->session, $properties)->getValueFromPost(@args);
}


1;

