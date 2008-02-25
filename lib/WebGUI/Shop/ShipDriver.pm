package WebGUI::Shop::ShipDriver;

use strict;

use Class::InsideOut qw{ :std };
use Carp qw(croak);
use Tie::IxHash;
use WebGUI::International;
use WebGUI::HTMLForm;
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
readonly className => my %className;
readonly shipperId => my %shipperId;
readonly options   => my %options;

#-------------------------------------------------------------------

=head2 _buildObj (  )

Private method used to build objects, shared by new and create.

=cut

sub _buildObj {
    my ($class, $session, $shipperId, $options) = @_;
    my $self    = {};
    bless $self, $class;
    register $self;

    my $id        = id $self;

    $session{ $id }   = $session;
    $shipperId{ $id } = $shipperId;
    $options{ $id }   = $options;
    $className{ $id } = $class;

    return $self;
}


#-------------------------------------------------------------------

=head2 calculate (  )

This method calculates how much it costs to ship the contents of a cart.  This method
MUST be overridden in all child classes.

=cut

sub calculate {
    croak "You must override the calculate method";
}

#-------------------------------------------------------------------

=head2 className (  )

Accessor for the className of the object.  This is the name of the driver that is used
to do calculations.

=cut

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
    my $options = shift;
    croak "You must pass a hashref of options to create a new ShipDriver object"
        unless defined($options) and ref $options eq 'HASH' and scalar keys %{ $options };
    my $shipperId = $session->id->generate;
    my $self = WebGUI::Shop::ShipDriver->_buildObj($session, $shipperId, $options);

    $session->db->write('insert into shipper (shipperId,className) VALUES (?,?)', [$shipperId, $class]);
    $self->set($options);

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
    croak "Definition requires a session object"
        unless ref $session eq 'WebGUI::Session';
    my $definition = shift || [];
    my $i18n = WebGUI::International->new($session, 'ShipDriver');
    tie my %properties, 'Tie::IxHash';
    %properties = (
        name => 'Shipper Driver',
        fields => {
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
        },
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
    $self->session->db->write('delete from shipper');
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
    my $options = $self->options;
    if (defined $param) {
        return $options->{$param};
    }
    else {
        return $options;
    }
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
        name  => 'shipperId',
        value => $self->getId,
    );
    $form->hidden(
        name  => 'className',
        value => $self->className,
    );
    $form->dynamicForm($definition, 'fields', $self);
    return $form;
}

#-------------------------------------------------------------------

=head2 getId ( )

Returns the shipperId.  This is an alias for shipperId provided
since a lot of WebGUI classes have a getId method.

=cut

sub getId {
    return shift->shipperId;
}

#-------------------------------------------------------------------

=head2 getName ( )

Return a human readable name for this driver. Never overridden in the
subclass, instead specified in definition with the name "name".

=cut

sub getName {
    my $self = shift;
    my $definition = WebGUI::Shop::ShipDriver->definition($self->session);
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
    croak "new requires a session object"
        unless ref $session eq 'WebGUI::Session';
    my $shipperId = shift;
    croak "new requires a shipperId"
        unless defined $shipperId;
    my $properties = $session->db->quickHashRef('select * from shipper where shipperId=?',[$shipperId]);
    croak "The requested shipperId does not exist in the db"
        unless scalar keys %{ $properties };
    croak "Somehow, the options property of this object, $shipperId, got broken in the db"
        unless exists $properties->{options} and $properties->{options};
    my $options = from_json($properties->{options});
    my $self = WebGUI::Shop::ShipDriver->_buildObj($session, $shipperId, $options);
    return $self;
}

#-------------------------------------------------------------------

=head2 options (  )

Accessor for the driver properties.  This returns a hashref
any driver specific properties.  To set the properties, use
the C<set> method.

=cut

#-------------------------------------------------------------------

=head2 session (  )

Accessor for the session object.  Returns the session object.

=cut

#-------------------------------------------------------------------

=head2 set ( $options )

Setter for user configurable options in the ship objects.

=head4 $options

A list of properties to assign to this ShipperDriver.  See C<definition> for details.

=cut

sub set {
    my $self    = shift;
    my $options = shift;
    croak "set was not sent a hashref of options to store in the database"
        unless ref($options) eq 'HASH' and scalar keys %{ $options };
    my $jsonOptions = to_json($options);
    $self->session->db->write('update shipper set options=? where shipperId=?', [$jsonOptions, $self->shipperId]);
    return;
}

#-------------------------------------------------------------------

=head2 shipperId (  )

Accessor for the unique identifier for this shipperDriver.  The shipperId is 
a GUID.

=cut

1;
