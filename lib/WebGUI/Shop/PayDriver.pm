package WebGUI::Shop::PayDriver;

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

use Class::InsideOut qw{ :std };
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
use Storable qw/dclone/;
use Scalar::Util qw/blessed/;

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

readonly session            => my %session;
readonly className          => my %className;
readonly paymentGatewayId   => my %paymentGatewayId;
readonly options            => my %options;

#-------------------------------------------------------------------

=head2 _buildObj (  )

Private method used to build objects, shared by new and create.

=cut

sub _buildObj {
    my ($class, $session, $requestedClass, $paymentGatewayId, $options) = @_;
    my $self    = {};
    bless $self, $requestedClass;
    register $self;

    my $id                      = id $self;

    $session{ $id }             = $session;
    $options{ $id }             = $options;
    $className{ $id }           = $requestedClass;
    $paymentGatewayId{ $id }    = $paymentGatewayId;

    return $self;
}


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
    return 0 unless $self->get('enabled');
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
    return $userObject->isInGroup($self->get('groupToUse'));
}

#-------------------------------------------------------------------

=head2 className (  )

Accessor for the className of the object.  This is the name of the driver that is used
to do calculations.

=cut

#-------------------------------------------------------------------

=head2 create ( $session, $options )

Constructor for new WebGUI::Shop::PayDriver objects.  Returns a WebGUI::Shop::PayDriver object.
To access driver objects that have already been configured, use C<new>.

=head3 $session

A WebGUI::Session object.

=head4 $options

A list of properties to assign to this PayDriver.  See C<definition> for details.

=cut

sub create {
    my $class   = shift;
    my $session = shift;
    WebGUI::Error::InvalidParam->throw(error => q{Must provide a session variable})
        unless ref $session eq 'WebGUI::Session';
    my $options = shift;
    WebGUI::Error::InvalidParam->throw(error => q{Must provide a hashref of options})
        unless ref $options eq 'HASH' and scalar keys %{ $options };
    WebGUI::Error::InvalidParam->throw(error => q{Must provide a human readable label in the hashref of options})
        unless exists $options->{label} && $options->{label};

    # Generate a unique id for this payment
    my $paymentGatewayId = $session->id->generate;

    # Build object
    my $self = WebGUI::Shop::PayDriver->_buildObj($session, $class, $paymentGatewayId, $options);

    # and persist this instance in the db
    $session->db->write('insert into paymentGateway (paymentGatewayId, className) VALUES (?,?)', [
        $paymentGatewayId, 
        $class,
    ]);
    
    # Set the options via the update method because update() will automatically serialize the options hash
    $self->update($options);

    return $self;
}

#-------------------------------------------------------------------

=head2 definition ( $session )

This subroutine returns an arrayref of hashrefs, used to validate data put into
the object by the user, and to automatically generate the edit form to show
the user.

=cut

