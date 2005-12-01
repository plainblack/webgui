package WebGUI::Operation::Commerce;

use strict;
use WebGUI::Session;
use WebGUI::SQL;
use WebGUI::ErrorHandler;
use WebGUI::Commerce::Transaction;
use WebGUI::Commerce::ShoppingCart;
use WebGUI::Commerce::Payment;
use WebGUI::Commerce::Shipping;
use WebGUI::AdminConsole;
use WebGUI::TabForm;
use WebGUI::Setting;
use WebGUI::Style;
use WebGUI::Commerce;
use WebGUI::Operation;
use WebGUI::Operation::Shared;
use WebGUI::URL;
use WebGUI::International;
use WebGUI::Asset::Template;
use WebGUI::HTTP;
use WebGUI::Paginator;
use WebGUI::Form;
use Storable;
use WebGUI::Icon;


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
	$ac->addSubmenuItem(WebGUI::URL::page('op=listTransactions'), $i18n->get('list transactions')); 
        return $ac->render($workarea, $title);
}

#-------------------------------------------------------------------
sub _clearCheckoutScratch {
	_clearShippingScratch();
	_clearPaymentScratch();
}

#-------------------------------------------------------------------
sub _clearPaymentScratch {
	WebGUI::Session::setScratch('paymentGateway', '-delete-');
}

#-------------------------------------------------------------------
sub _clearShippingScratch {
	WebGUI::Session::setScratch('shippingMethod', '-delete-');
	WebGUI::Session::setScratch('shippingOptions', '-delete-');
}

#-------------------------------------------------------------------
sub _paymentSelected {
	return 0 unless (WebGUI::Session::getScratch('paymentGateway'));
	my $plugin = WebGUI::Commerce::Payment->load(WebGUI::Session::getScratch('paymentGateway'));
	return 1 if ($plugin && $plugin->enabled);
	return 0;
}

#-------------------------------------------------------------------
sub _shippingSelected {
	return 0 unless (WebGUI::Session::getScratch('shippingMethod'));

	my $plugin = WebGUI::Commerce::Shipping->load(WebGUI::Session::getScratch('shippingMethod'));
	if ($plugin) {
		$plugin->setOptions(Storable::thaw(WebGUI::Session::getScratch('shippingOptions'))) if (WebGUI::Session::getScratch('shippingOptions'));
		return 1 if ($plugin->enabled && $plugin->optionsOk);
	}
	
	return 0;
}

#-------------------------------------------------------------------
sub www_addToCart {
	WebGUI::Commerce::ShoppingCart->new->add($session{form}{itemId}, $session{form}{itemType}, $session{form}{quantity});

	return WebGUI::Operation::execute('viewCart');
}

#-------------------------------------------------------------------
sub www_cancelTransaction {
	my ($transaction, %var);
	
	$transaction = WebGUI::Commerce::Transaction->new($session{form}{tid});
	unless ($transaction->status eq 'Completed') {
		$transaction->cancelTransaction;
	}

	$var{message} = WebGUI::International::get('checkout canceled message', 'Commerce');
	
	return WebGUI::Operation::Shared::userStyle(WebGUI::Asset::Template->new($session{setting}{commerceCheckoutCanceledTemplateId})->process(\%var));
}

# This operation is here for easier future extensions to the commerce system.
#-------------------------------------------------------------------
sub www_checkout {
	return WebGUI::Operation::execute('selectShippingMethod') unless (_shippingSelected);

	return WebGUI::Operation::execute('selectPaymentGateway') unless (_paymentSelected);

	return WebGUI::Operation::execute('checkoutConfirm');
}

