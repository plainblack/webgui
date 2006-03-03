package WebGUI::Workflow::Activity::ProcessRecurringPayments;


=head1 LEGAL

 -------------------------------------------------------------------
  WebGUI is Copyright 2001-2006 Plain Black Corporation.
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
use WebGUI::Commerce::Payment;
use WebGUI::Commerce::Transaction;
use WebGUI::Commerce::Item;
use WebGUI::Mail::Send;

=head1 NAME

Package WebGUI::Workflow::Activity::ProcessRecurringPayments

=head1 DESCRIPTION

Deals with recurring payments from the subscription system.

=head1 SYNOPSIS

See WebGUI::Workflow::Activity for details on how to use any activity.

=head1 METHODS

These methods are available from this class:

=cut


#-------------------------------------------------------------------

=head2 definition ( session, definition )

See WebGUI::Workflow::Activity::defintion() for details.

=cut 

sub definition {
	my $class = shift;
	my $session = shift;
	my $definition = shift;
	my $i18n = WebGUI::International->new($session, "Commerce");
	push(@{$definition}, {
		name=>$i18n->get("process recurring payments"),
		properties=> {}
		});
	return $class->SUPER::definition($session,$definition);
}



#-------------------------------------------------------------------
sub getDuration {
	my $self = shift;
	my $duration = shift;
	return $self->session->datetime->addToDate(0,0,0,7) if $duration eq 'Weekly';
	return $self->session->datetime->addToDate(0,0,0,14) if $duration eq 'BiWeekly';
	return $self->session->datetime->addToDate(0,0,0,28) if $duration eq 'FourWeekly';
	return $self->session->datetime->addToDate(0,0,1,0) if $duration eq 'Monthly';
	return $self->session->datetime->addToDate(0,0,3,0) if $duration eq 'Quarterly';
	return $self->session->datetime->addToDate(0,0,6,0) if $duration eq 'HalfYearly';
	return $self->session->datetime->addToDate(0,1,0,0) if $duration eq 'Yearly';
}

#-------------------------------------------------------------------

=head2 execute (  )

See WebGUI::Workflow::Activity::execute() for details.

=cut

sub execute {
	my $self = shift;
	my @recurringTransactions = $self->session->db->buildArray("select transactionId from transaction where recurring=1 and status='Completed'");
	my (@unprocessed, @ok, @failed, @fatal);	
	foreach (@recurringTransactions) {
		my $transaction = WebGUI::Commerce::Transaction->new($self->session,$_);
		my $itemProperties = $transaction->getItems->[0];
		my $item = WebGUI::Commerce::Item->new($self->session, $itemProperties->{itemId}, $itemProperties->{itemType});
		my $time = time;
		$time -= $transaction->get('initDate');
		my $term = int($time / $self->getDuration($item->duration)) + 1;
		if ($term > $transaction->lastPayedTerm) {
			my $payment = WebGUI::Commerce::Payment->load($self->session, $transaction->gateway);
 			$transaction->gatewayId;
			my $status = $payment->getRecurringPaymentStatus($self->session, $transaction->gatewayId, $term);
			my $output = $item->name." (tid: ".$transaction->get('transactionId').") ";
		        $output .= " by user ".WebGUI::User->new($self->session, $transaction->get("userId"))->username." (uid: ".$transaction->get("userId").") ";
			$output .= " for term ". sprintf('% 6d', $term)." "; 
			$output .= " -> ".$transaction->gateway.": (".$transaction->gatewayId.")\t";
			unless ($payment->resultCode) {
				unless (defined $status) {
					$output .= "NOT PROCESSED YET";
					push (@unprocessed, $output);
				} elsif ($status->{resultCode} eq '0') {
					$output .= "OK";
					push (@ok, $output);
					$item->handler($transaction->get("userId")) unless ($term == 1);
					$transaction->lastPayedTerm($term);
				} else {
					$output .= "PAYMENT FAILED: ".$status->{resultCode};
					push (@failed, $output);
				}
			} else {
				$output .= "FATAL ERROR: ".$payment->resultMessage." (".$payment->errorCode.")";
			}
		}
	}
	my $message = "FAILED PAYMENTS:\n-----------------------------\n".join("\n", @failed)."\n\n\n";
	$message .= "UNPROCESSED PAYMENTS:\n-----------------------------\n".join("\n", @unprocessed)."\n\n\n";
	$message .= "FATAL ERRORS:\n-----------------------------\n".join("\n",@fatal)."\n\n\n";
	$message .= "SUCCESFUL PAYMENTS:\n-----------------------------\n".join("\n", @ok)."\n\n\n";
	my $mail = WebGUI::Mail::Send->new($self->session, {
		to=>$self->session->setting->get("commerceSendDailyReportTo"), 
		subject=>'Daily recurring payments report'
		});
	$mail->addText($message);
	$mail->send;
}

1;
			
