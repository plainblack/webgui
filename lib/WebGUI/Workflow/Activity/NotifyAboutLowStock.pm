package WebGUI::Workflow::Activity::NotifyAboutLowStock;


=head1 LEGAL

 -------------------------------------------------------------------
  WebGUI is Copyright 2001-2009 Plain Black Corporation.
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

Package WebGUI::Workflow::Activity::NotifyAboutLowStock

=head1 DESCRIPTION

Notify group about users when Products fall below a configurable amount of stock
in inventory.

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
	my $i18n = WebGUI::International->new($session, "Workflow_Activity_NotifyAboutLowStock");
	push(@{$definition}, {
		name=>$i18n->get("activityName"),
		properties=> {
			warningLimit => {
				fieldType=>"integer",
				label=>$i18n->get("warning limit"),
				defaultValue=>42,
				hoverHelp=>$i18n->get("warning limit help"),
				},
			toGroup => {
				fieldType=>"group",
				label=>$i18n->get("group to notify"),
				defaultValue=>3,
				hoverHelp=>$i18n->get("group to notify help"),
				},
			subject => {
				fieldType=>"text",
				label=>$i18n->get("229", 'WebGUI'),
				defaultValue=>'',
				hoverHelp=>$i18n->get("229 description", 'WebGUI'),
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
	my ($self, undef, $instance) = @_;
    my $session         = $self->session;
	my $message         = $instance->getScratch('LowStockMessage') || '';
	my $counter         = $instance->getScratch('LowStockLast')    || 0;
	my $belowThreshold  = $instance->getScratch('LowStockBelow')   || 0;
    my $productIterator = WebGUI::Asset::Sku::Product->getIsa($session, $counter);
    my $warningLimit = $self->get('warningLimit');
    my $finishTime = time() + $self->getTTL;
    my $expired = 0;
    PRODUCT: while (1) {
        my $product = eval { $productIterator->() };
        if (my $e = Exception::Class->caught()) {
            $session->log->error($@);
            next PRODUCT;
        }
        last PRODUCT unless $product;
        VARIANT: foreach my $collateral ( @{ $product->getAllCollateral('variantsJSON') }) {
            if ($collateral->{quantity} <= $warningLimit) {
                ##Build message
                $belowThreshold = 1;
                $message .= $product->getUrl(sprintf 'func=editVariant;vid=%s', $collateral->{variantId})
                         .  "\n";
            }
        }
        $counter++;
        ##Time check and set flag
        if (time() > $finishTime) {
            $expired = 1;
            last PRODUCT;
        }
    }
    ##If timer expired, then store message and limit and release
    if ($expired) {
        $instance->setScratch('LowStockMessage', $message);
        $instance->setScratch('LowStockLast',    $counter);
        $instance->setScratch('LowStockBelow',   $belowThreshold);
        return $self->WAITING(1);
    }

    $instance->deleteScratch('LowStockMessage');
    $instance->deleteScratch('LowStockLast');
    $instance->deleteScratch('LowStockBelow');
    if ($belowThreshold) {
        my $inbox = WebGUI::Inbox->new($session);
        $inbox->addMessage({
            status  => 'unread',
            subject => $self->get('subject'),
            groupId => $self->get('toGroup'),
            message => $message,
        });
    }

    return $self->COMPLETE;
}

1;
