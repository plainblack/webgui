package WebGUI::Form::Slider;

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

Package WebGUI::Form::Slider

=head1 DESCRIPTION

Abstract base class for slider controls. It cannot be used just by itself.
You must overload some of the methods.

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

=head4 maximum

Defaults to "100". The maximum that the slider can go to.

=head4 minimum

Defaults to "0". The minimum value that the slider can go to.

=head4 editable

Defaults to 1. Setting this option to 0 will hide the input element tied to the 
slider.

=cut

sub definition {
	my $class = shift;
	my $session = shift;
	my $definition = shift || [];
	push(@{$definition}, {
		maximum=>{
			defaultValue=> "100",
			},
		minimum=>{
			defaultValue=> "0",
			},
		editable=>{
			defaultValue=> "1",
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

	return $self->getOriginalValue();
}

#-------------------------------------------------------------------

=head2 getDisplayVariable ( )

Returns the javascript variable for the td element used for display of the
slider value.

=cut

sub getDisplayVariable {
	my $self = shift;

	my $uniqueness = $self->get('id');
	$uniqueness =~ s/-/\$/g;
	
	return 'd_'.$uniqueness;
}

#-------------------------------------------------------------------

=head2 getInputElement ( )

Returns the form element used for manual input. You must overload this method.

=cut

sub getInputElement {
	my $self = shift;

	$self->session->errorHandler->fatal("Subclasses of WebGUI::Form::Slider must overload getInputElement");
}

#-------------------------------------------------------------------

=head2 getInputVariable ( )

Returns the javascript variable for the input element tied to the slider.

=cut

sub getInputVariable {
	my $self = shift;

	my $uniqueness = $self->get('id');
	$uniqueness =~ s/-/\$/g;
	
	return 'i_'.$uniqueness;
}

#-------------------------------------------------------------------

=head2 getName ( session )

Returns the human readable name of this control.

=cut

sub getName {
    my ($self, $session) = @_;
    return WebGUI::International->new($session, 'WebGUI')->get('slider');
}

#-------------------------------------------------------------------

=head2 getOnChangeInputElement ( )

This method should return the javascript code that should be executed on an
onchange event of the input element. This should at the very least include
updating the slider. 

You must overload this method.

For examples see any WebGUI::Form object that in herits
from this class. For instance WebGUI::Form::SelectSlider.

=cut

sub getOnChangeInputElement {
	my $self = shift;

	$self->session->errorHandler->fatal("Subclasses of WebGUI::Form::Slider must overload getOnChangeInputElement");
}

#-------------------------------------------------------------------

=head2 getOnChangeSlider ( )

This method should return the javascript code that should be executed on an
onchange event of the slider. This should at the very least include
updating the input element and the display table cell. 

You must overload this method.

For examples see any WebGUI::Form object that in herits
from this class. For instance WebGUI::Form::SelectSlider.

=cut

sub getOnChangeSlider {
	my $self = shift;
	
	$self->session->errorHandler->fatal("Subclasses of WebGUI::Form::Slider must overload getOnChangeSlider");
}

#-------------------------------------------------------------------

=head2 getSliderMaximum ( )

Returns the maximum value the slider can be set to in slider units.

=cut

sub getSliderMaximum {
	my $self = shift;

	return $self->get('maximum');
}

#-------------------------------------------------------------------

=head2 getSliderMinimum ( )

Returns the minimum value the slider can be set to in slider units.

=cut

sub getSliderMinimum {
	my $self = shift;

	return $self->get('minimum');
}

#-------------------------------------------------------------------

=head2 getSliderValue ( )

Returns the initial position of the slider in slider units.

=cut

sub getSliderValue {
	my $self = shift;

	return $self->getOriginalValue();
}

#-------------------------------------------------------------------

=head2 getSliderVariable ( )

Returns the javascript variable for the slider.

=cut

sub getSliderVariable {
	my $self = shift;

	my $uniqueness = $self->get('id');
	$uniqueness =~ s/-/\$/g;
	
	return 's_'.$uniqueness;
}

#-------------------------------------------------------------------

=head2 toHtml ( )

Renders an input tag of type text.

=cut

sub toHtml {
	my $self = shift;
	$self->session->style->setScript($self->session->url->extras("slider/js/range.js"), {type=>"text/javascript"});
	$self->session->style->setScript($self->session->url->extras("slider/js/timer.js"), {type=>"text/javascript"});
	$self->session->style->setScript($self->session->url->extras("slider/js/slider.js"), {type=>"text/javascript"});
	$self->session->style->setLink($self->session->url->extras("slider/css/bluecurve/bluecurve.css"), {rel=>"stylesheet", type=>"text/css"});

	# We need to make the variables unique because javascript does not have block scope. Also js cannot 
	# have dashes in identifiers, so we convert those to dollars, which are allowed in identifiers.
	my $uniqueness = $self->get('id');
	$uniqueness =~ s/-/\$/g;
	
	my $output = '<table border="0"><tr>';

	# Slider
	$output .= '<td><div class="slider" id="'.$self->get('id').'" '.$self->get("extras").' tabindex="1">';
	$output .= WebGUI::Form::hidden($self->session, {
		-name	=> 'slider-'.$self->get('name'),
		-value	=> $self->getOriginalValue(),
		-id	=> $self->get('id').'-input',
		-extras	=> 'class="slider-input"',
	});
	$output .= '</div></td>';
	
	if ($self->get('editable')) {
		# Form element
		$output .= '<td>'.$self->getInputElement.'</td>';

		# Display box
		$output .= '<td style="display : none;" id="text-'.$self->get('id').'">';
		$output .= $self->getDisplayValue;
		$output .= '</td>';
	} else {
		# Form element
		$output .= '<td style="display : none;">'.$self->getInputElement.'</td>';

		# Display box
		$output .= '<td id="text-'.$self->get('id').'">';
		$output .= $self->getDisplayValue;
		$output .= '</td>';
	}
	
	$output .= '</tr></table>';

	# Javascript
	my $input = $self->getInputVariable;
	my $display = $self->getDisplayVariable;
	my $slider = $self->getSliderVariable;
	my $id = $self->get('id');
	
	$output .= '<script type="text/javascript">';
	$output .= qq|
		var $input = document.getElementById('view-$id');
		var $display = document.getElementById('text-$id');
		var sliderEl_$uniqueness = document.getElementById ? document.getElementById('$id') : null;
		var inputEl_$uniqueness = document.forms[0]['$id-input'];
		var $slider = new Slider(sliderEl_$uniqueness, inputEl_$uniqueness);
		
		$slider.setMaximum(|.$self->getSliderMaximum.qq|);
		$slider.setMinimum(|.$self->getSliderMinimum.qq|);
		$slider.setValue("|.$self->getSliderValue.qq|");
		
		$slider.onchange = function () {|.
			$self->getOnChangeSlider.qq|;
		};

		$input.onchange = function () {|.
			$self->getOnChangeInputElement.qq|;
		};
	|;
	$output .= '</script>';

	return $output;
}

1;

