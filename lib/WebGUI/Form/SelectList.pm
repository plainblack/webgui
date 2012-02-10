package WebGUI::Form::SelectList;

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

Package WebGUI::Form::SelectList

=head1 DESCRIPTION

Creates a select list, aka dropdown list form control with multiple select.

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

The number of characters tall this list should be. Defaults to '5'.

=head4 multiple

A boolean indicating whether the user can select multiple items from this list like a checkList. Defaults to "1".

=cut

sub definition {
	my $class = shift;
	my $session = shift;
	my $definition = shift || [];
	push(@{$definition}, {
		multiple=>{
			defaultValue=>1
        },
		size=>{
			defaultValue=>5
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
    return WebGUI::International->new($session, 'WebGUI')->get('484');
}

#-------------------------------------------------------------------

=head2 isDynamicCompatible ( )

A class method that returns a boolean indicating whether this control is compatible with the DynamicField control.

=cut

sub isDynamicCompatible {
    return 1;
}

#-------------------------------------------------------------------

=head2 isInRequest ( )

=cut


sub isInRequest {
    my $self = shift;
    my $form = $self->session->form;
    return $form->hasParam($self->privateName('isIn'));
}

#-------------------------------------------------------------------

=head2 toHtml ( )

Renders a select list form control.

=cut

sub toHtml {
	my $self     = shift;
    my $session  = $self->session;
	my $multiple = $self->get("multiple") ? ' multiple="multiple"' : '';
	my $output   = '<select name="'.($self->get("name")||'').'" size="'.($self->get("size")||'').'" id="'.($self->get('id')||'').'" '.($self->get("extras")||'').$multiple.'>';
    my $options = $self->getOptions;
	my @values = $self->getOriginalValue();
	foreach my $key (keys %{$options}) {
		$output .= '<option value="'.$key.'"';
		foreach my $item (@values) {
			if ($item eq $key) {
				$output .= ' selected="selected"';
			}
		}
		$output .= '>'.$options->{$key}.'</option>';
	}
	$output .= '</select>'."\n";
    $output .= WebGUI::Form::Hidden->new($session, { name => $self->privateName('isIn'), value => 1, })->toHtml;
	return $output;
}

1;

