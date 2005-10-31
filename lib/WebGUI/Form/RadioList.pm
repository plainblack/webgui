package WebGUI::Form::RadioList;

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
use WebGUI::Form::Radio;
use WebGUI::International;
use WebGUI::Session;

=head1 NAME

Package WebGUI::Form::RadioList

=head1 DESCRIPTION

Creates a series of radio button form fields.

=head1 SEE ALSO

This is a subclass of WebGUI::Form::Control. Also take a look ath WebGUI::Form::checkbox as this class creates a list of checkboxes.

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

=head4 vertical

Boolean representing whether the checklist should be represented vertically or horizontally. If set to "1" will be displayed vertically. Defaults to "0".

=cut

sub definition {
	my $class = shift;
	my $definition = shift || [];
	push(@{$definition}, {
		options=>{
			defaultValue=>{}
			},
		vertical=>{
			defaultValue=>0
			}
		});
	return $class->SUPER::definition($definition);
}


#-------------------------------------------------------------------

=head2 getName ()

Returns the human readable name or type of this form control.

=cut

sub getName {
        return WebGUI::International::get("942","WebGUI");
}


#-------------------------------------------------------------------

=head2 toHtml ( )

Renders a series of radio buttons.

=cut

sub toHtml {
	my $self = shift;
	my $output;
	my $alignment;
	if ($self->{vertical}) {
		$alignment = "<br />\n";
	}
	else {
		$alignment = " &nbsp; &nbsp;\n";
	}
	foreach my $key (keys %{$self->{options}}) {
                my $checked = 0;
                if ($self->{value} eq $key) {
                        $checked = 1;
                }
                $output .= WebGUI::Form::Radio->new({
                        name=>$self->{name},
                        value=>$key,
                        extras=>$self->{extras},
                        checked=>$checked
                        })->toHtml;
                $output .= ${$self->{options}}{$key} . $alignment;
        }
        return $output;
}

1;

