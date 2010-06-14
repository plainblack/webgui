package WebGUI::SQL::ResultSet;

=head1 LEGAL

 -------------------------------------------------------------------
  WebGUI is Copyright 2001-2009 Plain Black Corporation.
 -------------------------------------------------------------------
  Please read the legal notices (docs/legal.txt) and the license
  (docs/license.txt) that came with this distribution before using
  this software.
 -------------------------------------------------------------------
  http://www.plainblack.com                     info@plainblack.com
 -------------------------------------------------------------------

=cut

use strict;

=head1 NAME

Package WebGUI::SQL::ResultSet

=head1 DESCRIPTION

This class provides methods for working with SQL result sets. If you're used to working with Perl DBI, then the object returned here is similar to a statement handler.

=head1 SYNOPSIS

 my $result = WebGUI::SQL::ResultSet->prepare($query, $db);

 $result->execute([ @values ]);

 @arr = $result->array;
 @arr = $result->getColumnNames;
 %hash = $result->hash;
 $hashRef = $result->hashRef;
 $num = $result->rows;
 $result->finish;

=head1 METHODS

These methods are available from this package:

=cut

#-------------------------------------------------------------------

=head2 prepare ( sql, db ) 

Constructor. Returns a result set statement handler.

=head3 sql

An SQL statement. Can use the "?" placeholder for maximum performance on multiple statements with the execute method.

=head3 db

A WebGUI::SQL database handler.

=cut

sub prepare {
    my $class = shift;
    my $sql = shift;
    my $db = shift;
    return $db->prepare($sql);
}

#-------------------------------------------------------------------

=head2 read ( sql, db, placeholders )

Constructor. Returns a result set statement handler after doing a prepare and execute on
the supplied SQL query and the placeholders.

=head3 sql

An SQL query. Can use the "?" placeholder for maximum performance on multiple statements with the execute method.

=head3 db

A WebGUI::SQL database handler.

=head3 placeholders

An array reference containing a list of values to be used in the placeholders defined in the SQL statement.

=cut

sub read {
    my $class = shift;
    my $sql = shift;
    my $db = shift;
    my $placeholders = shift;
    return $db->read($sql, $placeholders);
}

#-------------------------------------------------------------------

=head2 unconditionalRead ( sql, db, placeholders )

Constructor. This is the same as the read method, except that it doesn't throw a fatal error if the query fails.

=head3 sql

An SQL query.

=head3 db

A WebGUI::SQL database handler.

=head3 placeholders

An array reference containing a list of values to be used in the placeholders defined in the SQL statement.

=cut

sub unconditionalRead {
    my $class = shift;
    my $sql = shift;
    my $db = shift;
    my $placeholders = shift;
    return $db->unconditionalRead($sql, $placeholders);
}

package WebGUI::SQL::st;

our @ISA = qw(DBI::st);

#-------------------------------------------------------------------

=head2 array ( )

Returns the next row of data as an array.

=cut

sub array {
    my $self = shift;
    return $self->fetchrow_array;
}

#-------------------------------------------------------------------

=head2 arrayRef ( )

Returns the next row of data as an array reference. Note that this is 12% faster than array().

=cut

sub arrayRef {
    my $self = shift;
    return $self->fetchrow_arrayref;
}


#-------------------------------------------------------------------

=head2 db ( )

A reference to the current WebGUI::SQL object.

=cut

sub db {
    my $self = shift;
    return $self->{Database};
}

#-------------------------------------------------------------------

=head2 errorCode {

Returns an error code for the current handler.

=cut

sub errorCode {
    my $self = shift;
    return $self->err;
}


#-------------------------------------------------------------------

=head2 errorMessage {

Returns a text error message for the current handler.

=cut

sub errorMessage {
    my $self = shift;
    return $self->errstr;
}

#-------------------------------------------------------------------

=head2 execute ( [ placeholders ] )

Executes a prepared SQL statement.  For SELECT queries, returns a true value on success.  For
other queries, returns the number of rows effected.  Return value will always evaluate as true
even if zero rows were effected.

=head3 placeholders

An array reference containing a list of values to be used in the placeholders defined in the SQL statement.

=cut

sub execute {
    my $self = shift;
    my $placeholders =
        ( @_ == 1 && ref $_[0] eq 'ARRAY' ) ? $_[0]
                                            : \@_;
    return $self->SUPER::execute(@$placeholders);
}

#-------------------------------------------------------------------

=head2 getColumnNames 

Returns an array of column names. Use with a "read" method.

=cut

sub getColumnNames {
    my $self = shift;
    return @{ $self->{NAME} }
        if (ref $self->{NAME} eq 'ARRAY');
    return;
}


#-------------------------------------------------------------------

=head2 hash ( )

Returns the next row of data in the form of a hash. 

=cut

sub hash {
    my $self = shift;
    my $hashRef = $self->fetchrow_hashref || {};
    return %$hashRef;
}


#-------------------------------------------------------------------

=head2 hashRef ( )

Returns the next row of data in the form of a hash reference. 

=cut

sub hashRef {
    my $self = shift;
    return $self->fetchrow_hashref;
}

#-------------------------------------------------------------------

=head2 sth ( )

Returns the working DBI statement handler for this result set.

=cut

sub sth {
    my $self = shift;
    return $self;
}

1;

