package WebGUI::Operation::Commerce;

use strict;
use WebGUI::SQL;
use WebGUI::Commerce::Transaction;
use WebGUI::Commerce::ShoppingCart;
use WebGUI::Commerce::Payment;
use WebGUI::Commerce::Shipping;
use WebGUI::AdminConsole;
use WebGUI::TabForm;
use WebGUI::Commerce;
use WebGUI::Operation;
use WebGUI::Operation::Shared;
use WebGUI::International;
use WebGUI::Asset::Template;
use WebGUI::Paginator;
use WebGUI::Form;
use Storable;


#-------------------------------------------------------------------

=head2 _submenu ( $session )

Returns a rendered Admin Console view, with a standard list of five submenu items.

=head3 $session

The current WebGUI session object.

=head3 workarea

A scalar of HTML that defines the current workarea.

=head3 title

The i18n key of the title of this workarea.

=head3 help

The i18n key of the help link for this workarea.

=cut

sub _submenu {
	my $session = shift;
	my $i18n = WebGUI::International->new($session, "Commerce");

	my $workarea = shift;
        my $title = shift;
        $title = $i18n->get($title) if ($title);
        my $help = shift;
        my $ac = WebGUI::AdminConsole->new($session,"commerce");
        if ($help) {
                $ac->setHelp($help, 'Commerce');
        }
	$ac->addSubmenuItem($session->url->page('op=editCommerceSettings'), $i18n->get('manage commerce settings'));
	$ac->addSubmenuItem($session->url->page('op=listTransactions'), $i18n->get('list transactions')); 
        return $ac->render($workarea, $title);
}

#-------------------------------------------------------------------

=head2 _clearCheckoutScratch ( $session )

A wrapper around _clearShippingScratch and _clearPaymentScratch.

=cut

sub _clearCheckoutScratch {
	my $session = shift;
	_clearShippingScratch($session);
	_clearPaymentScratch($session);
}

#-------------------------------------------------------------------

=head2 _clearPaymentScratch ( $session )

Clears the C<paymentGateway> scratch variable.

=cut

sub _clearPaymentScratch {
	my $session = shift;
	$session->scratch->set('paymentGateway', '-delete-');
}

#-------------------------------------------------------------------

=head2 _clearShippingScratch ( $session )

Clear the C<shippingMethod> and C<shippingOptions> scratch variables.

=cut

sub _clearShippingScratch {
	my $session = shift;
	$session->scratch->set('shippingMethod', '-delete-');
	$session->scratch->set('shippingOptions', '-delete-');
}

#-------------------------------------------------------------------

=head2 _paymentSelected ( $session )

A utility method to tell if the C<paymentGateway> scratch variable is
set, that it points to a valid payment plugin that can be loaded and
is enabled.

=cut

sub _paymentSelected {
	my $session = shift;
	return 0 unless ($session->scratch->get('paymentGateway'));
	my $plugin = WebGUI::Commerce::Payment->load($session, $session->scratch->get('paymentGateway'));
	return 1 if ($plugin && $plugin->enabled);
	return 0;
}

#-------------------------------------------------------------------

=head2 _shippingSelected ( $session )


A utility method to tell if the C<shippingMethod> scratch variable is
set, that it points to a valid shipping plugin that can be loaded and
is enabled and whose C<optionsOk> method returns true.

=cut

sub _shippingSelected {
	my $session = shift;
	return 0 unless ($session->scratch->get('shippingMethod'));

	my $plugin = WebGUI::Commerce::Shipping->load($session, $session->scratch->get('shippingMethod'));
	if ($plugin) {
		$plugin->setOptions(Storable::thaw($session->scratch->get('shippingOptions'))) if ($session->scratch->get('shippingOptions'));
		return 1 if ($plugin->enabled && $plugin->optionsOk);
	}
	
	return 0;
}

#-------------------------------------------------------------------

=head2 www_addToCart ( $session )

Adds the requested item to the user's shopping cart and creates a cart if necessary.

Uses these form variables:

=over 4

=item C<itemId>

The id of the item to add.

=item C<itemType>

The type (namespace) of the item that's to be added to the cart.

=item C<quantity>

The number of items to add. Defaults to 1 if quantity is not given.

=back

=cut

sub www_addToCart {
	my $session = shift;
	WebGUI::Commerce::ShoppingCart->new($session)->add($session->form->process("itemId"), $session->form->process("itemType"), $session->form->process("quantity"));

	return WebGUI::Operation::execute($session,'viewCart');
}

#-------------------------------------------------------------------

=head2 www_cancelTransaction ( $session )

Cancel the transaction described by the form varialbe C<tid> if the
transaction status is C<Completed>.  Display an internationalized
message to the user using the C<commerceCheckoutCanceledTemplateId> template from the site settings.

=cut

