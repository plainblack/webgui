package WebGUI::SQL;

=head1 LEGAL

 -------------------------------------------------------------------
  WebGUI is Copyright 2001-2003 Plain Black LLC.
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
use WebGUI::Session;
use WebGUI::Utility;

our @ISA = qw(Exporter);
our @EXPORT = qw(&quote &getNextId);

=head1 NAME

Package WebGUI::SQL

=head1 DESCRIPTION

Package for interfacing with SQL databases. This package implements Perl DBI functionality in a less code-intensive manner and adds some extra functionality.

=head1 SYNOPSIS

 use WebGUI::SQL;
 $sth = WebGUI::SQL->new($sql);
 $sth = WebGUI::SQL->read($sql);
 $sth = WebGUI::SQL->unconditionalRead($sql);
 @arr = $sth->array;
 @arr = $sth->getColumnNames;
 %hash = $sth->hash;
 $hashRef = $sth->hashRef;
 $num = $sth->rows;
 $sth->finish;

 @arr = WebGUI::SQL->buildArray($sql);
 $arrayRef = WebGUI::SQL->buildArrayRef($sql);
 %hash = WebGUI::SQL->buildHash($sql);
 $hashRef = WebGUI::SQL->buildHashRef($sql);
 @arr = WebGUI::SQL->quickArray($sql);
 $text = WebGUI::SQL->quickCSV($sql);
 %hash = WebGUI::SQL->quickHash($sql);
 $hashRef = WebGUI::SQL->quickHashRef($sql);
 $text = WebGUI::SQL->quickTab($sql);

 WebGUI::SQL->write($sql);

 $id = getNextId("wobjectId");
 $string = quote($string);

=head1 METHODS

These methods are available from this package:

=cut


#-------------------------------------------------------------------

=head2 array ( )

Returns the next row of data as an array.

=cut

sub array {
        return $_[0]->{_sth}->fetchrow_array() or WebGUI::ErrorHandler::fatalError("Couldn't fetch array. ".$_[0]->{_sth}->errstr);
}


#-------------------------------------------------------------------

=head2 buildArray ( sql [, dbh ] )

Builds an array of data from a series of rows.

=over

=item sql

An SQL query. The query must select only one column of data.

=item dbh

By default this method uses the WebGUI database handler. However, you may choose to pass in your own if you wish.

=back

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

=over

=item sql

An SQL query. The query must select only one column of data.

=item dbh

By default this method uses the WebGUI database handler. However, you may choose to pass in your own if you wish.

=back

=cut

sub buildArrayRef {
	my @array = $_[0]->buildArray($_[1],$_[2]);
	return \@array;
}

#-------------------------------------------------------------------

=head2 buildHash ( sql [, dbh ] )

Builds a hash of data from a series of rows.

=over

=item sql

An SQL query. The query must select at least two columns of data, the first being the key for the hash, the second being the value. If the query selects more than two columns, then the last column will be the value and the remaining columns will be joined together by an underscore "_" to form a complex key.

=item dbh

By default this method uses the WebGUI database handler. However, you may choose to pass in your own if you wish.

=back

=cut

sub buildHash {
	my ($sth, %hash, @data);
	tie %hash, "Tie::IxHash";
        $sth = WebGUI::SQL->read($_[1],$_[2]);
        while (@data = $sth->array) {
		my $value = pop @data;
		my $key = join("_",@data);	
               	$hash{$key} = $value;
        }
        $sth->finish;
	return %hash;
}


#-------------------------------------------------------------------

=head2 buildHashRef ( sql [, dbh ] )

Builds a hash reference of data from a series of rows.

=over

=item sql

An SQL query. The query must select at least two columns of data, the first being the key for the hash, the second being the value. If the query selects more than two columns, then the last column will be the value and the remaining columns will be joined together by an underscore "_" to form a complex key.

=item dbh

 By default this method uses the WebGUI database handler. However, you may choose to pass in your own if you wish.

=back

=cut

