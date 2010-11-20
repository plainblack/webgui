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

################################################################
#
# Checks that Assets can use WebGUI::JSONCollateral, that assets
# can automatically serialize and deserialize data structures
# and other asset functions work correctly.
#
################################################################

use WebGUI::Test;
use WebGUI::Session;
use WebGUI::Asset;
use WebGUI::AssetVersioning;
use WebGUI::VersionTag;
use WebGUI::Asset::JSONCollateralDummy;

use Test::More;
use Test::Deep;
use Data::Dumper;

my $session = WebGUI::Test->session;

$session->db->write(<<EOSQL);
drop table if exists jsonCollateralDummy
EOSQL

$session->db->write(<<EOSQL);
create table jsonCollateralDummy (
  `assetId`      varchar(22) character set utf8 collate utf8_bin NOT NULL,
  `revisionDate` bigint(20) NOT NULL default '0',
  `jsonField`    mediumtext,
  PRIMARY KEY  (`assetId`,`revisionDate`)
) ENGINE=MyISAM DEFAULT CHARSET=latin1;
EOSQL

WebGUI::Test->addToCleanup(SQL => 'drop table jsonCollateralDummy');

plan tests => 40;

my $asset = WebGUI::Test->asset->addChild({
    className => 'WebGUI::Asset::JSONCollateralDummy',
    title     => 'JSON Collateral Test Asset',
});

################################################################
#
# Checking Asset serialization
#
################################################################

isa_ok($asset, 'WebGUI::Asset::JSONCollateralDummy');
cmp_deeply(
    $asset->get('jsonField'),
    [],
    'jsonField set to empty arrayref initially'
);

is(
    $session->db->quickScalar(q|select jsonField from jsonCollateralDummy where assetId=? and revisionDate=?|, [$asset->getId, $asset->get('revisionDate')]),
    '[]',
    'bare JSON arrayref stored in the db'
);

$asset->update({
    jsonField => [ { alpha => "aye", beta => "bee", },  ],
});

is(
    $session->db->quickScalar(q|select jsonField from jsonCollateralDummy where assetId=? and revisionDate=?|, [$asset->getId, $asset->get('revisionDate')]),
    '[{"alpha":"aye","beta":"bee"}]',
    'JSON updated in the db'
);

cmp_deeply(
    $asset->get('jsonField'),
    [ { alpha => "aye", beta => "bee"} ],
    'get returns a hash ref with data in it'
);

################################################################
#
# Checking Asset deserialization
#
################################################################

my $assetClone = $asset->cloneFromDb;

cmp_deeply(
    $assetClone->get('jsonField'),
    [ { alpha => "aye", beta => "bee"} ],
    'new deserializes data from the db'
);

$asset->update({
    jsonField => [ ],
});

################################################################
#
# setJSONCollateral, getJSONCollateral
#
################################################################

my $key1 = $asset->setJSONCollateral('jsonField', 'jsonId', 'new', { first => "one", second => "two", });
ok($session->id->valid($key1), 'setJSONCollateral: returns a valid guid, new, no key in collateral');

my $key2 = $asset->setJSONCollateral('jsonField', 'jsonId', '', { first => "uno", second => "dos", });
ok($session->id->valid($key2), '... returns a valid guid, empty key, no key in collateral');
isnt($key2, $key1, '... returns unique guids each time.  Generates GUID if guid is ""');

my $key3 = $session->id->generate();

my $returnedKey;
$returnedKey = $asset->setJSONCollateral('jsonField', 'jsonId', 'new', { first => 'Aye', second => 'Bay', jsonId => $key3});
is($returnedKey, $key3, '... created collateral with set GUID');

$returnedKey = $asset->setJSONCollateral('jsonField', 'jsonId', 'new', { first => 'Aye', second => 'Bay', jsonId => 'notAGUID'});
isnt($returnedKey, 'notAGUID', '... created valid GUID when passed a new one');

my $collateral;
$collateral = $asset->getJSONCollateral('jsonField', 'jsonId', 'notAGUID');
cmp_deeply( $collateral, {}, 'getJSONCollateral returns empty hashref for a non-existant id');

$collateral = $asset->getJSONCollateral('jsonField', 'jsonId', "new");
cmp_deeply( $collateral, {}, '... returns empty hashref for id=new');

$collateral = $asset->getJSONCollateral('jsonField', 'jsonId', "");
cmp_deeply( $collateral, {}, '... returns empty hashref for id=""');

################################################################
#
# Setup for move, delete tests.
#
################################################################

$asset->update({
    jsonField => [ ],
});

my $guid1 = $asset->setJSONCollateral('jsonField', 'jsonId', 'new', { first => 'alpha', second => 'beta'});
my $guid2 = $asset->setJSONCollateral('jsonField', 'jsonId', '', { first => 'aee', second => 'bee'});

cmp_deeply(
    $asset->get('jsonField'),
    [
        { first => 'alpha', second => 'beta', jsonId => $guid1, },
        { first => 'aee',   second => 'bee',  jsonId => $guid2, },
    ],
    '...checking collateral content, deeply'
);

my $guid3 = $asset->setJSONCollateral('jsonField', 'jsonId', 'new', { first => 'Aye', second => 'Bay', });