sub www_cancelTransaction {
	my $session = shift;
	my ($transaction, %var);
	
	$transaction = WebGUI::Commerce::Transaction->new($session, $session->form->process("tid"));
	unless ($transaction->status eq 'Completed') {
		$transaction->cancelTransaction;
	}

	my $i18n = WebGUI::International->new($session, 'Commerce');
	$var{message} = $i18n->get('checkout canceled message');
	
	return $session->style->userStyle(WebGUI::Asset::Template->new($session,$session->setting->get("commerceCheckoutCanceledTemplateId"))->process(\%var));
}

# This operation is here for easier future extensions to the commerce system.
#-------------------------------------------------------------------

=head2 www_checkout ( $session )

A wrapper around the selectShippingMethod, selectPaymentGateway and
checkoutConform methods.  selectShippingMethod and selectPaymentGateway 
are only executed if their respective scratch variables are not set.

=cut

sub www_checkout {
	my $session = shift;
	return WebGUI::Operation::execute($session,'selectShippingMethod') unless (_shippingSelected($session));

	return WebGUI::Operation::execute($session,'selectPaymentGateway') unless (_paymentSelected($session));

	return WebGUI::Operation::execute($session,'checkoutConfirm');
}

#-------------------------------------------------------------------

=head2 www_checkoutConfirm ( $session )

Show the user the contents of their shopping cart and a button to pay for the contents.  Form
controls are provided to delete items from the cart, change quantities on items, and to
change payment and shipping plugins.  All information is placed in variables and styled
using the C<commerceConfirmCheckoutTemplateId> template.

If no plugins have been chosen yet, then they are redirected back to www_checkout.

If the user continues, the next sub called is www_checkoutSubmit.

=cut