sub definition {
    my $class      = shift;
    my $session    = shift;
    WebGUI::Error::InvalidParam->throw(error => q{Must provide a session variable})
        unless ref $session eq 'WebGUI::Session';
    my $definition = shift || [];
    my $i18n = WebGUI::International->new($session, 'PayDriver');

    tie my %fields, 'Tie::IxHash';
    %fields = (
        label           => {
            fieldType       => 'text',
            label           => $i18n->get('label'),
            hoverHelp       => $i18n->get('label help'),
            defaultValue    => "Credit Card",
        },
        enabled         => {
            fieldType       => 'yesNo',
            label           => $i18n->get('enabled'),
            hoverHelp       => $i18n->get('enabled help'),
            defaultValue    => 1,
        },
        groupToUse      => {
            fieldType       => 'group',
            label           => $i18n->get('who can use'),
            hoverHelp       => $i18n->get('who can use help'),
            defaultValue    => 7,
        },
    );

    my %properties = (
        name        => 'Payment Driver',
        properties  => \%fields,
    );
    push @{ $definition }, \%properties;

    return $definition;
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

=head2 get ( [ $param ] )

This is an enhanced accessor for the options property.  By default,
it returns all the options as a hashref.  If the name of a key
in the hash is passed, it will only return that value from the
options hash.

=head3 $param

An optional parameter.  If it matches the key of a hash, it will
return the value from the options hash.

=cut

sub get {
    my $self  = shift;
    my $param = shift;
    my $options = $self->options;
    if (defined $param) {
        return $options->{ $param };
    }
    else {
        return { %{ $options } };
    }
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

=head2 getDoFormTags ( $method, $htmlForm )

Returns a string containing the required form fields for doing a www_do method call. If an HTMLForm object is
passed the fields are automatically added to it. In that case no form tags a returned by this method.

=head3 $htmlForm

The HTMLForm object you want to add the fields to. This is optional.

=cut

sub getDoFormTags {
    my $self        = shift;
    my $doMethod    = shift;
    my $htmlForm    = shift;
    my $session     = $self->session;

    if ($htmlForm) {
        $htmlForm->hidden(name => 'shop',               value => 'pay');
        $htmlForm->hidden(name => 'method',             value => 'do');
        $htmlForm->hidden(name => 'do',                 value => $doMethod);
        $htmlForm->hidden(name => 'paymentGatewayId',   value => $self->getId);

        return undef;
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
    
    my $definition = $self->definition($self->session);
    my $form = WebGUI::HTMLForm->new($self->session);
    $form->submit;
    
    $self->getDoFormTags('editSave', $form);
    $form->hidden(
        name  => 'className',
        value => $self->className,
    );
    $form->dynamicForm($definition, 'properties', $self);

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
subclass, instead specified in definition with the name "name".

This is a class method.

=cut

sub getName {
    my $class       = shift;
    my $session     = shift;
    WebGUI::Error::InvalidParam->throw(error => q{Must provide a session variable})
        unless ref $session eq 'WebGUI::Session';

    my $definition  = $class->definition($session);

    return $definition->[0]->{name};
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

sub new {
    my $class               = shift;
    my $session             = shift;
    WebGUI::Error::InvalidParam->throw(error => q{Must provide a session variable})
        unless ref $session eq 'WebGUI::Session';
    my $paymentGatewayId    = shift;
    WebGUI::Error::InvalidParam->throw(error => q{Must provide a paymentGatewayId})
        unless defined $paymentGatewayId;

    # Fetch the instance data from the db
    my $properties = $session->db->quickHashRef('select * from paymentGateway where paymentGatewayId=?', [
        $paymentGatewayId,
    ]);
    WebGUI::Error::ObjectNotFound->throw(error => q{paymentGatewayId not found in db}, id => $paymentGatewayId)
        unless scalar keys %{ $properties };

    croak "Somehow, the options property of this object, $paymentGatewayId, got broken in the db"
        unless exists $properties->{options} and $properties->{options};

    my $options = from_json($properties->{options});

    my $self = WebGUI::Shop::PayDriver->_buildObj($session, $class, $paymentGatewayId, $options);

    return $self;
}

#-------------------------------------------------------------------

=head2 options (  )

Accessor for the driver properties.  This returns a hashref
any driver specific properties.  To set the properties, use
the C<set> method.

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

=head2 processPropertiesFromFormPost ( )

Updates pay driver with data from Form.

=cut

sub processTemplate {
    my $self       = shift;
    my $session    = $self->session;
    my $templateId = shift;
    my $var        = shift;
    my $i18n       = WebGUI::International->new($session, 'PayDriver');

    my $template = WebGUI::Asset::Template->new($session, $templateId);
    my $output;
    if (defined $template) {
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
    my %properties;
    my $fullDefinition = $self->definition($self->session);

    foreach my $definition (@{$fullDefinition}) {
        foreach my $property (keys %{$definition->{properties}}) {
            $properties{$property} = $self->session->form->process(
                $property,
                $definition->{properties}{$property}{fieldType},
                $definition->{properties}{$property}{defaultValue}
            );
        }
    }
    $properties{label} = $fullDefinition->[0]{name} if ($properties{label} eq "" || lc($properties{label}) eq "untitled");
    $self->update(\%properties);
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

        # Create a transaction...
        $transaction = WebGUI::Shop::Transaction->create( $self->session, $transactionProperties );
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

=head2 update ( $options )

Setter for user configurable options in the payment objects.

=head4 $options

A list of properties to assign to this PayDriver.  See C<definition> for details.  The options are
flattened into JSON and stored in the database as text.  There is no content checking performed.

=cut

sub update {
    my $self        = shift;
    my $properties  = shift;
    WebGUI::Error::InvalidParam->throw(error => 'update was not sent a hashref of options to store in the database')
        unless ref $properties eq 'HASH' and scalar keys %{ $properties };

    my $jsonOptions = to_json($properties);
    $self->session->db->write('update paymentGateway set options=? where paymentGatewayId=?', [
        $jsonOptions,
        $self->paymentGatewayId
    ]);
    my $storedProperties = dclone $properties;
    $options{ id $self } = $storedProperties;

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

    my $output   = $self->processTemplate($self->get("summaryTemplateId"), $var);
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
    $form->submit;
  
    return $admin->getAdminConsole->render($form->print, $i18n->get('payment methods'));
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
    $session->http->setRedirect($session->url->page('shop=pay;method=manage'));

    return undef;
}

=head2 CHANGES ( )

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
