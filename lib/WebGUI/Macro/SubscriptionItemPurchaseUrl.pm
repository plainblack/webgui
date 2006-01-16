package WebGUI::Macro::SubscriptionItemPurchaseUrl;

use strict;

=head1 NAME

Package WebGUI::Macro::SubscriptionItemPurchaseUrl

=head1 DESCRIPTION

Macro that returns a URL to purchase a subscription item.

=head2 process ( subscriptionId )

process returns a URL that is the current page with an operation appended
to purchase the requested subscription item.

=head3 subscriptionId

The ID of the subscription item to purchase.

=cut

sub process {
	my $session = shift; use WebGUI; WebGUI::dumpSession($session);
	return $session->url->page('op=purchaseSubscription;sid='.shift);
}

1;
