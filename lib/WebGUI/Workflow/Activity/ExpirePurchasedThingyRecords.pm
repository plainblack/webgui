package WebGUI::Workflow::Activity::ExpirePurchasedThingyRecords;

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

=head1 NAME

Package WebGUI::Workflow::Activity::ExpirePurchasedThingyRecords

=head1 DESCRIPTION

Expire the purchased thingy records.

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
	my $i18n = WebGUI::International->new($session, "Workflow_Activity_ExpirePurchasedThingyRecords");
	push @{$definition}, {
		name => $i18n->get("topicName"),
		properties => {
            notificationOffset => {
                fieldType       => "interval",
                defaultValue    => 60*60*24*3,
                label           => $i18n->get('notificationOffset label'),
                hoverHelp       => $i18n->get('notificationOffset description'),
            },
            notificationMessage => {
                fieldType       => "HTMLArea",
                defaultValue    => $i18n->get('default notification'),
                label           => $i18n->get('notificationMessage label'),
                hoverHelp       => $i18n->get('notificationMessage description'),
            },
            notificationSubject => {
                fieldType       => "text",
                defaultValue    => $i18n->get('default notification subject'),
                label           => $i18n->get('notificationSubject label'),
                hoverHelp       => $i18n->get('notificationSubject description'),
            },
        },
    };
	return $class->SUPER::definition($session,$definition);
}

#-------------------------------------------------------------------

=head2 execute ( [ object ] )

See WebGUI::Workflow::Activity::execute() for details.

=cut

sub execute {
	my $self        = shift;
    my $object      = shift;
    my $instance    = shift;
    my $time        = time;
    my %asset       = (); # Keep track of assets we're using
    
    ### Notify of those about to expire
    my $iter 
        = WebGUI::AssetCollateral::Sku::ThingyRecord::Record->getAllIterator(
            $self->session,
            {
                constraints => [
                    { "expires < ?"   => $time + $self->get('notificationOffset') },
                    { "sentExpiresNotice != ?" => 1 },
                ],
            });
    while ( my $record = $iter->() ) {
        $record->update({
            sentExpiresNotice   => 1,
        });
        
        my $msg = WebGUI::Mail::Send->create( $self->session, {
            toUser      => $record->get('userId'),
            subject     => $self->get('notificationSubject'),
        });
        $msg->addHtml( $self->get('notificationMessage') );
        $msg->queue;

        if ( time - $time > 60 ) {
            return $self->WAITING(1);
        }
    }

    ### Delete expired
    $iter 
        = WebGUI::AssetCollateral::Sku::ThingyRecord::Record->getAllIterator(
            $self->session,
            {
                constraints => [
                    { "expires < ?"   => $time },
                    { "isHidden != ?" => 1 },
                ],
            });
    while ( my $record = $iter->() ) {
        # Record is hidden
        $record->update({ isHidden => 1 }); 
        my $asset;
        if ( !$asset{$record->get('assetId')} ) {
            $asset = $asset{$record->get('assetId')} 
                = WebGUI::Asset->newById( $self->session, $record->get('assetId') );
        }
        else {
            $asset = $asset{$record->get('assetId')};
        }

        $asset->deleteThingRecord( $asset->get('thingId'), $record->getId );

        if ( time - $time > 60 ) {
            return $self->WAITING(1);
        }
    }

    return $self->COMPLETE;
}

1;

#vim:ft=perl
