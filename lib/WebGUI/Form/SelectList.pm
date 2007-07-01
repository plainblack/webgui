package WebGUI::Form::SelectList;

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
			defaultValue=>$i18n->get("484"),
        },
		multiple=>{
			defaultValue=>1
        },
		size=>{
			defaultValue=>5
        },
		profileEnabled=>{
			defaultValue=>1
        },
        dbDataType => {
            defaultValue => "LONGTEXT",
        },
    });
    return $class->SUPER::definition($session, $definition);
}

#-------------------------------------------------------------------

=head2 toHtml ( )

Renders a select list form control.

=cut

sub toHtml {
	my $self = shift;
	my $multiple = $self->get("multiple") ? ' multiple="multiple"' : '';
	my $output = '<select name="'.($self->get("name")||'').'" size="'.($self->get("size")||'').'" id="'.($self->get('id')||'').'" '.($self->get("extras")||'').$multiple.'>';
	my %options;
	tie %options, 'Tie::IxHash';
	%options = $self->orderedHash;
	my @values = $self->getValues();
	foreach my $key (keys %options) {
		$output .= '<option value="'.$key.'"';
		foreach my $item (@values) {
			if ($item eq $key) {
				$output .= ' selected="selected"';
			}
		}
		$output .= '>'.$self->get("options")->{$key}.'</option>';
	}
	$output .= '</select>'."\n";
	return $output;
}

1;

