package WebGUI::Macro::SubscriptionItemPurchaseUrl;

use strict;
use WebGUI::URL;

sub process {
	return WebGUI::URL::page('op=purchaseSubscription;sid='.shift);
}

1;
