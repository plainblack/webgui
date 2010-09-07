package WebGUI::SQL;

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
use DBI ();
use Tie::IxHash ();
use Text::CSV_XS ();
use WebGUI::SQL::ResultSet ();
use WebGUI::Exception;
use Scalar::Util ();
use Try::Tiny;
use namespace::clean;
use Scalar::Util qw( weaken );

=head1 NAME

Package WebGUI::SQL

=head1 DESCRIPTION

Package for interfacing with SQL databases. This package implements Perl DBI functionality in a less code-intensive manner and adds some extra functionality.

=head1 SYNOPSIS

 use WebGUI::SQL;

 $db = WebGUI::SQL->connect($session,$dsn, $user, $pass);
 $db->disconnect;
 
 $sth = $db->prepare($sql);
 $sth = $db->read($sql);
 $sth = $db->unconditionalRead($sql);

 $db->write($sql);

 $db->beginTransaction;
 $db->commit;
 $db->rollback;

 @arr      = $db->buildArray($sql);
 $arrayRef = $db->buildArrayRef($sql);
 %hash     = $db->buildHash($sql);
 $hashRef  = $db->buildHashRef($sql);
 @arr      = $db->quickArray($sql);
 $scalar   = $db->quickScalar($sql);
 $text     = $db->quickCSV($sql);
 %hash     = $db->quickHash($sql);
 $hashRef  = $db->quickHashRef($sql);
 $text     = $db->quickTab($sql);

 $id     = $db->getNextId("someId");
 $string = $db->quote($string);
 $string = $db->quoteAndJoin(\@array);

=head1 METHODS

These methods are available from this package:

=cut

our @ISA = qw(DBI);

#-------------------------------------------------------------------

=head2 connect ( session, dsn, user, pass )

Constructor. Connects to the database using DBI.

=head2 session

A reference to the active WebGUI::Session object.

=head2 dsn

The Database Service Name of the database  you wish to connect to. It looks like 'DBI:mysql:dbname;host=localhost'.

=head2 user

The username to use to connect to the database defined by dsn.

=head2 pass

The password to use to connect to the database defined by dsn.

=cut

sub connect {
    my $class   = shift;
    my $session;
    my $dsn;
    my $user;
    my $pass;
    if (ref $_[0] && $_[0]->isa('WebGUI::Session')) {
        $session = shift;
    }
    if (ref $_[0] && $_[0]->isa('WebGUI::Config')) {
        my $config = shift;
        $dsn = $config->get('dsn');
        $user = $config->get('dbuser');
        $pass = $config->get('dbpass');
    }
    else {
        $dsn = shift;
        $user = shift;
        $pass = shift;
    }
    my $params = shift;

    if (! $params) {
        $params = {};
    }
    if (ref $params) {
        $params = { %$params };
    }
    else {
        my @params = map { split /=/, $_, 2 } split /\n/, $params;
        for (@params) {
            s/\s+$//;
            s/^\s+//;
        }
        $params = { @params };
    }
    $params->{RaiseError} = 0;
    $params->{PrintError} = 0;
    $params->{AutoCommit} = 1;
    $params->{ShowErrorStatement} = 1;
    $params->{HandleError} = sub {
        WebGUI::Error::Database->throw(shift);
    };
    if ( ($class->parse_dsn($dsn))[1] eq 'mysql' ) {
        $params->{mysql_enable_utf8} = 1;
    }

    my $dbh = $class->SUPER::connect($dsn, $user, $pass, $params);
    unless (defined $dbh) {
        die "Couldn't connect to database: $dsn : $DBI::errstr";
    }
    if ($session) {
        $dbh->session($session);
    }

    return $dbh;
}


package WebGUI::SQL::db;
use Try::Tiny;
our @ISA = qw(DBI::db);

#-------------------------------------------------------------------

=head2 beginTransaction ( )

Starts a transaction sequence. To be used with commit and rollback. Any writes after this point will not be applied to the database until commit is called.

=cut

sub beginTransaction {
    my $self = shift;
    $self->begin_work;
}


#-------------------------------------------------------------------

=head2 buildArray ( sql, params )

Builds an array of data from a series of rows.

=head3 sql

An SQL query. The query must select only one column of data.

=head3 params

An array reference containing values for any placeholder params used in the SQL query.

=cut

