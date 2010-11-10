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
use strict;
use Test::More;
use WebGUI::Test; # Must use this before any other WebGUI modules
use WebGUI::SubClass;

#----------------------------------------------------------------------------
# Init
my $session         = WebGUI::Test->session;

#----------------------------------------------------------------------------
# Tests

plan tests => 4;        # Increment this number for each test you create

#----------------------------------------------------------------------------

# Create
WebGUI::Crud::Subclass->crud_createTable($session);
WebGUI::Test->addToCleanup(sub { WebGUI::Crud::Subclass->crud_dropTable($session); });
my $record1 = WebGUI::Crud::Subclass->new($session, { field1 => 10 });
isa_ok($record1, "WebGUI::Crud", "isa WebGUI::Crud");
is($record1->get('field1'), 10, "got back correct field1 value");

# bug #10660 (zero should not trigger defaultValue)
is(WebGUI::Crud::Subclass->new($session, { field1 => 0 })->get('field1'), 0, 'zero does not trigger default');
is(WebGUI::Crud::Subclass->new($session, { field1 => '' })->get('field1'), '', '..but empty string does not trigger default either');

#vim:ft=perl
