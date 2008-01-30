package WebGUI::Commerce::Payment;

=head1 LEGAL

 -------------------------------------------------------------------
  WebGUI is Copyright 2001-2007 Plain Black Corporation.
 -------------------------------------------------------------------
  Please read the legal notices (docs/legal.txt) and the license
  (docs/license.txt) that came with this distribution before using
  this software.
 -------------------------------------------------------------------
  http://www.plainblack.com                     info@plainblack.com
 -------------------------------------------------------------------

=cut

use strict;
use WebGUI::SQL;
use WebGUI::International;
use Tie::IxHash;
use WebGUI::HTMLForm;

=head1 NAME

Package WebGUI::Commerce::Payment

=head1 DESCRIPTION

An abstract class for all payment plugins to extend.

=head1 SYNOPSIS

 use WebGUI::CommercePayment;
 our @ISA = qw(WebGUI::Commerce::Payment);

Invoking goes as follows:

 $plugin = WebGUI::Commerce::Payment->init($session,'MyPlugin');

=head1 METHODS

These methods are available from this class:

=cut


#-------------------------------------------------------------------

=head2 cancelRecurringPayment ( data )

This method takes care of canceling a recurring transaction. You must override this
method if your plugin can handle recurring payments.

=head3 data

A hashref containing:

	id		=> the gateway ID of the transaction,
	transaction	=> the instantiated WebGUI::Commerce::Transaction object

=cut	

sub cancelRecurringPayment {
	return "";
}

#-------------------------------------------------------------------

=head2 checkoutForm ( )

This must return a printRowsOnly'ed WebGUI::HTMLForm containing the fields for the checkout
dat you want to collect. Do not include submit buttons. You probably want to override this 
method.

=cut

sub checkoutForm {
	return "";
}

#-------------------------------------------------------------------

=head2 configurationForm ( )

This generates the configuration form that's displayed in the admin console. You must 
extend this method to include parameters specific to this payment module. To do so return
the SUPER::configurationForm method with a printRowsOnly'ed WebGUI::HTMLForm as the argument.

Also be sure to prepend all formfield names with the prepend method. See propend for more info.

=cut

sub configurationForm {
	my ($self, $form, $f);
	$self = shift;
	$form = shift;

	$f = WebGUI::HTMLForm->new($self->session);
	my $i18n = WebGUI::International->new($self->session, 'Commerce');
	$f->text(
        -name   => $self->prepend('label'),
        -value  => $self->label,
        -label  => $i18n->get('label'),
        -hoverHelp => $i18n->get('label hoverhelp'),
    );
    $f->yesNo(
		-name	=> $self->prepend('enabled'),
		-value	=> $self->enabled,
		-label	=> $i18n->get('enable'),
		);
	$f->group(
		-name	=> $self->prepend('whoCanUse'),
		-value 	=> [$self->get('whoCanUse')],
		-label 	=> 'Who Can Use?',
		-hoverHelp => 'Members belonging to this group will see this payment gateway as a choice at the payment gateway selection screen during checkout.'
		);

	$f->raw($form);

	return $f->printRowsOnly;
}

#-------------------------------------------------------------------

=head2 confirmRecurringTransaction ( )

This method is called if your gateway signals you (ie. posts data to some URL) to confirm a 
recurring payment term has been processed. If this is the case, you probably want to store 
the result in some table so it can be processed by the Schedualer plugin through the 
getRecurringPaymentStatus method. 

You only need to override this method if your gateway uses a webbased contacting scheme.

=cut

sub confirmRecurringTransaction {
	return undef;
}

#-------------------------------------------------------------------

=head2 confirmTransaction ( )

This method is called when your gateway contacts a specific URL to notify you of the result of a
transaction. You should override this method only if your gateway uses this kind of notification 
(ie. like PayPal APN). Returns a boolean indicating whether the transaction was successful or not.

=cut

sub confirmTransaction {
	return 0;
}

#-------------------------------------------------------------------

=head2 connectionError ( )

Returns an error message if there was a connection error. You must override this method.

=cut

sub connectionError {
	return "The connetionError method must be overridden.";
}

#-------------------------------------------------------------------

=head2 enabled ( )

Returns a boolean indicating whether the plugin is enabled or not.

=cut

sub enabled {
	return $_[0]->{_enabled};
}

#-------------------------------------------------------------------

=head2 get ( property )

Returns property of the plugin.

=head3 property

The name of the property you want.

=cut

sub get {
	return $_[0]->{_properties}{$_[1]};
}

#-------------------------------------------------------------------

=head2 getEnabledPlugins ( )

Returns a reference to an array of all enabled instantiated payment plugins.

=cut

