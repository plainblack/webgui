package WebGUI::Shop::ShipDriver;

use strict;

use Carp qw(croak);
use Tie::IxHash;
use WebGUI::International;
use WebGUI::HTMLForm;
use WebGUI::Exception::Shop;
use JSON;

use Moose;
use WebGUI::Definition::Shop;

=head1 NAME

Package WebGUI::Shop::ShipDriver

=head1 DESCRIPTION

This package is the base class for all modules which calculate shipping
costs.

=head1 SYNOPSIS

 use WebGUI::Shop::ShipDriver;

 my $tax = WebGUI::Shop::ShipDriver->new($session);

=head1 METHODS

These subroutines are available from this package:

=cut

define tableName  => 'shipper';
define pluginName => ['Shipping Driver', 'ShipDriver'];

property label => (
            fieldType       => 'text',
            label           => ['label', 'ShipDriver'],
            hoverHelp       => ['label help', 'ShipDriver'],
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
            label           => ['enabled', 'ShipDriver'],
            hoverHelp       => ['enabled help', 'ShipDriver'],
            default         => 1,
         );
property groupToUse => (
            fieldType       => 'group',
            label           => ['who can use', 'ShipDriver'],
            hoverHelp       => ['who can use help', 'ShipDriver'],
            default         => 7,
         );

has [ qw/session shipperId/ ] => (
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
        $options->{session}   = $session;
        $options->{shipperId} = $session->id->generate;
        return $class->$orig($options);
    }
    ##Must be a paymentGatewayId, look it up in the database
    my $shipperId = shift;
    WebGUI::Error::InvalidParam->throw(error => q{Must provide a shipperId})
        unless defined $shipperId;
    my $properties = $session->db->quickHashRef('select * from shipper where shipperId=?', [
        $shipperId,
    ]);
    WebGUI::Error::ObjectNotFound->throw(error => q{shipperId not found in db}, id => $shipperId)
        unless scalar keys %{ $properties };

    croak "Somehow, the options property of this object, $shipperId, got broken in the db"
        unless exists $properties->{options} and $properties->{options};

    my $options = from_json($properties->{options});
    $options->{session}   = $session;
    $options->{shipperId} = $shipperId;
    return $class->$orig($options);
};

#-------------------------------------------------------------------

=head2 calculate (  )

This method calculates how much it costs to ship the contents of a cart.  This method
MUST be overridden in all child classes.

=cut

sub calculate {
    croak "You must override the calculate method";
}

#-------------------------------------------------------------------

=head2 canUse ( user )

Checks to see if the user can use this Payment Driver.

=head3 user

A hashref containing user information.  The user referenced will be checked
to see if they can use the Shipping Driver.  If missing, then $session->user
will be used.

=head4 userId

A userId used to build a user object.

=head4 user

A user object that will be used directly.

=cut

sub canUse {
    my $self = shift;
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

Removes this ShipDriver object from the db.

=cut

sub delete {
    my $self = shift;
    $self->session->db->write('delete from shipper where shipperId=?', [$self->getId]);
    return;
}

#-------------------------------------------------------------------

=head2 getEditForm ( )

Returns the configuration form for the options of this plugin.

=cut

sub getEditForm {
    my $self = shift;
    
    my $form = WebGUI::HTMLForm->new($self->session);
    $form->submit;
    
    $form->hidden(name  => 'shop',value => "ship");
    $form->hidden(name  => 'method',value => "do");
    $form->hidden(name  => 'do',value => "editSave");
    $form->hidden(
        name  => 'className',
        value => $self->className,
    );
    $form->hidden(
        name  => 'driverId',
        value => $self->getId,
    );
    tie my %form_options, 'Tie::IxHash';
    foreach my $property_name ($self->getProperties) {
        my $property = $self->meta->find_attribute_by_name($property_name);
        $form_options{$property_name} = {
            value => $self->$property_name,
            %{ $self->getFormProperties($property_name)},
        };
    }
    my $definition = [ { properties => \%form_options }, ];
    $form->dynamicForm($definition, 'properties', $self);

    return $form;
}

#-------------------------------------------------------------------

=head2 getId ( )

Returns the shipperId.  This is an alias for shipperId provided
since a lot of WebGUI classes have a getId method.

=cut

sub getId {
	my $self = shift;
    return $self->shipperId;
}

#-------------------------------------------------------------------

=head2 getName ( $session )

Return a human readable name for this driver. Never overridden in the
subclass, instead specified in definition with the name "name".

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

=head2 session (  )

Accessor for the session object.  Returns the session object.

=cut

#-------------------------------------------------------------------

=head2 write ( $options )

Setter for user configurable options in the payment objects.

=cut

sub write {
    my $self        = shift;

    my $properties  = $self->get();
    delete $properties->{session};
    delete $properties->{shipperId};
    my $jsonOptions = to_json($properties);
    $self->session->db->setRow($self->tableName, 'shipperId', {
        shipperId => $self->shipperId,
        className => $self->className,
        options   => $jsonOptions,
    });
    return;
}


#-------------------------------------------------------------------

=head2 www_edit ( )

Generates an edit form.

=cut

sub www_edit {
    my $self = shift;
    my $session = $self->session;
    return $session->privilege->insufficient() unless $session->user->isAdmin;
    my $admin = WebGUI::Shop::Admin->new($session);
    my $i18n = WebGUI::International->new($session, "Shop");
    my $form = $self->getEditForm;
    $form->submit;
    return $admin->getAdminConsole->render($form->print, $i18n->get("shipping methods"));
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
    $session->http->setRedirect($session->url->page('shop=ship;method=manage'));
    return undef;
}

1;
