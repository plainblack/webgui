package WebGUI::Macro::If;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2012 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use strict;

=head1 NAME

Package WebGUI::Macro::If

=head1 DESCRIPTION

Macro for displaying text based on whether or not the value entered is true.

=head2 process ( value, textIfTrue, textIfFalse )

=head3 value

The value to test to see if it's true or not.  False values are the empty string, 0 and
any string which is only whitespace.

=head3 textIfTrue

The text to be displayed if the value is not false.  Use %s to represent the value itself.

ex: ^If(test,<li>%s</li>,);
returns: <li>test</li>

=head3 textIfFalse

Text to be displayed if the value is empty.

=cut

#-------------------------------------------------------------------
sub process {
	my $session = shift;
	my ($value, $trueText, $falseText ) = @_;
    $value =~ s/^\s//;
    $value =~ s/\s$//;
    if (!$value) {
		return $falseText;
	}
    return sprintf($trueText,$value);
}



1;
