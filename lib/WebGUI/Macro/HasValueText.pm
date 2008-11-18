package WebGUI::Macro::HasValueText;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2008 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use strict;

=head1 NAME

Package WebGUI::Macro::HasValueText

=head1 DESCRIPTION

Macro for displaying text based on whether or not the value entered it empty.

=head2 process ( value, textIfValue, textIfNotValule )

Either the textIfValue or textIfNotValue fields can be empty

=head3 value

The value to test to see if it's empty.

=head3 textIfValue

The text to be displayed if the value is not empty.  Use %s to represent the value itself.

ex: ^HasValueText(test,<li>%s</li>,);
returns: <li>test</li>

=head3 textIfNoValue

Text to be displayed if the value is empty.

=cut

#-------------------------------------------------------------------
sub process {
	my $session = shift;
	my ($value, $valueText, $noValueText ) = @_;
    $value =~ s/^\s//;
    $value =~ s/\s$//;
    if ($value eq "") {
		return $noValueText;
	}
    return sprintf($valueText,$value);
}



1;