#-------------------------------------------------------------------
sub www_checkoutConfirm {
	my ($plugin, $f, %var, $errors, $i18n, $shoppingCart, $normal, $recurring, $shipping, $total);
	$errors = shift;
	
	$i18n = WebGUI::International->new('Commerce');
	
	# If the user isn't logged in yet, let him do so or have him create an account
	if ($session{user}{userId} == 1) {
		WebGUI::Session::setScratch('redirectAfterLogin', WebGUI::URL::page('op=checkout'));
		return WebGUI::Operation::execute('auth');
	}
	
	# If no payment gateway has been selected yet, have the user do so now.
	return WebGUI::Operation::execute('checkout') unless (_paymentSelected && _shippingSelected);

	$var{errorLoop} = [ map {{message => $_}} @{$errors} ] if $errors;

	# Put contents of cart in template vars
	$shoppingCart = WebGUI::Commerce::ShoppingCart->new;
	($normal, $recurring) = $shoppingCart->getItems;

	foreach (@$normal) {
		$_->{deleteIcon} = deleteIcon('op=deleteCartItem;itemId='.$_->{item}->id.';itemType='.$_->{item}->type);
		$_->{'quantity.form'} = WebGUI::Form::integer({
			name	=> 'quantity~'.$_->{item}->type.'~'.$_->{item}->id,
			value	=> $_->{quantity},
			size	=> 3,
		});
		$total += $_->{totalPrice};
	}
	foreach (@$recurring) {
		$_->{deleteIcon} = deleteIcon('op=deleteCartItem;itemId='.$_->{item}->id.';itemType='.$_->{item}->type);
		$_->{'quantity.form'} = WebGUI::Form::integer({
			name	=> 'quantity~'.$_->{item}->type.'~'.$_->{item}->id,
			value	=> $_->{quantity},
			size	=> 3,
		});
		$total += $_->{totalPrice};
	}

	$var{normalItemsLoop} = $normal;
	$var{normalItems} = scalar(@$normal);
	$var{recurringItemsLoop} = $recurring;
	$var{recurringItems} = scalar(@$recurring);

	$var{subTotal} = sprintf('%.2f', $total);

	$shipping = WebGUI::Commerce::Shipping->load(WebGUI::Session::getScratch('shippingMethod'));
	$shipping->setOptions(Storable::thaw(WebGUI::Session::getScratch('shippingOptions'))) if (WebGUI::Session::getScratch('shippingOptions'));

	$var{shippingName} = $shipping->name;
	$var{shippingCost} = sprintf('%.2f', $shipping->calc);

	$var{total} = sprintf('%.2f', $total + $shipping->calc);
	
	$plugin = WebGUI::Commerce::Payment->load(WebGUI::Session::getScratch('paymentGateway'));

	$f = WebGUI::HTMLForm->new;
	$f->hidden(
		-name => 'op', 
		-value => 'checkoutSubmit'
		);
	$f->raw($plugin->checkoutForm);
	$f->submit(value=>$i18n->get('pay button'));
	
	$var{form} = $f->print;
	$var{title} = $i18n->get('checkout confirm title');
	
	$var{'changePayment.url'} = WebGUI::URL::page('op=selectPaymentGateway');
	$var{'changePayment.label'} = $i18n->get('change payment gateway');
	$var{'changeShipping.url'} = WebGUI::URL::page('op=selectShippingMethod');
	$var{'changeShipping.label'} = $i18n->get('change shipping method');
	$var{'viewShoppingCart.url'} = WebGUI::URL::page('op=viewCart');
	$var{'viewShoppingCart.label'} = $i18n->get('view shopping cart');

	return WebGUI::Operation::Shared::userStyle(WebGUI::Asset::Template->new($session{setting}{commerceConfirmCheckoutTemplateId})->process(\%var));
}

#-------------------------------------------------------------------
sub www_checkoutSubmit {
	my ($plugin, $shoppingCart, $transaction, $var, $amount, @cartItems, $i18n, @transactions, 
		@normal, $currentPurchase, $checkoutError, @resultLoop, %param, $normal, $recurring, 
		$formError, $shipping, $shippingCost, $shippingDescription);
	
	$i18n = WebGUI::International->new('Commerce');

	# check if user has already logged in
	if ($session{user}{userId} == 1) {
		WebGUI::Session::setScratch('redirectAfterLogin', WebGUI::URL::page('op=checkout'));
		return WebGUI::Operation::execute('displayLogin');
	}

	# Check if a valid payment gateway has bee selected. If not have the user do so.
	return WebGUI::Operation::execute('checkout') unless (_paymentSelected && _shippingSelected);

	# Load shipping plugin.
	$shipping = WebGUI::Commerce::Shipping->load(WebGUI::Session::getScratch('shippingMethod'));
	$shipping->setOptions(Storable::thaw(WebGUI::Session::getScratch('shippingOptions'))) if (WebGUI::Session::getScratch('shippingOptions'));
	
	# Load payment plugin.
	$plugin = WebGUI::Commerce::Payment->load(WebGUI::Session::getScratch('paymentGateway'));
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

		$shipping->setShippingItems($currentPurchase->{items});
		$shippingCost = $shipping->calc;
		$shippingDescription = $shipping->description;
	
		$plugin->shippingCost($shippingCost);
		$plugin->shippingDescription($shippingDescription);
		
		# Write transaction to the log with status pending
		$transaction = WebGUI::Commerce::Transaction->new('new');
		foreach (@{$currentPurchase->{items}}) {
			$transaction->addItem($_->{item}, $_->{quantity});
			$amount += ($_->{item}->price * $_->{quantity});
			$var->{purchaseDescription} .= $_->{quantity}.' x '.$_->{item}->name.'<br />';
		}
		$transaction->shippingCost($shippingCost);
		$transaction->shippingMethod($shipping->namespace);
		$transaction->shippingOptions($shipping->getOptions);
		$transaction->shippingStatus('NotSent');
		
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

	_clearCheckoutScratch;
	
	# If everythings ok show the purchase history
	return WebGUI::Operation::execute('viewPurchaseHistory') unless ($checkoutError);

	# If an error has occurred show the template errorlog
	return WebGUI::Operation::Shared::userStyle(WebGUI::Asset::Template->new($session{setting}{commerceTransactionErrorTemplateId})->process(\%param));
}

