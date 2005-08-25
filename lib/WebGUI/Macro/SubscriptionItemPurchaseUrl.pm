package WebGUI::Macro::SubscriptionItemPurchaseUrl;

use strict;
use WebGUI::Macro;
use WebGUI::URL;

sub process {
	my ($subscriptionId) = WebGUI::Macro::getParams(@_);
	return WebGUI::URL::page('op=purchaseSubscription;sid='.$subscriptionId);
}

1;
