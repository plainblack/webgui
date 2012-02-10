#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2012 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use strict;

use WebGUI::Test;
use WebGUI::Session;
use Data::Dumper;
use Test::More;
use Test::Deep;

my $session = WebGUI::Test->session;

# read
ok(my $sth = $session->db->read("select * from settings"), "read()");

# array
my @row = $sth->array;
is(@row, 2, "array()");

# arrayRef
my $row = $sth->arrayRef;
is(@{$row}, 2, "arrayRef()");

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
{
    # we know this will fail, so keep it quiet
    local $SIG{__WARN__} = sub {};
    ok(my $sth = $session->db->unconditionalRead("select * from tableThatDoesntExist"), "unconditionalRead()");
}

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

# prepare
ok(my $sth = $session->db->prepare("select value from settings where name=?"), "prepare() with placeholder");

# execute
$sth->execute(['showDebug']);
is($sth->errorCode, undef, "execute()");

$sth->finish;

# quickArray
my ($value) = $session->db->quickArray("select value from settings where name='authMethod'");
ok($value, "quickArray()");

# quickScalar
my $quickScalar = $session->db->quickScalar("SELECT COUNT(*) from userProfileField where fieldName='email'");
is(ref $quickScalar, '', 'quickScalar returns a scalar');
is($quickScalar, 1, 'quickScalar returns the correct scalar');

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
my $buildHashRef = $session->db->buildHashRef("select incrementerId from incrementer where incrementerId='theBigTest'");
is_deeply($buildHashRef, {'theBigTest' => 'theBigTest'}, "buildHashRef() with 1 column");

$buildHashRef = $session->db->buildHashRef("select incrementerId,nextValue from incrementer where incrementerId='theBigTest'");
is_deeply($buildHashRef, {'theBigTest' => 25}, "buildHashRef() with 2 columns");

$buildHashRef = $session->db->buildHashRef("select incrementerId,incrementerId,nextValue from incrementer where incrementerId='theBigTest'");
is_deeply($buildHashRef, {'theBigTest:theBigTest' => 25}, "buildHashRef() with 3 columns");

$buildHashRef = $session->db->buildHashRef("select incrementerId,nextValue from incrementer where incrementerId='nonexistantIncrementer'");
is_deeply($buildHashRef, {}, "buildHashRef() with no results");

# getNextId
is($session->db->getNextId('theBigTest'), 25, "getNextId()");
$session->db->write("delete from incrementer where incrementerId='theBigTest'");

# setRow
my $setRowId = $session->db->setRow("incrementer","incrementerId",{incrementerId=>"new", nextValue=>47});
ok($setRowId ne "", "setRow() - return ID");
my ($setRowResult) = $session->db->quickArray("select nextValue from incrementer where incrementerId=".$session->db->quote($setRowId));
is($setRowResult, 47, "setRow() - set data");
is $session->db->setRow("incrementer", "incrementerId",{incrementerId=>'new', nextValue => 48}, 'oogeyBoogeyBoo'),
   'oogeyBoogeyBoo', 'overriding default id with a custom one';

# getRow
my $getRow = $session->db->getRow("incrementer","incrementerId",$setRowId);
is($getRow->{nextValue}, 47, "getRow()");
$session->db->write("delete from incrementer where incrementerId=".$session->db->quote($setRowId));

#test that beginTransaction and commit set AutoCommit correctly.
$session->db->dbh->{AutoCommit} = 1;
ok( $session->db->dbh->{AutoCommit}, 'AutoCommits enabled by default');

$session->db->beginTransaction();
ok( !$session->db->dbh->{AutoCommit}, 'AutoCommit disabled, transaction started.');

$session->db->commit;
ok( $session->db->dbh->{AutoCommit}, 'AutoCommits reenabled, null transaction finished');

$session->db->beginTransaction();
ok( !$session->db->dbh->{AutoCommit}, 'AutoCommit disabled, transaction started.');

$session->db->rollback;
ok( $session->db->dbh->{AutoCommit}, 'AutoCommits reenabled, aborted transaction finished');

my %mysqlVariables = $session->db->quickArray("SHOW GLOBAL VARIABLES where Variable_name='have_innodb'");

SKIP: {

	skip("No InnoDB tables in this MySQL.  Skipping all transaction related tests.",7) if (lc $mysqlVariables{have_innodb} ne 'yes');
    $session->db->dbh->do('DROP TABLE IF EXISTS testTable');
    $session->db->dbh->do('CREATE TABLE testTable (myIndex int(8) NOT NULL default 0, message CHAR(64), PRIMARY KEY(myIndex)) TYPE=InnoDB');
    WebGUI::Test->addToCleanup( SQL => 'DROP TABLE testTable' );

    my $dbh2 = WebGUI::SQL->connect($session->config->get("dsn"), $session->config->get("dbuser"), $session->config->get("dbpass"));
    my ($sth, $sth2, $rc);

    $sth  = $session->db->prepare('select myIndex from testTable');
    $sth2 = $dbh2->prepare('select myIndex from testTable');

    #rollback test

    $rc = $session->db->beginTransaction();
    ok( $rc, 'beginTransaction returned successfully');
    ok( !$session->db->dbh->{AutoCommit}, 'AutoCommit disabled, new transaction started');

    $session->db->dbh->do("INSERT INTO testTable VALUES(0,'zero')");
    $session->db->dbh->do("INSERT INTO testTable VALUES(1,'one')");
    $session->db->dbh->do("INSERT INTO testTable VALUES(2,'two')");

    $sth2->execute;
    is( $sth2->rows, 0, 'access from second dbh on uncommitted data');
    $sth2->finish;

    $session->db->rollback;

    $sth->execute;
    is( $sth->rows, 0, 'rollback called, no updates to table');
    $sth->finish;

    $session->db->beginTransaction();
    $rc = $session->db->dbh->do("INSERT INTO testTable VALUES(0,'zero')");
    $session->db->dbh->do("INSERT INTO testTable VALUES(1,'one')");
    $session->db->dbh->do("INSERT INTO testTable VALUES(2,'two')");

    $sth2->execute;
    is( $sth2->rows, 0, 'access from second dbh on uncommitted data');
    $sth2->finish;

    $session->db->commit;

    $sth->execute;
    is( $sth->rows, 3, 'rows inserted, committed');
    $sth->finish;

    $sth2->execute;
    is( $sth2->rows, 3, 'access from second dbh on committed data');
    $sth2->finish;

    $session->db->dbh->do('DROP TABLE IF EXISTS testTable');

}

