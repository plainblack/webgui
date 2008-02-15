package WebGUI::Shop::Tax;

use strict;

use Class::InsideOut qw{ :std };

=head1 NAME

Package WebGUI::Shop::Tax

=head1 DESCRIPTION

This package manages tax information, and calculates taxes on a shopping cart.  It isn't a classic object
in that the only data it contains is a WebGUI::Session object, but it does provide several methods for
handling the information in the tax tables.

=head1 SYNOPSIS

 use WebGUI::Shop::Tax;

 my $tax = WebGUI::Shop::Tax->new($session);

=head1 METHODS

These subroutines are available from this package:

=cut

readonly session => my %session;

#-------------------------------------------------------------------

=head2 add ( [$params] )

Add tax information to the table.  Returns the taxId of the newly created tax information.  

=head3 $params

A hash ref of the geographic and rate information.  All parameters are required.

=head4 field

field denotes what kind of location the tax information is for.  This should
be country, state, or code.  The combination of field and value is unique
in the database.

=head4 value

value is the value of the field to be added.  For example, appropriate values
for a field of country might be China, United States, Mexico.  If the field
is state, it could be British Colombia, Oregon or Maine.

=head4 taxRate

This is the tax rate for the location, as specified by field and value.  The tax rate is stored
as a percentage, like 5.5 .

=cut

sub add {
    my $self   = shift;
    my $params = shift;
    my $id = $self->session->id->generate();
    $self->session->db->write('insert into tax (taxId, field, value, taxRate) VALUES (?,?,?,?)', [$id, @{ $params }{qw[ field value taxRate ]}]);
    return $id;
}

#-------------------------------------------------------------------

=head2 getItems ( )

Returns a WebGUI::SQL::Result object for accessing all of the data in the tax table.  This
is a convenience method for listing and/or exporting tax data.

=cut

sub getItems {
    my $self = shift;
    my $result = $self->session->db->read('select * from tax');
    return $result;
}

#-------------------------------------------------------------------

=head2 new ( $session )

Constructor for the WebGUI::Shop::Tax.  Returns a WebGUI::Shop::Tax object.

=cut

sub new {
    my $class   = shift;
    my $session = shift;
    my $self    = {};
    bless $self, $class;
    register $self;
    $session{ id $self } = $session;
    return $self;
}

#-------------------------------------------------------------------

=head2 session (  )

Accessor for the session object.  Returns the session object.

=cut

1;
