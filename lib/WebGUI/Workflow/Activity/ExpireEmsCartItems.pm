package WebGUI::Workflow::Activity::ExpireEmsCartItems;


=head1 LEGAL

 -------------------------------------------------------------------
  WebGUI is Copyright 2001-2012 Plain Black Corporation.
 -------------------------------------------------------------------
  Please read the legal notices (docs/legal.txt) and the license
  (docs/license.txt) that came with this distribution before using
  this software.
 -------------------------------------------------------------------
  http://www.plainblack.com                     info@plainblack.com
 -------------------------------------------------------------------

=cut

use strict;
use base 'WebGUI::Workflow::Activity';
use WebGUI::Shop::Cart;

=head1 NAME

Package WebGUI::Workflow::Activity::ExpireEmsCartItems

=head1 DESCRIPTION

Removes EMS items from shopping carts that have been held up by the user too long.

=head1 SYNOPSIS

See WebGUI::Workflow::Activity for details on how to use any activity.

=head1 METHODS

These methods are available from this class:

=cut


#-------------------------------------------------------------------

=head2 definition ( session, definition )

See WebGUI::Workflow::Activity::definition() for details.

=cut 

sub definition {
	my $class = shift;
	my $session = shift;
	my $definition = shift;
	my $i18n = WebGUI::International->new($session, "Asset_EventManagementSystem");
	push(@{$definition}, {
		name=>$i18n->get("expire ems cart items"),
		properties=> {
			expireAfter => {
				fieldType=>"interval",
				label=>$i18n->get("item expiration time"),
				defaultValue=>60*60,
				hoverHelp=>$i18n->get('item expiration time help')
				},
			}
		});
	return $class->SUPER::definition($session,$definition);
}


#-------------------------------------------------------------------

=head2 execute ( [ object ] )

See WebGUI::Workflow::Activity::execute() for details.

=cut

sub execute {
	my $self = shift;
    my $object = shift;
    my $instance = shift;
	my $start = time();
	my $log = $self->session->log;
	$log->info('Searching for EMS items that have been in the cart too long.');
    my $ttl = $self->getTTL;
	my $items = $self->session->db->read("select itemId, cartId, assetId from cartItem where
		assetId in (select assetId from asset where className like 'WebGUI::Asset::Sku::EMS%')
		and DATE_ADD(dateAdded, interval ".($self->get("expireAfter") + 0)." second) < now()");
	while (my ($itemId, $cartId, $assetId) = $items->array) {
		$log->info('Removing item '.$itemId.' (asset '.$assetId.') from cart '.$cartId);
		WebGUI::Shop::Cart->new($self->session, $cartId)->getItem($itemId)->remove;
		if (time() - $start > $ttl) {
			$items->finish;
			$log->('Ran out of time. Will have to expire the rest later.');
			return $self->WAITING(1);
		}
	}
	$log->info('No more EMS items to expire.');
    return $self->COMPLETE;
}



1;