sub buildArray {
    my $self = shift;
    my $arrayRef = $self->buildArrayRef(@_);
    return @{ $arrayRef };
}

#-------------------------------------------------------------------

=head2 buildArrayRef ( sql, params )

Builds an array reference of data from a series of rows.

=head3 sql

An SQL query. The query must select only one column of data.

=head3 params

An array reference containing values for any placeholder params used in the SQL query.

=cut

sub buildArrayRef {
    my $self = shift;
    my $sql = shift;
    my $params = shift;
    my $array = $self->selectall_arrayref($sql, { Slice => [0] }, @$params);
    for (@$array) {
        $_ = $_->[0];
    }

    return $array;
}


#-------------------------------------------------------------------

=head2 buildHash ( sql, params, options )

Builds a hash of data from a series of rows.

=head3 sql

An SQL query. The query should select at least two columns of data, the first being the key for the hash, the second being the value. If the query selects more than two columns, then the last column will be the value and the remaining columns will be joined together by a colon ":" to form a complex key. If the query selects only one column, then the key and value will be the same.

=head3 params

An array reference containing values for any placeholder params used in the SQL query.

=head3 options

A hash reference of options

=head4 noOrder

By default, buildHash returns the result tied to Tie::IxHash to maintain
order.  Setting this option will prevent the tie, so the result will be a
straight hash that is faster but does not maintain order.

=cut

sub buildHash {
    my $self = shift;
    my $hashRef = $self->buildHashRef(@_);
    return %{ $hashRef };
}


#-------------------------------------------------------------------

=head2 buildHashRef ( sql, params, options )

Builds a hash reference of data from a series of rows.

=head3 sql

An SQL query. The query should select at least two columns of data, the first being the key for the hash, the second being the value. If the query selects more than two columns, then the last column will be the value and the remaining columns will be joined together by a colon ":" to form a complex key. If the query selects only one column, then the key and the value will be the same.

=head3 params

An array reference containing values for any placeholder params used in the SQL query.

=head3 options

A hash reference of options

=head4 noOrder

By default, buildHashRef returns the result tied to Tie::IxHash to maintain
order.  Setting this option will prevent the tie, so the result will be a
straight hash that is faster but does not maintain order.

=cut

