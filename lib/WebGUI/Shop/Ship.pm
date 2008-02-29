package WebGUI::Shop::Ship;

use strict;

use Carp qw(croak);
use WebGUI::International;
use WebGUI::Shop::ShipDriver;
use WebGUI::Pluggable;
use WebGUI::Utility;
use WebGUI::Exception;

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

=head2 create ( $session, $class, $options )

The interface method for creating new, configured instances of ShipDriver.  If the ShipperDriver throws an exception,  it is propagated
back up to the top.

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
    WebGUI::Error::InvalidParam->throw(error => q{Must provide a session variable})
        unless ref $session eq 'WebGUI::Session';
    my $requestedClass = shift;
    WebGUI::Error::InvalidParam->throw(error => q{Must provide a class to create an object})
        unless defined $requestedClass;
    WebGUI::Error::InvalidParam->throw(error => q{The requested class is not enabled in your WebGUI configuration file}, param => $requestedClass)
        unless isIn($requestedClass, @{ WebGUI::Shop::Ship->getDrivers($session) } );
    my $options = shift;
    WebGUI::Error::InvalidParam->throw(error => q{You must pass a hashref of options to create a new ShipDriver object})
        unless defined($options) and ref $options eq 'HASH' and scalar keys %{ $options };
    my $driver = eval { WebGUI::Pluggable::instanciate($requestedClass, 'create', [ $session, $options ]) };
    return $driver;
}

#-------------------------------------------------------------------

=head2 getDrivers ( $session )

This subroutine returns an arrayref of available shipping driver classes
from the WebGUI config file.

=head3 $session

A WebGUI::Session object.  A WebGUI::Error::InvalidParam exception will be thrown if it doesn't get one.

=cut

sub getDrivers {
    my $class      = shift;
    my $session    = shift;
    WebGUI::Error::InvalidParam->throw(error => q{Must provide a session variable})
        unless ref $session eq 'WebGUI::Session';
    return $session->config->get('shippingDrivers');
}

#-------------------------------------------------------------------

=head2 getOptions ( $session, $cart )

Returns a list of options for the user to ship, along with the cost of using each one.  It is a hash of hashrefs,
with the key of the primary hash being the shipperId of the driver, and sub keys of label and price.

=head3 $session

A WebGUI::Session object.  A WebGUI::Error::InvalidParam exception will be thrown if it doesn't get one.

=head3

=cut

sub getOptions {
    my $class      = shift;
    my $session    = shift;
    croak "Definition requires a session object"
        unless ref $session eq 'WebGUI::Session';
}

#-------------------------------------------------------------------

=head2 getShippers ( $session )

Returns an array ref of all shipping objects in the db.

=head3 $session

A WebGUI::Session object.  A WebGUI::Error::InvalidParam exception will be thrown if it doesn't get one.

=head3

=cut

sub getShippers {
    my $class      = shift;
    my $session    = shift;
    WebGUI::Error::InvalidParam->throw(error => q{Must provide a session variable})
        unless ref $session eq 'WebGUI::Session';
    my $drivers;
    my $sth = $session->db->prepare('select shipperId from shipper');
    $sth->execute();
    while (my $driver = $sth->hashRef()) {
        push @{ $drivers }, WebGUI::Shop::Ship->new($session, $driver->{shipperId});
    }
    $sth->finish;
    return $drivers;
}

#-------------------------------------------------------------------

=head2 new ( $session, $shipperId )

Looks up an existing ShipperDriver in the db by shipperId and returns
that object.  If the ShipperDriver throws an exception,  it is propagated
back up to the top.

=head3 $session

A WebGUI::Session object.

=head3 $shipperId

The ID of a shipper to look up and instanciate.

=cut

sub new {
    my $class     = shift;
    my $session   = shift;
    WebGUI::Error::InvalidParam->throw(error => q{Must provide a session variable})
        unless ref $session eq 'WebGUI::Session';
    my $shipperId = shift;
    WebGUI::Error::InvalidParam->throw(error => q{Must provide a shipperId})
        unless defined $shipperId;
    my $requestedClass = $session->db->quickScalar('select className from shipper where shipperId=?',[$shipperId]);
    WebGUI::Error::ObjectNotFound->throw(error => q{shipperId not found in db}, id => $shipperId)
        unless $requestedClass;
    my $driver = eval { WebGUI::Pluggable::instanciate($requestedClass, 'new', [ $session, $shipperId ]) };
    return $driver;
}

1;
