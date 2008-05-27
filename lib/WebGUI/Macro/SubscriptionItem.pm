package WebGUI::Macro::SubscriptionItem;

use strict;
use WebGUI::Asset::Template;

=head1 NAME

Package WebGUI::Macro::SubscriptionItem;

=head1 DESCRIPTION

Macro for displaying information about subscription items.

=head2 process (  subscriptionId [,templateId ] )

process takes two optional parameters for customizing the content and layout
of the account link.

=head3 subscriptionId

The text of the link.  If no text is displayed an internationalized default will be used.

=head3 templateId

A templateId to use for formatting the link.  If this is empty, a default template will
be used from the Macro/SubscriptionItem namespace.

=cut

sub process {
	my $session         = shift;
    my $subscriptionId  = shift;
    my $templateId      = shift || 'PBtmpl0000000000000046';

    # Fetch subscription asset
    my $subscription = WebGUI::Asset->newByDynamicClass( $session, $subscriptionId );
    return "Could not find subscription with id: [$subscriptionId]" unless $subscription;
    return "Only Subscription assets can be used with this macro."
        unless $subscription->get('className') =~ m{^WebGUI::Asset::Sku::Subscription};

    # Setup template vars
    my $var;
    $var->{ subscriptionId      } = $subscription->getId;
    $var->{ name                } = $subscription->get('title');
    $var->{ price               } = $subscription->getPrice;
    $var->{ description         } = $subscription->get('description');
    $var->{ subscriptionGroup   } = $subscription->get('subscriptionGroup');
    $var->{ duration            } = $subscription->get('duration');
    $var->{ karma               } = $subscription->get('karma');
    $var->{ useSalesTax         } = $subscription->get('useSalesTax');
    $var->{ url                 } = $subscription->getUrl('func=purchaseSubscription');

    # Fetch template 
    my $template = WebGUI::Asset::Template->new( $session, $templateId );
    return "Could not instantiate template with id:[$templateId]" unless $template;

	return $template->process( $var );
}

1;
