package Hourly::DeleteExpiredEvents;

my $offset = 0; # in days, time to wait before deleting

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2002 Plain Black LLC.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------


use strict;
use WebGUI::Session;
use WebGUI::SQL;

#-----------------------------------------
sub process {
	WebGUI::SQL->write("delete from EventsCalendar_event where endDate<".(time()-(86400*$offset)));
}

1;

