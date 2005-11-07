package WebGUI::Macro::LastModified;

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
use WebGUI::DateTime;
use WebGUI::Asset;
use WebGUI::Session;
use WebGUI::International;
use WebGUI::SQL;

#-------------------------------------------------------------------
sub process {
	return '' unless $session{asset};
	my ($label, $format, $time);
	($label, $format) = @_;
	$format = '%z' if ($format eq "");
	($time) = WebGUI::SQL->quickArray("SELECT max(revisionDate) FROM assetData where assetId=".quote($session{asset}->getId),WebGUI::SQL->getSlave);
	return WebGUI::International::get(43,'Asset_Survey') if $time eq 0;
	return $label.epochToHuman($time,$format) if ($time);
}

1;


