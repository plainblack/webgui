package Hourly::NotifyExpiredGroupings;

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
use WebGUI::International;
use WebGUI::MessageLog;
use WebGUI::Session;
use WebGUI::SQL;

#-----------------------------------------
sub process {
	my $verbose = shift;
	my @date = WebGUI::DateTime::localtime(WebGUI::DateTime::time());
        if ($date[3] == 1) { # only occurs at 1am on the day in question.
		my $now = WebGUI::DateTime::time();
        	my $a = WebGUI::SQL->read("select groupId,expireNotifyOffset,expireNotifyMessage from groups
			where expireNotify=1");
        	while (my $group = $a->hashRef) {
			my $start = $now + (86400 * ($group->{expireNotifyOffset}-1));
			my $end = $start + 86400;
			my $b = WebGUI::SQL->read("select userId from groupings where groupId=".quote($group->{groupId})." and 
				expireDate>=".$start." and expireDate<=".$end);
			while (my ($userId) = $b->array) { 
				WebGUI::MessageLog::addEntry($userId,"",WebGUI::International::get(867),$group->{expireNotifyMessage});
				print "\n\t\tNotified ".$userId." about ".$group->{groupId} if ($verbose);
			}
			$b->finish;
        	}
	        $a->finish;
	}
}

1;

