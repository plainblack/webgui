package WebGUI::Operation::Commerce;

use strict;
use WebGUI::Session;
use WebGUI::SQL;
use WebGUI::ErrorHandler;
use WebGUI::Commerce::Transaction;
use WebGUI::Commerce::ShoppingCart;
use WebGUI::Commerce::Payment;
use WebGUI::AdminConsole;
use WebGUI::TabForm;
use WebGUI::Style;
use WebGUI::Commerce;
use WebGUI::Operation;
use WebGUI::URL;
use WebGUI::International;
use WebGUI::Template;
use WebGUI::HTTP;
use WebGUI::Paginator;

#-------------------------------------------------------------------
sub _submenu {
	my $i18n = WebGUI::International->new("Commerce");

	my $workarea = shift;
        my $title = shift;
        $title = $i18n->get($title) if ($title);
        my $help = shift;
        my $ac = WebGUI::AdminConsole->new("commerce");
        if ($help) {
                $ac->setHelp($help, 'Commerce');
        }
	$ac->addSubmenuItem(WebGUI::URL::page('op=editCommerceSettings'), $i18n->get('manage commerce settings'));
	$ac->addSubmenuItem(WebGUI::URL::page('op=listPendingTransactions'), $i18n->get('pending transactions')); 
        return $ac->render($workarea, $title);
}

#-------------------------------------------------------------------
sub www_cancelTransaction {
	my ($transaction, %var);
	
	$transaction = WebGUI::Commerce::Transaction->new($session{form}{tid});
	unless ($transaction->status eq 'Completed') {
		$transaction->cancelTransaction;
	}

	$var{message} = WebGUI::International::get('checkout canceled message', 'Commerce');
	
	return WebGUI::Template::process($session{setting}{commerceCheckoutCanceledTemplateId}, 'Commerce/CheckoutCanceled', \%var);
}

# This operation is here for easier future extensions to the commerce system.
#-------------------------------------------------------------------
sub www_checkout {
	return WebGUI::Operation::execute('checkoutConfirm');
}

#-------------------------------------------------------------------
sub www_checkoutConfirm {
	my ($plugin, $f, %var, $errors, $i18n, $shoppingCart, $normal, $recurring);
	$errors = shift;
	
	$i18n = WebGUI::International->new('Commerce');

	unless ($session{setting}{commercePaymentPlugin}) {
		$var{errorLoop} = [{message=>$i18n->get('no payment gateway')}];
		return WebGUI::Template::process($session{setting}{commerceConfirmCheckoutTemplateId}, 'Commerce/ConfirmCheckout', \%var);
	}
	
	$var{errorLoop} = [ map {{message => $_}} @{$errors} ] if $errors;

	# Put contents of cart in template vars
	$shoppingCart = WebGUI::Commerce::ShoppingCart->new;
	($normal, $recurring) = $shoppingCart->getItems;

	$var{normalItemLoop} = $normal;
	$var{normalItems} = scalar(@$normal);
	$var{recurringLoop} = $recurring;
	$var{recurringItems} = scalar(@$recurring);
	
	$plugin = WebGUI::Commerce::Payment->load($session{setting}{commercePaymentPlugin});

	# If the user isn't logged in yet, let him do so or have him create an account
	if ($session{user}{userId} == 1) {
		WebGUI::Session::setScratch('redirectAfterLogin', WebGUI::URL::page('op=checkout'));
		return WebGUI::Operation::execute('displayLogin');
	}

	$f = WebGUI::HTMLForm->new;
	$f->hidden('op', 'checkoutSubmit');
	$f->raw($plugin->checkoutForm);
	$f->submit($i18n->get('pay button'));
	
	$var{form} = $f->print;
	$var{title} = $i18n->get('checkout confirm title');

	return WebGUI::Template::process($session{setting}{commerceConfirmCheckoutTemplateId}, 'Commerce/ConfirmCheckout', \%var);
}

