package WebGUI::Macro::SubscriptionItem;

use strict;
use WebGUI::Macro;
use WebGUI::SQL;
use WebGUI::URL;

sub process {
	my ($subscriptionId, $templateId, %var);
	($subscriptionId, $templateId) = WebGUI::Macro::getParams(@_);

	%var = WebGUI::SQL->quickHash('select * from subscription where subscriptionId='.quote($subscriptionId));
	
	$var{url} = WebGUI::URL::page('op=purchaseSubscription&sid='.$subscriptionId);
	return WebGUI::Template::process($templateId || 1, 'Macro/SubscriptionItem', \%var);
}

1;
