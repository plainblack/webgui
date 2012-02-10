package WebGUI::Shop::PayDriver;

=head1 LEGAL

 -------------------------------------------------------------------
  WebGUI is Copyright 2001-2012 Plain Black Corporation.
 -------------------------------------------------------------------
  Please read the legal notices (docs/legal.txt) and the license
  (docs/license.txt) that came with this distribution before using
  this software.
 -------------------------------------------------------------------
  http://www.plainblack.com                     info@plainblack.com
 -------------------------------------------------------------------

=cut

use strict;

use Carp qw(croak);
use Tie::IxHash;
use WebGUI::Exception::Shop;
use WebGUI::Inbox;
use WebGUI::International;
use WebGUI::HTMLForm;
use WebGUI::Macro;
use WebGUI::User;
use WebGUI::Shop::Cart;
use JSON;
use Clone qw/clone/;
use Scalar::Util qw/blessed/;

use Moose;
use WebGUI::Definition::Shop;

=head1 NAME

Package WebGUI::Shop::PayDriver

=head1 DESCRIPTION

This package is the base class for all modules which implement a payment driver.

=head1 SYNOPSIS

 use WebGUI::Shop::PayDriver;

 my $payDriver = WebGUI::Shop::PayDriver->new($session);

=head1 METHODS

These subroutines are available from this package:

=cut

define tableName  => 'paymentGateway';
define pluginName => ['Payment Driver', 'PayDriver'];

property label => (
            fieldType       => 'text',
            label           => ['label', 'PayDriver'],
            hoverHelp       => ['label help', 'PayDriver'],
            default         => "Credit Card",
         );
around label => sub {
    my $orig = shift;
    my $self = shift;
    if (@_ > 0) {
        my $label = shift;
        $label = $self->getName($self->session) if $label eq '' || lc($label) eq 'untitled';
        unshift @_, $label;
    }
    $self->$orig(@_);
};
property enabled => (
            fieldType       => 'yesNo',
            label           => ['enabled', 'PayDriver'],
            hoverHelp       => ['enabled help', 'PayDriver'],
            default         => 1,
         );
property groupToUse => (
            fieldType       => 'group',
            label           => ['who can use', 'PayDriver'],
            hoverHelp       => ['who can use help', 'PayDriver'],
            default         => 7,
         );

has [ qw/session paymentGatewayId/ ] => (
    is       => 'ro',
    required => 1,
);

around BUILDARGS => sub {
    my $orig  = shift;
    my $class = shift;
    if(ref $_[0] eq 'HASH') {
        ##Standard Moose invocation for creating a new object
        return $class->$orig(@_);
    }
    my $session = shift;
    WebGUI::Error::InvalidParam->throw(error => q{Must provide a session variable})
        unless blessed $session && $session->isa('WebGUI::Session');
    if (ref $_[0] eq 'HASH') {
        ##Create an object from a hashref of options
        my $options = shift;
        $options->{session} = $session;
        $options->{paymentGatewayId} = $session->id->generate;
        return $class->$orig($options);
    }
    ##Must be a paymentGatewayId, look it up in the database
    my $paymentGatewayId = shift;
    WebGUI::Error::InvalidParam->throw(error => q{Must provide a paymentGatewayId})
        unless defined $paymentGatewayId;
    my $properties = $session->db->quickHashRef('select * from paymentGateway where paymentGatewayId=?', [
        $paymentGatewayId,
    ]);
    WebGUI::Error::ObjectNotFound->throw(error => q{paymentGatewayId not found in db}, id => $paymentGatewayId)
        unless scalar keys %{ $properties };

    croak "Somehow, the options property of this object, $paymentGatewayId, got broken in the db"
        unless exists $properties->{options} and $properties->{options};

    my $options = from_json($properties->{options});
    $options->{session}          = $session;
    $options->{paymentGatewayId} = $paymentGatewayId;
    return $class->$orig($options);
};

#-------------------------------------------------------------------

=head2 appendCartVariables ( $var )

Append the subtotal, shipping, tax, and shop credit deductions to a set of template
variables.  Returns the modified hashreference of variables.

=head3 $var

A hashref.  Template variables will be added to it.  If $var is not passed, a new
hashref is created, and that is returned.

=cut

sub appendCartVariables {
    my ($self, $var) = @_;
    $var      ||= {};
    my $cart    = $self->getCart;
    $var->{shippableItemsInCart} = $cart->requiresShipping;
    $var->{subtotal} = $cart->formatCurrency($cart->calculateSubtotal);
    $var->{shipping} = $cart->calculateShipping;
    $var->{taxes}    = $cart->calculateTaxes;
    my $totalPrice   = $var->{subtotal} + $var->{shipping} + $var->{taxes};
    my $session = $self->session;
    my $credit = WebGUI::Shop::Credit->new($session, $cart->getPosUser->userId);
    $var->{inShopCreditAvailable} = $credit->getSum;
    $var->{inShopCreditDeduction} = $credit->calculateDeduction($totalPrice);
    $var->{totalPrice           } = $cart->formatCurrency($totalPrice + $var->{inShopCreditDeduction});
    return $var;
}


