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

=head2 exportTaxData ( )

Creates a tab deliniated file containing all the information from
the tax table.  Returns a temporary WebGUI::Storage object containing
the file.  The file will be named "siteTaxData.csv".

=cut

sub exportTaxData {
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

=head2 importTaxData ( $filePath )

Import tax information from the specified file in CSV format.  The
first line of the file should contain the name of the columns, in
any order.  The following lines will contain tax information.  Blank
lines and anything following a '#' sign will be ignored.

=cut

sub importTaxData {
    my $self     = shift;
    my $filePath = shift;
    croak q{Must provide the path to a file}
        unless $filePath;
    croak qq{$filePath could not be found}
        unless -e $filePath;
    croak qq{$filePath is not readable}
        unless -r $filePath;
    open my $table, '<', $filePath or
        croak "Unable to open $filePath for reading: $!\n";
    my $headers;
    $headers = <$table>;
    chomp $headers;
    my @headers = WebGUI::Text::splitCSV($headers);
    croak qq{Bad header found in the CSV file}
        unless (join(q{-}, sort @headers) eq 'field-taxRate-value')
           and (scalar @headers == 3);
    my @taxData = ();
    my $line = 1;
    while (my $taxRow = <$table>) {
        chomp $taxRow;
        my @taxRow = WebGUI::Text::splitCSV($taxRow);
        croak qq{Error on line $line in file $filePath}
            unless scalar @taxRow == 3;
        push @taxData, [ @taxRow ];
    }
    ##Okay, if we got this far, then the data looks fine.
    $self->session->db->beginTransaction;
    $self->session->db->write('delete from tax');
    foreach my $taxRow (@taxData) {
        my %taxRow;
        @taxRow{ @headers } = @{ $taxRow }; ##Must correspond 1:1, or else...
        $self->add(\%taxRow);
    }
    $self->session->db->commit;
    return;
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
