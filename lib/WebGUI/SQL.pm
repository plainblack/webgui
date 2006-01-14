package WebGUI::SQL;

=head1 LEGAL

 -------------------------------------------------------------------
  WebGUI is Copyright 2001-2006 Plain Black Corporation.
 -------------------------------------------------------------------
  Please read the legal notices (docs/legal.txt) and the license
  (docs/license.txt) that came with this distribution before using
  this software.
 -------------------------------------------------------------------
  http://www.plainblack.com                     info@plainblack.com
 -------------------------------------------------------------------

=cut

use DBI;
use strict;
use Tie::IxHash;
use WebGUI::SQL::Resultset;
use WebGUI::Utility;

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

 @arr = $db->buildArray($sql);
 $arrayRef = $db->buildArrayRef($sql);
 %hash = $db->buildHash($sql);
 $hashRef = $db->buildHashRef($sql);
 @arr = $db->quickArray($sql);
 $text = $db->quickCSV($sql);
 %hash = $db->quickHash($sql);
 $hashRef = $db->quickHashRef($sql);
 $text = $db->quickTab($sql);

 $dbh = $db->getSlave;

 $id = $db->getNextId("someId");
 $string = $db->quote($string);
 $string = $db->quoteAndJoin(\@array);

=head1 METHODS

These methods are available from this package:

=cut


#-------------------------------------------------------------------

=head2 beginTransaction ( )

Starts a transaction sequence. To be used with commit and rollback. Any writes after this point will not be applied to the database until commit is called.

=cut

sub beginTransaction {
	my $self = shift;
	$self->dbh->begin_work;
}


#-------------------------------------------------------------------

=head2 buildArray ( sql )

Builds an array of data from a series of rows.

=head3 sql

An SQL query. The query must select only one column of data.

=cut

sub buildArray {
	my $self = shift;
	my $sql = shift;
        my ($sth, $data, @array, $i);
        $sth = $self->read($sql);
	$i=0;
        while (($data) = $sth->array) {
                $array[$i] = $data;
		$i++;
        }
        $sth->finish;
        return @array;
}


#-------------------------------------------------------------------

=head2 buildArrayRef ( sql )

Builds an array reference of data from a series of rows.

=head3 sql

An SQL query. The query must select only one column of data.

=cut

sub buildArrayRef {
	my $self = shift;
	my $sql = shift;
	my @array = $self->buildArray($sql);
	return \@array;
}


#-------------------------------------------------------------------

=head2 buildHash ( sql )

Builds a hash of data from a series of rows.

=head3 sql

An SQL query. The query must select at least two columns of data, the first being the key for the hash, the second being the value. If the query selects more than two columns, then the last column will be the value and the remaining columns will be joined together by a colon ":" to form a complex key.

=cut

sub buildHash {
	my $self = shift;
	my $sql = shift;
	my ($sth, %hash, @data);
	tie %hash, "Tie::IxHash";
        $sth = $self->read($sql);
        while (@data = $sth->array) {
		my $value = pop @data;
		my $key = join(":",@data);	
               	$hash{$key} = $value;
        }
        $sth->finish;
	return %hash;
}


#-------------------------------------------------------------------

=head2 buildHashRef ( sql )

Builds a hash reference of data from a series of rows.

=head3 sql

An SQL query. The query must select at least two columns of data, the first being the key for the hash, the second being the value. If the query selects more than two columns, then the last column will be the value and the remaining columns will be joined together by an underscore "_" to form a complex key.

=cut

sub buildHashRef {
	my $self = shift;
	my $sql = shift;
        my ($sth, %hash);
        tie %hash, "Tie::IxHash";
	%hash = $self->buildHash($sql);
        return \%hash;
}

                                                                                                                                                             
#-------------------------------------------------------------------

=head2 commit ( )

Ends a transaction sequence. To be used with beginTransaction. Applies all of the writes since beginTransaction to the database.

=cut