#-------------------------------------------------------------------

=head2 cancelRecurringPayment ( transaction )

Cancels a recurring transaction. Returns an array containing ( isSuccess, gatewayStatus, gatewayError). Needs to be overridden by subclasses capable of dealing with recurring payments.

=head3 transaction

The instanciated recurring transaction object.

=cut

sub cancelRecurringPayment {
    my $self        = shift;
    my $transaction = shift;
    WebGUI::Error::OverrideMe->throw();
}
    
#-------------------------------------------------------------------

=head2 canUse ( user )

Checks to see if the user can use this Payment Driver.  Ability to use
is based on whether or not this user has the correct privileges, and if
the driver is enabled or not.

=head3 user

A hashref containing user information.  The user referenced will be checked
to see if they can use the Payment Driver.  If missing, then $session->user
will be used.

=head4 userId

A userId used to build a user object.

=head4 user

A user object that will be used directly.

=cut

sub canUse {
    my $self = shift;
    return 0 unless $self->enabled;
    my $user = shift;
    my $userObject;
    if (!defined $user or ref($user) ne 'HASH') {
        $userObject = $self->session->user;
    }
    else {
        if (exists $user->{user}) {
            $userObject = $user->{user};
        }
        elsif (exists $user->{userId}) {
            $userObject = WebGUI::User->new($self->session, $user->{userId});
        }
        else {
            WebGUI::Error::InvalidParam->throw(error => q{Must provide user information})
        }
    }
    return $userObject->isInGroup($self->groupToUse);
}

#-------------------------------------------------------------------

=head2 className (  )

Accessor for the className of the object.  This is the name of the driver that is used
to do calculations.

=cut

sub className {
    return ref $_[0];
}

#-------------------------------------------------------------------

=head2 delete ( )

Removes this PayDriver object from the db.

=cut

sub delete {
    my $self = shift;

    $self->session->db->write('delete from paymentGateway where paymentGatewayId=?', [
        $self->getId,
    ]);

    return;
}

#-------------------------------------------------------------------

=head2 displayPaymentError ( transaction )

The default error message that gets displayed when a payment is rejected.

=cut

sub displayPaymentError {
    my ($self, $transaction) = @_;
    my $i18n    = WebGUI::International->new($self->session, "PayDriver");
    my $output  = q{<h1>} . $i18n->get('error processing payment') . q{</h1>}
                . q{<p>} . $i18n->get('error processing payment message') . q{</p>};
    if ($transaction) {
        $output .= q{<p>} . $transaction->get('statusMessage') . q{</p>};
    }
    else {
        $output .= q{<p>} . $i18n->get('unable to finish transaction') . q{</p>};
    }
    $output     .= q{<p><a href="?shop=cart;method=checkout">} . $i18n->get( 'try again' ) . q{</a></p>};
    return $self->session->style->userStyle($output);
}

#-------------------------------------------------------------------

=head2 getAddress ( addressId )

Returns an instantiated WebGUI::Shop::Address object for the passed address id.

=head3 addressId

The id of the adress to instantiate.

=cut

sub getAddress {
    my $self        = shift;
    my $addressId   = shift;

    if ($addressId) {
        return $self->getCart->getAddressBook->getAddress( $addressId );
    }

    return undef;
}

#-------------------------------------------------------------------

=head2 getButton ( )

Used for the generic, vanilla checkout form.  Must be overridden by any methods that
use the default www_getCredentials.

=cut

sub getButton {
    return '';
}

#-------------------------------------------------------------------

=head2 getCart ( )

Returns the WebGUI::Shop::Cart object for the current session.

=cut

sub getCart {
    my $self = shift;
    my $cart = WebGUI::Shop::Cart->newBySession( $self->session );
    return $cart;
}

#-------------------------------------------------------------------

=head2 getDoFormTags ( $method, $fb )

Returns a string containing the required form fields for doing a www_do method call. If a FormBuilder object is
passed the fields are automatically added to it. In that case no form tags a returned by this method.

=head3 $fb

The FormBuilder object you want to add the fields to. This is optional.

=cut

