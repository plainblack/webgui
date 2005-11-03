package WebGUI::Form::SelectList;

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
use WebGUI::Form::HiddenList;
use WebGUI::International;
use WebGUI::Session;

=head1 NAME

Package WebGUI::Form::SelectList

=head1 DESCRIPTION

Creates a select list, aka dropdown list form control.

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

=head4 options

A hash reference containing key values that will be returned with the form post and displayable text pairs. Defaults to an empty hash reference.

=head4 defaultValue

An array reference of the items to be checked if no value is specified. Defaults to an empty array reference.

=head4 size

The number of characters tall this list should be. Defaults to '1'.

=head4 multiple

Boolean indicating whether the user can select multiple items from this list like a checkList. Defaults to "0".

=head4 sortByValue

A boolean value for whether or not the values in the options hash should be sorted. Defaults to "0".

=cut

sub definition {
	my $class = shift;
	my $definition = shift || [];
	push(@{$definition}, {
		options=>{
			defaultValue=>{}
			},
		defaultValue=>{
			defaultValue=>[],
			},
		multiple=>{
			defaultValue=>0
			},
		sortByValue=>{
			defaultValue=>0
			},
		size=>{
			defaultValue=>1
			}
		});
	return $class->SUPER::definition($definition);
}


#-------------------------------------------------------------------

=head2 getName ()

Returns the human readable name or type of this form control.

=cut

sub getName {
        return WebGUI::International::get("484","WebGUI");
}


#-------------------------------------------------------------------

=head2 getValueFromPost ( )

Returns an array or a carriage return ("\n") separated scalar depending upon whether you're returning the values into an array or a scalar.

=cut

sub getValueFromPost {
	my $self = shift;
	my @data = $session{req}->param($self->{name});
        return wantarray ? @data : join("\n",@data);
}

#-------------------------------------------------------------------

=head2 toHtml ( )

Renders a select list form control.

=cut

sub toHtml {
	my $self = shift;
        my $multiple = ' multiple="1"' if ($self->{multiple});
        my $output = '<select name="'.$self->{name}.'" size="'.$self->{size}.'" id="'.$self->{id}.'" '.$self->{extras}.$multiple.'>';
        my %options;
        tie %options, 'Tie::IxHash';
        if ($self->{sortByValue}) {
                foreach my $optionKey (sort {"\L${$self->{options}}{$a}" cmp "\L${$self->{options}}{$b}" } keys %{$self->{options}}) {
                         $options{$optionKey} = $self->{options}{$optionKey};
                }
        } else {
                %options = %{$self->{options}};
        }
        foreach my $key (keys %options) {
                $output .= '<option value="'.$key.'"';
                 foreach my $item (@{$self->{value}}) {
                        if ($item eq $key) {
                                $output .= ' selected="selected"';
                        }
                }
                $output .= '>'.${$self->{options}}{$key}.'</option>';
        }
        $output .= '</select>'."\n";
        return $output;
}

#-------------------------------------------------------------------

=head2 toHtmlAsHidden ( )

Creates a series of hidden fields representing the data in the list.

=cut

sub toHtmlAsHidden {
	my $self = shift;
	return WebGUI::Form::HiddenList->new(
		value=>$self->{value},
		defaultValue=>$self->{defaultValue},
		name=>$self->{name},
		options=>$self->{options}
		)->toHtmlAsHidden;
}

1;

