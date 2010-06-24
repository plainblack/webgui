package WebGUI::Shop::Pay;

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

#use Class::InsideOut qw{ :std };
use Moose;
use WebGUI::Exception;
use WebGUI::International;
use WebGUI::Pluggable;
use WebGUI::Shop::Admin;
#use WebGUI::Shop::PayDriver;
use WebGUI::Utility;
use Tie::IxHash;
use Scalar::Util;

=head1 NAME

Package WebGUI::Shop::Pay

=head1 DESCRIPTION

This is the master class to manage pay drivers.

=head1 SYNOPSIS

 use WebGUI::Shop::Pay;

=head1 METHODS

These subroutines are available from this package:

=cut

#-------------------------------------------------------------------

=head2 session () 

Returns a reference to the current session.

=cut


has session => (
    is              => 'ro',
    required        => 1,
);

around BUILDARGS => sub {
    my $orig       = shift;
    my $className  = shift;

    ##Original arguments start here.
    my $protoSession = $_[0];
    if (blessed $protoSession && $protoSession->isa('WebGUI::Session')) {
        return $className->$orig(session => $protoSession);
    }
    return $className->$orig(@_);
};

#-------------------------------------------------------------------

=head2 addPaymentGateway ( $class, $label, $options )

The interface method for creating new, configured instances of PayDriver.  If the PayDriver throws an exception,  it is propagated
back up to the top.

=head4 $class

The class of the new PayDriver object to create.

=head4 $options

A list of properties to assign to this PayDriver.  See C<definition> for details.

=cut

sub addPaymentGateway {
    my $self            = shift;
    my $requestedClass  = shift;
    my $options         = shift;
    WebGUI::Error::InvalidParam->throw(error => q{Must provide a class to create an object})
        unless defined $requestedClass;
    WebGUI::Error::InvalidParam->throw(error => q{The requested class is not enabled in your WebGUI configuration file}, param => $requestedClass)
        unless isIn($requestedClass, (keys %{$self->getDrivers}) );
    WebGUI::Error::InvalidParam->throw(error => q{You must pass a hashref of options to create a new PayDriver object})
        unless defined($options) and ref $options eq 'HASH' and scalar keys %{ $options };
    my $driver = eval { WebGUI::Pluggable::instanciate($requestedClass, 'create', [ $self->session, $options ]) };

    return $driver;
}

#-------------------------------------------------------------------

=head2 getDrivers ( )

This subroutine returns a hash reference of available shipping driver classes as keys with their human readable names as values, read from the WebGUI config file in the shippingDrivers directive.

=cut

sub getDrivers {
    my $self      = shift;
    my %drivers = ();
    CLASS: foreach my $class (@{$self->session->config->get('paymentDrivers')}) {
        my $driverName   = eval { WebGUI::Pluggable::instanciate($class, 'getName', [ $self->session ])};
        if ($@) {
            $self->session->log->warn("Error loading $class: $@");
        }
        next CLASS unless $driverName;
        $drivers{$class} = $driverName;
    }
    return \%drivers;
}

#-------------------------------------------------------------------

=head2 getOptions ( $cart )

Returns a set of options for the user to pay to.  It is a hash of
hashrefs, with the key of the primary hash being the paymentGatewayId
of the driver, and sub keys of label and button.  The hash will only
contain payment gateways that this user is allowed to use.

=head3 $cart

A WebGUI::Shop::Cart object.  A WebGUI::Error::InvalidParam exception will be thrown if it doesn't get one.

=cut

sub getOptions {
    my $self    = shift;
    my $cart    = shift;

    WebGUI::Error::InvalidParam->throw(error => q{Need a cart.}) unless defined $cart and $cart->isa("WebGUI::Shop::Cart");

    my $session = $cart->session; 
    my $recurringRequired = $cart->requiresRecurringPayment;
    my %options = ();

    foreach my $gateway (@{ $self->getPaymentGateways() }) {
        next unless $gateway->canUse;
        if (!$recurringRequired || $gateway->handlesRecurring) {
            $options{$gateway->getId} = {
                label   => $gateway->get("label"),
                button  => $gateway->getButton( $cart ),
            };    
        }
    }
    return \%options;
}

#-------------------------------------------------------------------

=head2 getPaymentGateway ( $id )

