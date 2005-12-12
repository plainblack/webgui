package WebGUI::SQL;

=head1 LEGAL

 -------------------------------------------------------------------
  WebGUI is Copyright 2001-2005 Plain Black Corporation.
 -------------------------------------------------------------------
  Please read the legal notices (docs/legal.txt) and the license
  (docs/license.txt) that came with this distribution before using
  this software.
 -------------------------------------------------------------------
  http://www.plainblack.com                     info@plainblack.com
 -------------------------------------------------------------------

=cut

use DBI;
use Exporter;
use strict;
use Tie::IxHash;
use WebGUI::ErrorHandler;
use WebGUI::Id;
use WebGUI::Session;
use WebGUI::Utility;

our @ISA = qw(Exporter);
our @EXPORT = qw(&quote &getNextId &quoteAndJoin);

=head1 NAME

Package WebGUI::SQL

=head1 DESCRIPTION

Package for interfacing with SQL databases. This package implements Perl DBI functionality in a less code-intensive manner and adds some extra functionality.

=head1 SYNOPSIS

 use WebGUI::SQL;

 my $sth = WebGUI::SQL->prepare($sql);
 $sth->execute([ @values ]);

 $sth = WebGUI::SQL->read($sql);
 $sth = WebGUI::SQL->unconditionalRead($sql);
 @arr = $sth->array;
 @arr = $sth->getColumnNames;
 %hash = $sth->hash;
 $hashRef = $sth->hashRef;
 $num = $sth->rows;
 $sth->finish;

 WebGUI::SQL->write($sql);

 WebGUI::SQL->beginTransaction;
 WebGUI::SQL->commit;
 WebGUI::SQL->rollback;

 @arr = WebGUI::SQL->buildArray($sql);
 $arrayRef = WebGUI::SQL->buildArrayRef($sql);
 %hash = WebGUI::SQL->buildHash($sql);
 $hashRef = WebGUI::SQL->buildHashRef($sql);
 @arr = WebGUI::SQL->quickArray($sql);
 $text = WebGUI::SQL->quickCSV($sql);
 %hash = WebGUI::SQL->quickHash($sql);
 $hashRef = WebGUI::SQL->quickHashRef($sql);
 $text = WebGUI::SQL->quickTab($sql);

 $dbh = WebGUI::SQL->getSlave;

 $id = getNextId("someId");
 $string = quote($string);

=head1 METHODS

These methods are available from this package:

=cut


#-------------------------------------------------------------------
sub _getDefaultDb {
	return $WebGUI::Session::session{dbh};
}


#-------------------------------------------------------------------

=head2 array ( )

Returns the next row of data as an array.

=cut

sub array {
        return $_[0]->{_sth}->fetchrow_array() or WebGUI::ErrorHandler::fatal("Couldn't fetch array. ".$_[0]->{_sth}->errstr);
}


#-------------------------------------------------------------------

=head2 beginTransaction ( [ dbh ])

Starts a transaction sequence. To be used with commit and rollback. Any writes after this point will not be applied to the database until commit is called.

=head3 dbh

A database handler. Defaults to the WebGUI default database handler.

=cut

sub beginTransaction {
	my $class = shift;
	my $dbh = shift || _getDefaultDb();
	$dbh->begin_work;
}


#-------------------------------------------------------------------

=head2 buildArray ( sql [, dbh ] )

Builds an array of data from a series of rows.

=head3 sql

An SQL query. The query must select only one column of data.

=head3 dbh

By default this method uses the WebGUI database handler. However, you may choose to pass in your own if you wish.

=cut

sub buildArray {
        my ($sth, $data, @array, $i);
        $sth = WebGUI::SQL->read($_[1],$_[2]);
	$i=0;
        while (($data) = $sth->array) {
                $array[$i] = $data;
		$i++;
        }
        $sth->finish;
        return @array;
}

#-------------------------------------------------------------------

=head2 buildArrayRef ( sql [, dbh ] )

Builds an array reference of data from a series of rows.

=head3 sql

An SQL query. The query must select only one column of data.

=head3 dbh

