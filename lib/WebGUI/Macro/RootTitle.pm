package WebGUI::Macro::RootTitle;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2004 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com info@plainblack.com
#-------------------------------------------------------------------

use strict;
use Tie::CPHash;
use WebGUI::Macro;
use WebGUI::Session;
use WebGUI::SQL;
use WebGUI::URL;

#-------------------------------------------------------------------
sub process {
        my ($sth, %data, $output);
        tie %data, 'Tie::CPHash';
	my $pageid = $_[0] || $session{page}{parentId};
        %data = WebGUI::SQL->quickHash("select pageId,parentId,title,urlizedTitle from page where pageId=".quote($pageId),WebGUI::SQL->getSlave);
	if ($data{parentId} == 0) {
		$output = $data{title} || $session{page}{title};
	} else {
                $output = &process($data{parentId},$_[1]);
	}
	return $output;
}


1;

