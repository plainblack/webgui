package Hourly::DeleteExpiredEvents;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2006 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------


use strict;
use WebGUI::DateTime;
use WebGUI::Session;
use WebGUI::SQL;
use WebGUI::Asset::Event;

#-----------------------------------------
sub process {
	if ($session{config}{DeleteExpiredEvents_offset} ne "") {
		my $sth = WebGUI::SQL->read("select assetId from EventsCalendar_event where eventEndDate < ".(time()-(86400*$session{config}{DeleteExpiredEvents_offset})));
		while (my ($id) = $sth->array) {
			WebGUI::Asset::Event->new($id)->purge;
		}
		$sth->finish;
	}
}

1;