sub commit {
	my $self = shift;
	$self->dbh->commit;
}


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
	my $class = shift;
	my $session = shift;
	my $dsn = shift;
	my $user = shift;
	my $pass = shift;
	my $dbh = DBI->connect($dsn,$user,$pass,{RaiseError=>0,AutoCommit=>1 }) or $session->errorHandler->fatal("Couldn't connect to database.");
	if ( $dsn =~ /Oracle/ ) { # Set Oracle specific attributes
		$dbh->{LongReadLen} = 512 * 1024;
		$dbh->{LongTruncOk} = 1;
	}
	bless {_dbh=>$dbh, _session=>$session}, $class;
}

#-------------------------------------------------------------------

=head2 dbh ( )

Returns a reference to the working DBI database handler for this WebGUI::SQL object.

=cut

sub dbh {
	my $self = shift;
	return $self->{_dbh};
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
        $self->write("delete from $table where ".$key."=".$self->quote($keyValue));
}


#-------------------------------------------------------------------

=head DESTROY ( )

Deconstructor.

=cut

sub DESTROY {
	my $self = shift;
	$self->disconnect;
	undef $self;
}


#-------------------------------------------------------------------

=head2 disconnect ( )

Disconnects from the database. And destroys the object.

=cut

sub disconnect {
	my $self = shift;
	$self->dbh->disconnect;
	undef $self;
}


#-------------------------------------------------------------------

