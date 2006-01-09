package Hourly::SummarizePassiveProfileLog;

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
use WebGUI::PassiveProfiling;
use WebGUI::DateTime;

#-----------------------------------------
sub process {
	my $verbose = shift;
	unless ($session{setting}{passiveProfilingEnabled}) {
		print " - Passive profiling is disabled." if ($verbose);
		return;
	}
	my ($firstDate) = WebGUI::SQL->quickArray("select min(dateOfEntry) from passiveProfileLog");
	my $interval = $session{config}{passiveProfileInterval} || 86400; 
        if (WebGUI::DateTime::time()-$firstDate < $interval) {
                print " - Recently summarized: Skipping" if ($verbose);
                return "";
        }

	my $sessionExpired = WebGUI::DateTime::time() - $session{setting}{sessionTimeout};

	# We process entries for registered users and expired visitor sessions
	my $sql = "select * from passiveProfileLog";
	$sql .= " where userId <> 1 or (userId = 1 and dateOfEntry < ".quote($sessionExpired).")";
        my $sth = WebGUI::SQL->read($sql);
        while (my $data = $sth->hashRef) {
		WebGUI::PassiveProfiling::summarizeAOI($data);
		WebGUI::SQL->write("delete from passiveProfileLog where passiveProfileLogId = ".
					quote($data->{passiveProfileLogId}));
	}
	$sth->finish;
}

1;

