package WebGUI::Shop::Tax;

use strict;

use Class::InsideOut qw{ :std };
use Carp qw(croak);
use WebGUI::Text;
use WebGUI::Storage;

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

A hash ref of the geographic and rate information.  All parameters are required and
must have defined values.

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
    croak "Must pass in a hashref"
        unless ref($params) eq 'HASH';
    foreach my $key (qw/field value taxRate/) {
        croak "Hash ref must contain a $key key with a defined value"
            unless exists($params->{$key}) and defined $params->{$key};
    }
    $self->session->db->write('insert into tax (taxId, field, value, taxRate) VALUES (?,?,?,?)', [$id, @{ $params }{qw[ field value taxRate ]}]);
    return $id;
}

#-------------------------------------------------------------------

=head2 delete ( [$params] )

Deletes data from the tax table by taxId.

=head3 $params

A hashref containing the taxId of the data to delete from the table.

=head4 taxId

The taxId of the data to delete from the table.

=cut

sub delete {
    my $self   = shift;
    my $params = shift;
    croak "Must pass in a hashref"
        unless ref($params) eq 'HASH';
    croak "Hash ref must contain a taxId key with a defined value"
        unless exists($params->{taxId}) and defined $params->{taxId};
    $self->session->db->write('delete from tax where taxId=?', [$params->{taxId}]);
    return;
}

#-------------------------------------------------------------------

=head2 export ( )

Creates a tab deliniated file containing all the information from
the tax table.  Returns a temporary WebGUI::Storage object containing
the file.  The file will be named "siteTaxData.csv".

=cut

sub export {
    my $self = shift;
    my $taxIterator = $self->getItems;
    my @columns = qw{ field value taxRate };
    my $taxData = WebGUI::Text::joinCSV(@columns) . "\n";
    while (my $taxRow = $taxIterator->hashRef() ) {
        my @taxData = @{ $taxRow }{@columns};
        $taxData .= WebGUI::Text::joinCSV(@taxData) . "\n";
    }
    my $storage = WebGUI::Storage->createTemp($self->session);
    $storage->addFileFromScalar('siteTaxData.csv', $taxData);
    return $storage;
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
