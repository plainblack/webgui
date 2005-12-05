#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2005 Plain Black Corporation.
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
use WebGUI::SQL;

initialize();  # this line is required

# read
ok(my $sth = WebGUI::SQL->read("select * from settings"), "read()");

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
ok(my $sth = WebGUI::SQL->unconditionalRead("select * from tableThatDoesntExist"), "unconditionalRead()");

# errorCode 
is($sth->errorCode, "1146" ,"errorCode()");

# errorMessage
like ($sth->errorMessage, qr/Table [^.]*\.tableThatDoesntExist' doesn't exist/ , "errorMessage()");

$sth->finish;

# quote
is(quote("that's great"), "'that\\\'s great'", "quote()");
is(quote(0), "'0'", "quote(0)");
is(quote(''), "''", "quote('')");

# quoteAndJoin
my @quoteAndJoin = ("that's great", '"Howdy partner!"');
is(quoteAndJoin(\@quoteAndJoin), "'that\\\'s great','\\\"Howdy partner!\\\"'", "quoteAndJoin()");

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
ok(my $sth = WebGUI::SQL->prepare("select value from settings where name=?"), "prepare()");

# execute
$sth->execute(['showDebug']);
is($sth->errorCode, undef, "execute()");

$sth->finish;

# quickArray
my ($value) = WebGUI::SQL->quickArray("select value from settings where name='authMethod'");
ok($value, "quickArray()");

# write
WebGUI::SQL->write("delete from incrementer where incrementerId='theBigTest'"); # clean up previous failures
WebGUI::SQL->write("insert into incrementer (incrementerId, nextValue) values ('theBigTest',25)");
my ($value) = WebGUI::SQL->quickArray("select nextValue from incrementer where incrementerId='theBigTest'");
is($value, 25, 'write()');

# quickCSV
is(WebGUI::SQL->quickCSV("select * from incrementer where incrementerId='theBigTest'"), "incrementerId,nextValue\ntheBigTest,25\n", "quickCSV()");

# quickHash
my %quickHash = WebGUI::SQL->quickHash("select * from incrementer where incrementerId='theBigTest'");
is($quickHash{nextValue}, 25, "quickHash()");

# quickHash
my $quickHashRef = WebGUI::SQL->quickHashRef("select * from incrementer where incrementerId='theBigTest'");
is($quickHashRef->{nextValue}, 25, "quickHashRef()");

# quickTab
is(WebGUI::SQL->quickTab("select * from incrementer where incrementerId='theBigTest'"), "incrementerId\tnextValue\ntheBigTest\t25\n", "quickCSV()");

# buildArray
my ($buildArray) = WebGUI::SQL->buildArray("select nextValue from incrementer where incrementerId='theBigTest'");
is($buildArray, 25, "buildArray()");

# buildArrayRef
my $buildArrayRef = WebGUI::SQL->buildArrayRef("select nextValue from incrementer where incrementerId='theBigTest'");
is($buildArrayRef->[0], 25, "buildArrayRef()");

# buildHash
my %buildHash = WebGUI::SQL->buildHash("select incrementerId,nextValue from incrementer where incrementerId='theBigTest'");
is($buildHash{theBigTest}, 25, "buildHash()");

# buildHashRef
my $buildHashRef = WebGUI::SQL->buildHashRef("select incrementerId,nextValue from incrementer where incrementerId='theBigTest'");
is($buildHashRef->{theBigTest}, 25, "buildHashRef()");

# getNextId
is(getNextId('theBigTest'), 25, "getNextId()");
WebGUI::SQL->write("delete from incrementer where incrementerId='theBigTest'");

# setRow
my $setRowId = WebGUI::SQL->setRow("incrementer","incrementerId",{incrementerId=>"new", nextValue=>47});
ok($setRowId ne "", "setRow() - return ID");
my ($setRowResult) = WebGUI::SQL->quickArray("select nextValue from incrementer where incrementerId=".quote($setRowId));
is($setRowResult, 47, "setRow() - set data");

# getRow
my $getRow = WebGUI::SQL->getRow("incrementer","incrementerId",$setRowId);
is($getRow->{nextValue}, 47, "getRow()");
WebGUI::SQL->write("delete from incrementer where incrementerId=".quote($setRowId));


cleanup(); # this line is required


# ---- DO NOT EDIT BELOW THIS LINE -----

sub initialize {
	$|=1; # disable output buffering
	my $configFile;
	GetOptions(
        	'configFile=s'=>\$configFile
	);
	exit 1 unless ($configFile);
	WebGUI::Session::open("..",$configFile);
}

sub cleanup {
	WebGUI::Session::close();
}

