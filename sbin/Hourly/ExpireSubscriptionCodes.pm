package Hourly::ExpireSubscriptionCodes;

use strict;
use WebGUI::SQL;

#-------------------------------------------------------------------
sub process {
	WebGUI::SQL->write("update subscriptionCode set status='Expired' where status = 'Unused' and dateCreated + expires < ".time);
}

1;

