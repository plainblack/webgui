package Hourly::DeleteExpiredGroupings;

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

#-----------------------------------------
sub process {
	my @date = WebGUI::DateTime::localtime();
        if ($date[3] == 3) { # only occurs at 3am on the day in question.
        	my $sth = WebGUI::SQL->read("select groupId,deleteOffset,dbCacheTimeout from groups");
        	while (my $data = $sth->hashRef) {
        		if ($data->{dbCacheTimeout} > 0) {
				# there is no need to wait deleteOffset days for expired external group cache data
				WebGUI::SQL->write("delete from groupings where groupId=".quote($data->{groupId})." and expireDate < ".WebGUI::DateTime::time());
			} else {
        			WebGUI::SQL->write("delete from groupings where groupId=".quote($data->{groupId})." and expireDate < "
                        		.(WebGUI::DateTime::time()-(86400*$data->{deleteOffset})));
			}
        	}
	        $sth->finish;
	}
}

1;