sub getDoFormTags {
    my $self        = shift;
    my $doMethod    = shift;
    my $fb          = shift;
    my $session     = $self->session;

    if ($fb) {
        $fb->addField( "hidden", name => 'shop',               value => 'pay');
        $fb->addField( "hidden", name => 'method',             value => 'do');
        $fb->addField( "hidden", name => 'do',                 value => $doMethod);
        $fb->addField( "hidden", name => 'paymentGatewayId',   value => $self->getId);
    }
    else {
        return WebGUI::Form::hidden($session, { name => 'shop',               value => 'pay' })
            . WebGUI::Form::hidden($session, { name => 'method',             value => 'do' })
            . WebGUI::Form::hidden($session, { name => 'do',                 value => $doMethod })
            . WebGUI::Form::hidden($session, { name => 'paymentGatewayId',   value => $self->getId })
    }
}


#-------------------------------------------------------------------

=head2 getEditForm ( )

Returns the configuration form for the options of this plugin.

=cut

sub getEditForm {
    my $self = shift;
    
    my $form = WebGUI::FormBuilder->new($self->session);
    $form->addField( "submit", name => "send" );
    
    $self->getDoFormTags('editSave', $form);
    $form->addField( "hidden",
        name  => 'className',
        value => $self->className,
    );
    foreach my $property_name ($self->getProperties) {
        my $property = $self->meta->find_attribute_by_name($property_name);
        my %form_options = (
            name => $property_name,
            value => $self->$property_name,
            %{ $self->getFormProperties($property_name)},
        );
        $form->addField( delete $form_options{ fieldType }, %form_options );
    }

    return $form;
}

#-------------------------------------------------------------------

=head2 getId ( )

Returns the paymentGatewayId. 

=cut

sub getId {
    my $self = shift;

    return $self->paymentGatewayId;
}

#-------------------------------------------------------------------

=head2 getName ( )

Return a human readable name for this driver. Never overridden in the
subclass, instead specified via WebGUI::Definition::Shop with the name "pluginName".

This is a class method.

=cut

sub getName {
    my $class       = shift;
    my $session     = shift;
    WebGUI::Error::InvalidParam->throw(error => q{Must provide a session variable})
        unless ref $session eq 'WebGUI::Session';

    return WebGUI::International->new($session)->get(@{ $class->meta->pluginName });
}

#-------------------------------------------------------------------

=head2 handlesRecurring ()

Returns 0. Should be overridden to return 1 by any subclasses that can handle recurring payments.

=cut

sub handlesRecurring {
    return 0;
}


#-------------------------------------------------------------------

=head2 new ( $session, $paymentGatewayId )

Looks up an existing PayDriver in the db by paymentGatewayId and returns
that object.

=cut

#-------------------------------------------------------------------

=head2 processPayment ()

