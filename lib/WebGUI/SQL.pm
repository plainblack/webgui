package WebGUI::SQL;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2002 Plain Black Software.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use CGI::Carp qw(fatalsToBrowser);
use DBI;
use Exporter;
use strict;
use Tie::IxHash;
use WebGUI::ErrorHandler;
use WebGUI::Session;

our @ISA = qw(Exporter);
our @EXPORT = qw(&quote &getNextId);

#-------------------------------------------------------------------
sub array {
        return $_[0]->{_sth}->fetchrow_array() or WebGUI::ErrorHandler::fatalError("Couldn't fetch array. ".$_[0]->{_sth}->errstr);
}

#-------------------------------------------------------------------
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
sub buildHash {
	my ($sth, %hash, @data);
	tie %hash, "Tie::IxHash";
        $sth = WebGUI::SQL->read($_[1],$_[2]);
        while (@data = $sth->array) {
		if ($data[1] eq "") {
			$hash{$data[0]} = $data[0];
		} else {
                	$hash{$data[0]} = $data[1];
		}
        }
        $sth->finish;
	return %hash;
}

#-------------------------------------------------------------------
sub finish {
        return $_[0]->{_sth}->finish;
}

#-------------------------------------------------------------------
sub getNextId {
        my ($id);
        ($id) = WebGUI::SQL->quickArray("select nextValue from incrementer where incrementerId='$_[0]'");
        WebGUI::SQL->write("update incrementer set nextValue=nextValue+1 where incrementerId='$_[0]'");
        return $id;
}

#-------------------------------------------------------------------
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
sub hashRef {
        return $_[0]->{_sth}->fetchrow_hashref() or WebGUI::ErrorHandler::fatalError("Couldn't fetch hashref. ".$_[0]->{_sth}->errstr);
}

#-------------------------------------------------------------------
sub new {
	my ($class, $sql, $dbh, $sth);
        $class = shift;
        $sql = shift;
        $dbh = shift || $WebGUI::Session::session{dbh};
        $sth = $dbh->prepare($sql) or WebGUI::ErrorHandler::fatalError("Couldn't prepare statement: ".$sql." : ". DBI->errstr);
        $sth->execute or WebGUI::ErrorHandler::fatalError("Couldn't execute statement: ".$sql." : ". DBI->errstr);
	bless ({_sth => $sth}, $class);
}

#-------------------------------------------------------------------
sub quickArray {
	my ($sth, @data);
        $sth = WebGUI::SQL->new($_[1],$_[2]);
	@data = $sth->array;
	$sth->finish;
	return @data;
}

#-------------------------------------------------------------------
sub quickHash {
        my ($sth, $data);
        $sth = WebGUI::SQL->new($_[1],$_[2]);
        $data = $sth->hashRef;
        $sth->finish;
	if (defined $data) {
        	return %{$data};
	}
}

#-------------------------------------------------------------------
sub quote {
        my $value = $_[0]; #had to add this here cuz Tie::CPHash variables cause problems otherwise.
        return $WebGUI::Session::session{dbh}->quote($value);
}

#-------------------------------------------------------------------
sub read {
     	return WebGUI::SQL->new($_[1],$_[2],$_[3]);
}

#-------------------------------------------------------------------
sub rows {
        return $_[0]->{_sth}->rows;
}

#-------------------------------------------------------------------
sub unconditionalRead {
        my ($sth);
        $sth = $_[2]->prepare($_[1]);
        $sth->execute;
        bless ({_sth => $sth}, $_[0]);
}

#-------------------------------------------------------------------
sub write {
	my ($dbh);
	$dbh = $_[2] || $WebGUI::Session::session{dbh};
     	$dbh->do($_[1]) or WebGUI::ErrorHandler::fatalError("Couldn't prepare statement: ".$_[1]." : ". DBI->errstr);
}


1;

