package Hourly::DeleteExpiredSessions;

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
use WebGUI::DateTime;
use WebGUI::Session;
use WebGUI::SQL;

#-------------------------------------------------------------------
sub process {
	my $epoch = time();
	my $sth = WebGUI::SQL->read("select sessionId from userSession where expires<".$epoch);
	while (my ($sessionId) = $sth->array) {
		WebGUI::SQL->write("delete from userSessionScratch where sessionId=".quote($sessionId));
	}
	$sth->finish;
	WebGUI::SQL->write("delete from userSession where expires<".$epoch);
}

1;