#-------------------------------------------------------------------
sub www_completePendingTransaction {
	return WebGUI::Privilege::adminOnly() unless (WebGUI::Grouping::isInGroup(3));

	WebGUI::Commerce::Transaction->new($session{form}{tid})->completeTransaction;

	return WebGUI::Operation::execute('listPendingTransactions');
}

#-------------------------------------------------------------------
sub www_confirmRecurringTransaction {
	my($plugin, %var);
	
	$plugin = WebGUI::Commerce::Payment->load($session{form}{gateway});
	if ($plugin) {
		$plugin->confirmRecurringTransaction;
	}
}

#-------------------------------------------------------------------
sub www_confirmTransaction {
	my($plugin, %var);
	$plugin = WebGUI::Commerce::Payment->load($session{form}{pg});

	if ($plugin->confirmTransaction) {
		WebGUI::Commerce::Transaction->new($plugin->getTransactionId)->completeTransaction;
	}
}

#-------------------------------------------------------------------
sub www_deleteCartItem {
	WebGUI::Commerce::ShoppingCart->new->delete($session{form}{itemId}, $session{form}{itemType});

	return WebGUI::Operation::execute('viewCart');
}

#-------------------------------------------------------------------
sub www_editCommerceSettings {
	my (%tabs, $tabform, $jscript, $currentPlugin, $ac, $jscript, $i18n, 
		$paymentPlugin, @paymentPlugins, %paymentPlugins, @failedPaymentPlugins, $plugin,
		$shippingPlugin, @shippingPlugins, %shippingPlugins, @failedShippingPlugins);
	return WebGUI::Privilege::adminOnly() unless (WebGUI::Grouping::isInGroup(3));
	
	$i18n = WebGUI::International->new('Commerce');
	
	tie %tabs, 'Tie::IxHash';
 	%tabs = (
       		general=>{label=>$i18n->get('general tab')},
		payment=>{label=>$i18n->get('payment tab')},
		shipping=>{label=>$i18n->get('shipping tab')},
        );

	$paymentPlugin = $session{config}{paymentPlugins}->[0];
	$shippingPlugin = $session{config}{shippingPlugins}->[0];
	
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
	$tabform->getTab('general')->template(
		-name		=> 'commerceSelectPaymentGatewayTemplateId',
		-label		=> $i18n->get('checkout select payment template'),
		-value		=> $session{setting}{commerceSelectPaymentGatewayTemplateId},
		-namespace	=> 'Commerce/SelectPaymentGateway'
		);
	$tabform->getTab('general')->template(
		-name		=> 'commerceSelectShippingMethodTemplateId',
		-label		=> $i18n->get('checkout select shipping template'),
		-value		=> $session{setting}{commerceSelectShippingMethodTemplateId},
		-namespace	=> 'Commerce/SelectShippingMethod'
		);
	$tabform->getTab('general')->template(
		-name		=> 'commerceViewShoppingCartTemplateId',
		-label		=> $i18n->get('view shopping cart template'),
		-value		=> $session{setting}{commerceViewShoppingCartTemplateId},
		-namespace	=> 'Commerce/ViewShoppingCart'
		);

	$tabform->getTab('general')->email(
		-name		=> 'commerceSendDailyReportTo',
		-label		=> $i18n->get('daily report email'),
		-value		=> $session{setting}{commerceSendDailyReportTo}
		);

	# Check which payment plugins will compile, and load them.
	foreach (@{$session{config}{paymentPlugins}}) {
		$plugin = WebGUI::Commerce::Payment->load($_);
		if ($plugin) {
			push(@paymentPlugins, $plugin);
			$paymentPlugins{$_} = $plugin->name;
		} else {
			push(@failedPaymentPlugins, $_);
		}
	}
		
	# payment plugin
	if (%paymentPlugins) {
		WebGUI::Style::setRawHeadTags('<script type="text/javascript">var activePayment="'.$paymentPlugin.'";</script>');
		$tabform->getTab("payment")->selectBox(
			-name		=> 'commercePaymentPlugin',
			-options	=> \%paymentPlugins,
			-label		=> $i18n->get('payment form'),
			-value		=> $paymentPlugin,
			-extras		=> 'onchange="activePayment=operateHidden(this.options[this.selectedIndex].value,activePayment)"'
			);
			
		foreach $currentPlugin (@paymentPlugins) {
			my $style = '" style="display: none;' unless ($currentPlugin->namespace eq $paymentPlugin);
			$tabform->getTab('payment')->raw('<tr id="'.$currentPlugin->namespace.$style.'"><td colspan="2" width="100%">'.
				'<table border="0" cellspacing="0" cellpadding="0" width="100%">'.
				$currentPlugin->configurationForm.'<tr><td width="304">&nbsp;</td><td width="496">&nbsp;</td></tr></table></td></tr>');
		}
	} else {
		$tabform->getTab('payment')->raw('<tr><td colspan="2" align="left">'.$i18n->get('no payment plugins selected').'</td></tr>');
	}

	if (@failedPaymentPlugins) {
		$tabform->getTab('payment')->raw('<tr><td colspan="2" align="left"><br />'.$i18n->get('failed payment plugins').
						'<br /><ul><li>'.join('</li><li>', @failedPaymentPlugins).'</li></ul></td></tr>');
	}

# Shipping plugins...
	# Check which payment plugins will compile, and load them.
	foreach (@{$session{config}{shippingPlugins}}) {
		$plugin = WebGUI::Commerce::Shipping->load($_);
		if ($plugin) {
			push(@shippingPlugins, $plugin);
			$shippingPlugins{$_} = $plugin->name;
		} else {
			push(@failedShippingPlugins, $_);
		}
	}
	
	# shipping plugin
	if (%shippingPlugins) {
		WebGUI::Style::setRawHeadTags('<script type="text/javascript">var activeShipping="'.$shippingPlugin.'";</script>');
		$tabform->getTab('shipping')->selectBox(
			-name	=> 'commerceShippingPlugin',
			-options=> \%shippingPlugins,
			-label	=> $i18n->get('shipping plugin label'),
			-value	=> $shippingPlugin,
			-extras	=> 'onchange="activeShipping=operateHidden(this.options[this.selectedIndex].value,activeShipping)"'
			);
		
		foreach $currentPlugin (@shippingPlugins) {
			my $style = '" style="display: none;' unless ($currentPlugin->namespace eq $shippingPlugin);
			$tabform->getTab('shipping')->raw('<tr id="'.$currentPlugin->namespace.$style.'"><td colspan="2" width="100%">'.
				'<table border="0" cellspacing="0" cellpadding="0" width="100%">'.
				$currentPlugin->configurationForm.'<tr><td width="304">&nbsp;</td><td width="496">&nbsp;</td></tr></table></td></tr>');
		}
	} else {
		$tabform->getTab('shipping')->raw('<tr><td colspan="2" align="left">'.$i18n->get('no shipping plugins selected').'</td></tr>');
	}

	$tabform->submit;

	WebGUI::Style::setScript($session{config}{extrasURL}.'/swapLayers.js',{type=>"text/javascript"});
	
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
			WebGUI::Setting::set($_,$session{form}{$_});
		}
	}
	
	return WebGUI::Operation::execute('editCommerceSettings');
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
		$output .= '<td><a href="'.WebGUI::URL::page('op=completePendingTransaction;tid='.$properties->{transactionId}).'">'.$i18n->get('complete pending transaction').'</a></td>';
		$output .= '</tr>';
	}
	$output .= '</table>';
	$output .= $p->getBarTraditional($session{form}{pn});

	_submenu($output, 'list pending transactions', 'list pending transactions');
}

