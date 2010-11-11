# vim:syntax=perl
#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2009 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#------------------------------------------------------------------

# Tests WebGUI::Crud


use strict;
use Test::More;
use WebGUI::Test; # Must use this before any other WebGUI modules
use WebGUI::Session;

BEGIN {
    $INC{'WebGUI/Cruddy.pm'} = __FILE__;
}

package WebGUI::Cruddy;

use Moose;
use WebGUI::Definition::Crud;
extends 'WebGUI::Crud';

define tableName => 'some_crud_table';
define tableKey  => 'id';

has id => (
    required  => 1,
    is        => 'ro',
);

property prop => (
    label => 'prop',
    fieldType => 'text',
    default   => 'propeller',
);

package main;

#----------------------------------------------------------------------------
# Init
my $session         = WebGUI::Test->session;


#----------------------------------------------------------------------------
# Tests

# check table structure
WebGUI::Cruddy->crud_createTable($session);
WebGUI::Test->addToCleanup(sub { WebGUI::Cruddy->crud_dropTable($session); });
my $sth = $session->db->read("describe some_crud_table");
my ($col, $type) = $sth->array();
is($col, 'id', "structure: id name");
is($type, 'char(22)', "structure: id type");
($col, $type) = $sth->array();
is($col, 'sequenceNumber', "structure: sequenceNumber name");
is($type, 'int(11)', "structure: sequenceNumber type");
($col, $type) = $sth->array();
is($col, 'dateCreated', "structure: dateCreated name");
is($type, 'datetime', "structure: dateCreated type");
($col, $type) = $sth->array();
is($col, 'lastUpdated', "structure: lastUpdated name");
is($type, 'datetime', "structure: lastUpdated type");
$sth->finish;

# check data
my $record1 = WebGUI::Cruddy->new($session);
$record1->write;
can_ok($record1, 'id');
isa_ok($record1, "WebGUI::Crud");
like($record1->dateCreated, qr/\d{4}-\d{2}-\d{2}\s\d{2}:\d{2}:\d{2}/, "dateCreated looks like a date");
like($record1->lastUpdated, qr/\d{4}-\d{2}-\d{2}\s\d{2}:\d{2}:\d{2}/, "lastUpdated looks like a date");
like($record1->sequenceNumber, qr/\d+/, "sequenceNumber looks like a number");
is($record1->sequenceNumber, 1, "record 1 sequenceNumber is 1");
like($record1->id, qr/[A-Za-z0-9_-]{22}/, "id looks like a guid");

can_ok($record1, 'prop');
my $prop = $record1->meta->find_attribute_by_name('prop');
ok($prop->does('WebGUI::Definition::Meta::Property'), 'prop does WebGUI::Definition::Meta::Property');
ok($prop->does('WebGUI::Definition::Meta::Property::Crud'), 'prop does WebGUI::Definition::Meta::Property::Crud');
ok($prop->does('WebGUI::Definition::Meta::Settable'), 'prop does WebGUI::Definition::Meta::Settable');
$record1->update({ prop => 'proposition', });
is $record1->prop, 'proposition', 'update works';
my $dbBday = WebGUI::DateTime->new($session, WebGUI::Test->webguiBirthday)->toDatabase;
$record1->update({
    prop => '',
    lastUpdated => $dbBday,
});
isnt $record1->lastUpdated, $dbBday, 'lastUpdated overwritten';

# custom id
my $record2 = WebGUI::Cruddy->new($session, {id=>'theshawshankredemption'});
is($record2->id,'theshawshankredemption',"custom id works");
$record2->delete;

# instanciation
$record2 = WebGUI::Cruddy->new($session);
$record2->write;
isnt($record1->getId, $record2->getId, "can retrieve unique rows");
my $copyOfRecord2 = WebGUI::Cruddy->new($session, $record2->getId);
is($record2->getId, $copyOfRecord2->getId, "can reinstanciate record");

# sequencing
is($record2->sequenceNumber, 2, "record 1 sequenceNumber is 2");
my $record3 = WebGUI::Cruddy->new($session);
$record3->write;
is($record3->sequenceNumber, 3, "record 1 sequenceNumber is 3");
my $record4 = WebGUI::Cruddy->new($session);
$record4->write;
is($record4->sequenceNumber, 4, "record 1 sequenceNumber is 4");
ok($record4->demote, "demotion reports success");
is($record4->sequenceNumber, 4, "can't demote further than end");
ok($record1->promote, "promotion reports success");
is($record1->sequenceNumber, 1, "can't promote further than beginning");
$record4->promote;
is($record4->sequenceNumber, 3, "promotion from end works");
$record4->demote;
is($record4->sequenceNumber, 4, "demotion to end works");
$record1->demote;
is($record1->sequenceNumber, 2, "demotion from beginning works");
$record1->promote;
is($record1->sequenceNumber, 1, "promotion to beginning works");
$record2->demote;
is($record2->sequenceNumber, 3, "demotion from middle works");
$record2->promote;
is($record2->sequenceNumber, 2, "promotion from middle works");

