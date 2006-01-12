package WebGUI::Operation::TransactionLog;

use strict;
use WebGUI::Commerce::Transaction;
use WebGUI::Asset::Template;
use WebGUI::Operation;
use WebGUI::Form;
use WebGUI::Grouping;

=head1 NAME

Package WebGUI::Operation::TransactionLog

=head1 DESCRIPTION

Operations for dealing with transactions from the WebGUI Commerce System.

=cut
#-------------------------------------------------------------------

=head2 www_viewPurchaseHistory ( errorMessage )

Templated output of all Commerce transactions by this user.  Allows the user to cancel any recurring
transactions.

=head3 errorMessage

This error message will be added to the template variables.

=cut

sub www_viewPurchaseHistory {
	my $session = shift;
	my (@history, @historyLoop, %var, %properties);

	$var{errorMessage} = shift;
	
	@history = @{WebGUI::Commerce::Transaction->transactionsByUser($session->user->profileField("userId"))};
	foreach (@history) {
		%properties = %{$_->get};
		$properties{initDate} = $session->datetime->epochToHuman($properties{initDate});
		$properties{completionDate} = $session->datetime->epochToHuman($properties{completionDate}) if ($properties{completionDate});
		push(@historyLoop, {
			(%properties),
			itemLoop 	=> $_->getItems,
			cancelUrl 	=> $session->url->page('op=cancelRecurringTransaction;tid='.$properties{transactionId}),
			canCancel 	=> ($properties{recurring} && ($properties{status} eq 'Completed')),
			});
	}

	$var{purchaseHistoryLoop} = \@historyLoop;

	return $session->style->userStyle(WebGUI::Asset::Template->new("PBtmpl0000000000000019")->process(\%var));
}

#-------------------------------------------------------------------

=head2 www_cancelRecurringTransaction ( )

Cancels a transaction if it is recurring.  If not, an error message is returned.
The transaction to cancel is passed in via a form field entry in the session variable,
$session->form->process("tid").

=cut

sub www_cancelRecurringTransaction {
	my $session = shift;
	my ($transaction, $error, $message);
	
	my $i18n = WebGUI::International->new($session, "TransactionLog");
	
	$transaction = WebGUI::Commerce::Transaction->new($session->form->process("tid"));
	if ($transaction->isRecurring) {
		$error = $transaction->cancelTransaction;
		$message = $i18n->get('cancel error').$error if ($error);
	} else {
		$message = $i18n->get('cannot cancel');
	}

	return www_viewPurchaseHistory($message);
}

#-------------------------------------------------------------------

=head2 www_deleteTransaction ( )

Deletes a transaction, as specified by $session->form->process("tid").
Afterward, it calls www_listTransactions

=cut

sub www_deleteTransaction {
	my $session = shift;
	my $transactionId;

	return $session->privilege->insufficient unless ($session->user->isInGroup(3));

	$transactionId = $session->form->process("tid");

	WebGUI::Commerce::Transaction->new($transactionId)->delete;

	return WebGUI::Operation::execute('listTransactions');
}

#-------------------------------------------------------------------
sub www_deleteTransactionItem {
	my $session = shift;
	return $session->privilege->insufficient unless ($session->user->isInGroup(3));
	
	WebGUI::Commerce::Transaction->new($session->form->process("tid"))->deleteItem($session->form->process("iid"), $session->form->process("itype"));

	return WebGUI::Operation::execute('listTransactions');
}

1;

