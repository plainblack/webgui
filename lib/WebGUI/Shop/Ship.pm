package WebGUI::Shop::Ship;

use strict;

use Carp qw(croak);
use WebGUI::International;
use WebGUI::Shop::ShipDriver;
use WebGUI::Pluggable;
use WebGUI::Utility;

=head1 NAME

Package WebGUI::Shop::Ship

=head1 DESCRIPTION

This is the master class to manage ship drivers.

=head1 SYNOPSIS

 use WebGUI::Shop::Ship;

=head1 METHODS

These subroutines are available from this package:

=cut

#-------------------------------------------------------------------

=head2 _loadDriver (  )

The method used to safely load the Shipping drivers.

=cut

sub _loadDriver {
}

#-------------------------------------------------------------------

=head2 create ( $session, $class, $options )

The interface method for creating new, configured instances of ShipDriver.

=head3 $session

A WebGUI::Session object.

=head4 $class

The class of the new ShipDriver object to create.

=head4 $options

A list of properties to assign to this ShipperDriver.  See C<definition> for details.

=cut

sub create {
    my $class   = shift;
    my $session = shift;
    croak "create requires a session object"
        unless ref $session eq 'WebGUI::Session';
    my $requestedClass = shift;
    croak "create requires the name of a class to create an object"
        unless defined $requestedClass;
    croak "The requested class $class is not enabled in your WebGUI configuration file"
        unless isIn($requestedClass, @{ WebGUI::Shop::Ship->getDrivers($session) } );
    my $options = shift;
    croak "You must pass a hashref of options to create a new ShipDriver object"
        unless defined($options) and ref $options eq 'HASH' and scalar keys %{ $options };

}

#-------------------------------------------------------------------

=head2 getDrivers ( $session )

This subroutine returns an arrayref of available shipping driver classes
from the WebGUI config file.

=head3 $session

A WebGUI::Session object.

=cut

sub getDrivers {
    my $class      = shift;
    my $session    = shift;
    croak "getDrivers requires a session object"
        unless ref $session eq 'WebGUI::Session';
    return $session->config->get('shippingDrivers');
}

#-------------------------------------------------------------------

=head2 getOptions ( $session, $cart )

Returns a list of options for the user to ship, along with the cost of using each one.  It is a hash of hashrefs,
with the key of the primary hash being the shipperId of the driver, and sub keys of label and price.

=head3 $session

A WebGUI::Session object.

=head3

=cut

sub getOptions {
    my $class      = shift;
    my $session    = shift;
    croak "Definition requires a session object"
        unless ref $session eq 'WebGUI::Session';
}

#-------------------------------------------------------------------

=head2 new ( $session, $shipperId )

Looks up an existing ShipperDriver in the db by shipperId and returns
that object.

=head3 $session

A WebGUI::Session object.

=head3 $shipperId

The ID of a shipper to look up and instanciate.

=cut

sub new {
    my $class     = shift;
    my $session   = shift;
    croak "new requires a session object"
        unless ref $session eq 'WebGUI::Session';
    my $shipperId = shift;
    croak "new requires a shipperId"
        unless defined $shipperId;
}

1;
