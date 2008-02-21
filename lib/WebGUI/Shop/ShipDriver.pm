package WebGUI::Shop::ShipDriver;

use strict;

use Class::InsideOut qw{ :std };
use Carp qw(croak);
use Tie::IxHash;
use WebGUI::International;

=head1 NAME

Package WebGUI::Shop::ShipDriver

=head1 DESCRIPTION

This package manages tax information, and calculates taxes on a shopping cart.  It isn't a classic object
in that the only data it contains is a WebGUI::Session object, but it does provide several methods for
handling the information in the tax tables.

=head1 SYNOPSIS

 use WebGUI::Shop::ShipDriver;

 my $tax = WebGUI::Shop::ShipDriver->new($session);

=head1 METHODS

These subroutines are available from this package:

=cut

readonly session   => my %session;
readonly className => my %className;
readonly shipperId => my %shipperId;
readonly label     => my %label;
readonly options   => my %options;

#-------------------------------------------------------------------

=head2 className (  )

Accessor for the className of the object.  This is the name of the driver that is used
to do calculations.

=cut

#-------------------------------------------------------------------

=head2 create ( $session, $properties )

Constructor for new WebGUI::Shop::ShipperDriver objects.  Returns a WebGUI::Shop::ShipperDriver object.
To access driver objects that have already been configured, use C<new>.

=head3 $session

A WebGUI::Session object.

=head4 $properties

A list of properties to assign to this ShipperDriver.  See C<definition> for details.

=cut

sub create {
    my $class   = shift;
    my $session = shift;
    my $self    = {};
    bless $self, $class;
    register $self;
    $session{ id $self } = $session;
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

=head2 label (  )

Accessor for the label property.  This is the name assigned to this
driver, something like "Slow and dangerous".

=cut

#-------------------------------------------------------------------

=head2 options (  )

Accessor for the driver properties.  This returns a JSON string of
any driver specific properties.  Driver properties have a

=cut

#-------------------------------------------------------------------

=head2 session (  )

Accessor for the session object.  Returns the session object.

=cut

#-------------------------------------------------------------------

=head2 shipperId (  )

Accessor for the unique identifier for this shipperDriver.  The shipperId is 
a GUID.

=cut

1;