Looks up an existing PayDriver in the db by paymentGatewayId and returns
that object.  If the PayDriver throws an exception,  it is propagated
back up to the top.

=head3 id

The id of the gateway to instanciate.

=cut

sub getPaymentGateway {
    my ($self, $gatewayId) = @_;
    my $session = $self->session;
    WebGUI::Error::InvalidParam->throw(error => q{Must provide a paymentGatewayId})
        unless defined $gatewayId;
    my $requestedClass = $session->db->quickScalar('select className from paymentGateway where paymentGatewayId=?',[$gatewayId]);
    WebGUI::Error::ObjectNotFound->throw(error => q{payment gateway not found in db}, id => $gatewayId)
        unless $requestedClass;
    my $driver = eval { WebGUI::Pluggable::instanciate($requestedClass, 'new', [ $session, $gatewayId ]) };
    return $driver;
}

#-------------------------------------------------------------------

=head2 getPaymentGateways ( )

Returns an array ref of all payment gateway objects in the db.

=cut

sub getPaymentGateways {
    my $self     = shift;
    my @drivers = ();
    my $sth = $self->session->db->prepare('select paymentGatewayId from paymentGateway');
    $sth->execute();
    while (my $driver = $sth->hashRef()) {
        push @drivers, $self->getPaymentGateway($driver->{paymentGatewayId});
    }
    $sth->finish;
    return \@drivers;
}

#-------------------------------------------------------------------

=head2 getRecurringPeriodValues ( period )

A utility method that returns the internationalized name for period.

=head3 period

The period you want the name for.

=cut

