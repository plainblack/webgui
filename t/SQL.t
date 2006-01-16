#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2006 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

# ---- BEGIN DO NOT EDIT ----
use strict;
use lib '../lib';
use Getopt::Long;
use WebGUI::Session;
use Data::Dumper;
# ---- END DO NOT EDIT ----

use Test::More tests => 33; # increment this value for each test you create

my $session = initialize();  # this line is required

# read
ok(my $sth = $session->db->read("select * from settings"), "read()");

# array
my @row = $sth->array;
is(@row, 2, "array()");

# getColumnNames
my @columnNames = $sth->getColumnNames;
ok($columnNames[0] eq "name" && $columnNames[1] eq "value", "geColumnNames()");

# hash
is(scalar($sth->hash), "2/8", "hash()");

# hashRef
my %hash = %{ $sth->hashRef };
is(scalar(%hash), "2/8", "hashRef()");

# rows
ok($sth->rows > 1, "rows()");

# finish
ok($sth->finish, "finish()");

# unconditionalRead
ok(my $sth = $session->db->unconditionalRead("select * from tableThatDoesntExist"), "unconditionalRead()");

# errorCode 
is($sth->errorCode, "1146" ,"errorCode()");

# errorMessage
like ($sth->errorMessage, qr/Table [^.]*\.tableThatDoesntExist' doesn't exist/i , "errorMessage()");

$sth->finish;

# quote
is($session->db->quote("that's great"), "'that\\\'s great'", "quote()");
is($session->db->quote(0), "'0'", "quote(0)");
is($session->db->quote(''), "''", "quote('')");

# quoteAndJoin
my @quoteAndJoin = ("that's great", '"Howdy partner!"');
is($session->db->quoteAndJoin(\@quoteAndJoin), "'that\\\'s great','\\\"Howdy partner!\\\"'", "quoteAndJoin()");

# beginTransaction
SKIP: {
	skip("Don't know how to test beginTransaction.",1);
	ok(undef,"beginTransaction()");
}

# commit
SKIP: {
	skip("Don't know how to test commit",1);
	ok(undef, "commit()");
}

# rollback
SKIP: {
	skip("Don't know how to test rollback()",1);
	ok(undef, "rollback()");
}

# prepare
ok(my $sth = $session->db->prepare("select value from settings where name=?"), "prepare()");

# execute
$sth->execute(['showDebug']);
is($sth->errorCode, undef, "execute()");

$sth->finish;

# quickArray
my ($value) = $session->db->quickArray("select value from settings where name='authMethod'");
ok($value, "quickArray()");

# write
$session->db->write("delete from incrementer where incrementerId='theBigTest'"); # clean up previous failures
$session->db->write("insert into incrementer (incrementerId, nextValue) values ('theBigTest',25)");
my ($value) = $session->db->quickArray("select nextValue from incrementer where incrementerId='theBigTest'");
is($value, 25, 'write()');

# quickCSV
is($session->db->quickCSV("select * from incrementer where incrementerId='theBigTest'"), "incrementerId,nextValue\ntheBigTest,25\n", "quickCSV()");

# quickHash
my %quickHash = $session->db->quickHash("select * from incrementer where incrementerId='theBigTest'");
is($quickHash{nextValue}, 25, "quickHash()");

# quickHash
my $quickHashRef = $session->db->quickHashRef("select * from incrementer where incrementerId='theBigTest'");
is($quickHashRef->{nextValue}, 25, "quickHashRef()");

# quickTab
is($session->db->quickTab("select * from incrementer where incrementerId='theBigTest'"), "incrementerId\tnextValue\ntheBigTest\t25\n", "quickCSV()");

# buildArray
my ($buildArray) = $session->db->buildArray("select nextValue from incrementer where incrementerId='theBigTest'");
is($buildArray, 25, "buildArray()");

# buildArrayRef
my $buildArrayRef = $session->db->buildArrayRef("select nextValue from incrementer where incrementerId='theBigTest'");
is($buildArrayRef->[0], 25, "buildArrayRef()");

# buildHash
my %buildHash = $session->db->buildHash("select incrementerId,nextValue from incrementer where incrementerId='theBigTest'");
is($buildHash{theBigTest}, 25, "buildHash()");

# buildHashRef
my $buildHashRef = $session->db->buildHashRef("select incrementerId,nextValue from incrementer where incrementerId='theBigTest'");
is($buildHashRef->{theBigTest}, 25, "buildHashRef()");

# getNextId
is($session->db->getNextId('theBigTest'), 25, "getNextId()");
$session->db->write("delete from incrementer where incrementerId='theBigTest'");

# setRow
my $setRowId = $session->db->setRow("incrementer","incrementerId",{incrementerId=>"new", nextValue=>47});
ok($setRowId ne "", "setRow() - return ID");
my ($setRowResult) = $session->db->quickArray("select nextValue from incrementer where incrementerId=".$session->db->quote($setRowId));
is($setRowResult, 47, "setRow() - set data");

# getRow
my $getRow = $session->db->getRow("incrementer","incrementerId",$setRowId);
is($getRow->{nextValue}, 47, "getRow()");
$session->db->write("delete from incrementer where incrementerId=".$session->db->quote($setRowId));


cleanup($session); # this line is required


# ---- DO NOT EDIT BELOW THIS LINE -----

sub initialize {
        $|=1; # disable output buffering
        my $configFile;
        GetOptions(
                'configFile=s'=>\$configFile
        );
        exit 1 unless ($configFile);
        my $session = WebGUI::Session->open("..",$configFile);
}

sub cleanup {
        my $session = shift;
        $session->close();
}

