package WebGUI::Shop::Pay;

use strict;

use Class::InsideOut qw{ :std };
use WebGUI::Exception;
use WebGUI::International;
use WebGUI::Pluggable;
use WebGUI::Shop::Admin;
#use WebGUI::Shop::PayDriver;
use WebGUI::Utility;

=head1 NAME

Package WebGUI::Shop::Pay

=head1 DESCRIPTION

This is the master class to manage pay drivers.

=head1 SYNOPSIS

 use WebGUI::Shop::Pay;

=head1 METHODS

These subroutines are available from this package:

=cut

readonly session => my %session;


#-------------------------------------------------------------------

=head2 addPaymentGateway ( $class, $options )

The interface method for creating new, configured instances of PayDriver.  If the PayDriver throws an exception,  it is propagated
back up to the top.

=head4 $class

The class of the new PayDriver object to create.

=head4 $options

A list of properties to assign to this PayDriver.  See C<definition> for details.

=cut

sub addPaymentGateway {
    my $self   = shift;
    my $requestedClass = shift;
    my $options = shift;
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
    foreach my $class (@{$self->session->config->get('paymentDrivers')}) {
        $drivers{$class} = eval { WebGUI::Pluggable::instanciate($class, 'getName', [ $self->session ])};
    }
    return \%drivers;
}

#-------------------------------------------------------------------

=head2 getOptions ( $cart )

Returns a list of options for the user to pay to.  It is a hash of hashrefs, with the key of the primary hash being the paymentGatewayId of the driver, and sub keys of label and button.

=head3 $cart

A WebGUI::Shop::Cart object.  A WebGUI::Error::InvalidParam exception will be thrown if it doesn't get one.

=head3

=cut

sub getOptions {
    my ($self, $cart) = @_;
    WebGUI::Error::InvalidParam->throw(error => q{Need a cart.}) unless defined $cart and $cart->isa("WebGUI::Shop::Cart");
    my $session = $cart->session; 
    my %options = ();
    foreach my $gateway (@{$self->getPaymentGateways()}) {
        $options{$gateway->getId} = {
            label => $gateway->get("label"),
            button => $gateway->getButton($cart),
            };    
    }
    return \%options;
}

#-------------------------------------------------------------------

=head2 getPaymentGateway ( )

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

=head3

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

=head2 new ( $session )

Constructor.

=head3 $session

A WebGUI::Session object.

=cut

sub new {
    my $class     = shift;
    my $session   = shift;
    WebGUI::Error::InvalidObject->throw(expected=>"WebGUI::Session", got=>(ref $session), error => q{Must provide a session variable}) unless ref $session eq 'WebGUI::Session';
    my $self = register $class;
    my $id        = id $self;
    $session{ $id }   = $session;
    return $self;
}

#-------------------------------------------------------------------

=head2 session () 

Returns a reference to the current session.

=cut

#-------------------------------------------------------------------

=head2 www_do ( )

Let's payment gateway drivers do method calls. Requires a driver param in the post form vars which contains the id of the driver to load.

=cut

sub www_do {
    my ($self) = @_;
    my $form = $self->session->form;
    WebGUI::Error::InvalidParam->throw(error => q{must have a form var called driver with a driver id }) if ($form->get("driver") eq "");
    WebGUI::Error::InvalidParam->throw(error => q{must have a form var called do with a www_ method to call }) if ($form->get("do") eq "");
    my $driver = $self->getPaymentGateway($form->get("driver"));
    my $output = undef;
    my $method = "www_". ( $form->get("do"));
    if ($driver->can($method)) {
        $output = $driver->$method();
    }
    return $output;
}

#-------------------------------------------------------------------

=head2 www_manage ( )

The main management screen for payment gateways.

=cut

sub www_manage {
    my ($self) = @_;
    my $session = $self->session;
    return $session->privilege->adminOnly() unless ($session->user->isInGroup("3"));
    my $admin = WebGUI::Shop::Admin->new($session);
    my $i18n = WebGUI::International->new($session, "Shop");
    my $output = WebGUI::Form::formHeader($session)
        .WebGUI::Form::hidden($session, {name=>"shop", value=>"pay"})
        .WebGUI::Form::hidden($session, {name=>"method", value=>"addDriver"})
        .WebGUI::Form::selectBox($session, {name=>"className", options=>$self->getDrivers})
        .WebGUI::Form::submit($session, {value=>$i18n->get("add payment method")})
        .WebGUI::Form::formFooter($session);
    foreach my $payer (@{$self->getPaymentGateways}) {
        
    }
    my $console = $admin->getAdminConsole;
    return $console->render($output, $i18n->get("payment methods"));
}

1;
