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

#-------------------------------------------------------------------
sub www_makePrintable {
	if ($session{form}{styleId} ne "") {
		$session{page}{printableStyleId} = $session{form}{styleId};
	}
	$session{page}{makePrintable} = 1;
	return "";
}

#-------------------------------------------------------------------
sub www_setPersonalStyle {
	WebGUI::Session::setScratch("personalStyleId",$session{form}{styleId});
	return "";
}

#-------------------------------------------------------------------
sub www_unsetPersonalStyle {
	WebGUI::Session::deleteScratch("personalStyleId");
	return "";
}


1;