Should interact with the payment gateway and then return an array containing success/failure (as 1 or 0), transaction code (or payment gateway's transaction id), status code, and status message. Must be overridden by subclasses.

=cut

sub processPayment {
    my $self = shift;
    WebGUI::Error::OverrideMe->throw(error=>'Override processPayment()');
}

#-------------------------------------------------------------------

=head2 processTemplate ( )

Common code for processing a template and doing exception handling.

=cut

sub processTemplate {
    my $self       = shift;
    my $session    = $self->session;
    my $templateId = shift;
    my $var        = shift;
    my $i18n       = WebGUI::International->new($session, 'PayDriver');

    my $template = eval { WebGUI::Asset->newById($session, $templateId); };
    my $output;
    if (!Exception::Class->caught) {
        $template->prepare;
        $output = $template->process($var);
    }
    else {
        $output = $i18n->get('template gone');
    }
    return $output;


}

#-------------------------------------------------------------------

=head2 processPropertiesFromFormPost ( )

Updates ship driver with data from Form.

=cut

sub processPropertiesFromFormPost {
    my $self = shift;

    my $form = $self->session->form;
    foreach my $property_name ($self->getProperties) {
        my $property = $self->meta->find_attribute_by_name($property_name);
        my $value    = $form->process(
            $property_name,
            $property->form->{fieldType},
            $self->$property_name,
        );
        $self->$property_name($value);
    }
    $self->write;
}

#-------------------------------------------------------------------

=head2 processTransaction ( [ object ] )

This method is responsible for handling success or failure from the payment processor, completing or denying the transaction, and sending out notification and receipt emails. Returns a WebGUI::Shop::Transaction object.

=head3 object

Can be undef, in which case a WebGUI::Shop::Transaction object will be generated using the cart. Can also be a reference to a WebGUI::Shop::Address object that should be attached as payment information to the autogenerated WebGUI::Shop::Transaction. Or can be a WebGUI::Shop::Transaction that you've already constructed and then no transaction will be generated, but rather just updated.

=cut

sub processTransaction {
    my ($self, $object) = @_;

    my $cart = $self->getCart;
    
    # determine object type
    my $transaction;
    my $paymentAddress;
    if (blessed $object) {
        if ($object->isa('WebGUI::Shop::Transaction')) {
            $transaction = $object;
        }
        elsif ($object->isa('WebGUI::Shop::Address')) {
            $paymentAddress = $object;
        }
    }

    # Setup dynamic transaction
    unless (defined $transaction) {     
        my $transactionProperties;
        $transactionProperties->{ paymentMethod } = $self;
        $transactionProperties->{ cart          } = $cart;
        $transactionProperties->{ isRecurring   } = $cart->requiresRecurringPayment;
        $transactionProperties->{ session       } = $self->session;

        # Create a transaction...
        $transaction = WebGUI::Shop::Transaction->new( $transactionProperties );
        $transaction->write;
    }

    # And handle the payment for it
    my ($success, $transactionCode, $statusCode, $statusMessage) = $self->processPayment( $transaction );
    if ($success) {
        $transaction->completePurchase($transactionCode, $statusCode, $statusMessage);
        $cart->onCompletePurchase;
        $transaction->sendNotifications();
    }
    else {
        $transaction->denyPurchase($transactionCode, $statusCode, $statusMessage);
    }
    return $transaction;
}



#-------------------------------------------------------------------

=head2 session (  )

Accessor for the session object.  Returns the session object.

=cut

#-------------------------------------------------------------------

=head2 write ( $options )

Setter for user configurable options in the payment objects.

=head4 $options

A list of properties to assign to this PayDriver.  See C<new> for details.  The options are
flattened into JSON and stored in the database as text.  There is no content checking performed.

=cut

sub write {
    my $self        = shift;

    my $properties  = $self->get();
    delete $properties->{session};
    delete $properties->{paymentGatewayId};
    my $jsonOptions = to_json($properties);
    $self->session->db->setRow($self->tableName, 'paymentGatewayId', {
        paymentGatewayId => $self->paymentGatewayId,
        className        => $self->className,
        options          => $jsonOptions,
    });
    return;
}

#-------------------------------------------------------------------

=head2 paymentGatewayId (  )

Accessor for the unique identifier for this PayDriver.  The paymentGatewayId is 
a GUID.

=cut

#-------------------------------------------------------------------

=head2 www_getCredentials ( )

Displays a summary of the cart, and a button to checkout.  Plugins that need to get additional
information, or perform additional checks, should override this method.  Uses the getButton
method to create the checkout button.

=cut

sub www_getCredentials {
    my ($self)    = @_;
    my $session = $self->session;

    # Generate 'Proceed' button
    my $i18n = WebGUI::International->new($session, 'PayDriver_Cash');
    my $var = {
        proceedButton => $self->getButton,
    };
    $self->appendCartVariables($var);

    my $output   = $self->processTemplate($self->summaryTemplateId, $var);
    return $session->style->userStyle($output);
}

#-------------------------------------------------------------------

=head2 www_edit ( )

Generates an edit form.

=cut

sub www_edit {
    my $self    = shift;
    my $session = $self->session;
    my $admin   = WebGUI::Shop::Admin->new($session);
    my $i18n    = WebGUI::International->new($session, "PayDriver");

    return $session->privilege->insufficient() unless $session->user->isAdmin;

    my $form = $self->getEditForm;
    $form->addField( 'csrfToken', name => 'csrfToken' );
    $form->addField( "submit", name => "send" );
  
    return '<h1>' . $i18n->get('payment methods') . '</h1>' . $form->toHtml;
}

#-------------------------------------------------------------------

=head2 www_editSave ( )

Saves the data from the post.

=cut

sub www_editSave {
    my $self = shift;
    my $session = $self->session;
    return $session->privilege->insufficient() unless $session->user->isAdmin;

    $self->processPropertiesFromFormPost;
    $session->response->setRedirect($session->url->page('shop=pay;method=manage'));

    return undef;
}

=head2 CHANGES ( )

=head3 8.0.0

In 8.0.0, the base PayDriver class was modified so that it uses WebGUI::Definition::Shop as its base,
rather than Class::InsideOut.  All PayDriver subclasses from 7.x will need to do the same.
The current PayDriver subclasses, like Cash and ITransact, can be used as examples on what to do.

=head3 7.9.4

In 7.9.4, the base PayDriver class was changed to accomodate the new Cart.  The Cart is now in
charge of gathering billing information.  The PayDriver's job is to summarize all the payment
information for the user to review (www_getCredentials) and provide the user a button to complete
the checkout process (getButton), and then to complete the checkout.  PayDrivers can
do additional things beyond those steps, like the PayPal driver.

PayDrivers also now have a defult template for displaying that screen, the summaryTemplate.
While each core driver has its own template, custom drivers can use any existing one that
meets its needs.

=cut

1;