sub getEnabledPlugins {
	#my ($session) = @_;
	my $class = shift;
	my $session = shift;
	my (@enabledPlugins, $plugin, @plugins);
	@enabledPlugins = $session->db->buildArray("select namespace from commerceSettings where type='Payment' and fieldName='enabled' and fieldValue='1'");

	foreach (@enabledPlugins) {
		$plugin = WebGUI::Commerce::Payment->load($session, $_);
		push(@plugins, $plugin) if ($plugin);
	}

	return \@plugins;
}
	
#-------------------------------------------------------------------

=head2 init ( session, namespace )

Constructor for the plugin. You should extend this method.

=head3 session

A copy of the session object

=head3 namespace

The namespace of the plugin.

=cut

sub init {
	my ($class, $session, $namespace, $properties);
	$class = shift;
	$session = shift;
	$namespace = shift;
	
	$properties = $session->db->buildHashRef("select fieldName, fieldValue from commerceSettings where namespace=".$session->db->quote($namespace)." and type='Payment'");

	bless {_session=>$session, _properties=>$properties, _namespace=>$namespace, _enabled=>$properties->{enabled}}, $class;
}

#-------------------------------------------------------------------

=head2 gatewayId ( )

Returns the gatewayId of the transaction. You must override this method.

=cut

sub gatewayId {
	my ($self) = @_;
	return $self->session->errorHandler->fatal("You must override the gatewayId method in your Payment plugin.");
}

#-------------------------------------------------------------------

=head2 getRecurringPaymentStatus ( recurringId, term )

This should return a hashref containing the payment status of the specified term. If
the term has not been processed yet this method should return undef. Override only if 
your plugin is capable of recurring transactions.

The hashref should contain:

	resultCode	=> the result of the payment

=head3 recurringId

The ID the gateway has assigned to the recurring transaction.

=head3 term

The term number you want the status of.

=cut

sub getRecurringPaymentStatus {
	return undef;
}

#-------------------------------------------------------------------

=head2 errorCode ( )

Returns the error code of the last submission.

=cut

sub errorCode {
	my ($self) = @_;
	return $self->session->errorHandler->fatal("You must override thie errorCode method in the payment plugin.");
}

#-------------------------------------------------------------------

=head2 label ( )

Returns the label for the commerce plugin.

=cut

sub label {
    my $self = shift;
	return $self->get("label") || $self->namespace;
}

#-------------------------------------------------------------------

=head2 load ( namespace )

A convienient method to load a plugin. It handles all error checking and stuff for you.
This is a SUPER class method only and shoud NOT be overridden.

=head3 session

The session variable.

=head3 namespace

The namespace of the plugin.

=cut

sub load {
	my ($class, $namespace, $load, $cmd, $plugin);
    	$class = shift;
    	my $session = shift;
	$namespace = shift;
	
    	$cmd = "WebGUI::Commerce::Payment::$namespace";
	$load = "use $cmd";
	eval($load);
	$session->errorHandler->warn("Payment plugin failed to compile: $cmd.".$@) if($@);
	$plugin = eval($cmd.'->init($session)');
	
	$session->errorHandler->warn("Couldn't instantiate payment plugin: $cmd.".$@) if($@);
	return $plugin;
}

#-------------------------------------------------------------------

=head2 name

Returns the (display) name of the plugin. You must override this method.

=cut

sub name {
	my ($session) = @_;
	return $session->errorHandler->fatal("You must override the name method in the payment plugin.");
}

#-------------------------------------------------------------------

=head2 namespace ( )

Returns the namespace of the plugin.

=cut

sub namespace {
	return $_[0]->{_namespace};
}

#-------------------------------------------------------------------

=head2 normalTransaction ( transactionData )

This method submits a normal (non-recurring) transaction to the payment gateway. You probably
should override this method.

=head3 transactionData

A hashref containing:

	amount		=> the total amount of the transaction
	description	=> the transaction description
	invoiceNumber	=> the invoice number of the transaction
	id		=> the webgui transaction ID

=cut

sub normalTransaction {
	return undef;
}

#-------------------------------------------------------------------

=head2 recurringTransaction ( transactionData )

This method submits a recurring transaction to the payment gateway. You must override
this method if your plugin supports recurring payments.

=head3 transactionData

A hashref containing:

	amount		=> the total amount of the transaction,
	term		=> the number of terms of the subscription should last.
			   If none is given your plugin should use an infinite number of terms,
	payPeriod	=> the billing interval,
	description	=> the transaction description,
	invoiceNumber	=> the invoice number of the transaction,
	id		=> the webgui transaction ID,

=cut

sub recurringTransaction {
	return undef;
}

#-------------------------------------------------------------------

=head2 resultCode ( )

Returns the result code of the transaction. You must override this method.

=cut

