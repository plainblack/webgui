# vim:syntax=perl
#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2008 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#------------------------------------------------------------------

# Tests WebGUI::Crud


use FindBin;
use strict;
use lib "$FindBin::Bin/lib";
use Test::More;
use WebGUI::Test; # Must use this before any other WebGUI modules
use WebGUI::Session;
use WebGUI::Crud;

#----------------------------------------------------------------------------
# Init
my $session         = WebGUI::Test->session;


#----------------------------------------------------------------------------
# Tests

plan tests => 29;        # Increment this number for each test you create

#----------------------------------------------------------------------------

# check table structure
WebGUI::Crud->crud_createTable($session);
my $sth = $session->db->read("describe unnamed_crud_table");
my ($col, $type) = $sth->array();
is($col, 'id', "structure: id name");
is($type, 'varchar(22)', "structure: id type");
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


#----------------------------------------------------------------------------
# Cleanup
END {
	
WebGUI::Crud->crud_dropTable($session);

}
#vim:ft=perl
