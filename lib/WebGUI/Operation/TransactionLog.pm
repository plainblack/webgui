package WebGUI::Operation::TransactionLog;

use strict;
use WebGUI::Session;
use WebGUI::Commerce::Transaction;
use WebGUI::Asset::Template;
use WebGUI::DateTime;
use WebGUI::Operation;
use WebGUI::Form;
use WebGUI::Privilege;
use WebGUI::Grouping;

#-------------------------------------------------------------------
sub www_viewPurchaseHistory {
	my (@history, @historyLoop, %var, %properties);

	$var{errorMessage} = shift;
	
	@history = @{WebGUI::Commerce::Transaction->transactionsByUser($session{user}{userId})};
	foreach (@history) {
		%properties = %{$_->get};
		$properties{initDate} = WebGUI::DateTime::epochToHuman($properties{initDate});
		$properties{completionDate} = WebGUI::DateTime::epochToHuman($properties{completionDate}) if ($properties{completionDate});
		push(@historyLoop, {
			(%properties),
			itemLoop 	=> $_->getItems,
			cancelUrl 	=> WebGUI::URL::page('op=cancelRecurringTransaction;tid='.$properties{transactionId}),
			canCancel 	=> ($properties{recurring} && ($properties{status} eq 'Completed')),
			});
	}

	$var{purchaseHistoryLoop} = \@historyLoop;

	return WebGUI::Operation::Shared::userStyle(WebGUI::Asset::Template->new("PBtmpl0000000000000019")->process(\%var));
}

#-------------------------------------------------------------------
sub www_cancelRecurringTransaction {
	my ($transaction, $error, $message);
	
	my $i18n = WebGUI::International->new("TransactionLog");
	
	$transaction = WebGUI::Commerce::Transaction->new($session{form}{tid});
	if ($transaction->isRecurring) {
		$error = $transaction->cancelTransaction;
		$message = $i18n->get('cancel error').$error if ($error);
	} else {
		$message = $i18n->get('cannot cancel');
	}

	return www_viewPurchaseHistory($message);
}

#-------------------------------------------------------------------
sub www_deleteTransaction {
	my $transactionId;

	return WebGUI::Privilege::insufficient unless (WebGUI::Grouping::isInGroup(3));

	$transactionId = $session{form}{tid};

	WebGUI::Commerce::Transaction->new($transactionId)->delete;

	return WebGUI::Operation::execute('listTransactions');
}

#-------------------------------------------------------------------
sub www_deleteTransactionItem {
	return WebGUI::Privilege::insufficient unless (WebGUI::Grouping::isInGroup(3));
	
	WebGUI::Commerce::Transaction->new($session{form}{tid})->deleteItem($session{form}{iid}, $session{form}{itype});

	return WebGUI::Operation::execute('listTransactions');
}

1;

