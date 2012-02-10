package WebGUI::Form::SelectSlider;

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
use WebGUI::Form::SelectBox;
use WebGUI::International;
use Tie::IxHash;

=head1 NAME

Package WebGUI::Form::SelectSlider

=head1 DESCRIPTION

Creates a slider control that chooses arbitrary, programmer supplied values.  Similar
to a SelectBox, but with a different UI.

=head1 SEE ALSO

This is a subclass of WebGUI::Form::Slider.

=head1 METHODS 

The following methods are specifically available from this class. Check the superclass for additional methods.

=cut

sub definition {
	my $class = shift;
	my $session = shift;
	my $definition = shift || [];
	push(@{$definition}, {
		options =>{
			defaultValue=>{},
			},
		value	=>{
		},
		});
        return $class->SUPER::definition($session, $definition);
}

#-------------------------------------------------------------------

=head2  getDatabaseFieldType ( )

Returns "TEXT".

=cut 

sub getDatabaseFieldType {
    return "TEXT";
}

#-------------------------------------------------------------------

=head2 getName ( session )

Returns the human readable name of this control.

=cut

sub getName {
    my ($self, $session) = @_;
    return WebGUI::International->new($session, 'WebGUI')->get('select slider');
}

#-------------------------------------------------------------------

=head2 getDisplayValue ( )

Returns the value that should be displayed initially.

=cut

sub getDisplayValue {
	my $self = shift;
    my $options = $self->getOptions;
	return $options->{$self->getOriginalValue} || $options->{(keys %$options)[0]};
}

#-------------------------------------------------------------------

=head2 getInputElement ( )

Returns the form element used for manual input.

=cut

sub getInputElement {
	my $self = shift;

	return WebGUI::Form::SelectBox($self->session, {
		-name	=> $self->get('name'),
		-value	=> $self->getOriginalValue,
		-options=> $self->getOptions,
		-id	=> 'view-'.$self->get('id'),
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

=head2 getOptions ( )

Options are passed in for many list types. Those options can come in as a hash ref, or a \n separated string, or a key|value\n separated string. This method returns a hash ref regardless of what's passed in.

=cut

sub getOptions {
    my ($self) = @_;
    my $possibleValues = $self->get('options');
    my %options = ();
    tie %options, 'Tie::IxHash';
    if (ref $possibleValues eq "HASH") {
       %options = %{$possibleValues};
    }
    else {
        foreach my $line (split "\n", $possibleValues) {
            $line =~ s/^(.*)\r|\s*$/$1/;
            if ($line =~ m/(.*)|(.*)/) {
                $options{$1} = $2;
            }
            else {
                $options{$line} = $line;
            }
        }
    } 
    return \%options;
}

#-------------------------------------------------------------------

=head2 getSliderMaximum ( )

Returns the maximum value the slider can be set to in slider units.

=cut

sub getSliderMaximum {
	my $self = shift;

	return scalar(keys %{$self->getOptions}) - 1;
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

	my @keys = keys %{$self->getOptions};
	for (my $i = 0; $i < @keys; $i++) {
		return $i if $keys[$i] eq $self->getOriginalValue;
	}
    return $keys[0];
}

#-------------------------------------------------------------------

=head2 getValue ( [ value ] )

Retrieves a value from a form GET or POST and returns it. If the value comes
back as undef, this method will return the defaultValue instead. Strip
newlines/carriage returns from the value.

=head2 value

A value to process instead of POST input.

=cut

sub getValue {
	my $self = shift;
	my @args = @_;

	my $properties =  {
		-name	=> $self->get('name'),
		-value	=> $self->get('value'),
		-options=> $self->getOptions,
		-id	=> 'view-'.$self->get('id'),
	};

    my $newValue = WebGUI::Form::SelectBox->new($self->session, $properties)->getValue(@args);
    return $self->{_param}{value} = $newValue;
}


#-------------------------------------------------------------------

=head2 isDynamicCompatible ( )

A class method that returns a boolean indicating whether this control is compatible with the DynamicField control.

=cut

sub isDynamicCompatible {
    return 1;
}

1;