By default this method uses the WebGUI database handler. However, you may choose to pass in your own if you wish.

=cut

sub buildArrayRef {
	my @array = $_[0]->buildArray($_[1],$_[2]);
	return \@array;
}

#-------------------------------------------------------------------

=head2 buildHash ( sql [, dbh ] )

Builds a hash of data from a series of rows.

=head3 sql

An SQL query. The query must select at least two columns of data, the first being the key for the hash, the second being the value. If the query selects more than two columns, then the last column will be the value and the remaining columns will be joined together by a colon ":" to form a complex key.

=head3 dbh

By default this method uses the WebGUI database handler. However, you may choose to pass in your own if you wish.

=cut

sub buildHash {
	my ($sth, %hash, @data);
	tie %hash, "Tie::IxHash";
        $sth = WebGUI::SQL->read($_[1],$_[2]);
        while (@data = $sth->array) {
		my $value = pop @data;
		my $key = join(":",@data);	
               	$hash{$key} = $value;
        }
        $sth->finish;
	return %hash;
}


#-------------------------------------------------------------------

=head2 buildHashRef ( sql [, dbh ] )

Builds a hash reference of data from a series of rows.

=head3 sql

An SQL query. The query must select at least two columns of data, the first being the key for the hash, the second being the value. If the query selects more than two columns, then the last column will be the value and the remaining columns will be joined together by an underscore "_" to form a complex key.

=head3 dbh

 By default this method uses the WebGUI database handler. However, you may choose to pass in your own if you wish.

=cut

sub buildHashRef {
        my ($sth, %hash);
        tie %hash, "Tie::IxHash";
	%hash = $_[0]->buildHash($_[1],$_[2]);
        return \%hash;
}
                                                                                                                                                             
#-------------------------------------------------------------------

=head2 commit ( [ dbh ])

Ends a transaction sequence. To be used with beginTransaction. Applies all of the writes since beginTransaction to the database.

=head3 dbh

A database handler. Defaults to the WebGUI default database handler.

=cut

sub commit {
	my $class = shift;
	my $dbh = shift || _getDefaultDb();
	$dbh->commit;
}


#-------------------------------------------------------------------

=head2 deleteRow ( table, key, keyValue [, dbh ] )

Deletes a row of data from the specified table.

=head3 table

The name of the table to delete the row of data from.

=head3 key

The name of the column to use as the key. Should be a primary or unique key in the table.

=head3 keyValue

The value to search for in the key column.

=head3 dbh

A database handler to use. Defaults to the WebGUI database handler.

=cut

sub deleteRow {
        my ($self, $table, $key, $keyValue, $dbh) = @_;
        WebGUI::SQL->write("delete from $table where ".$key."=".quote($keyValue), $dbh);
}


#-------------------------------------------------------------------