#-------------------------------------------------------------------
sub www_checkoutSubmit {
	my ($plugin, $shoppingCart, $transaction, $var, $amount, @cartItems, $i18n, @transactions, 
		@normal, $currentPurchase, $checkoutError, @resultLoop, %param, $normal, $recurring, $formError);
	
	$i18n = WebGUI::International->new('Commerce');
	
	# check if user has already logged in
	if ($session{user}{userId} == 1) {
		WebGUI::Session::setScratch('redirectAfterLogin', WebGUI::URL::page('op=checkout'));
		return WebGUI::Operation::execute('displayLogin');
	}

	$plugin = WebGUI::Commerce::Payment->load($session{setting}{commercePaymentPlugin});
	$shoppingCart = WebGUI::Commerce::ShoppingCart->new;
	($normal, $recurring) = $shoppingCart->getItems;

	# Check if shoppingcart contains any items. If not the user probably clicked reload, so we redirect to the current page.
	unless (@$normal || @$recurring) {
		WebGUI::HTTP::setRedirect(WebGUI::URL::page);
		return '';
	}

	# check submitted form params
	$formError = $plugin->validateFormData;
	return www_checkoutConfirm($formError) if ($formError);

	# Combine all non recurring item in one transaction and combine with all recurring ones
	map {push(@transactions, {recurring => 1, items => [$_]})} @$recurring;
	push(@transactions, {recurring => 0, items => [@$normal]}) if (@$normal);
	
	$shoppingCart->empty;
	
	foreach $currentPurchase (@transactions) {
		$amount = 0;
		$var = {};
		
		# Write transaction to the log with status pending
		$transaction = WebGUI::Commerce::Transaction->new('new');
		foreach (@{$currentPurchase->{items}}) {
			$transaction->addItem($_->{item}, $_->{quantity});
			$amount += ($_->{item}->price * $_->{quantity});
			$var->{purchaseDescription} .= $_->{quantity}.' x '.$_->{item}->name.'<br>';
		}
		$var->{purchaseAmount} = sprintf('%.2f', $amount);

		# submit	
		if ($currentPurchase->{recurring}) {
			$transaction->isRecurring(1);
			$plugin->recurringTransaction({
				amount		=> $amount,
				id              => $transaction->transactionId,
				term		=> 0,
				payPeriod	=> $currentPurchase->{items}->[0]->{item}->duration,
				profilename	=> $currentPurchase->{items}->[0]->{item}->name,
				checkCard	=> 1,
				});
		} else {
			$plugin->normalTransaction({
				amount          => $amount,
				id		=> $transaction->transactionId,
				});
		}

		$transaction->gatewayId($plugin->gatewayId);
		$transaction->gateway($plugin->namespace);
		
		# check transaction result
		unless ($plugin->connectionError) {
			unless ($plugin->transactionError) {
				$transaction->completeTransaction if ($plugin->transactionCompleted);
				$var->{status} = $i18n->get('ok');
			} elsif ($plugin->transactionPending) {
				$checkoutError = 1;
				$var->{status} = $i18n->get('pending');
				$var->{error} = $plugin->transactionError;
				$var->{errorCode} = $plugin->errorCode;
			} else {
				$checkoutError = 1;
				$var->{status} = $i18n->get('transaction error');
				$var->{error} = $plugin->transactionError;
				$var->{errorCode} = $plugin->errorCode;
				$transaction->delete;
			}
		} else {
			$checkoutError = 1;
			$var->{status} = $i18n->get('connection error');
			$var->{error} = $plugin->connectionError;
			$var->{errorCode} = $plugin->errorCode;
			$transaction->delete;
		}
		
		push(@resultLoop, $var);
	}

	$param{title} = $i18n->get('transaction error title');
	$param{statusExplanation} = $i18n->get('status codes information');
	$param{resultLoop} = \@resultLoop;
	
	# If everythings ok show the purchase history
	return WebGUI::Operation::execute('viewPurchaseHistory') unless ($checkoutError);

	# If an error has occurred show the template errorlog
	return WebGUI::Template::process($session{setting}{commerceTransactionErrorTemplateId}, 'Commerce/TransactionError', \%param);
}

#-------------------------------------------------------------------
sub www_completePendingTransaction {
	return WebGUI::Privilege::adminOnly() unless (WebGUI::Grouping::isInGroup(3));

	WebGUI::Commerce::Transaction->new($session{form}{tid})->completeTransaction;

	return WebGUI::Operation::execute('listPendingTransactions');
}

#-------------------------------------------------------------------
sub www_confirmTransaction {
	my($plugin, %var);
	$plugin = WebGUI::Commerce::Payment->load($session{setting}{commercePaymentPlugin});

	if ($plugin->confirmTransaction) {
		WebGUI::Commerce::Transaction->new($plugin->getTransactionId)->completeTransaction;
	}
}

