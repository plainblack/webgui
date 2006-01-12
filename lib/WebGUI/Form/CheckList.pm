package WebGUI::Form::CheckList;

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
use WebGUI::Form::Checkbox;

=head1 NAME

Package WebGUI::Form::CheckList

=head1 DESCRIPTION

Creates a series of check box form fields.

=head1 SEE ALSO

This is a subclass of WebGUI::Form::List. Also take a look at WebGUI::Form::Checkbox as this class creates a list of checkboxes.

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

=head4 profileEnabled

Flag that tells the User Profile system that this is a valid form element in a User Profile

=cut

sub definition {
	my $class = shift;
	my $session = shift;
	my $definition = shift || [];
	my $i18n = WebGUI::International->new($self->session);
	push(@{$definition}, {
		formName=>{
			defaultValue=>$i18n->get("941"),
			},
		vertical=>{
			defaultValue=>0
			},
		profileEnabled=>{
			defaultValue=>1
			}
		});
        return $class->SUPER::definition($session, $definition);
}

#-------------------------------------------------------------------

=head2 toHtml ( )

Renders a series of checkboxes.

=cut

sub toHtml {
	my $self = shift;
	my $output;
	my $alignment = $self->alignmentSeparator;
        my %options;
        tie %options, 'Tie::IxHash';
	%options = $self->orderedHash();
	foreach my $key (keys %options) {
                my $checked = 0;
                foreach my $item (@{$self->get("value}")) {
                        if ($item eq $key) {
                                $checked = 1;
                        }
                }
                $output .= WebGUI::Form::Checkbox->new({
                        name=>$self->get("name"),
                        value=>$key,
                        extras=>$self->get("extras"),
                        checked=>$checked
                        })->toHtml;
                $output .= ${$self->get("options}"){$key} . $alignment;
        }
        return $output;
}

1;

