package Hourly::DeleteExpiredSessions;

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
use WebGUI::Session;
use WebGUI::SQL;

#-------------------------------------------------------------------
sub process {
	my $epoch = WebGUI::DateTime::time();
	my $sth = WebGUI::SQL->read("select sessionId from userSession where expires<".$epoch);
	while (my ($sessionId) = $sth->array) {
		WebGUI::Session::end($sessionId);
	}
	$sth->finish;
}

1;

