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
	my $session = shift; use WebGUI; WebGUI::dumpSession($session);
	my ($subscriptionId, $templateId, %var);
	($subscriptionId, $templateId) = @_;
	%var = $session->db->quickHash('select * from subscription where subscriptionId='.$session->db->quote($subscriptionId));
	$var{url} = $session->url->page('op=purchaseSubscription;sid='.$subscriptionId);
	return WebGUI::Asset::Template->new($session,$templateId || "PBtmpl0000000000000046")->process(\%var);
}

1;
