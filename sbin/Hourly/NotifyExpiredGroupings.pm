package Hourly::NotifyExpiredGroupings;

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
use WebGUI::DateTime;
use WebGUI::International;
use WebGUI::MessageLog;
use WebGUI::Session;
use WebGUI::SQL;

#-----------------------------------------
sub process {
	my @date = WebGUI::DateTime::localtime();
        if ($date[4] == 1) { # only occurs at 1am on the day in question.
		my $now = time();
        	my $a = WebGUI::SQL->read("select groupId,expireNotifyOffset,expireNotifyMessage from groups
			where expireNotify=1");
        	while (my $group = $a->hashRef) {
			my $start = $now + (86400 * $group->{expireNotifyOffset});
			my $end = $start + 86400;
			my $b = WebGUI::SQL->read("select userId from groupings where expireDate>=".$start." and expireDate<=".$end);
			while (my ($userId) = $b->array) { 
				WebGUI::MessageLog::addEntry($userId,"",WebGUI::International::get(867),$group->{expireNotifyMessage});
			}
			$b->finish;
        	}
	        $a->finish;
	}
}

1;