#-------------------------------------------------------------------
sub www_listTransactions {
	my ($output, %criteria, $transaction, @transactions);

	return WebGUI::Privilege::insufficient unless (WebGUI::Grouping::isInGroup(3));

	my $i18n = WebGUI::International->new('TransactionLog');

	my $transactionOptions = {
		''		=> 'Any',
		'Pending'	=> 'Pending',
		'Completed'	=> 'Completed',
	};

	my $shippingOptions = {
		''		=> 'Any',
		'Shipped'	=> 'Shipped',
		'NotShipped'	=> 'Not yet shipped',
		'Delivered'	=> 'Delivered',
	};
	
	my $initStart = WebGUI::FormProcessor::date('initStart');
	my $initStop  = WebGUI::DateTime::addToTime(WebGUI::FormProcessor::date('initStop'),23,59);
	my $completionStart = WebGUI::FormProcessor::date('completionStart');
	my $completionStop  = WebGUI::DateTime::addToTime(WebGUI::FormProcessor::date('completionStop'),23,59);

	$output .= $i18n->get('selection message');
	
	$output .= WebGUI::Form::formHeader;
	$output .= WebGUI::Form::hidden({name=>'op', value=>'listTransactions'});
	$output .= '<table>';
	$output .= '<td>'.WebGUI::Form::radio({name=>'selection', value => 'init', checked=>($session{form}{selection} eq 'init')}).'</td>';
	$output .= '<td align="left">'.$i18n->get('init date').'</td>';
	$output .= '<td>'.WebGUI::Form::date({name=>'initStart', value=>$initStart}).' '.$i18n->get('and').' '.WebGUI::Form::date({name=>'initStop', value=>$initStop}).'</td>';
	$output .= '</tr><tr>';
	$output .= '<td>'.WebGUI::Form::radio({name=>'selection', value => 'completion', checked=>($session{form}{selection} eq 'completion')}).'</td>';
	$output .= '<td align="left">'.$i18n->get('completion date').'</td>';
	$output .= '<td>'.WebGUI::Form::date({name=>'completionStart', value=>$completionStart}).' '.$i18n->get('and').' '.WebGUI::Form::date({name=>'completionStop', value=>$completionStop}).'</td>';
	$output .= '</tr><tr>';
	$output .= '<td></td>';
	$output .= '<td align="left">'.$i18n->get('transaction status').'</td>';
	$output .= '<td>'.WebGUI::Form::selectBox({name => 'tStatus', value => [$session{form}{tStatus}], options => $transactionOptions});
	$output .= '</tr><tr>';
	
	$output .= '<td></td>';
	$output .= '<td align="left">'.$i18n->get('shipping status').'</td>';
	$output .= '<td>'.WebGUI::Form::selectBox({name => 'sStatus', value => [$session{form}{sStatus}], options => $shippingOptions});
	$output .= '</tr><tr>';

	$output .= '<td></td>';
	$output .= '<td>'.WebGUI::Form::submit({value=>$i18n->get('select')}).'</td>';
	$output .= '</tr>';
	$output .= '</table>';
	$output .= WebGUI::Form::formFooter;

	$criteria{initStart} = WebGUI::FormProcessor::date('initStart') if ($session{form}{initStart} && ($session{form}{selection} eq 'init'));
	$criteria{initStop} = WebGUI::FormProcessor::date('initStop') if ($session{form}{initStop} && ($session{form}{selection} eq 'init'));
	$criteria{completionStart} = WebGUI::FormProcessor::date('completionStart') if ($session{form}{completionStart} && ($session{form}{selection} eq 'completion'));
	$criteria{completionStop} = WebGUI::FormProcessor::date('completionStop') if ($session{form}{completionStop} && ($session{form}{selection} eq 'completion'));
	$criteria{shippingStatus} = $session{form}{sStatus} if ($session{form}{sStatus});
	$criteria{paymentStatus} = $session{form}{tStatus} if ($session{form}{tStatus});
	
	@transactions = WebGUI::Commerce::Transaction->getTransactions(\%criteria);

	$output .= '<table border="1">';
	$output .= '<tr><th></th><th>Init Date</th><th>Completion Date</th><th>Amount</th><th>Shipping Cost</th><th>Status</th><th>Shipping Status</th></tr>';
	foreach $transaction (@transactions) {
		$output .= '<tr bgcolor="#ddd">';
		$output .= '<td>'.deleteIcon('op=deleteTransaction;tid='.$transaction->get('transactionId')).'</td>';
		$output .= '<td>'.WebGUI::DateTime::epochToHuman($transaction->get('initDate')).'</td>';
		$output .= '<td>'.WebGUI::DateTime::epochToHuman($transaction->get('completionDate')).'</td>';
		$output .= '<td>'.$transaction->get('amount').'</td>';
		$output .= '<td>'.$transaction->get('shippingCost').'</td>';
		$output .= '<td>'.$transaction->get('status').'</td>';
		$output .= '<td>'.$transaction->get('shippingStatus').'</td>';
		$output .= '</tr>';
		
		my @items = @{$transaction->getItems};
		foreach (@items) {
			$output .= '<tr>';
			$output .= '<td></td>';
			$output .= '<td colspan="3">'.
				deleteIcon('op=deleteTransactionItem;tid='.$transaction->get('transactionId').';iid='.$_->{itemId}.';itype='.$_->{itemType}).
				$_->{itemName}.'</td>';
			$output .= '<td>'.$_->{quantity}.'</td>';
			$output .= '<td> x </td>';
			$output .= '<td>'.$_->{amount}.'</td>';
			$output .= '</tr>';
		}
	}
	$output .= '</table>';

	return _submenu($output, 'list transactions')
}

