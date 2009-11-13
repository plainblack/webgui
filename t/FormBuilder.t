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

# Write a little about what this script tests.
# 
#

use FindBin;
use strict;
use lib "$FindBin::Bin/lib";
use Test::More;
use Test::Deep;
use WebGUI::Test; # Must use this before any other WebGUI modules
use WebGUI::Session;

#----------------------------------------------------------------------------
# Init
my $session         = WebGUI::Test->session;


#----------------------------------------------------------------------------
# Tests

plan tests => 53;        # Increment this number for each test you create

#----------------------------------------------------------------------------
# Constructor and properties
use_ok( 'WebGUI::FormBuilder' );
use WebGUI::FormBuilder::Tab;
use WebGUI::FormBuilder::Fieldset;

my $fb = WebGUI::FormBuilder->new( $session );
isa_ok( $fb, 'WebGUI::FormBuilder' );
is( $fb->method, 'POST', 'method default' );
ok( !$fb->action, 'action default' );
is( $fb->enctype, 'multipart/form-data', 'enctype default' );
ok( !$fb->name, 'name default' );

$fb = WebGUI::FormBuilder->new( $session,
    action      => '/myurl',
    enctype     => 'application/x-www-form-urlencoded',
    name        => 'search',
    method      => 'get',
);
isa_ok( $fb, 'WebGUI::FormBuilder' );
is( $fb->method, 'get' );
is( $fb->action, '/myurl' );
is( $fb->enctype, 'application/x-www-form-urlencoded' );
is( $fb->name, 'search' );

# Test mutators
is( $fb->method("POST"), "POST" );
is( $fb->method, "POST" );
is( $fb->action('/otherurl'), '/otherurl' );
is( $fb->action, '/otherurl' );
is( $fb->enctype('multipart/form-data'), 'multipart/form-data' );
is( $fb->enctype, 'multipart/form-data' );
is( $fb->name('myname'), 'myname' );
is( $fb->name, 'myname' );

#----------------------------------------------------------------------------
# Adding objects
# -- This tests the HasTabs, HasFieldsets, and HasFields roles

# addTab with properties
my $tab = $fb->addTab( name => "mytab", label => "My Tab" );
isa_ok( $tab, 'WebGUI::FormBuilder::Tab' );
is( $fb->getTab('mytab'), $tab, 'getTab returns exact object' );
is( $fb->tabs, $fb->tabs, 'tabs always returns same arrayref' );
cmp_deeply(
    $fb->tabs,
    [ $tab ],
    'tabs',
);

# addTab with objects
my $field = $tab->addField( 
    'WebGUI::Form::Text' => (
        name        => 'search',
        value       => "Search Now",
    ) 
);
my $fset = $tab->addFieldset(
    name        => 'advanced',
    label       => 'Advanced Search',
);
my $subtab = $tab->addTab(
    name        => 'more',
    label       => 'More',
);

my $newTab = $fb->addTab( $tab, name => 'newname' );
isa_ok( $newTab, 'WebGUI::FormBuilder::Tab' );
isnt( $newTab, $tab, 'addTab creates a new object from the properties' );
is( $newTab->name, 'newname', 'addTab allows property overrides' );
is( $newTab->label, 'My Tab', 'label was not overridden' );
ok( $newTab->fields->[0], 'field exists' );
is( $newTab->fields->[0]->get('name'), 'search', 'field has same name' );
ok( $newTab->fieldsets->[0], 'fieldset exists' );
is( $newTab->fieldsets->[0]->name, 'advanced', 'fieldset has same name' );
ok( $newTab->tabs->[0], 'subtab exists' );
is( $newTab->tabs->[0]->name, 'more', 'subtab has same name' );


# addFieldset with properties
$fb     = WebGUI::FormBuilder->new( $session );
$fset   = $fb->addFieldset(
    name        => 'advanced',
    label       => 'Advanced Search',
);
is( $fb->getFieldset('advanced'), $fset, 'getFieldset returns exact object' );
is( $fb->fieldsets, $fb->fieldsets, 'fieldsets always returns same arrayref' );
cmp_deeply( 
    $fb->fieldsets,
    [ $fset ],
    'fieldsets',
);

# addFieldset with objects
my $field = $fset->addField( 
    'WebGUI::Form::Text' => (
        name        => 'search',
        value       => "Search Now",
    ) 
);
my $subfset = $fset->addFieldset(
    name        => 'advanced',
    label       => 'Advanced Search',
);
my $tab = $fset->addTab(
    name        => 'more',
    label       => 'More',
);

my $newFset = $fb->addFieldset( $fset, name => 'newname' );
isa_ok( $newFset, 'WebGUI::FormBuilder::Fieldset' );
isnt( $newFset, $fset, 'addFieldset creates a new object from the properties' );
is( $newFset->name, 'newname', 'addFieldset allows property overrides' );
is( $newFset->label, 'Advanced Search', 'label was not overridden' );
ok( $newFset->fields->[0], 'field exists' );
is( $newFset->fields->[0]->get('name'), 'search', 'field has same name' );
ok( $newFset->fieldsets->[0], 'subfieldset exists' );
is( $newFset->fieldsets->[0]->name, 'advanced', 'subfieldset has same name' );
ok( $newFset->tabs->[0], 'tab exists' );
is( $newFset->tabs->[0]->name, 'more', 'tab has same name' );

# addField with properties
$fb         = WebGUI::FormBuilder->new( $session );
my $field   = $fb->addField( 
    'Text' => (
        name        => 'search',
        value       => 'Search Now',
    )
);

isa_ok( $field, 'WebGUI::Form::Text' );
is( $fb->getField('search'), $field, 'getField returns exact object' );
is( $fb->fields, $fb->fields, 'fields always returns same arrayref' );
cmp_deeply( 
    $fb->fields,
    [ $field ],
    'fields',
);

# addField with object
my $field2 = $fb->addField(
    WebGUI::Form::Text->new( $session, {
        name        => 'type',
        label       => "Asset Type",
    } )
);
isa_ok( $field2, 'WebGUI::Form::Text' );
is( $fb->getField('type'), $field2, 'getField returns exact object' );
cmp_deeply(
    $fb->fields,
    [ $field, $field2 ],
    'fields 2',
);

#----------------------------------------------------------------------------
# Serialize and deserialize


#vim:ft=perl
