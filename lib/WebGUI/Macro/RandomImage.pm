package WebGUI::Macro::RandomImage;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2003 Plain Black LLC.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use strict;
use Tie::CPHash;
use WebGUI::Collateral;
use WebGUI::Macro;
use WebGUI::Session;
use WebGUI::SQL;

#-------------------------------------------------------------------
sub process {
        my @param = WebGUI::Macro::getParams($_[0]);
	my $collateralFolderId;
	if ($param[0] ne "") {
		($collateralFolderId) = WebGUI::SQL->quickArray("select collateralFolderId from collateralFolder 
			where name=".quote($param[0]));
	} else {
		$collateralFolderId = 0; #Root
	}
	my @images = WebGUI::SQL->buildArray("select collateralId from collateral 
		where collateralType='image' and collateralFolderId=".$collateralFolderId);
	my $collateral = WebGUI::Collateral->new($images[rand($#images+1)]);
	return '<img src="'.$collateral->getURL.'" '.$collateral->get("parameters").' />';
}


1;