sub resultCode {
	my ($self) = @_;
	return $self->session->errorHandler->fatal("You must override the resultCode method in the payment plugin.");
}

#-------------------------------------------------------------------

=head2 resultMessage ( )

Returns the result message of the transaction. You must override this method.

=cut

sub resultMessage {
	my ($self) = @_;
	return $self->session->errorHandler->fatal("You must override the resultMessage method in the payment plugin.");
}

#-------------------------------------------------------------------

=head2 prepend ( fieldName )

A utility method that prepends fieldName with a string that's used to save configuration data to
the database. Use it on all fields in the configurationForm method.

For instance:

	$f = WebGUI::HTMLForm->new($self->session);
	$f->text(
		-name	=> $self->prepend('MyField');
		-label	=> 'MyField'
	);

=head3 fieldName

The string to prepend.

=cut

sub prepend {
	my ($self, $name);
	$self = shift;
	$name = shift;

	return "Payment_".$self->namespace."_".$name;
}

#-------------------------------------------------------------------

=head2 recurringPeriodValues ( period )

A utility method that returns the internationalized name for period.

=head3 period

The period you want the name for.

=cut

sub recurringPeriodValues {
	my $class = shift;
	my $session = shift;
	my ($i18n, %periods);
	$i18n = WebGUI::International->new($session, 'Commerce');
	tie %periods, "Tie::IxHash";	
	%periods = (
		Weekly		=> $i18n->get('weekly'),
		BiWeekly	=> $i18n->get('biweekly'),
		FourWeekly	=> $i18n->get('fourweekly'),
		Monthly		=> $i18n->get('monthly'),
		Quarterly	=> $i18n->get('quarterly'),
		HalfYearly	=> $i18n->get('halfyearly'),
		Yearly		=> $i18n->get('yearly'),
		);
	
	return \%periods;
}

#-------------------------------------------------------------------

=head2 session ( )

Returns the local copy of the session variable

=cut

sub session {
	my ($self) = @_;
	return $self->{_session};
}

##-------------------------------------------------------------------

=head2 shippingCost ( amount )

This sets the shippingcost involved with the transaction. Your plugin must override this
method.

=head3 amount

The amaount of money that's being charged for shipping.

=cut

sub shippingCost {
	my ($self) = @_;
	return $self->session->errorHandler->fatal("You must override the shippingCost method in the payment plugin.");
}

#-------------------------------------------------------------------

=head2 shippingDescription ( message )

This method sets the description for the shipping cost of the transaction. You must overload 
this method if you are writing a custom plugin.

=head3 message

The description of the shiping cost.

=cut

sub shippingDescription {
	my ($self) = @_;
	return $self->session->errorHandler->fatal("You must override the shippingDescription method in the payment plugin.");
}

#-------------------------------------------------------------------

=head2 supports ( )

Returns a hashref containg the types of payment the plugin supports. The hashref may contain:

	single		=> 1 if the plugin supports normal transactions,
	recurring	=> 1 if the plugin supports recurring transactions

You must override this method.

=cut

sub supports {
	my ($self) = @_;
	return $self->session->errorHandler->fatal("You must override the supports method in the payment plugin.");
}

#-------------------------------------------------------------------

=head2 transactionCompleted ( )

A boolean indicating whether the payment has been finished or not. You must override this method.

=cut

sub transactionCompleted {
	my ($self) = @_;
	return $self->session->errorHandler->fatal("You must override the transactionCompleted method in the payment plugin.");
}

#-------------------------------------------------------------------

=head2 transactionError ( )

Returns an error message if a transaction error has occurred. You must override this method.

=cut

sub transactionError {
	my ($self) = @_;
	return $self->session->errorHandler->fatal("You must override the transactionError method in the payment plugin.");
}

#-------------------------------------------------------------------

=head2 transactionPending ( )

A boolean indicating whether the payment is pending or not. You must override this method.

=cut

sub transactionPending {
	my ($self) = @_;
	return $self->session->errorHandler->fatal("You must override the transactionPending method in the payment plugin.");
}

#-------------------------------------------------------------------

=head2 validateFormData ( )

This method checks the data entered in the checkoutForm. If an error has occurred this method must 
return an arrayref containing the errormessages tied to the errors. If everything's ok it will return
undef. You must override this method.

=cut

sub validateFormData {
	my ($self) = @_;
	return $self->session->errorHandler->fatal("You must override the validateFormData method in the payment plugin.");
}

=head2 logExtraTransactionData ( $transaction )

This method puts extra, Payment plugin specific data into the transaction log.  This
needs to be be overridden to actually do the logging.

=head3 $transaction

A WebGUI::Commerce::Transaction object to do the logging.

=cut

sub logExtraTransactionData {
    return 1;
}

1;

