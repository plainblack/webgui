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
use WebGUI::Crud;

#----------------------------------------------------------------------------
# Init
my $session         = WebGUI::Test->session;


#----------------------------------------------------------------------------
# Tests

plan tests => 55;        # Increment this number for each test you create

#----------------------------------------------------------------------------

# check table structure
WebGUI::Crud->crud_createTable($session);
WebGUI::Test->addToCleanup(sub { WebGUI::Crud->crud_dropTable($session); });
my $sth = $session->db->read("describe unnamed_crud_table");
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
my $record1 = WebGUI::Crud->create($session);
isa_ok($record1, "WebGUI::Crud", "isa WebGUI::Crud");
like($record1->get('dateCreated'), qr/\d{4}-\d{2}-\d{2}\s\d{2}:\d{2}:\d{2}/, "dateCreated looks like a date");
like($record1->get('lastUpdated'), qr/\d{4}-\d{2}-\d{2}\s\d{2}:\d{2}:\d{2}/, "lastUpdated looks like a date");
like($record1->get('sequenceNumber'), qr/\d+/, "sequenceNumber looks like a number");
is($record1->get('sequenceNumber'), 1, "record 1 sequenceNumber is 1");
like($record1->get('id'), qr/[A-Za-z0-9_-]{22}/, "id looks like a guid");

# custom id
my $record2 = WebGUI::Crud->create($session,{},{id=>'theshawshankredemption'});
is($record2->get('id'),'theshawshankredemption',"custom id works");
$record2->delete;

# instanciation
my $record2 = WebGUI::Crud->create($session);
isnt($record1->getId, $record2->getId, "can retrieve unique rows");
my $copyOfRecord2 = WebGUI::Crud->new($session, $record2->getId);
is($record2->getId, $copyOfRecord2->getId, "can reinstanciate record");

# sequencing
is($record2->get('sequenceNumber'), 2, "record 1 sequenceNumber is 2");
my $record3 = WebGUI::Crud->create($session);
is($record3->get('sequenceNumber'), 3, "record 1 sequenceNumber is 3");
my $record4 = WebGUI::Crud->create($session);
is($record4->get('sequenceNumber'), 4, "record 1 sequenceNumber is 4");
ok($record4->demote, "demotion reports success");
is($record4->get('sequenceNumber'), 4, "can't demote further than end");
ok($record1->promote, "promotion reports success");
is($record1->get('sequenceNumber'), 1, "can't promote further than beginning");
$record4->promote;
is($record4->get('sequenceNumber'), 3, "promotion from end works");
$record4->demote;
is($record4->get('sequenceNumber'), 4, "demotion to end works");
$record1->demote;
is($record1->get('sequenceNumber'), 2, "demotion from beginning works");
$record1->promote;
is($record1->get('sequenceNumber'), 1, "promotion to beginning works");
$record2->demote;
is($record2->get('sequenceNumber'), 3, "demotion from middle works");
$record2->promote;
is($record2->get('sequenceNumber'), 2, "promotion from middle works");

# deleting
ok($record2->delete, "deletion reports success");
my $copyOfRecord3 = WebGUI::Crud->new($session, $record3->getId);
my $copyOfRecord4 = WebGUI::Crud->new($session, $record4->getId);
is($copyOfRecord3->get('sequenceNumber'), '2', "deletion of record 2 moved record 3 to sequence 2");
is($copyOfRecord4->get('sequenceNumber'), '3', "deletion of record 2 moved record 4 to sequence 3");

# updating
sleep 1;
ok($copyOfRecord4->update, "update returns success");
isnt($copyOfRecord4->get('lastUpdated'), $copyOfRecord4->get('dateCreated'), "updates work");

# retrieve data
my ($sql, $params) = WebGUI::Crud->getAllSql($session);
is($sql, "select `unnamed_crud_table`.`id` from `unnamed_crud_table` order by `unnamed_crud_table`.`sequenceNumber`", "getAllSql() SQL no options");
($sql, $params) = WebGUI::Crud->getAllSql($session, {sequenceKeyValue=>1});
is($sql, "select `unnamed_crud_table`.`id` from `unnamed_crud_table` order by `unnamed_crud_table`.`sequenceNumber`", "getAllSql() SQL sequence key value with no key specified");
is($params->[0], undef, "getAllSql() PARAMS sequence key value with no key specified");
($sql, $params) = WebGUI::Crud->getAllSql($session, {limit=>5});
is($sql, "select `unnamed_crud_table`.`id` from `unnamed_crud_table` order by `unnamed_crud_table`.`sequenceNumber` limit 5", "getAllSql() SQL with a row limit");
($sql, $params) = WebGUI::Crud->getAllSql($session,{limit=>[10,20]});
is($sql, "select `unnamed_crud_table`.`id` from `unnamed_crud_table` order by `unnamed_crud_table`.`sequenceNumber` limit 10,20", "getAllSql() SQL with a start and row limit");
($sql, $params) = WebGUI::Crud->getAllSql($session,{orderBy=>'lastUpdated'});
is($sql, "select `unnamed_crud_table`.`id` from `unnamed_crud_table` order by lastUpdated", "getAllSql() with a custom order by clause");
($sql, $params) = WebGUI::Crud->getAllSql($session,{join=>['someTable using (someId)']});
is($sql, "select `unnamed_crud_table`.`id` from `unnamed_crud_table` left join someTable using (someId) order by `unnamed_crud_table`.`sequenceNumber`", "getAllSql() with a custom join");
($sql, $params) = WebGUI::Crud->getAllSql($session,{joinUsing=>[{myTable => 'myId'}]});
is($sql, "select `unnamed_crud_table`.`id` from `unnamed_crud_table` left join `myTable` using (`myId`) order by `unnamed_crud_table`.`sequenceNumber`", "getAllSql() with a custom joinUsing");
($sql, $params) = WebGUI::Crud->getAllSql($session,{constraints=>[{'sequenceNumber=?'=>1}]});
is($sql, "select `unnamed_crud_table`.`id` from `unnamed_crud_table` where (sequenceNumber=?) order by `unnamed_crud_table`.`sequenceNumber`", "getAllSql() SQL with a constraint");
is($params->[0], 1, "getAllSql PARAMS with a constraint");
($sql, $params) = WebGUI::Crud->getAllSql($session,{constraints=>[{'sequenceNumber=? or sequenceNumber=?'=>[1,2]}]});
is($sql, "select `unnamed_crud_table`.`id` from `unnamed_crud_table` where (sequenceNumber=? or sequenceNumber=?) order by `unnamed_crud_table`.`sequenceNumber`", "getAllSql() SQL with two constraints");
is($params->[1], 2, "getAllSql PARAMS with two constraints");
is(scalar(@{WebGUI::Crud->getAllIds($session)}), 3, "getAllIds()");
my $iterator = WebGUI::Crud->getAllIterator($session);
while (my $object = $iterator->()) {
	isa_ok($object, 'WebGUI::Crud', 'Put your trust in the Lord. Your ass belongs to me.');
}


#crud management stuff
is(ref WebGUI::Crud->crud_getProperties($session), 'HASH', 'properties work');
is(WebGUI::Crud->crud_getTableKey($session), 'id', 'default key is id');
is(WebGUI::Crud->crud_getTableName($session), 'unnamed_crud_table', 'default table is unnamed_crud_table');
is(WebGUI::Crud->crud_getSequenceKey($session), '', 'default sequence key is blank');

#vim:ft=perl