#-------------------------------------------------------------------
sub www_selectPaymentGateway {
	my ($plugins, $f, $i18n, @pluginLoop, %var);

	_clearPaymentScratch;
	
	$i18n = WebGUI::International->new('Commerce');
	$plugins = WebGUI::Commerce::Payment->getEnabledPlugins;
	if (scalar(@$plugins) > 1) {
		foreach (@$plugins) {
			push(@pluginLoop, {
				name		=> $_->name,
				namespace	=> $_->namespace,
				formElement	=> WebGUI::Form::radio({name=>'paymentGateway', value=>$_->namespace})
				});
		}
	} elsif (scalar(@$plugins) == 1) {
		$session{form}{paymentGateway} = $plugins->[0]->namespace;
		return WebGUI::Operation::execute('selectPaymentGatewaySave');
	}
	
	$var{pluginLoop} = \@pluginLoop;
	$var{message} = $i18n->get('select payment gateway');
	$var{pluginsAvailable} = @$plugins;
	$var{noPluginsMessage} = $i18n->get('no payment gateway');
	$var{formHeader} = WebGUI::Form::formHeader.WebGUI::Form::hidden({name=>'op', value=>'selectPaymentGatewaySave'});
	$var{formSubmit} = WebGUI::Form::submit({value=>$i18n->get('payment gateway select')});
	$var{formFooter} = WebGUI::Form::formFooter;		
	
	return WebGUI::Operation::Shared::userStyle(WebGUI::Asset::Template->new($session{setting}{commerceSelectPaymentGatewayTemplateId})->process(\%var));
}

