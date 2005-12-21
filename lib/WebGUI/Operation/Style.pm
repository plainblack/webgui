package WebGUI::Operation::Style;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2005 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use strict;
use WebGUI::Grouping;
use WebGUI::Paginator;
use WebGUI::Privilege;
use WebGUI::Session;
use WebGUI::URL;

=head1 NAME

Package WebGUI::Operation::Style

=head1 DESCRIPTION

Operation for overriding styles in Assets.

=cut

#-------------------------------------------------------------------

=head2 www_makePrintable (  )

Copy $session{form}{styleId} to printableStyleId and set the makePrintable flag so that
the printableStyleId is used instead of the normal styleId for the page.

=cut

sub www_makePrintable {
	if ($session{form}{styleId} ne "") {
		$session{page}{printableStyleId} = $session{form}{styleId};
	}
	$session{page}{makePrintable} = 1;
	return "";
}


#-------------------------------------------------------------------

=head2 www_setPersonalStyle ( )

Sets personalStyleId in the scratch area of the session variable.  This allows
overriding the style without setting a printable style and on a per user basis.

=cut

sub www_setPersonalStyle {
	WebGUI::Session::setScratch("personalStyleId",$session{form}{styleId});
	return "";
}

#-------------------------------------------------------------------

=head2 www_unsetPersonalStyle ( )

Clears the personalStyleId from the scratch area of the session variable.

=cut

sub www_unsetPersonalStyle {
	WebGUI::Session::deleteScratch("personalStyleId");
	return "";
}


1;
