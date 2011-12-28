package WebGUI::Form::SelectBox;

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
use base 'WebGUI::Form::List';
use WebGUI::International;

=head1 NAME

Package WebGUI::Form::SelectBox

=head1 DESCRIPTION

Creates a select list, aka dropdown list form control with single select.

=head1 SEE ALSO

This is a subclass of WebGUI::Form::List.

=head1 METHODS 

The following methods are specifically available from this class. Check the superclass for additional methods.

=cut

#-------------------------------------------------------------------

=head2 definition ( [ additionalTerms ] )

See the super class for additional details.

=head3 additionalTerms

The following additional parameters have been added via this sub class.

=head4 size

The number of characters tall this list should be. Defaults to '1'.

=cut

sub definition {
	my $class = shift;
	my $session = shift;
	my $definition = shift || [];
	push(@{$definition}, {
		defaultValue=>{
			defaultValue=>'', # gotta be a scalar, not an arrayref.
			},
		size=>{
			defaultValue=>1,
			},
		});
        return $class->SUPER::definition($session, $definition);
}

#-------------------------------------------------------------------

=head2  getDatabaseFieldType ( )

Returns "CHAR(255)".

=cut 

sub getDatabaseFieldType {
    return "CHAR(255)";
}

#-------------------------------------------------------------------

=head2 getName ( session )

Returns the human readable name of this control.

=cut

sub getName {
    my ($self, $session) = @_;
    return WebGUI::International->new($session, 'WebGUI')->get('487');
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

=head2 getDefaultValue ( )

Returns the either the "value" or "defaultValue" passed in to the object in that order, and doesn't take into account form processing.

=cut

sub getDefaultValue {
    my $self = shift;
    my $value = $self->get("defaultValue");
	if (ref $value eq 'ARRAY') {
		$value = $value->[0];
	}
	return $value;
}

=head2 getOriginalValue ( )

Returns the either the "value" or "defaultValue" passed in to the object in that order, and doesn't take into account form processing.

=cut

sub getOriginalValue {
    my $self = shift;
    my $value = $self->get("value");
    unless (defined $value) {
		$value = $self->getDefaultValue();
	}
	if (ref $value eq 'ARRAY') {
		$value = $value->[0];
	}
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

Renders a select list form control.

=cut

sub toHtml {
	my $self = shift;
	my $output = '<select name="'.($self->get("name")||'').'" size="'.($self->get("size")||'').'" id="'.($self->get('id')||'').'" '.($self->get("extras")||'').'>';
    my $options = $self->getOptions;
	my $value = $self->getOriginalValue();

    # Recurse for <optgroups>
    my $buildOptionsHtml;
    $buildOptionsHtml = sub {
        my $options = shift;
        foreach my $key (keys %{$options}) {
            if ( ref $options->{$key} eq 'HASH' ) {
                $output .= qq{<optgroup label="$key">};
                $buildOptionsHtml->($options->{$key});
                $output .= qq{</optgroup>};
            }
            else {
                $output .= '<option value="'.$key.'"';
                if ($value eq $key) {
                    $output .= ' selected="selected"';
                }
                $output .= '>'.$options->{$key}.'</option>';
            }
        }
    };
    $buildOptionsHtml->($options);

	$output .= '</select>'."\n";
	return $output;
}

1;

