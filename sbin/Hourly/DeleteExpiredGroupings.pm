package Hourly::DeleteExpiredGroupings;

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
use WebGUI::Session;
use WebGUI::SQL;

#-----------------------------------------
sub process {
	my @date = WebGUI::DateTime::localtime();
        if ($date[4] == 3) { # only occurs at 3am on the day in question.
        	my $sth = WebGUI::SQL->read("select groupId,deleteOffset from groups");
        	while (my $data = $sth->hashRef) {
        		WebGUI::SQL->write("delete from groupings where groupId=$data->{groupId} and expireDate < "
                        	.(time()-(86400*$data->{deleteOffset})));
        	}
	        $sth->finish;
	}
}

1;

