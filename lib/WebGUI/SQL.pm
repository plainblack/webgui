package WebGUI::SQL;

#-------------------------------------------------------------------
# WebGUI is Copyright 2001 Plain Black Software.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use CGI::Carp qw(fatalsToBrowser);
use DBI;
use strict;
use Tie::IxHash;
use WebGUI::ErrorHandler;

# Note: This class is really not necessary, I just decided to wrapper DBI in case
# 	I wanted to change to some other DB connector in the future. Also, it shorthands
#	a few tasks. And to be honest, having it separated has come in handy a few times,
#	like when I started coding for databases beyond MySQL.

#-------------------------------------------------------------------
sub array {
        return $_[0]->{_sth}->fetchrow_array() or WebGUI::ErrorHandler::fatalError(DBI->errstr);
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
sub hash {
        return $_[0]->{_sth}->fetchrow_hashref() or WebGUI::ErrorHandler::fatalError(DBI->errstr);
}

#-------------------------------------------------------------------
sub new {
	my ($class, $sql, $dbh, $sth);
        $class = shift;
        $sql = shift;
        $dbh = shift;
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
        $data = $sth->hash;
        $sth->finish;
	if (defined $data) {
        	return %{$data};
	}
}

#-------------------------------------------------------------------
sub read {
     	return WebGUI::SQL->new($_[1],$_[2]);
}

#-------------------------------------------------------------------
sub write {
     	$_[2]->do($_[1]) or WebGUI::ErrorHandler::fatalError("Couldn't prepare statement: ".$_[1]." : ". DBI->errstr);
}


1;