$session->db->dbh->do('DROP TABLE IF EXISTS testTable');
$session->db->dbh->do('CREATE TABLE testTable (myIndex int(8) NOT NULL default 0, message CHAR(64), myKey varchar(32), PRIMARY KEY(myIndex))');

my @tableData = (
	[ 0, 'zero',  'A' ],
	[ 1, 'one',   'A' ],
	[ 2, 'two',   'A' ],
	[ 3, 'three', 'A' ],
	[ 4, 'four',  'B' ],
	[ 5, 'five',  'B' ],
	[ 6, 'six',   'B' ],
	[ 7, 'seven', 'B' ],
);

my $tsth = $session->db->prepare('insert into testTable (myIndex,message,myKey) VALUES (?,?,?)');
foreach my $trow ( @tableData ) {
	$tsth->execute($trow);
}

my $arefHref = $session->db->buildArrayRefOfHashRefs('select message from testTable order by myIndex',[]);
my @expected = map { { 'message' => $_->[1] } } @tableData;
cmp_deeply($arefHref, \@expected, 'buildArrayOfHashRefs, 1 column, no params');

$arefHref = $session->db->buildArrayRefOfHashRefs('select message, myIndex from testTable order by myIndex',[]);
my @expected = map { { 'message' => $_->[1],
			'myIndex' => $_->[0] } } @tableData;
cmp_deeply($arefHref, \@expected, 'buildArrayOfHashRefs, 2 columns, no params');

$arefHref = $session->db->buildArrayRefOfHashRefs('select myIndex, message from testTable order by myIndex',[]);
##Note that expected array didn't change
cmp_deeply($arefHref, \@expected, 'buildArrayOfHashRefs, 2 columns, different column order, no params');

$arefHref = $session->db->buildArrayRefOfHashRefs('select message, myIndex from testTable where myKey=? order by myIndex',['A']);
@expected = map { { 'message' => $_->[1],
			'myIndex' => $_->[0] } }
		grep { $_->[2] eq 'A'} @tableData;
cmp_deeply($arefHref, \@expected, 'buildArrayOfHashRefs, 2 columns, 1 param');

my $hrefHref = $session->db->buildHashRefOfHashRefs('select message from testTable order by myIndex',[], 'message');
my %expected = map { $_->[1] => { 'message' => $_->[1] } } @tableData;
cmp_deeply($hrefHref, \%expected, 'buildHashRefOfHashRefs, 1 column, no params');

$hrefHref = $session->db->buildHashRefOfHashRefs('select message, myIndex from testTable order by myIndex',[], 'myIndex');
%expected = map { $_->[0] => { 'message' => $_->[1],
				'myIndex' => $_->[0] } } @tableData;
cmp_deeply($hrefHref, \%expected, 'buildHashRefOfHashRefs, 2 columns, no params');

$hrefHref = $session->db->buildHashRefOfHashRefs('select message, myIndex from testTable where myKey=? order by myIndex',['B'], 'myIndex');
%expected = map { $_->[0] => { 'message' => $_->[1],
				'myIndex' => $_->[0] } }
		grep { $_->[2] eq 'B' } @tableData;
cmp_deeply($hrefHref, \%expected, 'buildHashRefOfHashRefs, 2 columns, 1 param');

#######################################################################
#
# buildDataTableStructure
#
# Uses the testTable data from the preceeding *RefOf*Ref tests above
#
#######################################################################

my %tableStruct = $session->db->buildDataTableStructure('select * from testTable');

my @hashedTableData = map { { myIndex=>$_->[0], message=>$_->[1], myKey=>$_->[2]} } @tableData;

cmp_deeply(
    \%tableStruct,
    {
        totalRecords    => 8,
        recordsReturned => 8,
        records         => \@hashedTableData,
    },
    'Check table structure',
);

#----------------------------------------------------------------------------
# REGRESSIONS

# 11940 : quickCSV chokes on newlines
$session->db->write( 
    'INSERT INTO testTable (myIndex,message,myKey) VALUES (?,?,?)',
    [ 10, "a\ntest", 'B' ],
);
ok( $session->db->quickCSV( 'SELECT * FROM testTable' ), 'get some output even with newlines in data' );

done_testing();
