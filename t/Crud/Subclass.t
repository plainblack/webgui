package WebGUI::Crud::Subclass;

use strict;
use base 'WebGUI::Crud';
sub crud_definition {
    my ($class, $session) = @_;
    my $definition = $class->SUPER::crud_definition($session);
    $definition->{tableName}   = 'crudSubclass';
    $definition->{tableKey}    = 'crudSubclassId';
    $definition->{sequenceKey} = '';
    my $properties = $definition->{properties};
    $properties->{field1} = {
        fieldType    => 'integer',
        defaultValue => 5,
    };    
    return $definition;
}

#package main;
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

# Tests a subclass of WebGUI::Crud
use FindBin;
use strict;
use lib "$FindBin::Bin/../lib";
use Test::More;
use WebGUI::Test; # Must use this before any other WebGUI modules

#----------------------------------------------------------------------------
# Init
my $session         = WebGUI::Test->session;

#----------------------------------------------------------------------------
# Tests

plan tests => 4;        # Increment this number for each test you create

#----------------------------------------------------------------------------

# Create
WebGUI::Crud::Subclass->crud_createTable($session);
my $record1 = WebGUI::Crud::Subclass->create($session, { field1 => 10 });
isa_ok($record1, "WebGUI::Crud", "isa WebGUI::Crud");
is($record1->get('field1'), 10, "got back correct field1 value");

# bug #10660 (zero should not trigger defaultValue)
is(WebGUI::Crud::Subclass->create($session, { field1 => 0 })->get('field1'), 0, 'zero does not trigger default');
is(WebGUI::Crud::Subclass->create($session, { field1 => '' })->get('field1'), 5, '..but empty string intentionally triggers default');

#----------------------------------------------------------------------------
# Cleanup
END {
	
WebGUI::Crud::Subclass->crud_dropTable($session);

}
#vim:ft=perl