=head2 errorCode {

Returns an error code for the current handler.

=cut

sub errorCode {
	my $self = shift;
	return $self->dbh->err;
}


#-------------------------------------------------------------------

=head2 errorMessage {

Returns a text error message for the current handler.

=cut

sub errorMessage {
	my $self = shift;
	return $self->dbh->errstr;
}


#-------------------------------------------------------------------

=head2 getNextId ( idName )

Increments an incrementer of the specified type and returns the value. 

B<NOTE:> This is not a regular method, but is an exported subroutine.

=head3 idName

Specify the name of one of the incrementers in the incrementer table.

=cut

sub getNextId {
	my $self = shift;
	my $name = shift;
        my ($id);
	$self->beginTransaction;
        ($id) = $self->quickArray("select nextValue from incrementer where incrementerId='$name'");
        $self->write("update incrementer set nextValue=nextValue+1 where incrementerId='$name'");
	$self->commit;
        return $id;
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
        my $row = $self->quickHashRef("select * from $table where ".$key."=".$self->quote($keyValue));
        return $row;
}

#-------------------------------------------------------------------

=head2 prepare ( sql ) {

This is a wrapper for WebGUI::SQL::ResultSet->prepare()

=head3 sql

An SQL statement. 

=cut

sub prepare {
	my $self = shift;
	my $sql = shift;
	return WebGUI::SQL::ResultSet->prepare($sql, $self);
}


#-------------------------------------------------------------------

=head2 quickArray ( sql )

Executes a query and returns a single row of data as an array.

=head3 sql

An SQL query.

=cut

sub quickArray {
	my $self = shift;
	my $sql = shift;
	my ($sth, @data);
        $sth = $self->read($sql);
	@data = $sth->array;
	$sth->finish;
	return @data;
}


#-------------------------------------------------------------------

=head2 quickCSV ( sql )

Executes a query and returns a comma delimited text blob with column headers.

=head3 sql

An SQL query.

=cut

sub quickCSV {
	my $self = shift;
	my $sql = shift;
        my ($sth, $output, @data);
        $sth = $self->read($sql);
        $output = join(",",$sth->getColumnNames)."\n";
        while (@data = $sth->array) {
                makeArrayCommaSafe(\@data);
                $output .= join(",",@data)."\n";
        }
        $sth->finish;
        return $output;
}


#-------------------------------------------------------------------

=head2 quickHash ( sql )

Executes a query and returns a single row of data as a hash.

=head3 sql

An SQL query.

=cut

sub quickHash {
	my $self = shift;
	my $sql = shift;
        my ($sth, $data);
        $sth = $self->read($sql);
        $data = $sth->hashRef;
        $sth->finish;
	if (defined $data) {
        	return %{$data};
	} else {
		return ();
	}
}

#-------------------------------------------------------------------

=head2 quickHashRef ( sql )

Executes a query and returns a single row of data as a hash reference.

=head3 sql

An SQL query.

=cut

sub quickHashRef {
	my $self = shift;
	my $sql = shift;
        my $sth = $self->read($sql);
        my $data = $sth->hashRef;
        $sth->finish;
        if (defined $data) {
                return $data;
        } else {
		return {};
	}
}

#-------------------------------------------------------------------

=head2 quickTab ( sql )

Executes a query and returns a tab delimited text blob with column headers.

=head3 sql

An SQL query.

=cut

sub quickTab {
	my $self = shift;
	my $sql = shift;
        my ($sth, $output, @data);
        $sth = $self->read($sql);
	$output = join("\t",$sth->getColumnNames)."\n";
	while (@data = $sth->array) {
                makeArrayTabSafe(\@data);
                $output .= join("\t",@data)."\n";
        }
        $sth->finish;
	return $output;
}

#-------------------------------------------------------------------

=head2 quote ( string ) 

Returns a string quoted and ready for insert into the database.  

B<NOTE:> This is not a regular method, but is an exported subroutine.

=head3 string

Any scalar variable that needs to be escaped to be inserted into the database.

=cut

sub quote {
	my $self = shift;
	my $value = shift;
	return $self->dbh->quote($value);
}

#-------------------------------------------------------------------

=head2 quoteAndJoin ( arrayRef ) 

Returns a comma seperated string quoted and ready for insert/select into/from the database.  This is typically used for a statement like "select * from someTable where field in (".$db->quoteAndJoin(\@strings).")".

B<NOTE:> This is not a regular method, but is an exported subroutine.

=head3 arrayRef 

An array reference containing strings to be quoted.

=cut

sub quoteAndJoin {
	my $self = shift;
        my $arrayRef = shift;
	my @newArray;
	foreach my $value (@$arrayRef) {
 		push(@newArray,$self->quote($value));
	}
	return join(",",@newArray);
}


#-------------------------------------------------------------------

=head2 read ( sql [ , placeholders ] )

This is a convenience method for WebGUI::SQL::ResultSet->read().

=head3 sql

An SQL query. Can use the "?" placeholder for maximum performance on multiple statements with the execute method.

=head3 placeholders

An array reference containing a list of values to be used in the placeholders defined in the SQL statement.

=cut

sub read {
	my $self = shift;
	my $sql = shift;
	my $placeholders = shift;
	return WebGUI::SQL::ResultSet->read($sql, $self, $placeholders);
}


#-------------------------------------------------------------------

=head2 rollback ( )

Ends a transaction sequence. To be used with beginTransaction. Cancels all of the writes since beginTransaction.

=head3 dbh

A database handler. Defaults to the WebGUI default database handler.

=cut

sub rollback {
	my $self = shift;
	$self->dbh->rollback;
}


#-------------------------------------------------------------------

=head2 session ( )

Returns the session object reference.

=cut

sub session {
	my $self = shift;
	return $self->{_session};
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
        if ($data->{$keyColumn} eq "new" || $id) {
                $data->{$keyColumn} = $id || $self->session->id->generate();
                $self->write("insert into $table ($keyColumn) values (".$self->quote($data->{$keyColumn}).")");
        }
        my (@pairs);
        foreach my $key (keys %{$data}) {
                unless ($key eq $keyColumn) {
                        push(@pairs, $key.'='.$self->quote($data->{$key}));
                }
        }
	if ($pairs[0] ne "") {
        	$self->write("update $table set ".join(", ", @pairs)." where ".$keyColumn."=".$self->quote($data->{$keyColumn}));
	}
	return $data->{$keyColumn};
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
	my $sql = shift;
	my $placeholders = shift;
	return WebGUI::SQL::ResultSet->unconditionalRead($sql, $self, $placeholders);
}


#-------------------------------------------------------------------

=head2 write ( sql )

A method specifically designed for writing to the database in an efficient manner. 

=head3 sql

An SQL insert or update.

=cut

sub write {
	my $self = shift;
	my $sql = shift;
	$self->session->errorHandler->debug("query: ".$sql);
     	$self->dbh->do($sql) or $self->session->errorHandler->fatal("Couldn't write to the database: ".$sql." : ". $self->dbh->errstr);
}


1;

