package WebGUI::Macro::RandomSnippet;

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
	my ($collateralFolderId) = WebGUI::SQL->quickArray("select collateralFolderId from collateralFolder where name=".quote($param[0]));
	my @snippets = WebGUI::SQL->buildArray("select collateralId from collateral where collateralType='snippet' and collateralFolderId=".$collateralFolderId);
	my $collateral = WebGUI::Collateral->new($snippets[rand($#snippets+1)]);
	return $collateral->get("parameters");
}


1;