sub buildHashRef {
    my $self = shift;
    my $sql = shift;
    my $params = shift;
    my $options = shift || {};
    my %hash;
    unless ($options->{noOrder}) {
        tie %hash, 'Tie::IxHash';
    }
    my $results = $self->selectall_arrayref($sql, {}, @$params);
    my $width = @{$results} && @{$results->[0]};
    %hash
        = $width == 2 ? map { @$_ } @{ $results }
        # for single column, use it for both key and value
        : $width == 1 ? map { ($_->[0]) x 2 } @{ $results }
        : $width == 0 ? ()
        : map {
            # for more than 2 columns, use all but last joined with colons for key
            join( q{:}, @{$_}[ 0 .. ($#{$_} - 1) ] ),
            # and last column as value
            $_->[-1]
        } @{ $results };
    return \%hash;
}


#-------------------------------------------------------------------

=head2 buildArrayRefOfHashRefs ( sql )

Builds an array reference of hash references of data from a series of rows.
Useful for returning many rows at once.  Each element of the returned array
reference is a hash of column names to column values.

=head3 sql

An SQL query. 

=head3 params

An array reference containing values for any placeholder params used in the SQL query.

=cut

sub buildArrayRefOfHashRefs {
    my $self = shift;
    my $sql = shift;
    my $params = shift;
    my $array = $self->selectall_arrayref($sql, { Slice => {} }, @$params);
    return $array;
}


#-------------------------------------------------------------------

=head2 buildDataTableStructure ( sql, params )

Builds a data structure that can be converted to JSON and sent
to a YUI Data Table.  This is basically a hash of information about
the results, with one of the keys being an array ref of hashrefs.  It also
calculates the total records that could have been matched without a limit
statement, as well as how many were actually matched.  It returns a hash.

=head3 sql

An SQL query. The query may select as many columns of data as you wish.  The query
should contain a SQL_CALC_ROWS_FOUND entry so that the total number of available
rows can be sent to the Data Table.

=head3 params

An array reference containing values for any placeholder params used in the SQL query.

=cut

sub buildDataTableStructure {
    my $self = shift;
    my $sql = shift;
    my $params = shift;

    ##Note, I need a valid statement handle for doing the rows method on.
    my $sth = $self->prepare($sql);
    $sth->execute(@$params);
    my $array = $sth->fetchall_arrayref( {} );

    my %hash = (
        records         => $array,
        totalRecords    => $self->selectrow_array('SELECT found_rows()') + 0, ##Convert to numeric
        recordsReturned => $sth->rows + 0,
    );

    $sth->finish;

    return %hash;
}

#-------------------------------------------------------------------

=head2 buildHashRefOfHashRefs ( sql, params, key )

Builds a hash reference of hash references of data 
from a series of rows.  Useful for returning many rows at once.
Assigns the data to a hash

=head3 sql

An SQL query. The query must select at least one column of data, including the one you choose as the key for the hashRef to be returned.  Each row is returned as its own hashRef as the value of its corresponding key, keyed by the key column, below.

=head3 params

An array reference containing values for any placeholder params used in the SQL query.

=head3 key

Which column of the result set to use as the key when creating the hashref.

=cut

sub buildHashRefOfHashRefs {
    my $self   = shift;
    my $sql    = shift;
    my $params = shift;
    my $key    = shift;

    my $sth = $self->prepare($sql);
    $sth->execute(@$params);
    tie my %hash, 'Tie::IxHash';
    while (my $data = $sth->fetchrow_hashref) {
        $hash{$data->{$key}} = $data;
    }
    $sth->finish;
    return \%hash;
}

#-------------------------------------------------------------------

=head2 buildSearchQuery ( $sql, $placeholders, $keywords, $columns )

Append information to an existing SQL statement for implementing
basic search functions.  The ammended SQL and an array of placeholder
variables will be returned.

=head3 $sql

A scalar reference to an SQL query.  The clauses to add search-like capabilities will be
appended to the end of the query.

=head3 $placeholders

An array reference of placeholders already added to the query.

=head3 $keywords

This is the data that will be searched for in columns.  An SQL wildcard '%' will
be added to the beginning and end of $keywords.

=head3 $columns

An arrayref of column names that should be searched for $keywords.

=cut

sub buildSearchQuery {
    my ($self, $sql, $placeHolders, $keywords, $columns) = @_;
    if ($$sql =~ m/where/i) {
        $$sql .= ' and (';
    }
    else { 
        $$sql .= ' where (';
    }
    $keywords = lc('%'.$keywords.'%');
    my $counter = 0;
    foreach my $field (@{ $columns }) {
        $$sql .= ' or' if ($counter > 0);
        $$sql .= qq{ LOWER( $field ) like ?};
        push(@{$placeHolders}, $keywords);
        $counter++;
    }
    $$sql .= ')';
}

#-------------------------------------------------------------------

=head2 dbh ( )

Returns a reference to the working DBI database handler for this WebGUI::SQL object.

=cut

sub dbh {
    my $self = shift;
    return $self;
}


#-------------------------------------------------------------------

=head2 deleteRow ( table, key, keyValue )

Deletes a row of data from the specified table.

=head3 table

The name of the table to delete the row of data from.

=head3 key

The name of the column to use as the key. Should be a primary or unique key in the table.

=head3 keyValue

The value to search for in the key column.

=cut

sub deleteRow {
    my ($self, $table, $key, $keyValue) = @_;
    $table = $self->quote_identifier($table);
    $key = $self->quote_identifier($key);
    return $self->do("DELETE FROM $table WHERE $key = ?", {}, $keyValue);
}

#-------------------------------------------------------------------

=head2 errorCode ( )

Returns an error code for the current handler.

=cut

sub errorCode {
    my $self = shift;
    return $self->err;
}


#-------------------------------------------------------------------

=head2 errorMessage ( )

Returns a text error message for the current handler.

=cut

sub errorMessage {
    my $self = shift;
    return $self->errstr;
}


#-------------------------------------------------------------------

=head2 getNextId ( idName )

Increments an incrementer of the specified type and returns the value.

=head3 idName

Specify the name of one of the incrementers in the incrementer table.

=cut

sub getNextId {
    my $self = shift;
    my $name = shift;
    $self->begin_work;
    my $id = $self->selectrow_array('SELECT nextValue FROM incrementer WHERE incrementerId = ?', {}, $name);
    $self->do('UPDATE incrementer SET nextValue=nextValue+1 WHERE incrementerId=?', {}, $name);
    $self->commit;
    return $id;
}

#-------------------------------------------------------------------

=head2 getDriver ( )

Returns the DBI driver used by this database link

=cut

sub getDriver {
    my $self = shift;
    return  $self->{Driver}->{Name};
}

#-------------------------------------------------------------------

=head2 getRow ( table, key, keyValue )

Returns a row of data as a hash reference from the specified table.

=head3 table

The name of the table to retrieve the row of data from.

=head3 key

The name of the column to use as the retrieve key. Should be a primary or unique key in the table.

=head3 keyValue

The value to search for in the key column.

=cut

sub getRow {
    my ($self, $table, $key, $keyValue) = @_;
    my $row = $self->selectrow_hashref(
        sprintf('SELECT * FROM %s WHERE %s = ?',
            $self->quote_identifier($table),
            $self->quote_identifier($key)
        ),
        {},
        $keyValue,
    );
    return $row;
}

#-------------------------------------------------------------------

=head2 quickArray ( sql, params )

Executes a query and returns a single row of data as an array.

=head3 sql

An SQL query.

=head3 params

An array reference containing values for any placeholder params used in the SQL query.

=cut

sub quickArray {
    my $self = shift;
    my $sql = shift;
    my $params = shift || [];
    my @result = $self->selectrow_array($sql, {}, @{ $params });
    return @result;
}


#-------------------------------------------------------------------

=head2 quickCSV ( sql, params )

Executes a query and returns a comma delimited text blob with column headers. Returns undef on failure.

=head3 sql

An SQL query.

=head3 params

An array reference containing values for any placeholder params used in the SQL query.

=cut

sub quickCSV {
    my $self = shift;
    my $sql = shift;
    my $params = shift;

    my $csv = Text::CSV_XS->new({ eol => "\n" });

    my $sth = $self->prepare($sql);
    $sth->execute(@$params);

    return undef unless $csv->combine($sth->getColumnNames);
    my $output = $csv->string;

    while (my @data = $sth->fetchrow_array) {
        return undef unless $csv->combine(@data);
        $output .= $csv->string;
    }

    $sth->finish;
    return $output;
}


#-------------------------------------------------------------------

=head2 quickHash ( sql, params )

Executes a query and returns a single row of data as a hash.

=head3 sql

An SQL query.

=head3 params

An array reference containing values for any placeholder params used in the SQL query.

=cut

sub quickHash {
    my $self = shift;
    my $sql = shift;
    my $params = shift;
    my $row = $self->selectrow_hashref($sql, {}, @$params);
    return $row ? %{$row} : ();
}

#-------------------------------------------------------------------

=head2 quickHashRef ( sql, params )

Executes a query and returns a single row of data as a hash reference.

=head3 sql

An SQL query.

=head3 params

An array reference containing values for any placeholder params used in the SQL query.

=cut

sub quickHashRef {
    my $self = shift;
    my $sql = shift;
    my $params = shift;
    return $self->selectrow_hashref($sql, {}, @$params) || {};
}

#-------------------------------------------------------------------

=head2 quickScalar ( sql, params )

Executes a query and returns the first column from a single row of data as a scalar.

=head3 sql

An SQL query.

=head3 params

An array reference containing values for any placeholder params used in the SQL query.

=cut

sub quickScalar {
    my $self = shift;
    my $sql = shift;
    my $params = shift;
    my ($data) = $self->selectrow_array($sql, {}, @$params);
    return $data;
}


#-------------------------------------------------------------------

=head2 quickTab ( sql, params )

Executes a query and returns a tab delimited text blob with column headers.

=head3 sql

An SQL query.

=head3 params

An array reference containing values for any placeholder params used in the SQL query.

=cut

sub quickTab {
    my $self = shift;
    my $sql = shift;
    my $params = shift;

    my $sth = $self->prepare($sql);
    $sth->execute(@{$params});

    my $csv = Text::CSV_XS->new({
        eol => "\n",
        quote_char => undef,
        escape_char => undef,
        sep_char => "\t",
    });

    return undef
        unless $csv->combine($sth->getColumnNames);

    my $output = $csv->string;
    while (my @data = $sth->fetchrow_array) {
        return undef unless $csv->combine(@data);
        $output .= $csv->string;
    }
    $sth->finish;
    return $output;
}

#-------------------------------------------------------------------

=head2 quoteAndJoin ( arrayRef ) 

Returns a comma seperated string quoted and ready for insert/select into/from the database.  This is typically used for a statement like "select * from someTable where field in (".$db->quoteAndJoin(\@strings).")".

=head3 arrayRef 

An array reference containing strings to be quoted.

=cut

sub quoteAndJoin {
    my $self = shift;
    my $arrayRef = shift;
    return join ',', map { $self->quote($_) } @$arrayRef;
}


#-------------------------------------------------------------------

=head2 quoteIdentifier ( string ) 

Returns a string quoted as an identifier to be used as a table name, column name, etc.

=head3 string

Any scalar variable that needs to be escaped to be inserted into the database.

=cut

sub quoteIdentifier {
    my $self  = shift;
    return $self->quote_identifier(@_);
}

#-------------------------------------------------------------------

=head2 read ( sql [ , placeholders ] )

This is a convenience method for WebGUI::SQL::ResultSet->read().  It returns the statement
handler.

=head3 sql

An SQL query. Can use the "?" placeholder for maximum performance on multiple statements with the execute method.

=head3 placeholders

An array reference containing a list of values to be used in the placeholders defined in the SQL statement.

=cut

sub read {
    my $self = shift;
    my $sql = shift;
    my $placeholders = shift;
    my $sth = $self->prepare($sql);
    $sth->execute(@$placeholders);
    return $sth;
}

#-------------------------------------------------------------------

=head2 session ( )

Returns a reference to the current session.

=cut

sub session {
    my $self = shift;
    if (@_) {
        $self->{private_webgui_session} = shift;
        Scalar::Util::weaken $self->{private_webgui_session};
    }
    return $self->{private_webgui_session};
}


#-------------------------------------------------------------------

=head2 setRow ( table, key, data [ ,id ] )

Inserts/updates a row of data into the database. Returns the value of the key.

=head3 table

The name of the table to use.

=head3 key

The name of the primary key of the table. 

=head3 data

A hash reference containing column names and values to be set. If the field matching the key parameter is set to "new" then a new row will be created.

=head3 id

Use this ID to create a new row. Same as setting the key value to "new" except that we'll use this passed in id instead.

=cut

sub setRow {
    my ($self, $table, $keyColumn, $data, $id) = @_;
    $table = $self->quote_identifier($table);
    my $key = $self->quote_identifier($keyColumn);

    if ($data->{$keyColumn} eq 'new' || $id) {
        $id ||= $self->session->id->generate;
        $data->{$keyColumn} = $id;
    }
    else {
        $id = $data->{$keyColumn};
    }

    try {
        my $fields = join ', ', map { $self->quote_identifier($_) } keys %$data;
        my $values = join ', ', ('?') x values %$data;
        $self->do("INSERT INTO $table ($fields) VALUES ($values)", {}, values %$data);
    }
    catch {
        my %data = %$data;
        delete $data{$keyColumn};

        if ( keys %data ) {
            my $fields = join ', ', map { $self->quote_identifier($_). '=?' } keys %data;
            $self->do("UPDATE $table SET $fields WHERE $key = ?", {}, values %data, $id);
        }
    };

    return $id;
}

#-------------------------------------------------------------------

=head2 unconditionalRead ( sql [, placeholders ] )

A convenience method that is an alias of WebGUI::SQL::ResultSet->unconditionalRead()

=head3 sql

An SQL query.

=head3 placeholders

An array reference containing a list of values to be used in the placeholders defined in the SQL statement.

=cut

sub unconditionalRead {
    my $self = shift;
    local $self->{RaiseError} = 0;
    local $self->{HandleError} = undef;
    my $sth = $self->read(@_);
    return $sth;
}


#-------------------------------------------------------------------

=head2 write ( sql, params )

A method specifically designed for writing to the database in an efficient manner. Returns
the number of rows effected.

=head3 sql

An SQL insert or update.

=head3 params

An array reference containing values for any placeholder params used in the SQL query.

=cut

sub write {
    my $self = shift;
    my $sql = shift;
    my $params = shift;
    return $self->do($sql, {}, @$params);
}


1;

