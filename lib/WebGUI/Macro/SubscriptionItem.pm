package WebGUI::Macro::SubscriptionItem;

use strict;
use WebGUI::Asset::Template;
use WebGUI::SQL;
use WebGUI::URL;

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
	my ($subscriptionId, $templateId, %var);
	($subscriptionId, $templateId) = @_;
	%var = WebGUI::SQL->quickHash('select * from subscription where subscriptionId='.quote($subscriptionId));
	$var{url} = WebGUI::URL::page('op=purchaseSubscription;sid='.$subscriptionId);
	return WebGUI::Asset::Template->new($templateId || "PBtmpl0000000000000046")->process(\%var);
}

1;
