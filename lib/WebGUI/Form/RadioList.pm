package WebGUI::Form::RadioList;

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
use base 'WebGUI::Form::List';
use WebGUI::Form::Radio;
use WebGUI::International;

=head1 NAME

Package WebGUI::Form::RadioList

=head1 DESCRIPTION

Creates a series of radio button form fields.

=head1 SEE ALSO

This is a subclass of WebGUI::Form::List. Also take a look at WebGUI::Form::Radio as this class creates a list of radio buttons.

=head1 METHODS 

The following methods are specifically available from this class. Check the superclass for additional methods.

=cut

#-------------------------------------------------------------------

=head2 definition ( [ additionalTerms ] )

See the super class for additional details.

=head3 additionalTerms

The following additional parameters have been added via this sub class.

=head4 vertical

Boolean representing whether the checklist should be represented vertically or horizontally. If set to "1" will be displayed vertically. Defaults to "0".

=cut

sub definition {
	my $class = shift;
	my $session = shift;
	my $definition = shift || [];
	push(@{$definition}, {
		vertical=>{
			defaultValue=>0
			},
		defaultValue=>{
			defaultValue=>''
			}
		});
        return $class->SUPER::definition($session, $definition);
}


#-------------------------------------------------------------------

=head2 getName ( session )

Returns the human readable name of this control.

=cut

sub getName {
    my ($self, $session) = @_;
    return WebGUI::International->new($session, 'WebGUI')->get('942');
}

#-------------------------------------------------------------------

=head2 getValue ( [ value ] )

See WebGUI::Form::Control::getValue()

=cut

sub getValue {
	my $self = shift;
    return $self->WebGUI::Form::Control::getValue(@_);
}

#-------------------------------------------------------------------

=head2 getDefaultValue ( [ value ] )

See WebGUI::Form::Control::getDefaultValue()

=cut

sub getDefaultValue {
	my $self = shift;
    return $self->WebGUI::Form::Control::getDefaultValue(@_);
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

Renders a series of radio buttons.

=cut

sub toHtml {
	my $self = shift;
	my $output = '<fieldset style="border:none;margin:0;padding:0">';
	my $alignment = $self->alignmentSeparator;
	my $i=0;
    my $options = $self->getOptions;
	foreach my $key (keys %{$options}) {
		$i++;
        my $checked = 0;
        if ($self->getOriginalValue() eq $key) {
            $checked = 1;
        }
        $output .= WebGUI::Form::Radio->new($self->session, {
            name=>$self->get('name'),
            value=>$key,
            extras=>$self->get('extras'),
            checked=>$checked,
            id=>$self->get('name').$i
            })->toHtml;
        $output .= '<label for="'.$self->get('name').$i.'">'.$options->{$key}."</label>" . $alignment;
    }
    $output .= "</fieldset>";
    return $output;
}

1;