# deleting
ok($record2->delete, "deletion reports success");
my $copyOfRecord3 = WebGUI::Cruddy->new($session, $record3->getId);
my $copyOfRecord4 = WebGUI::Cruddy->new($session, $record4->getId);
is($copyOfRecord3->sequenceNumber, '2', "deletion of record 2 moved record 3 to sequence 2");
is($copyOfRecord4->sequenceNumber, '3', "deletion of record 2 moved record 4 to sequence 3");

# updating
$copyOfRecord4->dateCreated(WebGUI::DateTime->new($session, WebGUI::Test->webguiBirthday)->toMysql);
ok($copyOfRecord4->update, "update returns success");
isnt($copyOfRecord4->lastUpdated, $copyOfRecord4->get('dateCreated'), "updates work");

# retrieve data
my ($sql, $params) = WebGUI::Cruddy->getAllSql($session);
is($sql, "select `some_crud_table`.`id` from `some_crud_table` order by `some_crud_table`.`sequenceNumber`", "getAllSql() SQL no options");
($sql, $params) = WebGUI::Cruddy->getAllSql($session, {sequenceKeyValue=>1});
is($sql, "select `some_crud_table`.`id` from `some_crud_table` order by `some_crud_table`.`sequenceNumber`", "getAllSql() SQL sequence key value with no key specified");
is($params->[0], undef, "getAllSql() PARAMS sequence key value with no key specified");
($sql, $params) = WebGUI::Cruddy->getAllSql($session, {limit=>5});
is($sql, "select `some_crud_table`.`id` from `some_crud_table` order by `some_crud_table`.`sequenceNumber` limit 5", "getAllSql() SQL with a row limit");
($sql, $params) = WebGUI::Cruddy->getAllSql($session,{limit=>[10,20]});
is($sql, "select `some_crud_table`.`id` from `some_crud_table` order by `some_crud_table`.`sequenceNumber` limit 10,20", "getAllSql() SQL with a start and row limit");
($sql, $params) = WebGUI::Cruddy->getAllSql($session,{orderBy=>'lastUpdated'});
is($sql, "select `some_crud_table`.`id` from `some_crud_table` order by lastUpdated", "getAllSql() with a custom order by clause");
($sql, $params) = WebGUI::Cruddy->getAllSql($session,{join=>['someTable using (someId)']});
is($sql, "select `some_crud_table`.`id` from `some_crud_table` left join someTable using (someId) order by `some_crud_table`.`sequenceNumber`", "getAllSql() with a custom join");
($sql, $params) = WebGUI::Cruddy->getAllSql($session,{joinUsing=>[{myTable => 'myId'}]});
is($sql, "select `some_crud_table`.`id` from `some_crud_table` left join `myTable` using (`myId`) order by `some_crud_table`.`sequenceNumber`", "getAllSql() with a custom joinUsing");
($sql, $params) = WebGUI::Cruddy->getAllSql($session,{constraints=>[{'sequenceNumber=?'=>1}]});
is($sql, "select `some_crud_table`.`id` from `some_crud_table` where (sequenceNumber=?) order by `some_crud_table`.`sequenceNumber`", "getAllSql() SQL with a constraint");
is($params->[0], 1, "getAllSql PARAMS with a constraint");
($sql, $params) = WebGUI::Cruddy->getAllSql($session,{constraints=>[{'sequenceNumber=? or sequenceNumber=?'=>[1,2]}]});
is($sql, "select `some_crud_table`.`id` from `some_crud_table` where (sequenceNumber=? or sequenceNumber=?) order by `some_crud_table`.`sequenceNumber`", "getAllSql() SQL with two constraints");
is($params->[1], 2, "getAllSql PARAMS with two constraints");
is(scalar(@{WebGUI::Cruddy->getAllIds($session)}), 3, "getAllIds()");
my $iterator = WebGUI::Cruddy->getAllIterator($session);
while (my $object = $iterator->()) {
	isa_ok($object, 'WebGUI::Cruddy', 'Put your trust in the Lord. Your ass belongs to me.');
}


#crud management stuff
is(ref WebGUI::Cruddy->crud_getProperties($session), 'HASH', 'properties work');
is(WebGUI::Cruddy->crud_getTableKey(), 'id', 'default key is id');
is(WebGUI::Cruddy->crud_getTableName(), 'some_crud_table', 'default table is some_crud_table');
is(WebGUI::Cruddy->crud_getSequenceKey(), undef, 'default sequence key is blank');

done_testing();

#vim:ft=perl