my $retVal;
$retVal = $asset->setJSONCollateral('jsonField', 'jsonId', $guid3, { first => 'ahh', second => 'bay', jsonId => $guid3, });

is($retVal, $guid3, 'setJSONCollateral returns GUID when it modifies existing collateral');
cmp_deeply(
    $asset->getJSONCollateral('jsonField', 'jsonId', $guid3),
    { first => 'ahh', second => 'bay', jsonId => $guid3 },
    '... collateral updated'
);

$retVal = $asset->setJSONCollateral('jsonField', 'jsonId', scalar reverse $guid3, { first => 'ook', second => 'eek'});
ok(!$retVal, '... returns false when it fails');
cmp_deeply(
    $asset->getJSONCollateral('jsonField', 'jsonId', $guid3),
    { first => 'ahh', second => 'bay', jsonId => $guid3 },
    '... collateral not updated'
);

cmp_deeply(
    [ map { $_->{jsonId} } @{ $asset->get('jsonField') } ],
    [
        $guid1,
        $guid2,
        $guid3,
    ],
    '...checking collateral order, ready for moving collateral'
);

################################################################
#
# getJSONCollateralDataIndex
#
################################################################

is(
    $asset->getJSONCollateralDataIndex($asset->get('jsonField'), 'jsonId', $guid1),
    0,
    'getJSONCollateralDataIndex: guid1 in the correct position'
);

is(
    $asset->getJSONCollateralDataIndex($asset->get('jsonField'), 'jsonId', scalar reverse($guid1)),
    -1,
    '... returns -1 when it cannot be found'
);

is(
    $asset->getJSONCollateralDataIndex($asset->get('jsonField'), 'JSONID', $guid1),
    -1,
    '... returns -1 when it cannot be found'
);

################################################################
#
# moveJSONCollateralDown
#
################################################################

cmp_deeply(
    [ map { $_->{jsonId} } @{ $asset->get('jsonField') } ],
    [
        $guid1,
        $guid2,
        $guid3,
    ],
    '...checking collateral order, ready for moving collateral'
);

$retVal = $asset->moveJSONCollateralDown('jsonField', 'jsonId', $guid3);
ok(!$retVal, 'moveJSONCollateralDown returned false');

cmp_deeply(
    [ map { $_->{jsonId} } @{ $asset->get('jsonField') } ],
    [
        $guid1,
        $guid2,
        $guid3,
    ],
    '...order did not change. Cannot move last one down'
);
$retVal = $asset->moveJSONCollateralDown('jsonField', 'jsonId', scalar reverse $guid3);
ok(!$retVal, '... returned false again (nonexistant guid)');

cmp_deeply(
    [ map { $_->{jsonId} } @{ $asset->get('jsonField') } ],
    [
        $guid1,
        $guid2,
        $guid3,
    ],
    '...order did not change. Cannot move an entry that cannot be found'
);

$retVal = $asset->moveJSONCollateralDown('jsonField', 'jsonId', $guid1);
ok($retVal, '... returned true');

cmp_deeply(
    [ map { $_->{jsonId} } @{ $asset->get('jsonField') } ],
    [
        $guid2,
        $guid1,
        $guid3,
    ],
    '...order changed'
);

################################################################
#
# moveJSONCollateralUp
#
################################################################

$retVal = $asset->moveJSONCollateralUp('jsonField', 'jsonId', $guid2);
ok(!$retVal, 'moveJSONCollateralUp returned false');

cmp_deeply(
    [ map { $_->{jsonId} } @{ $asset->get('jsonField') } ],
    [
        $guid2,
        $guid1,
        $guid3,
    ],
    '...order did not change. Cannot move first one up'
);
$retVal = $asset->moveJSONCollateralUp('jsonField', 'jsonId', scalar reverse $guid3);
ok(!$retVal, '... returned false again (nonexistant guid)');

cmp_deeply(
    [ map { $_->{jsonId} } @{ $asset->get('jsonField') } ],
    [
        $guid2,
        $guid1,
        $guid3,
    ],
    '...order did not change. Cannot move an entry that cannot be found'
);

$retVal = $asset->moveJSONCollateralUp('jsonField', 'jsonId', $guid3);
ok($retVal, '... returned true');

cmp_deeply(
    [ map { $_->{jsonId} } @{ $asset->get('jsonField') } ],
    [
        $guid2,
        $guid3,
        $guid1,
    ],
    '...order changed'
);

################################################################
#
# deleteJSONCollateral
#
################################################################

$retVal = $asset->deleteJSONCollateral('jsonField', 'jsonId', scalar reverse $guid3);
ok(!$retVal, 'deleteJSONCollateral returns false with an invalid id');
cmp_deeply(
    [ map { $_->{jsonId} } @{ $asset->get('jsonField') } ],
    [
        $guid2,
        $guid3,
        $guid1,
    ],
    '...nothing was deleted'
);

$retVal = $asset->deleteJSONCollateral('jsonField', 'jsonId', $guid3);
ok($retVal, '... delete was successful');
cmp_deeply(
    [ map { $_->{jsonId} } @{ $asset->get('jsonField') } ],
    [
        $guid2,
        $guid1,
    ],
    '...collateral was removed'
);

