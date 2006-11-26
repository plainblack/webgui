#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2006 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use FindBin;
use strict;
use lib "$FindBin::Bin/lib";
use WebGUI::Test;
use WebGUI::Session;
use Test::More; # increment this value for each test you create

my $session = WebGUI::Test->session;

my $numTests = 1; ##For conditional load check
$numTests += 9;

plan tests => $numTests;

my $loaded = use_ok('WebGUI::International');

SKIP: {

skip 'Module was not loaded, skipping all tests', $numTests-1 unless $loaded;

my $i18n = WebGUI::International->new($session, undef, 'English');

isa_ok($i18n, 'WebGUI::International', 'object of correct type created');

is($i18n->getNamespace(), undef, 'getNamespace: default namespace is undef');
is($i18n->get('topicName'), 'WebGUI', 'get: get English label for topicName with default namespace: WebGUI');

$i18n->setNamespace('WebGUI');
is($i18n->getNamespace(), 'WebGUI', 'getNamespace: set namespace to WebGUI');
is($i18n->get('topicName'), 'WebGUI', 'get: get English label for topicName: WebGUI');
is($i18n->get('84'), 'Group Name', 'get: get English label for 84: Group Name');

$i18n->setNamespace('Asset');
is($i18n->getNamespace(), 'Asset', 'getNamespace: set namespace to Asset');
is($i18n->get('topicName'), 'Assets', 'get: get English label for topicName in Asset: Assets');
is($i18n->get('topicName', 'WebGUI'), 'WebGUI', 'get: test manual namespace override');

}
