package WebGUI::Macro::RootTitle;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2003 Plain Black LLC.
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
        %data = WebGUI::SQL->quickHash("select pageId,parentId,title,urlizedTitle from page where pageId=$_[0]");
	if ($data{parentId} == 0) {
		$output = $data{title} || $session{page}{title};
	} else {
                $output = _recurse($data{parentId},$_[1]);
	}
	return $output;
}


1;

