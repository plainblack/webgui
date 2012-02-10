package WebGUI::Workflow::Activity::RemoveOldCarts;


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
use WebGUI::International;
use WebGUI::Asset::Sku::Product;
use WebGUI::Inbox;

=head1 NAME

Package WebGUI::Workflow::Activity::RemoveOldCarts

=head1 DESCRIPTION

Remove carts that are older than a configurable threshold.

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
    my $i18n = WebGUI::International->new($session, 'Workflow_Activity_RemoveOldCarts');
    push(@{$definition}, {
        name=>$i18n->get('activityName'),
        properties=> {
            cartTimeout => {
                fieldType=>'interval',
                label=>$i18n->get('cart timeout'),
                defaultValue=>48*3600,
                hoverHelp=>$i18n->get('cart timeout help'),
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
    my ($self)  = @_;
    my $session = $self->session;
    my $now = time();
    my $finishTime = $now + $self->getTTL;
    my $expired = 0;
    my $cartIds = [];
    my $limit = $now - $self->get('cartTimeout');
    my $expiredCarts = $session->db->read('select cartId from cart where creationDate < '.$limit);
    $expiredCarts->execute();
    CART: while( my ($cartId) = $expiredCarts->array() ) {
        my $cart = eval {
            WebGUI::Shop::Cart->new($session, $cartId);
        };
        next CART if WebGUI::Error->caught;
        $cart->delete; ##Delete will empty, then delete.
        ##Time check and set flag
        if (time() > $finishTime) {
            $expired = 1;
            last CART;
        }
    }
    ##If timer expired, then store message and limit and release
    if ($expired) {
        return $self->WAITING(1);
    }

    return $self->COMPLETE;
}

1;