#-------------------------------------------------------------------
sub www_selectPaymentGatewaySave {
	if (WebGUI::Commerce::Payment->load($session{form}{paymentGateway})->enabled) {
		WebGUI::Session::setScratch('paymentGateway', $session{form}{paymentGateway});
	} else {
		WebGUI::Session::setScratch('paymentGateway', '-delete-');
	}

	return WebGUI::Operation::execute('checkout');
}

#-------------------------------------------------------------------
sub www_selectShippingMethod {
	my ($plugins, $f, $i18n, @pluginLoop, %var);

	_clearShippingScratch;
	
	$i18n = WebGUI::International->new('Commerce');
	$plugins = WebGUI::Commerce::Shipping->getEnabledPlugins;
	
	if (scalar(@$plugins) > 1) {
		foreach (@$plugins) {
			push(@pluginLoop, {
				name		=> $_->name,
				namespace	=> $_->namespace,
				formElement	=> WebGUI::Form::radio({name=>'shippingMethod', value=>$_->namespace})
				});
		}
	} elsif (scalar(@$plugins) == 1) {
		$session{form}{shippingMethod} = $plugins->[0]->namespace;
		return WebGUI::Operation::execute("selectShippingMethodSave");
	}
	
	$var{pluginLoop} = \@pluginLoop;
	$var{message} = $i18n->get('select shipping method');
	$var{pluginsAvailable} = @$plugins;
	$var{noPluginsMessage} = $i18n->get('no shipping methods available');
	$var{formHeader} = WebGUI::Form::formHeader.WebGUI::Form::hidden({name=>'op', value=>'selectShippingMethodSave'});
	$var{formSubmit} = WebGUI::Form::submit({value=>$i18n->get('shipping select button')});
	$var{formFooter} = WebGUI::Form::formFooter;		
	
	return WebGUI::Operation::Shared::userStyle(WebGUI::Asset::Template->new($session{setting}{commerceSelectShippingMethodTemplateId})->process(\%var));
}

