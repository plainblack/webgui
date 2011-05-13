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

use strict;
use Test::More;
use Data::Dumper;
use File::Spec;
use WebGUI::Test; # Must use this before any other WebGUI modules
use WebGUI::Session;
use WebGUI::Form::Text;
use WebGUI::Form::HTMLArea;

#----------------------------------------------------------------------------
# Init
my $session         = WebGUI::Test->session;

my $newUser         = WebGUI::User->create( $session );
WebGUI::Test->addToCleanup($newUser);

#----------------------------------------------------------------------------
# Tests

plan tests => 58;        # Increment this number for each test you create

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


my $langField;
ok( $langField = WebGUI::ProfileField->new( $session, 'language' ), 'field "language instantiated' );
isa_ok( $langField, 'WebGUI::ProfileField' );

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



$ff         = undef;
$ffvalue    = undef;
ok( $ff     = $langField->formField, 'formField method returns something, language field, session user' );
$ffvalue    = $session->user->profileField('language');
like( $ff, qr/value="$ffvalue"[^>]+selected/, 'html returned contains value, language field, session user' );

installPigLatin();
WebGUI::Test->addToCleanup(sub {
	unlink File::Spec->catfile(WebGUI::Test->lib, qw/WebGUI i18n PigLatin WebGUI.pm/);
	unlink File::Spec->catfile(WebGUI::Test->lib, qw/WebGUI i18n PigLatin.pm/);
	rmdir File::Spec->catdir(WebGUI::Test->lib, qw/WebGUI i18n PigLatin/);
});

$ff         = undef;
$ffvalue    = "PigLatin";
$session->scratch->setLanguageOverride($ffvalue);
ok( $ff     = $langField->formField, 'formField method returns something, language field, session user, languageOverride' );
like( $ff, qr/value="$ffvalue"[^>]+selected/, 'html returned contains value, language field, session user, languageOverride' );
$session->scratch->delete('language');

###########################################################
#
# create
#
###########################################################

my $newProfileField = WebGUI::ProfileField->create($session, 'testField', {
    fieldType => 'Float',  ##Note, intentionally choosing a non-Text type of field
    label     => 'Test Field',
});

is($newProfileField->get('fieldType'), 'Float', 'create: makes field with correct type');
is $newProfileField->get('fieldName'), 'testField', '...correct fieldName';
is $newProfileField->getId, 'testField', '...correct id';
is($newProfileField->get('label'), 'Test Field', 'correct label');
is($newProfileField->getLabel, 'Test Field', 'getLabel works, too');

my $textFieldType = lc WebGUI::Form::Float->getDatabaseFieldType();
my $htmlFieldType = lc WebGUI::Form::HTMLArea->getDatabaseFieldType();

my $fieldSpec = $session->db->quickHashRef('describe userProfileData testField');
is (lc $fieldSpec->{Type}, $textFieldType, 'test field created with correct type for text field');

$newProfileField->set({ fieldType => 'HTMLArea' });
is($newProfileField->get('fieldType'), 'HTMLArea', 'test field updated to HTMLArea');

$fieldSpec = $session->db->quickHashRef('describe userProfileData testField');
is (lc $fieldSpec->{Type}, $htmlFieldType, 'database updated along with profile field object');

my $newProfileField2 = WebGUI::ProfileField->create($session, 'testField2', {
    label     => q|WebGUI::International::get('webgui','WebGUI')|,
    fieldName => 'Text',
});

is($newProfileField2->get('fieldType'), 'ReadOnly', 'create: default fieldType is ReadOnly');
is($newProfileField2->get('label'), q|WebGUI::International::get('webgui','WebGUI')|, 'getting raw label');
is($newProfileField2->getLabel, 'WebGUI', 'getLabel will process safeEval calls for i18n');
$newProfileField->delete;
$newProfileField2->delete;

$newProfileField = WebGUI::ProfileField->create($session, 'space field', {
    fieldType => 'Float',
    label     => 'Space Field',
});
is $newProfileField, undef, 'create returns undef if the field name contains white space';

###########################################################
#
# exists
#
###########################################################

ok( WebGUI::ProfileField->exists($session,"firstName"), "firstName field exists" );
ok( !WebGUI::ProfileField->exists($session, time), "random field does not exist" );

###########################################################
#
# isReservedFieldName
#
###########################################################

ok(  WebGUI::ProfileField->isReservedFieldName('func'),   'isReservedFieldName: func');
ok(  WebGUI::ProfileField->isReservedFieldName('op'),     '... op');
ok(  WebGUI::ProfileField->isReservedFieldName('userId'), '... userId');
ok(  WebGUI::ProfileField->isReservedFieldName('wg_privacySettings'), '... wg_privacySettings');
ok( !WebGUI::ProfileField->isReservedFieldName('function'),  '... function is not');
ok( !WebGUI::ProfileField->isReservedFieldName('operation'), '... operation is not');
ok(  WebGUI::ProfileField->isReservedFieldName('shop'),      '... shop is not');
ok(  WebGUI::ProfileField->isReservedFieldName('username'),  '... username');
ok(  WebGUI::ProfileField->isReservedFieldName('status'),    '... status');

###########################################################
#
# exists
#
###########################################################

ok(  WebGUI::ProfileField->exists($session, 'email'),  'exists: email');
ok( !WebGUI::ProfileField->exists($session, 'userId'), '... userId (not)');

###########################################################
#
# set
#
###########################################################

my $newProfileField3 = WebGUI::ProfileField->create($session, 'testField3', {
    label     => q|WebGUI::International::get('webgui','WebGUI')|,
    fieldName => 'Text',
});

is ($newProfileField3->get('editable'), 0, 'default editable = 0');
is ($newProfileField3->get('required'), 0, 'default required = 0');

$newProfileField3->set({ editable => 1});
is ($newProfileField3->get('editable'), 1, 'set editable=1');
is ($newProfileField3->get('required'), 0, '... required=0');

$newProfileField3->set({ editable => 0});
is ($newProfileField3->get('editable'), 0, 'set editable = 0');
is ($newProfileField3->get('required'), 0, '... required = 0');

$newProfileField3->set({ required => 1});
is ($newProfileField3->get('required'), 1, 'set required = 1');
is ($newProfileField3->get('editable'), 1, '... editable = 1');
$newProfileField3->delete;

###########################################################
#
# form fields, extras, form properties
#
###########################################################

my $extra_field = WebGUI::ProfileField->create($session, 'textual',
    {
        label     => 'Textual',
        fieldName => 'Textual',
        extras    => q|class="texted"|,
    }
);

is $extra_field->get('extras'), q|class="texted"|, 'extras set on field creation';
is $extra_field->formProperties->{extras}, q|class="texted"|, 'extras available from formProperties';

$extra_field->delete;

sub installPigLatin {
    use File::Copy;
	mkdir File::Spec->catdir(WebGUI::Test->lib, 'WebGUI', 'i18n', 'PigLatin');
	copy( 
		WebGUI::Test->getTestCollateralPath('International/lib/WebGUI/i18n/PigLatin/WebGUI.pm'),
		File::Spec->catfile(WebGUI::Test->lib, qw/WebGUI i18n PigLatin WebGUI.pm/)
	);
	copy(
		WebGUI::Test->getTestCollateralPath('International/lib/WebGUI/i18n/PigLatin.pm'),
		File::Spec->catfile(WebGUI::Test->lib, qw/WebGUI i18n PigLatin.pm/)
	);
}


