package WebGUI::Shop::ShipDriver;

use strict;

use Class::InsideOut qw{ :std };
use Carp qw(croak);
use Tie::IxHash;
use WebGUI::International;
use WebGUI::HTMLForm;
use WebGUI::Exception::Shop;
use JSON;

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

readonly session   => my %session;
private  options   => my %options;
private  shipperId => my %shipperId;

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
    return $userObject->isInGroup($self->get('groupToUse'));
}

#-------------------------------------------------------------------

=head2 create ( $session, $options )

Constructor for new WebGUI::Shop::ShipperDriver objects.  Returns a WebGUI::Shop::ShipperDriver object.
To access driver objects that have already been configured, use C<new>.

=head3 $session

A WebGUI::Session object.

=head4 $options

A list of properties to assign to this ShipperDriver.  See C<definition> for details.

=cut

sub create {
    my $class   = shift;
    my $session = shift;
    WebGUI::Error::InvalidParam->throw(error => q{Must provide a session variable})
        unless ref $session eq 'WebGUI::Session';
    my $options = shift;
    WebGUI::Error::InvalidParam->throw(error => q{Must provide a hashref of options})
        unless ref $options eq 'HASH' and scalar keys %{ $options };
    my $shipperId = $session->id->generate;
    $session->db->write('insert into shipper (shipperId,className) VALUES (?,?)', [$shipperId, $class]);
    my $self = $class->new($session, $shipperId);
    $self->update($options);
    return $self;
}

#-------------------------------------------------------------------

=head2 definition ( $session )

This subroutine returns an arrayref of hashrefs, used to validate data put into
the object by the user, and to automatically generate the edit form to show
the user.

The optional hash key noFormProcess may be added to any field definition.
This will prevent that field from being processed by processPropertiesFromFormPost.

=cut

sub definition {
    my $class      = shift;
    my $session    = shift;
    WebGUI::Error::InvalidParam->throw(error => q{Must provide a session variable})
        unless ref $session eq 'WebGUI::Session';
    my $definition = shift || [];
    my $i18n = WebGUI::International->new($session, 'ShipDriver');
    tie my %fields, 'Tie::IxHash';
    %fields = (
        label => {
            fieldType    => 'text',
            label        => $i18n->get('label'),
            hoverHelp    => $i18n->get('label help'),
            defaultValue => undef,
        },
        enabled => {
            fieldType    => 'yesNo',
            label        => $i18n->get('enabled'),
            hoverHelp    => $i18n->get('enabled help'),
            defaultValue => 1,
        },
        groupToUse      => {
            fieldType       => 'group',
            label           => $i18n->get('who can use'),
            hoverHelp       => $i18n->get('who can use help'),
            defaultValue    => 7,
        },
    );
    my %properties = (
        name        => 'Shipper Driver',
        properties  => \%fields,
    );
    push @{ $definition }, \%properties;
    return $definition;
}

#-------------------------------------------------------------------

=head2 delete ( )

Removes this ShipDriver object from the db.

=cut

sub delete {
    my $self = shift;
    $self->session->db->write('delete from shipper where shipperId=?',[$self->getId]);
    return;
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
	my $opts = $options{id $self};
    if ($opts eq "") {
        $opts = {};
    }
    else {
        $opts = JSON::from_json($opts);
    }
    if (defined $param) {
        return $opts->{$param};
    }
	my %copy = %{$opts};
	return \%copy;
}

#-------------------------------------------------------------------

=head2 getEditForm ( )

Dynamically generate an HTMLForm based on the contents
of the definition sub, and return the form.

=cut

sub getEditForm {
    my $self  = shift;
    my $definition = $self->definition($self->session);
    my $form = WebGUI::HTMLForm->new($self->session);
    $form->submit;
    $form->hidden(
        name  => 'driverId',
        value => $self->getId,
    );
    $form->hidden(name  => 'shop',value => "ship");
    $form->hidden(name  => 'method',value => "do");
    $form->hidden(name  => 'do',value => "editSave");
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
    return $shipperId{id $self};
}

#-------------------------------------------------------------------

=head2 getName ( $session )

Return a human readable name for this driver. Never overridden in the
subclass, instead specified in definition with the name "name".

This is a class method.

=cut

sub getName {
    my ($class, $session) = @_;
    my $definition = $class->definition($session);
    return $definition->[0]->{name};
}

#-------------------------------------------------------------------

=head2 new ( $session, $shipperId )

Looks up an existing ShipperDriver in the db by shipperId and returns
that object.

=cut

sub new {
    my $class     = shift;
    my $session   = shift;
    WebGUI::Error::InvalidParam->throw(error => q{Must provide a session variable})
        unless ref $session eq 'WebGUI::Session';
    my $shipperId = shift;
    WebGUI::Error::InvalidParam->throw(error => q{Must provide a shipperId})
        unless defined $shipperId;
    my $properties = $session->db->quickHashRef('select * from shipper where shipperId=?',[$shipperId]);
    WebGUI::Error::ObjectNotFound->throw(error => q{shipperId not found in db}, id => $shipperId)
        unless scalar keys %{ $properties };
    my $self = register $class;
    my $id        = id $self;
    $session{ $id }   = $session;
    $options{ $id }   = $properties->{options};
    $shipperId{ $id }   = $shipperId;
    return $self;
}


#-------------------------------------------------------------------

=head2 processPropertiesFromFormPost ( )

Updates ship driver with data from Form.

=cut

sub processPropertiesFromFormPost {
    my $self    = shift;
    my $session = $self->session;
    my $form    = $session->form;
    my %properties;
    my $fullDefinition = $self->definition($session);
    foreach my $definition (@{$fullDefinition}) {
        PROPERTY: foreach my $property (keys %{$definition->{properties}}) {
            next PROPERTY if $definition->{properties}{$property}->{noFormProcess};
            $properties{$property} = $form->process(
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

=head2 session (  )

Accessor for the session object.  Returns the session object.

=cut

#-------------------------------------------------------------------

=head2 update ( $options )

Setter for user configurable options in the ship objects.  It does not support updating subsets
of the options.  If a currently set option is missing from the set of passed in options, it will be lost.

=head4 $options

A list of properties to assign to this ShipperDriver.  See C<definition> for details.  The options are
flattened into JSON and stored in the database as text.  There is no content checking performed.

=cut

sub update {
    my $self    = shift;
    my $options = shift || {};
    WebGUI::Error::InvalidParam->throw(error => 'update was not sent a hashref of options to store in the database')
        unless ref $options eq 'HASH' and scalar keys %{ $options };
    my $jsonOptions = JSON::to_json($options);
    $options{id $self} = $jsonOptions;
    $self->session->db->write('update shipper set options=? where shipperId=?', [$jsonOptions, $self->getId]);
    return undef;
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
