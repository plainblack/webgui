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

plan tests => 11;        # Increment this number for each test you create

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

my $crud = WebGUI::Crud->create($session);
isa_ok($crud, "WebGUI::Crud", "isa WebGUI::Crud");
like($crud->get('dateCreated'), qr/\d{4}-\d{2}-\d{2}\s\d{2}:\d{2}:\d{2}/, "dateCreated looks like a date");
like($crud->get('lastUpdated'), qr/\d{4}-\d{2}-\d{2}\s\d{2}:\d{2}:\d{2}/, "lastUpdated looks like a date");


#----------------------------------------------------------------------------
# Cleanup
END {
	
WebGUI::Crud->crud_dropTable($session);

}
#vim:ft=perl
