package WebGUI::Macro::LastModified;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2004 Plain Black LLC.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use strict;
use WebGUI::DateTime;
use WebGUI::Macro;
use WebGUI::Session;
use WebGUI::SQL;

#-------------------------------------------------------------------
sub process {
        my ($label, $format, $time, $output);

        ($label, $format) = WebGUI::Macro::getParams(shift);
        $format = '%z' if ($format eq "");
	$output = "";

        ($time) = WebGUI::SQL->quickArray("SELECT max(lastEdited) FROM wobject where pageId=".quote($session{page}{pageId}),WebGUI::SQL->getSlave);
        if ($time) {
		$output = $label.epochToHuman($time,$format);
	}

        return $output;
}

1;


