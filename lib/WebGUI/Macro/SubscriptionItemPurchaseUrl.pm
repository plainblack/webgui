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
	my $session         = shift;
    my $subscriptionId  = shift;

    # Fetch subscription asset
    my $subscription = WebGUI::Asset->newByDynamicClass( $session, $subscriptionId );
    return "Could not find subscription with id: [$subscriptionId]" unless $subscription;
    return "Only Subscription assets can be used with this macro."
        unless $subscription->get('className') =~ m{^WebGUI::Asset::Sku::Subscription};

    # Construct and output the purchase url for this subscription
	return $subscription->getUrl('func=purchaseSubscription');
}

1;
