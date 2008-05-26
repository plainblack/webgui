package WebGUI::Shop::PayDriver;

use strict;

use Class::InsideOut qw{ :std };
use Carp qw(croak);
use Tie::IxHash;
use WebGUI::Exception::Shop;
use WebGUI::Inbox;
use WebGUI::International;
use WebGUI::HTMLForm;
use WebGUI::Shop::Cart;
use JSON;

=head1 NAME

Package WebGUI::Shop::PayDriver

=head1 DESCRIPTION

This package is the base class for all modules which implement a pyament driver.

=head1 SYNOPSIS

 use WebGUI::Shop::PayDriver;

 my $tax = WebGUI::Shop::PayDriver->new($session);

=head1 METHODS

These subroutines are available from this package:

=cut

readonly session            => my %session;
readonly className          => my %className;
readonly paymentGatewayId   => my %paymentGatewayId;
readonly options            => my %options;
readonly label              => my %label;

#-------------------------------------------------------------------

=head2 _buildObj (  )

Private method used to build objects, shared by new and create.

=cut

sub _buildObj {
    my ($class, $session, $requestedClass, $paymentGatewayId, $label, $options) = @_;
    my $self    = {};
    bless $self, $requestedClass;
    register $self;

    my $id                      = id $self;

    $session{ $id }             = $session;
    $paymentGatewayId{ $id }    = $paymentGatewayId;
    $label{ $id }               = $label;
    $options{ $id }             = $options;
    $className{ $id }           = $requestedClass;

    return $self;
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

=head2 className (  )

Accessor for the className of the object.  This is the name of the driver that is used
to do calculations.

=cut

#-------------------------------------------------------------------

=head2 create ( $session, $label, $options )

Constructor for new WebGUI::Shop::PayDriver objects.  Returns a WebGUI::Shop::PayDriver object.
To access driver objects that have already been configured, use C<new>.

=head3 $session

A WebGUI::Session object.

=head4 $label

A human readable label for this payment.

=head4 $options

A list of properties to assign to this PayDriver.  See C<definition> for details.

=cut

sub create {
    my $class   = shift;
    my $session = shift;
    WebGUI::Error::InvalidParam->throw(error => q{Must provide a session variable})
        unless ref $session eq 'WebGUI::Session';
    my $label   = shift;
    WebGUI::Error::InvalidParam->throw(error => q{Must provide a human readable label in the hashref of options})
        unless $label;
    my $options = shift;
    WebGUI::Error::InvalidParam->throw(error => q{Must provide a hashref of options})
        unless ref $options eq 'HASH' and scalar keys %{ $options };

    # Generate a unique id for this payment
    my $paymentGatewayId = $session->id->generate;

    # Build object
    my $self = WebGUI::Shop::PayDriver->_buildObj($session, $class, $paymentGatewayId, $label, $options);

    # and persist this instance in the db
    $session->db->write('insert into paymentGateway (paymentGatewayId, label, className) VALUES (?,?,?)', [
        $paymentGatewayId, 
        $label,
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
        receiptEmailTemplateId => {
            fieldType       => 'template',
            namespace       => "Shop/EmailReceipt",
            label           => $i18n->get("receipt email template"),
            hoverHelp       => $i18n->get("receipt email template help"),
            defaultValue    => '',
        },
        saleNotificationGroupId => {
            fieldType       => 'group',
            label           => $i18n->get("sale notification group"),
            hoverHelp       => $i18n->get("sale notification group help"),
            defaultValue    => '3',
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
    my $i18n = WebGUI::International->new($self->session, "PayDriver");
    my $output = q{<h1>}.$i18n->get('error processing payment').q{</h1><p>}.$i18n->get('error processing payment message').q{</p><p>}.$transaction->get('statusMessage').{</p>};
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
        return { %$options };
    }
}

#-------------------------------------------------------------------

=head2 getButton ( )

Returns the form that will take the user to check out.

=cut

sub getButton {
    my $self = shift;
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
#    $form->hidden(
#        -name   => 'shop',
#        -value  => 'pay',
#    );
#    $form->hidden(
#        -name   => 'method',
#        -value  => 'do',
#    );
#    $form->hidden(
#        -name   => 'do',
#        -value  => 'editSave',
#    );
#
#    $form->hidden(
#        name  => 'paymentGatewayId',
#        value => $self->getId,
#    );
    
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

    my $self = WebGUI::Shop::PayDriver->_buildObj($session, $class, $paymentGatewayId, $properties->{ label }, $options);

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
    $properties{title} = $fullDefinition->[0]{name} if ($properties{title} eq "" || lc($properties{title}) eq "untitled");
    $self->update(\%properties);
}

#-------------------------------------------------------------------

=head2 processTransaction ( [ paymentAddress ] )

This method is responsible for handling success or failure from the payment processor, completing or denying the transaction, and sending out notification and receipt emails. Returns a WebGUI::Shop::Transaction object.

=head3 paymentAddress

A reference to a WebGUI::Shop::Address object that should be attached as payment information. Not required.

=cut

sub processTransaction {
    my ($self, $paymentAddress) = @_;
    my $cart = $self->getCart;
    my $transaction = WebGUI::Shop::Transaction->create($self->session,{
        paymentMethod   => $self,
        paymentAddress  => $paymentAddress,
        cart            => $cart,
    });
    my ($success, $transactionCode, $statusCode, $statusMessage) = $self->processPayment( $transaction );
    if ($success) {
        $transaction->completePurchase($transactionCode, $statusCode, $statusMessage);
        $cart->onCompletePurchase;
        $self->sendNotifications($transaction);
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

=head2 sendNotifications ( transaction )

Sends out a receipt and a sale notification to the buyer and the store owner respectively.

=cut

sub sendNotifications {
    my ($self, $transaction) = @_;
    my $session = $self->session;
    my $i18n = WebGUI::International->new($session, 'PayDriver');
    my ($style, $url) = $session->quick(qw(style url));
    my %var = (
        %{$transaction->get},
        viewDetailUrl           => $url->page('shop=transaction;method=viewMy;transactionId='.$transaction->getId,1),
        amount                  => sprintf("%.2f", $transaction->get('amount')),
        inShopCreditDeduction   => sprintf("%.2f", $transaction->get('inShopCreditDeduction')),
        taxes                   => sprintf("%.2f", $transaction->get('taxes')),
        shippingPrice           => sprintf("%.2f", $transaction->get('shippingPrice')),
        shippingAddress         => $transaction->formatAddress({
                                        name        => $transaction->get('shippingAddressName'),
                                        address1    => $transaction->get('shippingAddress1'),
                                        address2    => $transaction->get('shippingAddress2'),
                                        address3    => $transaction->get('shippingAddress3'),
                                        city        => $transaction->get('shippingCity'),
                                        state       => $transaction->get('shippingState'),
                                        code        => $transaction->get('shippingCode'),
                                        country     => $transaction->get('shippingCountry'),
                                        phoneNumber => $transaction->get('shippingPhoneNumber'),
                                        }),
        paymentAddress          =>  $transaction->formatAddress({
                                        name        => $transaction->get('paymentAddressName'),
                                        address1    => $transaction->get('paymentAddress1'),
                                        address2    => $transaction->get('paymentAddress2'),
                                        address3    => $transaction->get('paymentAddress3'),
                                        city        => $transaction->get('paymentCity'),
                                        state       => $transaction->get('paymentState'),
                                        code        => $transaction->get('paymentCode'),
                                        country     => $transaction->get('paymentCountry'),
                                        phoneNumber => $transaction->get('paymentPhoneNumber'),
                                        }),
        );
    
    # items
    my @items = ();
    foreach my $item (@{$transaction->getItems}) {
        my $address = '';
        if ($transaction->get('shippingAddressId') ne $item->get('shippingAddressId')) {
            $address = $transaction->formatAddress({
                            name        => $item->get('shippingAddressName'),
                            address1    => $item->get('shippingAddress1'),
                            address2    => $item->get('shippingAddress2'),
                            address3    => $item->get('shippingAddress3'),
                            city        => $item->get('shippingCity'),
                            state       => $item->get('shippingState'),
                            code        => $item->get('shippingCode'),
                            country     => $item->get('shippingCountry'),
                            phoneNumber => $item->get('shippingPhoneNumber'),
                            });
        }
        push @items, {
            %{$item->get},
            viewItemUrl         => $url->page('shop=transaction;method=viewItem;transactionId='.$transaction->getId.';itemId='.$item->getId, 1),
            price               => sprintf("%.2f", $item->get('price')),
            itemShippingAddress => $address,
            orderStatus         => $i18n->get($item->get('orderStatus'),'Shop'),
        };
    }
    $var{items} = \@items;

    # render
    my $template = WebGUI::Asset::Template->new($session, $session->setting->get("receiptEmailTemplateId"));
    my $inbox = WebGUI::Inbox->new($session);

    # purchase receipt
    $inbox->addMessage(
        message     => $template->process(\%var),
        subject     => $i18n->get('receipt subject').' '.$transaction->get('orderNumber'),
        userId      => $transaction->get('userId'),
        status      => 'completed',
        );
    
    # shop owner notification
    $var{viewDetailUrl} = $url->page('shop=transaction;method=view;transactionId='.$transaction->getId,1);
    $inbox->addMessage(
        message     => $template->process(\%var),
        subject     => $i18n->get('a sale has been made').' '.$transaction->get('orderNumber'),
        groupId     => $self->get('saleNotificationGroupId'),
        status      => 'unread',
        );
}

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

    return;
}

#-------------------------------------------------------------------

=head2 paymentGatewayId (  )

Accessor for the unique identifier for this PayDriver.  The paymentGatewayId is 
a GUID.

=cut

#-------------------------------------------------------------------

=head2 www_edit ( )

Generates an edit form.

=cut

sub www_edit {
    my $self    = shift;
    my $session = $self->session;
    my $admin   = WebGUI::Shop::Admin->new($session);
    my $i18n    = WebGUI::International->new($session, "Pay");

    return $session->privilege->insufficient() unless $session->user->isInGroup(3);

    my $form = $self->getEditForm;
    $form->submit;
  
    return $admin->getAdminConsole->render($form->print, $i18n->echo("payment methods"));
}

#-------------------------------------------------------------------

=head2 www_editSave ( )

Saves the data from the post.

=cut

sub www_editSave {
    my $self = shift;
    my $session = $self->session;
    return $session->privilege->insufficient() unless $session->user->isInGroup(3);

    $self->processPropertiesFromFormPost;
    $session->http->setRedirect("/?shop=pay;method=manage");

    return undef;
}


1;