#-------------------------------------------------------------------
sub www_editCommerceSettings {
	my (%tabs, $tabform, $jscript, $currentPlugin, $ac, $jscript, $i18n, $paymentPlugin);
	return WebGUI::Privilege::adminOnly() unless (WebGUI::Grouping::isInGroup(3));
	
	$i18n = WebGUI::International->new('Commerce');
	
	tie %tabs, 'Tie::IxHash';
 	%tabs = (
       		general=>{label=>$i18n->get('general tab')},
        	payment=>{label=>$i18n->get('payment tab')},
        );

	$paymentPlugin = $session{setting}{commercePaymentPlugin} || $session{config}{paymentPlugins}->[0];

	$tabform = WebGUI::TabForm->new(\%tabs);
	$tabform->hidden({name => 'op', value => 'editCommerceSettingsSave'});
	
	# general
	$tabform->getTab('general')->template(
		-name		=> 'commerceConfirmCheckoutTemplateId',
		-label		=> $i18n->get('confirm checkout template'),
		-value		=> $session{setting}{commerceConfirmCheckoutTemplateId},
		-namespace	=> 'Commerce/ConfirmCheckout'
		);
	$tabform->getTab('general')->template(
		-name		=> 'commerceTransactionErrorTemplateId',
		-label		=> $i18n->get('transaction error template'),
		-value		=> $session{setting}{commerceTransactionPendingTemplateId},
		-namespace	=> 'Commerce/TransactionError'
		);
	$tabform->getTab('general')->template(
		-name		=> 'commerceCheckoutCanceledTemplateId',
		-label		=> $i18n->get('checkout canceled template'),
		-value		=> $session{setting}{commerceCheckoutCanceledTemplateId},
		-namespace	=> 'Commerce/CheckoutCanceled'
		);
	$tabform->getTab('general')->email(
		-name		=> 'commerceSendDailyReportTo',
		-label		=> $i18n->get('daily report email'),
		-value		=> $session{setting}{commerceSendDailyReportTo}
		);

	# payment plugin
	$tabform->getTab('payment')->raw('<script language="JavaScript" > var activePayment="'.$paymentPlugin.'"; </script>');
	$tabform->getTab("payment")->selectList(
		-name		=> 'commercePaymentPlugin',
		-options	=> {map {$_ => $_} @{$session{config}{paymentPlugins}}},
		-label		=> $i18n->get('payment form'),
		-value		=> [$paymentPlugin],
		-extras		=> 'onChange="activePayment=operateHidden(this.options[this.selectedIndex].value,activePayment)"'
		);

	$jscript = '<script language="JavaScript">';
	foreach (@{$session{config}{paymentPlugins}}) {
		$currentPlugin = WebGUI::Commerce::Payment->load($_);
		$tabform->getTab('payment')->raw('<tr id="'.$_.'"><td colspan="2" width="100%">'.
			'<table border=0 cellspacing=0 cellpadding=0  width="100%">'.
			$currentPlugin->configurationForm.'<tr><td width="304">&nbsp;</td><td width="496">&nbsp;</td></tr></table></td></tr>');
			$jscript .= "document.getElementById(\"$_\").style.display='".(($_ eq $paymentPlugin)?"":"none")."';";
	}
	$jscript .= '</script>';	
	
	$tabform->getTab('payment')->raw($jscript);
	$tabform->submit;

	WebGUI::Style::setScript($session{config}{extrasURL}.'/swapLayers.js',{language=>"Javascript"});
	
	return _submenu($tabform->print, 'edit commerce settings title', 'commerce manage');
}

#-------------------------------------------------------------------
sub www_editCommerceSettingsSave {
	return WebGUI::Privilege::adminOnly() unless (WebGUI::Grouping::isInGroup(3));
	
	foreach (keys(%{$session{form}})) {
		# Store the plugin confiuration data in a special table for security and the general settings in the
		# normal settings table for easy access.
		if (/~([^~]*)~([^~]*)~([^~]*)/) {
			WebGUI::Commerce::setCommerceSetting({
				type		=> $1,
				namespace	=> $2,
				fieldName	=> $3, 
				fieldValue	=> $session{form}{$_}
			});
		} elsif ($_ ne 'op') {
			WebGUI::SQL->write('update settings set value='.quote($session{form}{$_}).' where name='.quote($_));
		}
	}
	
	return WebGUI::Operation::execute('adminConsole');
}

#-------------------------------------------------------------------
sub www_listPendingTransactions {
	my ($p, $transactions, $output, $properties, $i18n);
	return WebGUI::Privilege::adminOnly() unless (WebGUI::Grouping::isInGroup(3));
	
	$i18n = WebGUI::International->new("Commerce");

	$p = WebGUI::Paginator->new(WebGUI::URL::page('op=listPendingTransactions'));
	$p->setDataByArrayRef(WebGUI::Commerce::Transaction->pendingTransactions);
	
	$transactions = $p->getPageData;

	$output = $p->getBarTraditional($session{form}{pn});
	$output .= '<table border="1" cellpadding="5" cellspacing="0" align="center">';
	$output .= '<tr><th>'.$i18n->get('transactionId').'</th><th>'.$i18n->get('gateway').'</th>'.
		'<th>'.$i18n->get('gatewayId').'</th><th>'.$i18n->get('init date').'</th></tr>';
	foreach (@{$transactions}) {
		$properties = $_->get;
		$output .= '<tr>';
		$output .= '<td>'.$properties->{transactionId}.'</td>';
		$output .= '<td>'.$properties->{gatewayId}.'</td>';
		$output .= '<td>'.$properties->{gateway}.'</td>';
		$output .= '<td>'.WebGUI::DateTime::epochToHuman($properties->{initDate}).'</td>';
		$output .= '<td><a href="'.WebGUI::URL::page('op=completePendingTransaction&tid='.$properties->{transactionId}).'">'.$i18n->get('complete pending transaction').'</a></td>';
		$output .= '</tr>';
	}
	$output .= '</table>';
	$output .= $p->getBarTraditional($session{form}{pn});

	_submenu($output, 'list pending transactions', 'list pending transactions');
}

#-------------------------------------------------------------------
sub www_transactionComplete {
	return WebGUI::Operation::execute('viewPurchaseHistory');	
}

1;

