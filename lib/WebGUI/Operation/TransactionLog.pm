package WebGUI::Operation::TransactionLog;

use strict;
use WebGUI::Session;
use WebGUI::Commerce::Transaction;
use WebGUI::Template;
use WebGUI::DateTime;
use WebGUI::Operation;

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
			cancelUrl 	=> WebGUI::URL::page('op=cancelRecurringTransaction&tid='.$properties{transactionId}),
			canCancel 	=> ($properties{recurring} && ($properties{status} eq 'Completed')),
			});
	}

	$var{purchaseHistoryLoop} = \@historyLoop;

	return WebGUI::Template::process(1, 'Commerce/ViewPurchaseHistory', \%var);
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
		
1;