#-------------------------------------------------------------------
sub www_selectShippingMethodSave {
	my $shipping = WebGUI::Commerce::Shipping->load($session{form}{shippingMethod});
	
	$shipping->processOptionsForm;
	return WebGUI::Operation::execute('selectShipping') unless ($shipping->optionsOk);
	
	if ($shipping->enabled) {
		WebGUI::Session::setScratch('shippingMethod', $shipping->namespace);
		WebGUI::Session::setScratch('shippingOptions', Storable::freeze($shipping->getOptions));
	} else {
		WebGUI::Session::setScratch('shippingMethod', '-delete-');
	}

	return WebGUI::Operation::execute('checkout');
}

#-------------------------------------------------------------------
sub www_transactionComplete {
	return WebGUI::Operation::execute('viewPurchaseHistory');	
}

#-------------------------------------------------------------------
sub www_updateCart {
my	$shoppingCart = WebGUI::Commerce::ShoppingCart->new;

	foreach my $formElement (keys(%{$session{form}})) {
		if ($formElement =~ m/^quantity~([^~]*)~([^~]*)$/) {
			$shoppingCart->setQuantity($2, $1, $session{form}{$formElement});
		}
	}

	return WebGUI::Operation::execute('viewCart');
}

#-------------------------------------------------------------------
sub www_viewCart {
	my ($shoppingCart, $normal, $recurring, %var, $total, $i18n);

	$i18n = WebGUI::International->new('Commerce');
	
	# Put contents of cart in template vars
	$shoppingCart = WebGUI::Commerce::ShoppingCart->new;
	($normal, $recurring) = $shoppingCart->getItems;

	foreach (@$normal) {
		$_->{deleteIcon} = deleteIcon('op=deleteCartItem;itemId='.$_->{item}->id.';itemType='.$_->{item}->type);
		$_->{'quantity.form'} = WebGUI::Form::integer({
			name	=> 'quantity~'.$_->{item}->type.'~'.$_->{item}->id,
			value	=> $_->{quantity},
			size	=> 3,
		});
		$total += $_->{totalPrice};
	}
	foreach (@$recurring) {
		$_->{deleteIcon} = deleteIcon('op=deleteCartItem;itemId='.$_->{item}->id.';itemType='.$_->{item}->type);
		$_->{'quantity.form'} = WebGUI::Form::integer({
			name	=> 'quantity~'.$_->{item}->type.'~'.$_->{item}->id,
			value	=> $_->{quantity},
			size	=> 3,
		});
		$total += $_->{totalPrice};
	}

	$var{'cartEmpty'} = !(scalar(@$normal) || scalar(@$recurring));
	$var{'cartEmpty.message'} = $i18n->get('shopping cart empty');
	
	$var{'updateForm.header'} = WebGUI::Form::formHeader().
		WebGUI::Form::hidden({name => 'op', value => 'updateCart'});
	$var{'updateForm.button'} = WebGUI::Form::submit({value => $i18n->get('update cart')});
	$var{'updateForm.footer'} = WebGUI::Form::formFooter;
	$var{'checkoutForm.header'} = WebGUI::Form::formHeader().
		WebGUI::Form::hidden({name => 'op', value => 'checkout'});
	$var{'checkoutForm.button'} = WebGUI::Form::submit({value => $i18n->get('checkout')});
	$var{'checkoutForm.footer'} = WebGUI::Form::formFooter;
	
	$var{normalItemsLoop} = $normal;
	$var{normalItems} = scalar(@$normal);
	$var{recurringItemsLoop} = $recurring;
	$var{recurringItems} = scalar(@$recurring);
	
	$var{total} = sprintf('%.2f', $total);

	return WebGUI::Operation::Shared::userStyle(WebGUI::Asset::Template->new($session{setting}{commerceViewShoppingCartTemplateId})->process(\%var));
}

1;

