package WebGUI::Operation::Style;

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
use WebGUI::Paginator;

=head1 NAME

Package WebGUI::Operation::Style

=head1 DESCRIPTION

Operation for overriding styles in Assets.

=cut

#-------------------------------------------------------------------

=head2 www_makePrintable (  )

Copy $session->form->process("styleId") to printableStyleId and set the makePrintable flag so that
the printableStyleId is used instead of the normal styleId for the page.

=cut

sub www_makePrintable {
	my $session = shift;
	my $styleId = $session->form->process("styleId");
	$session->style->setPrintableStyleId($styleId) if $styleId;
	$session->style->makePrintable("1");
	return "";
}


#-------------------------------------------------------------------

=head2 www_setPersonalStyle ( )

Sets personalStyleId in the scratch area of the session variable.  This allows
overriding the style without setting a printable style and on a per user basis.

=cut

sub www_setPersonalStyle {
	my $session = shift;
	$session->scratch->set("personalStyleId",$session->form->process("styleId"));
	return "";
}

#-------------------------------------------------------------------

=head2 www_unsetPersonalStyle ( )

Clears the personalStyleId from the scratch area of the session variable.

=cut

sub www_unsetPersonalStyle {
	my $session = shift;
	$session->scratch->delete("personalStyleId");
	return "";
}


1;
