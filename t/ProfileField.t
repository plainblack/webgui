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

# This test the WebGUI::ProfileField object
# 
#

use FindBin;
use strict;
use lib "$FindBin::Bin/lib";
use Test::More;
use Data::Dumper;
use WebGUI::Test; # Must use this before any other WebGUI modules
use WebGUI::Session;
use WebGUI::Form::Text;
use WebGUI::Form::HTMLArea;

#----------------------------------------------------------------------------
# Init
my $session         = WebGUI::Test->session;

my $newUser         = WebGUI::User->create( $session );
WebGUI::Test->usersToDelete($newUser);

#----------------------------------------------------------------------------
# Tests

plan tests => 20;        # Increment this number for each test you create

#----------------------------------------------------------------------------
# Test the creation of ProfileField
use_ok( 'WebGUI::ProfileField' );

is( WebGUI::ProfileField->new( $session ),          undef, 'new() returns undef with no id' );
is( WebGUI::ProfileField->new( $session, 'op'),     undef, 'new() returns undef with reserved field ID "op"' );
is( WebGUI::ProfileField->new( $session, 'func' ),  undef, 'new() returns undef with reserved field ID "func"' );
is( WebGUI::ProfileField->new( $session, 'fjnwsifkmamdiwjen' ), undef, 'new() returns undef with field ID not found' );
my $aliasField;
ok( $aliasField = WebGUI::ProfileField->new( $session, 'alias' ), 'field "alias" instantiated' );
isa_ok( $aliasField, 'WebGUI::ProfileField' );

my $uilevelField;
ok( $uilevelField = WebGUI::ProfileField->new( $session, 'uiLevel' ), 'field "uiLevel instantiated' );
isa_ok( $uilevelField, 'WebGUI::ProfileField' );

#----------------------------------------------------------------------------
# Test the formField method

my $ff      = undef;
my $ffvalue = undef;
ok( $ff  = $aliasField->formField, 'formField method returns something, alias field, session user' );
$ffvalue = $session->user->profileField('alias');
like( $ff, qr/$ffvalue/, 'html returned contains value, alias field, session user' );

$ff         = undef;
$ffvalue    = undef;
ok( $ff     = $uilevelField->formField, 'formField method returns something, uiLevel field, session user' );
$ffvalue    = $session->user->profileField('uiLevel');
like( $ff, qr/value="$ffvalue"[^>]+selected/, 'html returned contains value, uiLevel field, session user' );

# Test with a newly created user that has no profile fields filled in
$ff         = undef;
$ffvalue    = undef;
ok( $ff = $aliasField->formField(undef, undef, $newUser), 'formField method returns something, alias field, defaulted user' );
$ffvalue = $newUser->profileField('alias');
like( $ff, qr/$ffvalue/, 'html returned contains value, alias field, defaulted user' );

$ff         = undef;
$ffvalue    = undef;
ok( $ff = $uilevelField->formField(undef, undef, $newUser), 'formField method returns something, uiLevel field, defaulted user' );
$ffvalue = $newUser->profileField('uiLevel');
like( $ff, qr/$ffvalue/, 'html returned contains value, uiLevel field, defaulted user' );

#########################################################
#
# set, changing fieldTypes
#
#########################################################

my $newProfileField = WebGUI::ProfileField->create($session, 'testField', {
    fieldType => 'Text',
    label     => 'Test Field',
});

my $textFieldType = lc WebGUI::Form::Text->getDatabaseFieldType();
my $htmlFieldType = lc WebGUI::Form::HTMLArea->getDatabaseFieldType();

my $fieldSpec = $session->db->quickHashRef('describe userProfileData testField');
is (lc $fieldSpec->{Type}, $textFieldType, 'test field created with correct type for text field');

$newProfileField->set({ fieldType => 'HTMLArea' });
is($newProfileField->get('fieldType'), 'HTMLArea', 'test field updated to HTMLArea');

$fieldSpec = $session->db->quickHashRef('describe userProfileData testField');
is (lc $fieldSpec->{Type}, $htmlFieldType, 'database updated along with profile field object');

#----------------------------------------------------------------------------
# Cleanup
END {
    $newProfileField->delete;
}


