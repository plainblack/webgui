package WebGUI::Workflow::Activity::PayoutVendors;

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

use Business::PayPal::API qw{ MassPay };
use Data::Dumper;
use WebGUI::Mail::Send;

use base 'WebGUI::Workflow::Activity';

=head1 NAME

Package WebGUI::Workflow::Activity::PayoutVendors

=head1 DESCRIPTION

Pays profits to vendors, currently via paypal, but others may be added in the future.

=head1 SYNOPSIS

See WebGUI::Workflow::Activity for details on how to use any activity.

=head1 METHODS

These methods are available from this class:

=cut

#-------------------------------------------------------------------

=head2 definition ()

See WebGUI::Workflow::Activity for details.

=cut

sub definition {
	my $class       = shift;
	my $session     = shift;
	my $definition  = shift;
    my $i18n = WebGUI::International->new($session, "Workflow_Activity_PayoutVendors");

    tie my %properties, 'Tie::IxHash', (
        paypalUsername  => {
            fieldType       => 'text',
            label           => $i18n->get('PayPal username'),
        },
        paypalPassword  => {
            fieldType       => 'password',
            label           => $i18n->get('PayPal password'),
        },
        paypalSignature => {
            fieldType       => 'text',
            label           => $i18n->get('PayPal signature'),
        },
        useSandbox      => {
            fieldType       => 'yesNo',
            label           => $i18n->get('Use in Sandbox (test-mode)'),
            defaultValue    => 0,
        },
        currencyCode    => {
            fieldType       => 'text',
            label           => $i18n->get('Currency code'),
            maxlength       => 3,
            size            => 3,
            defaultValue    => 'USD',
        },
        paypalSubject   => {
            fieldType       => 'text',
            label           => $i18n->get('Subject for vendor notification email'),
            defaultValue    => $i18n->get('Vendor payout from').' ' . $session->setting->get('companyUrl'),
        },
        notificationGroupId => {
            fieldType       => 'group',
            label           => $i18n->get('Notify on error'),
        },
    );

	push @{ $definition }, {
		name        => $i18n->get('Vendor Payout'),
        properties  => \%properties,
    };

	return $class->SUPER::definition( $session, $definition );
}


#-------------------------------------------------------------------

=head2 payoutVendor (vendorId)

Sends unsent vendor payouts to paypal. 

=head3 vendorId

The vendor to be sent his payouts.

=cut

sub payoutVendor {
    my $self        = shift;
    my $vendorId    = shift;
    my $db          = $self->session->db;
    my $payoutId    = $self->session->id->generate;
        
    # Instanciate vendor and check if he exists.    
    my $vendor      = WebGUI::Shop::Vendor->new( $self->session, $vendorId );
    unless ( $vendor ) {
        $self->session->log->error( "Could not instanciate vendor with id [$vendorId] for payout" );
        return undef;
    }
   
    # check to see that the vendor has a payout address
    if ($vendor->get('paymentInformation') eq '') {
        $self->session->log->warn("Vendor ".$vendor->getId." hasn't specified a payout address.");
        return undef;
    }

    # Fetch all transactionItems that are scheduled for payout to the vendor.
    my $sth = $db->read( 
        'select itemId, vendorPayoutAmount from transactionItem '
        . ' where vendorId=? and vendorPayoutStatus=? and vendorPayoutAmount > 0',
        [
            $vendorId,
            'Scheduled',
        ] 
    );

    # Process all transaction items and log them in the db.
    my $totalAmount = 0;
    while ( my $item = $sth->hashRef ) {
        $totalAmount += $item->{ vendorPayoutAmount };
    
        $db->write( 'insert into vendorPayoutLog_items (payoutId, transactionItemId, amount) values (?,?,?)', [
            $payoutId,
            $item->{ itemId },
            $item->{ vendorPayoutAmount },
        ] );
    }
    my $itemCount = $sth->rows;
    $sth->finish;

    # Do PayPal MassPay request
    my $pp = new Business::PayPal::API( 
        Username   => $self->get('paypalUsername'),
        Password   => $self->get('paypalPassword'),
        Signature  => $self->get('paypalSignature'),
        sandbox    => $self->get('useSandbox'),
    );
    my %response = $pp->MassPay( 
        EmailSubject    => $self->get('paypalSubject'),
        currencyID      => $self->get('currencyCode'),
        MassPayItems    => [ { 
            ReceiverEmail => $vendor->get('paymentInformation'),
            Amount        => $totalAmount,
            UniqueID      => $payoutId,
            Note          => "Payout for $itemCount sold items",
        } ],
    );

    # Process paypal response
    my $payoutDetails = {
        payoutId            => $payoutId,
        isSuccessful        => $response{ Ack } eq 'Success' ? 1 : 0,
        paypalTimestamp     => $response{ Timestamp },
        correlationId       => $response{ CorrelationID },
        amount              => $totalAmount,
        currency            => $self->get('currencyCode'),
        paymentInformation  => $vendor->get('paymentInformation'),
    };
    if ( $response{ Ack } ne 'Success' ) {
        # An error occurred, keep the error codes
        my $errorCode       = $response{ Error }->[ 0 ]->{ ErrorCode   };
        my $errorMessage    = $response{ Error }->[ 0 ]->{ LongMessage };

        # TODO: Send out email.
        my $mail = WebGUI::Mail::Send->create($self->session, { 
            toGroup => $self->get('notificationGroupId'), 
            subject => 'Vendor payout error',
        });
        $mail->addText( 
            "An error occurred during an automated vendor payout attempt. Response details:\n" 
            . Dumper( \%response )
            . "\n\nVendor information:\n"
            . Dumper( $vendor->get )
        );
        $mail->queue;

        $payoutDetails->{ errorCode     } = $errorCode;
        $payoutDetails->{ errorMessage  } = $errorMessage;
    }
    else {
        # The transaction was successful, so change the state of the transactionItems to Paid.    
        $db->write( 
            'update transactionItem set vendorPayoutStatus=? where itemId in ( '
                .' select transactionItemId from vendorPayoutLog_items where payoutId=? '
            .')',
            [
                'Paid',
                $payoutId,
            ]
        );
    }

    # Persist response data to db
    $db->setRow( 'vendorPayoutLog', 'payoutId', $payoutDetails, $payoutId );

};


#-------------------------------------------------------------------

=head2 execute () 

See WebGUI::Workflow::Activity for details.

=cut

sub execute {
	my $self        = shift;
    my $object      = shift;
    my $instance    = shift;
    my $start       = time;
    my $ttl         = $self->getTTL;

    # Fetch vendors eligible for payout.
    my $sth = $self->session->db->read( 
        "select distinct vendorId from transactionItem where vendorPayoutStatus='Scheduled' and vendorPayoutAmount > 0"
    );

    # Pay on a vendor by vendor basis.
    while ( (my $vendorId) = $sth->array ) {
        $self->payoutVendor( $vendorId );

        # Make sure we won't run longer than allowed.
        if ( ( time - $start + 1 ) >= $ttl ) {
            $sth->finish;
            return $self->WAITING( 1 );
        }
    }

    $sth->finish;

    return $self->COMPLETE;
}

1;

