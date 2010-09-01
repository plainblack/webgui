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

use strict;
use Test::More;
use Test::Deep;
use WebGUI::Test; # Must use this before any other WebGUI modules
use WebGUI::Session;

#----------------------------------------------------------------------------
# Init
my $session         = WebGUI::Test->session;


#----------------------------------------------------------------------------
# Tests

plan tests => 69;        # Increment this number for each test you create

#----------------------------------------------------------------------------
# Constructor and properties
use_ok( 'WebGUI::FormBuilder' );

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
is( $fb->tabsets, $fb->tabsets, 'tabsets always returns same arrayref' );
cmp_deeply(
    $fb->tabsets,
    [ $fb->getTabset( "default" ) ],
    'tabsets',
);
cmp_deeply( 
    $fb->tabsets->[0]->tabs,
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
ok( $newTab->tabsets->[0], 'subtabset exists' );
is( $newTab->tabsets->[0]->name, 'default', 'subtabset has correct name' );
ok( $newTab->tabsets->[0]->tabs->[0], 'subtab exists' );
is( $newTab->tabsets->[0]->tabs->[0]->name, 'more', 'subtab has correct name' );

cmp_deeply( 
    $fb->tabsets->[0]->tabs,
    [ $tab, $newTab ],
    'added tab',
);
is( $fb->getTab('newname'), $newTab, 'new tab can be gotten' );

# deleteTab
my $deletedTab = $fb->deleteTab( 'newname' );
is( $deletedTab, $newTab, 'deleteTab returns object' );
cmp_deeply(
    $fb->tabsets->[0]->tabs,
    [ $tab ],
    'deleted tab',
);
ok( !$fb->getTab('newname'), 'deleted tab cannot be gotten' );

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
ok( $newFset->tabsets->[0]->tabs->[0], 'tab exists' );
is( $newFset->tabsets->[0]->tabs->[0]->name, 'more', 'tab has same name' );
cmp_deeply( 
    $fb->fieldsets,
    [ $fset, $newFset],
    'added fieldset',
);
is( $fb->getFieldset('newname'), $newFset, 'new fieldset can be gotten' );

# deletefieldset
my $deletedFieldset = $fb->deleteFieldset( 'newname' );
is( $deletedFieldset, $newFset, 'deletefieldset returns object' );
cmp_deeply(
    $fb->fieldsets,
    [ $fset ],
    'deleted fieldset',
);
ok( !$fb->getFieldset('newname'), 'deleted fieldset cannot be gotten' );

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

# deleteField
my $field3 = $fb->deleteField( 'type' );
is( $field3, $field2, 'deleteField returns same field' );
ok( !$fb->getField('type'), 'field is deleted' );
cmp_deeply(
    $fb->fields,
    [ $field ],
    'field is deleted from fields',
);


#----------------------------------------------------------------------------
# Serialize and deserialize

my $fb      = WebGUI::FormBuilder->new( $session );
my $fset    = $fb->addFieldset( name => 'search', label => 'Search' );
$fset->addField( 'text', name => 'keywords', label => 'Keywords' );
my $tab     = $fb->addTab( name => 'advanced', label => 'Advanced Search' );
$tab->addField( 'text', name => 'type', label => 'Type' );
$fb->addField( 'submit', name => 'submit', label => 'Submit' );


#----------------------------------------------------------------------------
# toHtml

print $fb->toHtml;

#vim:ft=perl
