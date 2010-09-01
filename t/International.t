#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2009 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use strict;
use WebGUI::Test;
use WebGUI::Session;
use Test::More; # increment this value for each test you create
use File::Copy;
use File::Spec;
use WebGUI::Content::SetLanguage;

my $session = WebGUI::Test->session;

plan tests => 25;

my $loaded = use_ok('WebGUI::International');

my $i18n = WebGUI::International->new($session, undef, 'English');

isa_ok($i18n, 'WebGUI::International', 'object of correct type created');

is($i18n->getNamespace(), 'WebGUI', 'getNamespace: default namespace is undef');
is($i18n->get('topicName'), 'WebGUI', 'get: get English label for topicName with default namespace: WebGUI');

$i18n->setNamespace('WebGUI');
is($i18n->getNamespace(), 'WebGUI', 'getNamespace: set namespace to WebGUI');
is($i18n->get('topicName'), 'WebGUI', 'get: get English label for topicName: WebGUI');
is($i18n->get('84'), 'Group Name', 'get: get English label for 84: Group Name');

$i18n->setNamespace('Asset');
is($i18n->getNamespace(), 'Asset', 'getNamespace: set namespace to Asset');
is($i18n->get('topicName'), 'Assets', 'get: get English label for topicName in Asset: Assets');
is($i18n->get('topicName', 'WebGUI'), 'WebGUI', 'get: test manual namespace override');

local @INC = @INC;
unshift @INC, File::Spec->catdir( WebGUI::Test->getTestCollateralPath, 'International', 'lib' );

#tests for sub new
my $i18nNew1 = WebGUI::International->new($session);
is($i18nNew1->{_language}, 'English', 'Calling new without parameters should return object with language English');
is($i18nNew1->{_namespace}, 'WebGUI', 'Calling without parameters should give namespace WebgUI');
my $i18nNew2 = WebGUI::International->new($session, 'WebGUI::Asset');
is($i18nNew2->{_language}, 'English', 'Calling new with only namespace parameter should return object with language English');
is($i18nNew2->{_namespace}, 'WebGUI::Asset', 'Calling with only parameter namespace should give requested namespace');
my $i18nNew3 = WebGUI::International->new($session, undef , 'PigLatin');
is($i18nNew3->{_language}, 'PigLatin', 'Calling new with only language parameter should return object with language PigLatin');
is($i18nNew3->{_namespace}, 'WebGUI', 'Calling with only parameter namespace should give WebGUI ');
my $languages = $i18n->getLanguages();

my $gotPigLatin = exists $languages->{PigLatin};

	is(
		$i18n->get('account','WebGUI','English'),
		$i18n->get('account','WebGUI','PigLatin'),
		'Language check: missing key returns English key'
	);
	is(
		$i18n->get('webgui','WebGUI','PigLatin'),
		'ebGUIWay',
		'Language check: existing key returns native language key'
	);
	is(
		$i18n->get('104','Asset','PigLatin'),
		$i18n->get('104', 'WebGUI', 'English'),
		'Language check: key from missing file return English key'
	);
	is(
		$i18n->get('neverAValidKey','notAValidFile','PigLatin'),
		undef,
		'Language check: key from non-existant file returns an empty string'
	);
	is(
		$i18n->get('key with spaces in it','WebGUI','PigLatin'),
		'Key Contained Spaces',
		'keys with spaces work'
	);

is($i18n->getLanguage('English', 'label'), 'English', 'getLanguage, specific property');

isa_ok($i18n->getLanguage('English'), 'HASH', 'getLanguage, without a specific property returns a hashref');

#test for sub new with language overridden by scratch
my $formvariables = {
    'op' =>'setLanguage',
    'language' => 'PigLatin'
};
$session->request->setup_body($formvariables);
WebGUI::Content::SetLanguage::handler($session);
my $newi18n = WebGUI::International->new($session);
is(
    $newi18n->get('webgui','WebGUI','PigLatin'),
    'ebGUIWay',
    'if the piglatin language is in the scratch that messages should be retrieved'
);
is(
    $newi18n->get('104','Asset','PigLatin'),
    $newi18n->get('104', 'WebGUI', 'English'),
    'Language check after SetLanguage contentHandler : key from missing file return English key'
);

#vim:ft=perl
