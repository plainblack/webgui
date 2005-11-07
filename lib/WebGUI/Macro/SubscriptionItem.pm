package WebGUI::Macro::SubscriptionItem;

use strict;
use WebGUI::Asset::Template;
use WebGUI::SQL;
use WebGUI::URL;

sub process {
	my ($subscriptionId, $templateId, %var);
	($subscriptionId, $templateId) = @_;
	%var = WebGUI::SQL->quickHash('select * from subscription where subscriptionId='.quote($subscriptionId));
	$var{url} = WebGUI::URL::page('op=purchaseSubscription;sid='.$subscriptionId);
	return WebGUI::Asset::Template->new($templateId || "PBtmpl0000000000000046")->process(\%var);
}

1;
