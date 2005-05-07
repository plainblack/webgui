package Hourly::ProcessRecurringPayments;

use strict;
use WebGUI::SQL;
use WebGUI::Commerce::Payment;
use WebGUI::Commerce::Transaction;
use WebGUI::Commerce::Item;
use WebGUI::DateTime;
use WebGUI::Session;

sub _getDuration {
	my $duration = shift;
	
	return addToDate(0,0,0,7) if $duration eq 'Weekly';
	return addToDate(0,0,0,14) if $duration eq 'BiWeekly';
	return addToDate(0,0,0,28) if $duration eq 'FourWeekly';
	return addToDate(0,0,1,0) if $duration eq 'Monthly';
	return addToDate(0,0,3,0) if $duration eq 'Quarterly';
	return addToDate(0,0,6,0) if $duration eq 'HalfYearly';
	return addToDate(0,1,0,0) if $duration eq 'Yearly';
}

sub process {
	my @recurringTransactions = WebGUI::SQL->buildArray("select transactionId from transaction where recurring=1 and status='Completed'");

	my (@unprocessed, @ok, @failed, @fatal);	
	foreach (@recurringTransactions) {
		my $transaction = WebGUI::Commerce::Transaction->new($_);
		my $itemProperties = $transaction->getItems->[0];
		my $item = WebGUI::Commerce::Item->new($itemProperties->{itemId}, $itemProperties->{itemType});
		my $time = time;
		$time -= $transaction->get('initDate');
		my $term = int($time / _getDuration($item->duration)) + 1;

		if ($term > $transaction->lastPayedTerm) {
			my $payment = WebGUI::Commerce::Payment->load($transaction->gateway);
			
 			$transaction->gatewayId;
			my $status = $payment->getRecurringPaymentStatus($transaction->gatewayId, $term);
			
			my $output = $item->name." (tid: ".$transaction->get('transactionId').") ";
		        $output .= " by user ".WebGUI::User->new($transaction->get(userId))->username." (uid: ".$transaction->get(userId).") ";
			$output .= " for term ". sprintf('% 6d', $term)." "; 
			$output .= " -> ".$transaction->gateway.": (".$transaction->gatewayId.")\t";
			unless ($payment->resultCode) {
				unless (defined $status) {
					$output .= "NOT PROCESSED YET";
					push (@unprocessed, $output);
				} elsif ($status->{resultCode} eq '0') {
					$output .= "OK";
					push (@ok, $output);
					$item->handler($transaction->get(userId)) unless ($term == 1);
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

	WebGUI::Mail::send($session{setting}{commerceSendDailyReportTo}, 'Daily recurring payments report', $message);
}

1;
			
