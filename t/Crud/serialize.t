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

# Tests WebGUI::Crud


use strict;
use Test::More;
use Test::Deep;
use JSON;
use WebGUI::Test; # Must use this before any other WebGUI modules
use WebGUI::Session;

#----------------------------------------------------------------------------
# Init
my $session         = WebGUI::Test->session;

#----------------------------------------------------------------------------
# Tests

plan tests => 10;        # Increment this number for each test you create

#----------------------------------------------------------------------------
use_ok('WebGUI::Serialize');

WebGUI::Serialize->crud_createTable($session);
WebGUI::Test->addToCleanup(sub {
    WebGUI::Serialize->crud_dropTable($session);
});

my $cereal = WebGUI::Serialize->new($session);
$cereal->write;
isa_ok($cereal, 'WebGUI::Serialize');
cmp_deeply(
    $cereal->get,
    {
        someName       => 'someName',
        jsonField      => [],
        dateCreated    => ignore(),
        lastUpdated    => ignore(),
        sequenceNumber => ignore(),
        serializeId    => ignore(),
    },
    'object contains data structure in the jsonField, not JSON'
);

my $expectedJson = $session->db->quickScalar('select jsonField from crudSerialize where serializeId=?', [ $cereal->getId]);
is ($expectedJson, '[]', 'json stored in the db');

$cereal->update({someName => 'Raisin Bran'});
my $name = $session->db->quickScalar('select someName from crudSerialize where serializeId=?', [ $cereal->getId]);
is($cereal->get('someName'), 'Raisin Bran', 'sparse object update works');
is($name, 'Raisin Bran', 'sparse update to db works');

$cereal->update({jsonField => [ { sugarContent => 50, averageNutrition => 3, foodColoring => 15,} ], });
cmp_deeply(
    $cereal->get('jsonField'),
    [
        {
            sugarContent     => 50,
            averageNutrition => 3,
            foodColoring     => 15,
        },
    ],
    'update/get work on json field'
);

my $json = $session->db->quickScalar('select jsonField from crudSerialize where serializeId=?', [ $cereal->getId]);
my $dbData = from_json($json);
cmp_deeply(
    $dbData,
    [
        {
            sugarContent     => 50,
            averageNutrition => 3,
            foodColoring     => 15,
        },
    ],
    'correct JSON data stored into db'
);

my $cereal2 = WebGUI::Serialize->new($session, $cereal->getId);
cmp_deeply(
    $cereal2->get('jsonField'),
    [
        {
            sugarContent     => 50,
            averageNutrition => 3,
            foodColoring     => 15,
        },
    ],
    'new: deserialized data correctly'
);

use Data::Dumper;
my $objData = $cereal->get('jsonField');
$objData->[0]->{fiber} = 0;
cmp_deeply(
    $cereal->get('jsonField'),
    [
        {
            sugarContent     => 50,
            averageNutrition => 3,
            foodColoring     => 15,
        },
    ],
    'get: returns safe references'
) or diag Dumper($cereal->jsonField);

#vim:ft=perl