=head2 errorCode {

Returns an error code for the current handler.

=cut

sub errorCode {
        return $_[0]->{_sth}->err;
}


#-------------------------------------------------------------------

=head2 errorMessage {

Returns a text error message for the current handler.

=cut

sub errorMessage {
        return $_[0]->{_sth}->errstr;
}


#-------------------------------------------------------------------

=head2 execute ( [ placeholders ] )

Executes a prepared SQL statement.

=head3 placeholders 

An array reference containing a list of values to be used in the placeholders defined in the SQL statement.

=cut

sub execute {
	my $self = shift;
	my $placeholders = shift || [];
	my $sql = $self->{_sql};
	$self->{_sth}->execute(@{$placeholders}) or WebGUI::ErrorHandler::fatal("Couldn't execute prepared statement: $sql  Root cause: ". DBI->errstr);
}


#-------------------------------------------------------------------

=head2 finish ( )

Ends a query after calling the read() or unconditionalRead() methods. Don't use this unless you're not retrieving the full result set, or if you're using it with the unconditionalRead() method.

=cut

sub finish {
        return $_[0]->{_sth}->finish;
}


#-------------------------------------------------------------------

=head2 getColumnNames {

Returns an array of column names. Use with a "read" method.

=cut

sub getColumnNames {
        return @{$_[0]->{_sth}->{NAME}} if (ref $_[0]->{_sth}->{NAME} eq 'ARRAY');
}


#-------------------------------------------------------------------

=head2 getNextId ( idName )

Increments an incrementer of the specified type and returns the value. 

B<NOTE:> This is not a regular method, but is an exported subroutine.

=head3 idName

Specify the name of one of the incrementers in the incrementer table.

=cut

sub getNextId {
        my ($id);
        ($id) = WebGUI::SQL->quickArray("select nextValue from incrementer where incrementerId='$_[0]'");
        WebGUI::SQL->write("update incrementer set nextValue=nextValue+1 where incrementerId='$_[0]'");
        return $id;
}

#-------------------------------------------------------------------

=head2 getRow ( table, key, keyValue [, dbh ] )

Returns a row of data as a hash reference from the specified table.

=head3 table

The name of the table to retrieve the row of data from.

=head3 key

The name of the column to use as the retrieve key. Should be a primary or unique key in the table.

=head3 keyValue

The value to search for in the key column.

=head3 dbh

A database handler to use. Defaults to the WebGUI database handler.

=cut

sub getRow {
        my ($self, $table, $key, $keyValue, $dbh) = @_;
        my $row = WebGUI::SQL->quickHashRef("select * from $table where ".$key."=".quote($keyValue), $dbh);
        return $row;
}


#-------------------------------------------------------------------

=head2 getSlave ( ) 

Returns a random slave database handler, if one is defined, otherwise it returns undef. Likewise if admin mode is on it returns undef.

=cut

sub getSlave {
	if ($WebGUI::Session::session{var}{adminOn}) {
		return undef;
	} else {
		return $WebGUI::Session::session{slave}->[rand @{$WebGUI::Session::session{slave}}];
	}
}



#-------------------------------------------------------------------

=head2 hash ( )

Returns the next row of data in the form of a hash. Must be executed on a statement handler returned by the "read" method.

=cut

sub hash {
	my ($hashRef);
        $hashRef = $_[0]->{_sth}->fetchrow_hashref();
	if (defined $hashRef) {
        	return %{$hashRef};
	} else {
		return ();
	}
}


#-------------------------------------------------------------------

=head2 hashRef ( )

Returns the next row of data in the form of a hash reference. Must be executed on a statement handler returned by the "read" method.

=cut

sub hashRef {
	my ($hashRef, %hash);
        $hashRef = $_[0]->{_sth}->fetchrow_hashref();
	tie %hash, 'Tie::CPHash';
        if (defined $hashRef) {
		%hash = %{$hashRef};
                return \%hash;
        } else {
                return $hashRef;
        }
}


#-------------------------------------------------------------------

=head2 prepare ( sql [, dbh ] ) {

Returns a statement handler. To be used in creating prepared statements. Use with the execute method.

=head3 sql

An SQL statement. Can use the "?" placeholder for maximum performance on multiple statements with the execute method.

=head3 dbh

A database handler. Defaults to the WebGUI default database handler.

=cut

sub prepare {
	my $class = shift;
	my $sql = shift;
	my $dbh = shift || _getDefaultDb();
	push(@{$WebGUI::Session::session{SQLquery}},$sql);
	my $sth = $dbh->prepare($sql) or WebGUI::ErrorHandler::fatal("Couldn't prepare statement: ".$sql." : ". DBI->errstr);
	bless ({_sth => $sth, _sql => $sql}, $class);
}



#-------------------------------------------------------------------

=head2 quickArray ( sql [, dbh ] )

Executes a query and returns a single row of data as an array.

=head3 sql

An SQL query.

=head3 dbh

By default this method uses the WebGUI database handler. However, you may choose to pass in your own if you wish.

=cut

sub quickArray {
	my ($sth, @data);
        $sth = WebGUI::SQL->read($_[1],$_[2]);
	@data = $sth->array;
	$sth->finish;
	return @data;
}


#-------------------------------------------------------------------

=head2 quickCSV ( sql [, dbh ] )

Executes a query and returns a comma delimited text blob with column headers.

=head3 sql

An SQL query.

=head3 dbh

By default this method uses the WebGUI database handler. However, you may choose to pass in your own if you wish.

=cut

sub quickCSV {
        my ($sth, $output, @data);
        $sth = WebGUI::SQL->read($_[1],$_[2]);
        $output = join(",",$sth->getColumnNames)."\n";
        while (@data = $sth->array) {
                makeArrayCommaSafe(\@data);
                $output .= join(",",@data)."\n";
        }
        $sth->finish;
        return $output;
}


#-------------------------------------------------------------------

=head2 quickHash ( sql [, dbh ] )

Executes a query and returns a single row of data as a hash.

=head3 sql

An SQL query.

=head3 dbh

By default this method uses the WebGUI database handler. However, you may choose to pass in your own if you wish.

=cut

sub quickHash {
        my ($sth, $data);
        $sth = WebGUI::SQL->read($_[1],$_[2]);
        $data = $sth->hashRef;
        $sth->finish;
	if (defined $data) {
        	return %{$data};
	} else {
		return ();
	}
}

#-------------------------------------------------------------------

=head2 quickHashRef ( sql [, dbh ] )

Executes a query and returns a single row of data as a hash reference.

=head3 sql

An SQL query.

=head3 dbh

By default this method uses the WebGUI database handler. However, you may choose to pass in your own if you wish.

=cut

sub quickHashRef {
	my $self = shift;
	my $sql = shift;
	my $dbh = shift;
        my $sth = WebGUI::SQL->read($sql,$dbh);
        my $data = $sth->hashRef;
        $sth->finish;
        if (defined $data) {
                return $data;
        } else {
		return {};
	}
}

#-------------------------------------------------------------------

=head2 quickTab ( sql [, dbh ] )

Executes a query and returns a tab delimited text blob with column headers.

=head3 sql

An SQL query.

=head3 dbh

By default this method uses the WebGUI database handler. However, you may choose to pass in your own if you wish.

=cut

sub quickTab {
        my ($sth, $output, @data);
        $sth = WebGUI::SQL->read($_[1],$_[2]);
	$output = join("\t",$sth->getColumnNames)."\n";
	while (@data = $sth->array) {
                makeArrayTabSafe(\@data);
                $output .= join("\t",@data)."\n";
        }
        $sth->finish;
	return $output;
}

#-------------------------------------------------------------------

=head2 quote ( string [ , dbh ] ) 

Returns a string quoted and ready for insert into the database.  

B<NOTE:> This is not a regular method, but is an exported subroutine.

=head3 string

Any scalar variable that needs to be escaped to be inserted into the database.

=head3 dbh

The database handler. Defaults to the WebGUI database handler.

=cut

sub quote {
	my $value = shift; 
	my $dbh = shift || _getDefaultDb();
	return $dbh->quote($value);
}

#-------------------------------------------------------------------

=head2 quoteAndJoin ( arrayRef [ , dbh ] ) 

Returns a comma seperated string quoted and ready for insert/select into/from the database.  This is typically used for a statement like "select * from someTable where field in (".quoteAndJoin(\@strings).")".

B<NOTE:> This is not a regular method, but is an exported subroutine.

=head3 arrayRef 

An array reference containing strings to be quoted.

=head3 dbh

The database handler. Defaults to the WebGUI database handler.

=cut

sub quoteAndJoin {
        my $arrayRef = shift;
	my $dbh = shift || _getDefaultDb();
	my @newArray;
	foreach my $value (@$arrayRef) {
 		push(@newArray,$dbh->quote($value));
	}
	return join(",",@newArray);
}


#-------------------------------------------------------------------

=head2 read ( sql [, dbh, placeholders ] )

Returns a statement handler. This is a utility method that runs both a prepare and execute all in one.

=head3 sql

An SQL query. Can use the "?" placeholder for maximum performance on multiple statements with the execute method.

=head3 dbh

By default this method uses the WebGUI database handler. However, you may choose to pass in your own if you wish.

=head3 placeholders

An array reference containing a list of values to be used in the placeholders defined in the SQL statement.

=cut

sub read {
	my $class = shift;
	my $sql = shift;
	my $dbh = shift;
	my $placeholders = shift;
	my $sth = WebGUI::SQL->prepare($sql, $dbh);
	$sth->execute($placeholders);
	return $sth;
}


#-------------------------------------------------------------------

=head2 rollback ( [ dbh ])

Ends a transaction sequence. To be used with beginTransaction. Cancels all of the writes since beginTransaction.

=head3 dbh

A database handler. Defaults to the WebGUI default database handler.

=cut

sub rollback {
	my $class = shift;
	my $dbh = shift || _getDefaultDb();
	$dbh->rollback;
}


#-------------------------------------------------------------------

=head2 rows ( )

Returns the number of rows in a statement handler created by the "read" method.

=cut

sub rows {
        return $_[0]->{_sth}->rows;
}


#-------------------------------------------------------------------

=head2 setRow ( table, key, data [, dbh, id ] )

Inserts/updates a row of data into the database. Returns the value of the key.

=head3 table

The name of the table to use.

=head3 key

The name of the primary key of the table. 

=head3 data

A hash reference containing column names and values to be set. If the field matching the key parameter is set to "new" then a new row will be created.

=head3 dbh

A database handler to use. Defaults to the WebGUI database handler.

=head3 id

Use this ID to create a new row. Same as setting the key value to "new" except that we'll use this passed in id instead.

=cut

sub setRow {
        my ($self, $table, $keyColumn, $data, $dbh, $id) = @_;
        if ($data->{$keyColumn} eq "new" || $id) {
                $data->{$keyColumn} = $id || WebGUI::Id::generate();
                WebGUI::SQL->write("insert into $table ($keyColumn) values (".quote($data->{$keyColumn}).")", $dbh);
        }
        my (@pairs);
        foreach my $key (keys %{$data}) {
                unless ($key eq $keyColumn) {
                        push(@pairs, $key.'='.quote($data->{$key}));
                }
        }
	if ($pairs[0] ne "") {
        	WebGUI::SQL->write("update $table set ".join(", ", @pairs)." where ".$keyColumn."=".quote($data->{$keyColumn}), $dbh);
	}
	return $data->{$keyColumn};
}


#-------------------------------------------------------------------

=head2 unconditionalRead ( sql [, dbh, placeholders ] )

An alias of the "read" method except that it will not cause a fatal error in WebGUI if the query is invalid. This is useful for user generated queries such as those in the SQL Report. Returns a statement handler.

=head3 sql

An SQL query.

=head3 dbh

By default this method uses the WebGUI database handler. However, you may choose to pass in your own if you wish.

=head3 placeholders

An array reference containing a list of values to be used in the placeholders defined in the SQL statement.

=cut

sub unconditionalRead {
	my $class = shift;
	my $sql = shift;
	my $dbh = shift || _getDefaultDb();
	my $placeholders = shift;
	if (WebGUI::ErrorHandler::canShowDebug()) {
		push(@{$WebGUI::Session::session{SQLquery}},$sql);
	}
        my $sth = $dbh->prepare($sql) or WebGUI::ErrorHandler::warn("Unconditional read failed: ".$sql." : ".DBI->errstr);
        if ($sth) {
        	$sth->execute(@$placeholders) or WebGUI::ErrorHandler::warn("Unconditional read failed: ".$sql." : ".DBI->errstr);
        	bless ({_sth => $sth} , $class);
        }       
}


#-------------------------------------------------------------------

=head2 write ( sql [, dbh ] )

A method specifically designed for writing to the database in an efficient manner. 

=head3 sql

An SQL insert or update.

=head3 dbh

By default this method uses the WebGUI database handler. However, you may choose to pass in your own if you wish.

=cut

sub write {
	my $class = shift;
	my $sql = shift;
	my $dbh = shift || _getDefaultDb();
	if (WebGUI::ErrorHandler::canShowDebug()) {
		push(@{$WebGUI::Session::session{SQLquery}},$sql);
	}
     	$dbh->do($sql) or WebGUI::ErrorHandler::fatal("Couldn't write to the database: ".$sql." : ". DBI->errstr);
}


1;