sub buildHashRef {
        my ($sth, %hash);
        tie %hash, "Tie::IxHash";
	%hash = $_[0]->buildHash($_[1],$_[2]);
        return \%hash;
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

=head2 finish ( )

Ends a query after calling the "new" or "read" methods.

=cut

sub finish {
        return $_[0]->{_sth}->finish;
}


#-------------------------------------------------------------------

=head2 getColumnNames {

Returns an array of column names. Use with a "read" method.

=cut

sub getColumnNames {
        return @{$_[0]->{_sth}->{NAME}};
}


#-------------------------------------------------------------------

=head2 getNextId ( idName )

Increments an incrementer of the specified type and returns the value. 

NOTE: This is not a regular method, but is an exported subroutine.

=over

=item idName

Specify the name of one of the incrementers in the incrementer table.

=back

=cut

sub getNextId {
        my ($id);
        ($id) = WebGUI::SQL->quickArray("select nextValue from incrementer where incrementerId='$_[0]'",$_[1]);
        WebGUI::SQL->write("update incrementer set nextValue=nextValue+1 where incrementerId='$_[0]'",$_[1]);
        return $id;
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

=head2 new ( sql [, dbh ] )

Constructor. Returns a statement handler.

=over

=item sql

An SQL query. 

=item dbh

By default this method uses the WebGUI database handler. However, you may choose to pass in your own if you wish.

=back

=cut

sub new {
	my ($class, $sql, $dbh, $sth);
        $class = shift;
        $sql = shift;
        $dbh = shift || $WebGUI::Session::session{dbh};
	if ($WebGUI::Session::session{setting}{showDebug}) {
		push(@{$WebGUI::Session::session{SQLquery}},$sql);
	}
        $sth = $dbh->prepare($sql) or WebGUI::ErrorHandler::fatalError("Couldn't prepare statement: ".$sql." : ". DBI->errstr);
        $sth->execute or WebGUI::ErrorHandler::fatalError("Couldn't execute statement: ".$sql." : ". DBI->errstr);
	bless ({_sth => $sth}, $class);
}


#-------------------------------------------------------------------

=head2 quickArray ( sql [, dbh ] )

Executes a query and returns a single row of data as an array.

=over

=item sql

An SQL query.

=item dbh

By default this method uses the WebGUI database handler. However, you may choose to pass in your own if you wish.

=back

=cut

sub quickArray {
	my ($sth, @data);
        $sth = WebGUI::SQL->new($_[1],$_[2]);
	@data = $sth->array;
	$sth->finish;
	return @data;
}


#-------------------------------------------------------------------

=head2 quickCSV ( sql [, dbh ] )

Executes a query and returns a comma delimited text blob with column headers.

=over

=item sql

An SQL query.

=item dbh

By default this method uses the WebGUI database handler. However, you may choose to pass in your own if you wish.

=back

=cut

sub quickCSV {
        my ($sth, $output, @data);
        $sth = WebGUI::SQL->new($_[1],$_[2]);
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

=over

=item sql

An SQL query.

=item dbh

By default this method uses the WebGUI database handler. However, you may choose to pass in your own if you wish.

=back

=cut

sub quickHash {
        my ($sth, $data);
        $sth = WebGUI::SQL->new($_[1],$_[2]);
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

=over

=item sql

An SQL query.

=item dbh

By default this method uses the WebGUI database handler. However, you may choose to pass in your own if you wish.

=back

=cut

sub quickHashRef {
        my ($sth, $data);
        $sth = WebGUI::SQL->new($_[1],$_[2]);
        $data = $sth->hashRef;
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

=over

=item sql

An SQL query.

=item dbh

By default this method uses the WebGUI database handler. However, you may choose to pass in your own if you wish.

=back

=cut

sub quickTab {
        my ($sth, $output, @data);
        $sth = WebGUI::SQL->new($_[1],$_[2]);
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

NOTE: This is not a regular method, but is an exported subroutine.

=over

=item string

Any scalar variable that needs to be escaped to be inserted into the database.

=back

=cut

sub quote {
        my $value = $_[0]; #had to add this here cuz Tie::CPHash variables cause problems otherwise.
        return $WebGUI::Session::session{dbh}->quote($value);
}


#-------------------------------------------------------------------

=head2 read ( sql [, dbh ] )

An alias of the "new" method. Returns a statement handler.

=over

=item sql

An SQL query.

=item dbh

By default this method uses the WebGUI database handler. However, you may choose to pass in your own if you wish.

=back

=cut

sub read {
     	return WebGUI::SQL->new($_[1],$_[2],$_[3]);
}


#-------------------------------------------------------------------

=head2 rows ( )

Returns the number of rows in a statement handler created by the "read" method.

=cut

sub rows {
        return $_[0]->{_sth}->rows;
}


#-------------------------------------------------------------------

=head2 unconditionalRead ( sql [, dbh ] )

An alias of the "read" method except that it will not cause a fatal error in WebGUI if the query is invalid. This is useful for user generated queries such as those in the SQL Report. Returns a statement handler.

=over

=item sql

An SQL query.

=item dbh

By default this method uses the WebGUI database handler. However, you may choose to pass in your own if you wish.

=back

=cut

sub unconditionalRead {
        my ($sth,$dbh);
	$dbh = $_[2] || $WebGUI::Session::session{dbh};
        $sth = $dbh->prepare($_[1]) or WebGUI::ErrorHandler::warn("Unconditional read failed: ".$_[1]." : ".DBI->errstr);
        if ($sth) {
        	$sth->execute or WebGUI::ErrorHandler::warn("Unconditional read failed: ".$_[1]." : ".DBI->errstr);
        	bless ({_sth => $sth}, $_[0]);
        }       
}


#-------------------------------------------------------------------

=head2 write ( sql [, dbh ] )

A method specifically designed for writing to the database in an efficient manner. Writing can be accomplished using the "new" method, but it is not as efficient.

=over

=item sql

An SQL insert or update.

=item dbh

By default this method uses the WebGUI database handler. However, you may choose to pass in your own if you wish.

=back

=cut

sub write {
	my ($dbh);
	$dbh = $_[2] || $WebGUI::Session::session{dbh};
     	$dbh->do($_[1]) or WebGUI::ErrorHandler::fatalError("Couldn't prepare statement: ".$_[1]." : ". DBI->errstr);
}


1;

