package WebGUI::Form::SelectBox;

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

##-------------------------------------------------------------------

=head2 correctValues ( )

Override method from master class since SelectBox only support a single value

=cut

sub correctValues { }

#-------------------------------------------------------------------

=head2 definition ( [ additionalTerms ] )

See the super class for additional details.

=head3 additionalTerms

The following additional parameters have been added via this sub class.

=head4 size

The number of characters tall this list should be. Defaults to '1'.

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
			defaultValue=>$i18n->get("487"),
			},
		size=>{
			defaultValue=>1,
			},
		profileEnabled=>{
			defaultValue=>1,
			},
		});
        return $class->SUPER::definition($session, $definition);
}

#-------------------------------------------------------------------

=head2 getValueFromPost ( )

Retrieves a value from a form GET or POST and returns it. If the value comes back as undef, this method will return the defaultValue instead.  Note, this is exactly the same method as used by Control since SelectBoxes only support a single value.

=cut

sub getValueFromPost {
	my $self = shift;
	my $formValue = $self->session->request->param($self->get("name"));
	if (defined $formValue) {
		return $formValue;
	} else {
		return $self->get("defaultValue");
	}
}

#-------------------------------------------------------------------

=head2 toHtml ( )

Renders a select list form control.

=cut

sub toHtml {
	my $self = shift;
	my $output = '<select name="'.$self->get("name").'" size="'.$self->get("size").'" id="'.$self->get('id').'" '.$self->get("extras").'>';
	my %options;
	tie %options, 'Tie::IxHash';
	%options = $self->orderedHash;
	my ($value) = $self->getValues();
        foreach my $key (keys %options) {
		$output .= '<option value="'.$key.'"';
		if ($value eq $key) {
			$output .= ' selected="selected"';
		}
		$output .= '>'.$self->get('options')->{$key}.'</option>';
        }
	$output .= '</select>'."\n";
	return $output;
}

1;

