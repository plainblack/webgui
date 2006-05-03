package WebGUI::Form::HexSlider;

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

=head1 NAME

Package WebGUI::Form::HexSlider

=head1 DESCRIPTION

Creates a slider control that controls hex values, as in the red, gree, blue values for HTML colors.

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

Defaults to "ff". The maximum that the slider can go to.

=head4 minimum

Defaults to "00". The minimum value that the slider can go to.

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
			defaultValue=> $i18n->get("475")
			},
		maximum=>{
			defaultValue=> "ff",
			},
		minimum=>{
			defaultValue=> "00",
			},
		profileEnabled=>{
			defaultValue=>1
			},
		});
        return $class->SUPER::definition($session, $definition);
}

#-------------------------------------------------------------------

=head2 getValueFromPost ( )

Retrieves a value from a form GET or POST and returns it. If the value comes back as undef, this method will return the defaultValue instead.  Strip newlines/carriage returns from the value.

=cut

sub getValueFromPost {
	my $self = shift;
	my $formValue = $self->session->form->param($self->get("name")) if ($self->session->request);
	if (defined $formValue && $formValue =~ m/^[a-f0-9]{2}$/) {
		return $formValue;
	} else {
		return $self->{defaultValue};
	}
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
	my $output = '<div class="slider" id="'.$self->get('id').'" '.$self->get("extras").' tabindex="1">
   <input class="slider-input" id="'.$self->get('id').'-input" name="'.$self->get("name").'" value="'.$self->get("value").'" />
</div><script type="text/javascript">
var sliderEl = document.getElementById ?  document.getElementById("'.$self->get('id').'") : null;
var inputEl = document.forms[0]["'.$self->get('id').'-input"];
var s = new Slider(sliderEl, inputEl);
/* s.setMaximum('.$self->get("maximum").');
s.setMinimum('.$self->get("minimum").');
s.setValue('.$self->get("value").'); */
</script>';
	return $output;
}

1;