sub getRecurringPeriodValues {
	my $self    = shift;
	my $session = $self->session;

	my $i18n = WebGUI::International->new($session, 'Shop');
	tie my %periods, "Tie::IxHash";	
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

=head2 www_addPaymentGateway ( $session ) 

Add a new payment gateway, based on the className form variable.  It will throw
an error, WebGUI::Error::InvalidParram if no className is passed.

=head3 $session

A reference to the current session object.

=cut

sub www_addPaymentGateway {
    my $self    = shift;
    my $session = $self->session;

    my $className = $session->form->process('className') 
        || WebGUI::Error::InvalidParam->throw(error => 'No class name passed');

    my $payDriver = $self->addPaymentGateway( $className, { enabled => 0, label =>  $className->getName($session), } );
    return $payDriver->www_edit;
}

#-------------------------------------------------------------------

=head2 www_deletePaymentGateway ()

Deletes a payment gateway from the shop.

=cut

sub www_deletePaymentGateway {
    my $self    = shift;
    my $session = $self->session;

    my $paymentGatewayId = $session->form->process('paymentGatewayId') 
        || WebGUI::Error::InvalidParam->throw(error => q{www_deletePaymentGateway requires a paymentGatewayId to be passed});

    my $payDriver = $self->getPaymentGateway( $paymentGatewayId );
    $payDriver->delete;

    return $self->www_manage;
}

#-------------------------------------------------------------------

=head2 www_do ( )

Let's payment gateway drivers do method calls. Requires a driver param in the post form vars which contains the id of the driver to load.

=cut

sub www_do {
    my ($self) = @_;
    my $form = $self->session->form;
    my $paymentGatewayId = $form->get("paymentGatewayId")
        || WebGUI::Error::InvalidParam->throw(error => q{must have a form var called driver with a payment gateway id});

    my $do = $form->get("do") 
        || WebGUI::Error::InvalidParam->throw(error => q{must have a form var called do with a www_ method to call});

    my $payDriver = $self->getPaymentGateway( $paymentGatewayId );

    my $output = undef;
    my $method = "www_$do";
    if ($payDriver->can($method)) {
        $output = $payDriver->$method();
    }
    return $output;
}

#-------------------------------------------------------------------

=head2 www_manage ( )

The main management screen for payment gateways.

=cut

sub www_manage {
    my $self    = shift;
    my $session = $self->session;
    my $admin   = WebGUI::Shop::Admin->new($session);
    my $i18n    = WebGUI::International->new($session, "Shop");

    return $session->privilege->adminOnly() unless ($admin->canManage);

    # Button for adding a payment gateway
    my $output = WebGUI::Form::formHeader($session)
        .WebGUI::Form::hidden($session,     { name  => "shop",      value   => "pay" })
        .WebGUI::Form::hidden($session,     { name  => "method",    value   => "addPaymentGateway" })
        .WebGUI::Form::selectBox($session,  { name  => "className", options => $self->getDrivers })
        .WebGUI::Form::submit($session,     { value => $i18n->get("add payment method") })
        .WebGUI::Form::formFooter($session);

    # Add a row with edit/delete buttons for each payment gateway.
    foreach my $paymentGateway (@{$self->getPaymentGateways}) {
        $output .= '<div style="clear: both;">'
            # Delete button for the current payment gateway.
			.WebGUI::Form::formHeader($session, {extras=>'style="float: left;"' })
            .WebGUI::Form::hidden($session, { name   => "shop",                value => "pay" })
            .WebGUI::Form::hidden($session, { name   => "method",              value => "deletePaymentGateway" })
            .WebGUI::Form::hidden($session, { name   => "paymentGatewayId",    value => $paymentGateway->getId })
            .WebGUI::Form::submit($session, { value  => $i18n->get("delete"),  extras => 'class="backwardButton"' }) 
            .WebGUI::Form::formFooter($session)

            # Edit button for current payment gateway
            .WebGUI::Form::formHeader($session, {extras=>'style="float: left;"' })
            .WebGUI::Form::hidden($session, { name   => "shop",              value => "pay" })
            .WebGUI::Form::hidden($session, { name   => "method",            value => "do" })
            .WebGUI::Form::hidden($session, { name   => "do",                value => "edit" })
            .WebGUI::Form::hidden($session, { name   => "paymentGatewayId",  value => $paymentGateway->getId })
            .WebGUI::Form::submit($session, { value  => $i18n->get("edit"),  extras => 'class="normalButton"' })
            .WebGUI::Form::formFooter($session)

            # Append payment gateway label
            .' '. $paymentGateway->get('label')
        .'</div>';        
    }

    # Wrap in admin console
    my $console = $admin->getAdminConsole;
    return $console->render($output, $i18n->get("payment methods"));
}

#-------------------------------------------------------------------

=head2 www_selectPaymentGateway ( )

The screen in which a customer chooses a payment gateway.

TODO: Template this screen.

=cut

sub www_selectPaymentGateway {
    my $self    = shift;
    my $session = $self->session;
  
    my $cart    = WebGUI::Shop::Cart->newBySession( $session );
    my $i18n    = WebGUI::International->new( $session, 'Shop' );

    # Make sure the user is logged in.
    if ($session->user->isVisitor) {
        $session->scratch->set( 'redirectAfterLogin', $session->url->page('shop=pay;method=selectPaymentGateway') );

        # We cannot use WebGUI::Operation::execute( $session, 'auth'); because the method form param used by the
        # Shop contenthandler overrides the method param used by WG::Op::Auth
        $session->http->setRedirect( $session->url->page('op=auth;method=init') );

        # If the redirect fails make sure people can still go to the login screen by giving them a link
        return $session->style->userStyle(
            sprintf $i18n->get('login message'), $session->url->page('op=auth;method=init')
        );
    }

    # Check if the cart is ready for checkout
    unless ($cart->readyForCheckout) {
        $session->http->setRedirect( $session->url->page('shop=cart;method=view') );
        return '';
    }
    
    # Complete Transaction if it's a $0 transaction.
    my $total = $cart->calculateTotal;
    if (sprintf('%.2f', $total + $cart->calculateShopCreditDeduction($total)) eq '0.00') {
        my $transaction = WebGUI::Shop::Transaction->create($session, {cart => $cart});
        $transaction->completePurchase('zero', 'success', 'success');
        $cart->onCompletePurchase;
        $transaction->sendNotifications();
        return $transaction->thankYou();
    }

    # All the output stuff below is just a placeholder until it's templated.
    my $payOptions  = $self->getOptions( $cart );

    # TODO: If only one payOption exists, just send us there
    # In order to do this, the PayDriver must give us a direct URL to go to

    my $var;
    my @paymentGateways;
    foreach my $payOption ( values %{$payOptions} ) {
        push @paymentGateways, $payOption;
    }
    $var->{ paymentGateways     }   = \@paymentGateways;
    $var->{ choose              }   = $i18n->get('choose payment gateway message');
    my $template = WebGUI::Asset::Template->newById($session, $session->setting->get("selectGatewayTemplateId"));
    return $session->style->userStyle($template->process($var));
}

1;