sub www_checkoutConfirm {
	my $session = shift;
	my ($plugin, $f, %var, $errors, $i18n, $shoppingCart, $normal, $recurring, $shipping, $total);
	$errors = shift;
	
	$i18n = WebGUI::International->new($session, 'Commerce');
	
	# If the user isn't logged in yet, let him do so or have him create an account
	if ($session->user->userId == 1) {
		$session->scratch->set('redirectAfterLogin', $session->url->page('op=checkout'));
		return WebGUI::Operation::execute($session,'auth');
	}
	
	# If no payment gateway has been selected yet, have the user do so now.
	return WebGUI::Operation::execute($session,'checkout') unless (_paymentSelected($session) && _shippingSelected($session));

	$var{errorLoop} = [ map {{message => $_}} @{$errors} ] if $errors;

	# Put contents of cart in template vars
	$shoppingCart = WebGUI::Commerce::ShoppingCart->new($session);
	($normal, $recurring) = $shoppingCart->getItems;

	foreach (@$normal) {
		$_->{deleteIcon} = $session->icon->delete('op=deleteCartItem;itemId='.$_->{item}->id.';itemType='.$_->{item}->type);
		$_->{'quantity.form'} = WebGUI::Form::integer($session,{
			name	=> 'quantity~'.$_->{item}->type.'~'.$_->{item}->id,
			value	=> $_->{quantity},
			size	=> 3,
		});
		$total += $_->{totalPrice};
	}
	foreach (@$recurring) {
		$_->{deleteIcon} = $session->icon->delete('op=deleteCartItem;itemId='.$_->{item}->id.';itemType='.$_->{item}->type);
		$_->{'quantity.form'} = WebGUI::Form::integer($session,{
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

	$shipping = WebGUI::Commerce::Shipping->load($session, $session->scratch->get('shippingMethod'));
	$shipping->setOptions(Storable::thaw($session->scratch->get('shippingOptions'))) if ($session->scratch->get('shippingOptions'));

	$var{shippingName} = $shipping->name;
	$var{shippingCost} = sprintf('%.2f', $shipping->calc);

	$var{total} = sprintf('%.2f', $total + $shipping->calc);
	
	$plugin = WebGUI::Commerce::Payment->load($session, $session->scratch->get('paymentGateway'));

	$f = WebGUI::HTMLForm->new($session);
	$f->hidden(
		-name => 'op', 
		-value => 'checkoutSubmit'
		);
	$f->raw($plugin->checkoutForm);
	$f->submit(value=>$i18n->get('pay button'));
	
	$var{form} = $f->print;
	$var{title} = $i18n->get('checkout confirm title');
	
	$var{'changePayment.url'} = $session->url->page('op=selectPaymentGateway');
	$var{'changePayment.label'} = $i18n->get('change payment gateway');
	$var{'changeShipping.url'} = $session->url->page('op=selectShippingMethod');
	$var{'changeShipping.label'} = $i18n->get('change shipping method');
	$var{'viewShoppingCart.url'} = $session->url->page('op=viewCart');
	$var{'viewShoppingCart.label'} = $i18n->get('view shopping cart');

	return $session->style->userStyle(WebGUI::Asset::Template->new($session,$session->setting->get("commerceConfirmCheckoutTemplateId"))->process(\%var));
}

#-------------------------------------------------------------------

=head2 www_checkoutSubmit ( $session )

This is the real, final checkout routine.  Requires that the user be logged in and have
valid Shipping and Payment plugins set.

Processes all transactions using the appropriate method for each one, and then return
any templated errors via C<commerceTransactionErrorTemplateId>.

If everything is okay, clears all scratch variables and returns the user to the
C<viewPurchaseHistory> operation.

=cut

sub www_checkoutSubmit {
	my $session = shift;
	my ($plugin, $shoppingCart, $transaction, $var, $amount, @cartItems, $i18n, @transactions, 
		@normal, $currentPurchase, $checkoutError, @resultLoop, %param, $normal, $recurring, 
		$formError, $shipping, $shippingCost, $shippingDescription);
	
	$i18n = WebGUI::International->new($session, 'Commerce');

	# check if user has already logged in
	if ($session->user->userId == 1) {
		$session->scratch->set('redirectAfterLogin', $session->url->page('op=checkout'));
		return WebGUI::Operation::execute($session,'displayLogin');
	}

	# Check if a valid payment gateway has been selected. If not have the user do so.
	return WebGUI::Operation::execute($session,'checkout') unless (_paymentSelected($session) && _shippingSelected($session));

	# Load shipping plugin.
	$shipping = WebGUI::Commerce::Shipping->load($session, $session->scratch->get('shippingMethod'));
	$shipping->setOptions(Storable::thaw($session->scratch->get('shippingOptions'))) if ($session->scratch->get('shippingOptions'));
	
	# Load payment plugin.
	$plugin = WebGUI::Commerce::Payment->load($session, $session->scratch->get('paymentGateway'));
	$shoppingCart = WebGUI::Commerce::ShoppingCart->new($session);
	($normal, $recurring) = $shoppingCart->getItems;

	# Check if shoppingcart contains any items. If not the user probably clicked reload, so we redirect to the current page.
	unless (@$normal || @$recurring) {
		$session->http->setRedirect($session->url->page);
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
		$transaction = WebGUI::Commerce::Transaction->new($session, 'new');
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

	_clearCheckoutScratch($session);
	
	# If everythings ok show the purchase history
	return WebGUI::Operation::execute($session,'viewPurchaseHistory') unless ($checkoutError);

	# If an error has occurred show the template errorlog
	return $session->style->userStyle(WebGUI::Asset::Template->new($session,$session->setting->get("commerceTransactionErrorTemplateId"))->process(\%param));
}

#-------------------------------------------------------------------

=head2 www_completePendingTransaction ( $session )

You must be in group Admin (3) to execute the subroutine.  Completes
the transaction specified in the form variable C<tid> by calling
WebGUI::Commerce::Transaction->completeTransaction.  Returns the user
to the C<listPendingTransactions> operation.

=cut

sub www_completePendingTransaction {
	my $session = shift;
	return $session->privilege->adminOnly() unless ($session->user->isInGroup(3));

	WebGUI::Commerce::Transaction->new($session, $session->form->process("tid"))->completeTransaction;

	return WebGUI::Operation::execute($session,'listPendingTransactions');
}

#-------------------------------------------------------------------

=head2 www_confirmRecurringTransaction ( $session )

Using the Payment plugin from the C<gateway> form variable and attempts to complete a
recurring transaction, but only if the plugin is valid.

=cut

sub www_confirmRecurringTransaction {
	my $session = shift;
	my($plugin, %var);
	
	$plugin = WebGUI::Commerce::Payment->load($session, $session->form->process("gateway"));
	if ($plugin) {
		$plugin->confirmRecurringTransaction;
	}
}

#-------------------------------------------------------------------

=head2 www_confirmTransaction ( $session )

Using the Payment plugin from the C<pg> form variable and attempts to complete the
transaction, but only if the plugin's C<confirmTransaction> returns true.

=cut

sub www_confirmTransaction {
	my $session = shift;
	my($plugin, %var);
	$plugin = WebGUI::Commerce::Payment->load($session, $session->form->process("pg"));

	if ($plugin->confirmTransaction) {
		WebGUI::Commerce::Transaction->new($session, $plugin->getTransactionId)->completeTransaction;
	}
}

#-------------------------------------------------------------------

=head2 www_deleteCartItem ( $session )

Delete an item, C<itemId>, from the user's cart.  Returns the user to
the C<viewCart> operation.

=cut

sub www_deleteCartItem {
	my $session = shift;
	WebGUI::Commerce::ShoppingCart->new($session)->delete($session->form->process("itemId"), $session->form->process("itemType"));

	return WebGUI::Operation::execute($session,'viewCart');
}

#-------------------------------------------------------------------

=head2 www_editCommerceSettings ( $session )

Only users in group Admin (3) can execute the subroutine.

Site wide setting for commerce, including payment plugins, shipping plugins
and templates.

Calls C<www_editCommerceSettingsSave> on form submission.

=cut

sub www_editCommerceSettings {
	my $session = shift;
	my (%tabs, $tabform, $currentPlugin, $ac, $jscript, $i18n, 
		$paymentPlugin, @paymentPlugins, %paymentPlugins, @failedPaymentPlugins, $plugin,
		$shippingPlugin, @shippingPlugins, %shippingPlugins, @failedShippingPlugins);
	return $session->privilege->adminOnly() unless ($session->user->isInGroup(3));
	
	$i18n = WebGUI::International->new($session, 'Commerce');
	
	tie %tabs, 'Tie::IxHash';
 	%tabs = (
       		general=>{label=>$i18n->get('general tab')},
		payment=>{label=>$i18n->get('payment tab')},
		shipping=>{label=>$i18n->get('shipping tab')},
        );

	$paymentPlugin = $session->config->get("paymentPlugins")->[0];
	$shippingPlugin = $session->config->get("shippingPlugins")->[0];
	
	$tabform = WebGUI::TabForm->new($session,\%tabs);
	$tabform->hidden({name => 'op', value => 'editCommerceSettingsSave'});
	
	# general
	$tabform->getTab('general')->template(
		-name		=> 'commerceConfirmCheckoutTemplateId',
		-label		=> $i18n->get('confirm checkout template'),
		-hoverHelp	=> $i18n->get('confirm checkout template description'),
		-value		=> $session->setting->get("commerceConfirmCheckoutTemplateId"),
		-namespace	=> 'Commerce/ConfirmCheckout'
		);
	$tabform->getTab('general')->template(
		-name		=> 'commerceTransactionErrorTemplateId',
		-label		=> $i18n->get('transaction error template'),
		-hoverHelp	=> $i18n->get('transaction error template description'),
		-value		=> $session->setting->get('commerceTransactionPendingTemplateId'),
		-namespace	=> 'Commerce/TransactionError'
		);
	$tabform->getTab('general')->template(
		-name		=> 'commerceCheckoutCanceledTemplateId',
		-label		=> $i18n->get('checkout canceled template'),
		-hoverHelp	=> $i18n->get('checkout canceled template description'),
		-value		=> $session->setting->get("commerceCheckoutCanceledTemplateId"),
		-namespace	=> 'Commerce/CheckoutCanceled'
		);
	$tabform->getTab('general')->template(
		-name		=> 'commerceSelectPaymentGatewayTemplateId',
		-label		=> $i18n->get('checkout select payment template'),
		-hoverHelp	=> $i18n->get('checkout select payment template description'),
		-value		=> $session->setting->get("commerceSelectPaymentGatewayTemplateId"),
		-namespace	=> 'Commerce/SelectPaymentGateway'
		);
	$tabform->getTab('general')->template(
		-name		=> 'commerceSelectShippingMethodTemplateId',
		-label		=> $i18n->get('checkout select shipping template'),
		-hoverHelp	=> $i18n->get('checkout select shipping template description'),
		-value		=> $session->setting->get("commerceSelectShippingMethodTemplateId"),
		-namespace	=> 'Commerce/SelectShippingMethod'
		);
	$tabform->getTab('general')->template(
		-name		=> 'commerceViewShoppingCartTemplateId',
		-label		=> $i18n->get('view shopping cart template'),
		-hoverHelp	=> $i18n->get('view shopping cart template description'),
		-value		=> $session->setting->get("commerceViewShoppingCartTemplateId"),
		-namespace	=> 'Commerce/ViewShoppingCart'
		);

	$tabform->getTab('general')->email(
		-name		=> 'commerceSendDailyReportTo',
		-label		=> $i18n->get('daily report email'),
		-hoverHelp	=> $i18n->get('daily report email description'),
		-value		=> $session->setting->get("commerceSendDailyReportTo")
		);

	# Check which payment plugins will compile, and load them.
	foreach (@{$session->config->get("paymentPlugins")}) {
		$plugin = WebGUI::Commerce::Payment->load($session, $_);
		if ($plugin) {
			push(@paymentPlugins, $plugin);
			$paymentPlugins{$_} = $plugin->name;
		} else {
			push(@failedPaymentPlugins, $_);
		}
	}
		
	# payment plugin
	if (%paymentPlugins) {
		$session->style->setRawHeadTags('<script type="text/javascript">var activePayment="'.$paymentPlugin.'";</script>');
		$tabform->getTab("payment")->selectBox(
			-name		=> 'commercePaymentPlugin',
			-options	=> \%paymentPlugins,
			-label		=> $i18n->get('payment plugin'),
			-hoverHelp	=> $i18n->get('payment plugin description'),
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
	foreach (@{$session->config->get("shippingPlugins")}) {
		$plugin = WebGUI::Commerce::Shipping->load($session, $_);
		if ($plugin) {
			push(@shippingPlugins, $plugin);
			$shippingPlugins{$_} = $plugin->name;
		} else {
			push(@failedShippingPlugins, $_);
		}
	}
	
	# shipping plugin
	if (%shippingPlugins) {
		$session->style->setRawHeadTags('<script type="text/javascript">var activeShipping="'.$shippingPlugin.'";</script>');
		$tabform->getTab('shipping')->selectBox(
			-name	=> 'commerceShippingPlugin',
			-options=> \%shippingPlugins,
			-label	=> $i18n->get('shipping plugin label'),
			-hoverHelp	=> $i18n->get('shipping plugin label description'),
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

	$session->style->setScript($session->config->get("extrasURL").'/swapLayers.js',{type=>"text/javascript"});
	
	return _submenu($session,$tabform->print, 'edit commerce settings title', 'commerce manage');
}

#-------------------------------------------------------------------

=head2 www_editCommerceSettingsSave ( $session )

Only users in group Admin (3) can execute the subroutine.

Form post processor for C<www_editCommerceSettings>.  Plugin
configuration data is stored in a special table for security and all
other settings in the WebGUI settings table for easy access.

Returns the user to C<www_editCommerceSettings>.

=cut

sub www_editCommerceSettingsSave {
	my $session = shift;
	return $session->privilege->adminOnly() unless ($session->user->isInGroup(3));
	
	foreach ($session->form->param) {
		# Store the plugin configuration data in a special table for security and the general settings in the
		# normal settings table for easy access.
		if (/~([^~]*)~([^~]*)~([^~]*)/) {
			WebGUI::Commerce::setCommerceSetting($session,{
				type		=> $1,
				namespace	=> $2,
				fieldName	=> $3, 
				fieldValue	=> $session->form->process($_)
			});
		} elsif ($_ ne 'op') {
			$session->setting->set($_,$session->form->process($_));
		}
	}
	
	return WebGUI::Operation::execute($session,'editCommerceSettings');
}

#-------------------------------------------------------------------

=head2 www_listPendingTransactions ( $session )

Only users in group Admin (3) can execute the subroutine.

Show a paginated list of all transactions with status, Pending.  Provide
links so the Admin can complete any pending transaction.

=cut

sub www_listPendingTransactions {
	my $session = shift;
	my ($p, $transactions, $output, $properties, $i18n);
	return $session->privilege->adminOnly() unless ($session->user->isInGroup(3));
	
	$i18n = WebGUI::International->new($session, "Commerce");

	$p = WebGUI::Paginator->new($session,$session->url->page('op=listPendingTransactions'));
	$p->setDataByArrayRef(WebGUI::Commerce::Transaction->pendingTransactions($session));
	
	$transactions = $p->getPageData;

	$output = $p->getBarTraditional($session->form->process("pn"));
	$output .= '<table border="1" cellpadding="5" cellspacing="0" align="center">';
	$output .= '<tr><th>'.$i18n->get('transactionId').'</th><th>'.$i18n->get('gateway').'</th>'.
		'<th>'.$i18n->get('gatewayId').'</th><th>'.$i18n->get('init date').'</th></tr>';
	foreach (@{$transactions}) {
		$properties = $_->get;
		$output .= '<tr>';
		$output .= '<td>'.$properties->{transactionId}.'</td>';
		$output .= '<td>'.$properties->{gatewayId}.'</td>';
		$output .= '<td>'.$properties->{gateway}.'</td>';
		$output .= '<td>'.$session->datetime->epochToHuman($properties->{initDate}).'</td>';
		$output .= '<td><a href="'.$session->url->page('op=completePendingTransaction;tid='.$properties->{transactionId}).'">'.$i18n->get('complete pending transaction').'</a></td>';
		$output .= '</tr>';
	}
	$output .= '</table>';
	$output .= $p->getBarTraditional($session->form->process("pn"));

	_submenu($session,$output, 'list pending transactions', 'list pending transactions');
}

#-------------------------------------------------------------------

=head2 www_listTransactions ( $session )

Show all transactions in the system and allow them to be managed.

You must be in group Admin (3) in order to access this screen.

The screen is not templated.

=cut

sub www_listTransactions {
	my $session = shift;
	my ($output, %criteria, $transaction, @transactions);

	return $session->privilege->insufficient unless ($session->user->isInGroup(3));

	my $i18n = WebGUI::International->new($session, 'TransactionLog');

	my $transactionOptions = {
		''		=> $i18n->get('any'),
		'Pending'	=> $i18n->get('pending'),
		'Completed'	=> $i18n->get('completed'),
	};

	my $shippingOptions = {
		''		=> $i18n->get('any'),
		'Shipped'	=> $i18n->get('shipped'),
		'NotShipped'	=> $i18n->get('not shipped'),
		'Delivered'	=> $i18n->get('delivered'),
	};
	
	my $initStart = $session->form->date('initStart');
	my $initStop  = $session->datetime->addToTime($session->form->date('initStop'),23,59);
	my $completionStart = $session->form->date('completionStart');
	my $completionStop  = $session->datetime->addToTime($session->form->date('completionStop'),23,59);

	$output .= $i18n->get('selection message');
	
	$output .= WebGUI::Form::formHeader($session);
	$output .= WebGUI::Form::hidden($session,{name=>'op', value=>'listTransactions'});
	$output .= '<table>';
	$output .= '<td>'.WebGUI::Form::radio($session,{name=>'selection', value => 'init', checked=>($session->form->process("selection") eq 'init')}).'</td>';
	$output .= '<td align="left">'.$i18n->get('init date').'</td>';
	$output .= '<td>'.WebGUI::Form::date($session,{name=>'initStart', value=>$initStart}).' '.$i18n->get('and').' '.WebGUI::Form::date($session,{name=>'initStop', value=>$initStop}).'</td>';
	$output .= '</tr><tr>';
	$output .= '<td>'.WebGUI::Form::radio($session,{name=>'selection', value => 'completion', checked=>($session->form->process("selection") eq 'completion')}).'</td>';
	$output .= '<td align="left">'.$i18n->get('completion date').'</td>';
	$output .= '<td>'.WebGUI::Form::date($session,{name=>'completionStart', value=>$completionStart}).' '.$i18n->get('and').' '.WebGUI::Form::date($session,{name=>'completionStop', value=>$completionStop}).'</td>';
	$output .= '</tr><tr>';
	$output .= '<td></td>';
	$output .= '<td align="left">'.$i18n->get('transaction status').'</td>';
	$output .= '<td>'.WebGUI::Form::selectBox($session,{name => 'tStatus', value => [$session->form->process("tStatus")], options => $transactionOptions});
	$output .= '</tr><tr>';
	
	$output .= '<td></td>';
	$output .= '<td align="left">'.$i18n->get('shipping status').'</td>';
	$output .= '<td>'.WebGUI::Form::selectBox($session,{name => 'sStatus', value => [$session->form->process("sStatus")], options => $shippingOptions});
	$output .= '</tr><tr>';

	$output .= '<td></td>';
	$output .= '<td>'.WebGUI::Form::submit($session,{value=>$i18n->get('select')}).'</td>';
	$output .= '</tr>';
	$output .= '</table>';
	$output .= WebGUI::Form::formFooter;

	$criteria{initStart} = $session->form->date('initStart') if ($session->form->process("initStart") && ($session->form->process("selection") eq 'init'));
	$criteria{initStop} = $session->form->date('initStop') if ($session->form->process("initStop") && ($session->form->process("selection") eq 'init'));
	$criteria{completionStart} = $session->form->date('completionStart') if ($session->form->process("completionStart") && ($session->form->process("selection") eq 'completion'));
	$criteria{completionStop} = $session->form->date('completionStop') if ($session->form->process("completionStop") && ($session->form->process("selection") eq 'completion'));
	$criteria{shippingStatus} = $session->form->process("sStatus") if ($session->form->process("sStatus"));
	$criteria{paymentStatus} = $session->form->process("tStatus") if ($session->form->process("tStatus"));
	
	@transactions = WebGUI::Commerce::Transaction->getTransactions(\%criteria);

	$output .= '<table border="1">';
	$output .= '<tr><th></th>'.
		'<th>'. $i18n->get('init date'). '</th>'.
		'<th>'. $i18n->get('completion date'). '</th>'.
		'<th>'. $i18n->get('amount'). '</th>'.
		'<th>'. $i18n->get('shipping cost'). '</th>'.
		'<th>'. $i18n->get('status'). '</th>'.
		'<th>'. $i18n->get('shipping status'). '</th></tr>';
	foreach $transaction (@transactions) {
		$output .= '<tr bgcolor="#ddd">';
		$output .= '<td>'.$session->icon->delete('op=deleteTransaction;tid='.$transaction->get('transactionId')).'</td>';
		$output .= '<td>'.$session->datetime->epochToHuman($transaction->get('initDate')).'</td>';
		$output .= '<td>'.$session->datetime->epochToHuman($transaction->get('completionDate')).'</td>';
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
				$session->icon->delete('op=deleteTransactionItem;tid='.$transaction->get('transactionId').';iid='.$_->{itemId}.';itype='.$_->{itemType}).
				$_->{itemName}.'</td>';
			$output .= '<td>'.$_->{quantity}.'</td>';
			$output .= '<td> x </td>';
			$output .= '<td>'.$_->{amount}.'</td>';
			$output .= '</tr>';
		}
	}
	$output .= '</table>';

	return _submenu($session,$output, 'list transactions')
}

#-------------------------------------------------------------------

=head2 www_selectPaymentGateway ( $session )

Allow the user to select a payment plugin.  Uses the C<commerceSelectPaymentGatewayTemplateId>
template.  After form submission, calls www_selectPaymentGatewaySave

=cut

sub www_selectPaymentGateway {
	my $session = shift;
	my ($plugins, $f, $i18n, @pluginLoop, %var);

	_clearPaymentScratch($session);
	
	$i18n = WebGUI::International->new($session, 'Commerce');
	$plugins = WebGUI::Commerce::Payment->getEnabledPlugins($session);
	if (scalar(@$plugins) > 1) {
		foreach (@$plugins) {
			push(@pluginLoop, {
				name		=> $_->name,
				namespace	=> $_->namespace,
				formElement	=> WebGUI::Form::radio($session,{name=>'paymentGateway', value=>$_->namespace})
				});
		}
	} elsif (scalar(@$plugins) == 1) {
		#$session->form->process("paymentGateway") = $plugins->[0]->namespace;
		$session->stow->set("paymentGateway", $plugins->[0]->namespace);
		return WebGUI::Operation::execute($session,'selectPaymentGatewaySave');
	}
	
	$var{pluginLoop} = \@pluginLoop;
	$var{message} = $i18n->get('select payment gateway');
	$var{pluginsAvailable} = @$plugins;
	$var{noPluginsMessage} = $i18n->get('no payment gateway');
	$var{formHeader} = WebGUI::Form::formHeader.WebGUI::Form::hidden($session,{name=>'op', value=>'selectPaymentGatewaySave'});
	$var{formSubmit} = WebGUI::Form::submit($session,{value=>$i18n->get('payment gateway select')});
	$var{formFooter} = WebGUI::Form::formFooter;		
	
	return $session->style->userStyle(WebGUI::Asset::Template->new($session,$session->setting->get("commerceSelectPaymentGatewayTemplateId"))->process(\%var));
}

#-------------------------------------------------------------------

=head2 www_selectPaymentGatewaySave ( $session )

Form processor for www_selectPaymentGateway.  If the user selected payment plugin can
be loaded and enabled, sets the scratch variable C<paymentGateway> so that it can
be used.  Otherwise the value of the scratch variable is cleared.

Returns the user to the operation C<checkout> when it is done.

=cut

sub www_selectPaymentGatewaySave {
	my $session = shift;
	# shifting stow first because it's only set when one payment gateway is defined
	my $paymentGateway = $session->stow->get("paymentGateway") || $session->form->process("paymentGateway");
	if (WebGUI::Commerce::Payment->load($session, $paymentGateway)->enabled) {
		$session->scratch->set('paymentGateway', $paymentGateway);
	} else {
		$session->scratch->set('paymentGateway', '-delete-');
	}

	return WebGUI::Operation::execute($session,'checkout');
}

#-------------------------------------------------------------------

=head2 www_selectShippingMethod ( $session )

Allow the user to select a payment plugin.  Uses the C<commerceSelectShippingMethodTemplateId>
template.  After form submission, calls www_selectPaymentGatewaySave

=cut

sub www_selectShippingMethod {
	my $session = shift;
	my ($plugins, $f, $i18n, @pluginLoop, %var);

	_clearShippingScratch($session);
	
	$i18n = WebGUI::International->new($session, 'Commerce');
	$plugins = WebGUI::Commerce::Shipping->getEnabledPlugins($session);
	
	if (scalar(@$plugins) > 1) {
		foreach (@$plugins) {
			push(@pluginLoop, {
				name		=> $_->name,
				namespace	=> $_->namespace,
				formElement	=> WebGUI::Form::radio($session,{name=>'shippingMethod', value=>$_->namespace})
				});
		}
	} elsif (scalar(@$plugins) == 1) {
		#$session->form->process("shippingMethod") = $plugins->[0]->namespace;
		$session->stow->set('shippingMethod', $plugins->[0]->namespace);
		return WebGUI::Operation::execute($session,"selectShippingMethodSave");
	}
	
	$var{pluginLoop} = \@pluginLoop;
	$var{message} = $i18n->get('select shipping method');
	$var{pluginsAvailable} = @$plugins;
	$var{noPluginsMessage} = $i18n->get('no shipping methods available');
	$var{formHeader} = WebGUI::Form::formHeader($session).WebGUI::Form::hidden($session,{name=>'op', value=>'selectShippingMethodSave'});
	$var{formSubmit} = WebGUI::Form::submit($session,{value=>$i18n->get('shipping select button')});
	$var{formFooter} = WebGUI::Form::formFooter($session);		
	
	return $session->style->userStyle(WebGUI::Asset::Template->new($session,$session->setting->get("commerceSelectShippingMethodTemplateId"))->process(\%var));
}

#-------------------------------------------------------------------

=head2 www_selectShippingMethodSave ( $session )

Form processor for www_selectShippingMethod.  If the shipping method
plugin can be loaded and the C<optionsOk> method returns false, then
takes the user back to the C<selectShipping> operation (probably
www_selectShippingMethod).

If the plugin is enabled, then set scratch variables to be used downstream.

Returns the user to the operation C<checkout> when it is done.

=cut

sub www_selectShippingMethodSave {
	my $session = shift;
	# Shifting stow first b/c it's only set when one shipping plug-in exists
	my $shippingMethod = $session->stow->get('shippingMethod') || $session->form->process("shippingMethod");
	my $shipping = WebGUI::Commerce::Shipping->load($session, $shippingMethod);
	
	$shipping->processOptionsForm;
	return WebGUI::Operation::execute($session,'selectShipping') unless ($shipping->optionsOk);
	
	if ($shipping->enabled) {
		$session->scratch->set('shippingMethod', $shipping->namespace);
		$session->scratch->set('shippingOptions', Storable::freeze($shipping->getOptions));
	} else {
		$session->scratch->set('shippingMethod', '-delete-');
	}

	return WebGUI::Operation::execute($session,'checkout');
}

#-------------------------------------------------------------------

=head2 www_transactionComplete ( $session )

This is wrapper for the C<viewPurchaseHistory> operation, probably
WebGUI::Operation::TransactionLog::www_viewPurchaseHistory.

=cut

sub www_transactionComplete {
	my $session = shift;
	return WebGUI::Operation::execute($session,'viewPurchaseHistory');	
}

#-------------------------------------------------------------------

=head2 www_updateCart ( $session )

Update the shopping cart with new quantities for items.  Returns the user
to the C<viewCart> operation, probably www_viewCart.

=cut

sub www_updateCart {
	my $session = shift;
my	$shoppingCart = WebGUI::Commerce::ShoppingCart->new($session);

	foreach my $formElement ($session->form->param) {
		if ($formElement =~ m/^quantity~([^~]*)~([^~]*)$/) {
			$shoppingCart->setQuantity($2, $1, $session->form->process($formElement));
		}
	}

	return WebGUI::Operation::execute($session,'viewCart');
}

#-------------------------------------------------------------------

=head2 www_viewCart ( $session )

Display the user's shopping cart to the user using the C<commerceViewShoppingCartTemplateId>
template, and allow them to delete items or change the quantity of regular items.

Will call the C<updateCart> operation, the C<checkout> operation or C<deleteCartItem>
based on user input.

=cut

sub www_viewCart {
	my $session = shift;
	my ($shoppingCart, $normal, $recurring, %var, $total, $i18n);

	$i18n = WebGUI::International->new($session, 'Commerce');
	
	# Put contents of cart in template vars
	$shoppingCart = WebGUI::Commerce::ShoppingCart->new($session);
	($normal, $recurring) = $shoppingCart->getItems;

	foreach (@$normal) {
		$_->{deleteIcon} = $session->icon->delete('op=deleteCartItem;itemId='.$_->{item}->id.';itemType='.$_->{item}->type);
		$_->{'quantity.form'} = WebGUI::Form::integer($session,{
			name	=> 'quantity~'.$_->{item}->type.'~'.$_->{item}->id,
			value	=> $_->{quantity},
			size	=> 3,
		});
		$total += $_->{totalPrice};
	}
	foreach (@$recurring) {
		$_->{deleteIcon} = $session->icon->delete('op=deleteCartItem;itemId='.$_->{item}->id.';itemType='.$_->{item}->type);
		$_->{'quantity.form'} = WebGUI::Form::integer($session,{
			name	=> 'quantity~'.$_->{item}->type.'~'.$_->{item}->id,
			value	=> $_->{quantity},
			size	=> 3,
		});
		$total += $_->{totalPrice};
	}

	$var{'cartEmpty'} = !(scalar(@$normal) || scalar(@$recurring));
	$var{'cartEmpty.message'} = $i18n->get('shopping cart empty');
	
	$var{'updateForm.header'} = WebGUI::Form::formHeader($session,).
		WebGUI::Form::hidden($session,{name => 'op', value => 'updateCart'});
	$var{'updateForm.button'} = WebGUI::Form::submit($session,{value => $i18n->get('update cart')});
	$var{'updateForm.footer'} = WebGUI::Form::formFooter;
	$var{'checkoutForm.header'} = WebGUI::Form::formHeader($session,).
		WebGUI::Form::hidden($session,{name => 'op', value => 'checkout'});
	$var{'checkoutForm.button'} = WebGUI::Form::submit($session,{value => $i18n->get('checkout')});
	$var{'checkoutForm.footer'} = WebGUI::Form::formFooter;
	
	$var{normalItemsLoop} = $normal;
	$var{normalItems} = scalar(@$normal);
	$var{recurringItemsLoop} = $recurring;
	$var{recurringItems} = scalar(@$recurring);
	
	$var{total} = sprintf('%.2f', $total);

	return $session->style->userStyle(WebGUI::Asset::Template->new($session,$session->setting->get("commerceViewShoppingCartTemplateId"))->process(\%var));
}

1;

