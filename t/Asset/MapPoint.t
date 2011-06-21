#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2009 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

# 1. The basic framework for a test suite for Map Points.
# Includes setup, cleanup, boilerplate, etc. Basically the really boring,
# repetitive parts of the test that you don't want to write yourself.

use FindBin;
use strict;
use lib "$FindBin::Bin/../lib";
use WebGUI::Test;
use WebGUI::Session;
use Test::More tests => 18; # increment this value for each test you create
use Test::Deep;
use WebGUI::Asset::Wobject::Map;
use WebGUI::Asset::MapPoint;
use WebGUI::Search;

my $session = WebGUI::Test->session;
#Run as Admin
$session->user({ userId => 3 });

# Do our work in the import node
my $node = WebGUI::Test->asset;

# Create a map
my $map = $node->addChild({
    className      => 'WebGUI::Asset::Wobject::Map',
    mapApiKey      => undef,
    startZoom      => "0",
    workflowIdPoint => "pbworkflow000000000003",
});

# Create a map point
my $test_point = {
    website      => 'http://www.plainblack.com',
    address1     => '520 University',
    address2     => 'Suite 320',
    city         => 'Madison',
    region       => 'Wisconsin',
    zipCode      => '53703',
    country      => 'United States',
    phone        => '608-555-1212',
    fax          => '608-555-1212',
    email        => 'info@plainblack.com',
    userDefined1 => 'one-plainblack',
    userDefined2 => 'two-plainblack',
    userDefined3 => 'three-plainblack',
    userDefined4 => 'four-plainblack',
    userDefined5 => 'five-plainblack',
};

my $mapPoint = $map->addChild({
    className    => 'WebGUI::Asset::MapPoint',
    latitude     => '43.0736',
    longitude    => '-89.3946',
    %{$test_point}
});

#Call commit manually so we don't have to wait on spectre to run the autocommit workflow
$mapPoint->commit;

# Test for a sane object type
isa_ok($mapPoint, 'WebGUI::Asset::MapPoint');

################################################################
#
#  indexContent
#
################################################################

# Test indexContent to make sure keywords are added to assetIndex by searching for them and
# ensuring the asset is returned in the results.  indexContent itself does not need to be called
# because commit takes care of that for us.

#In all cases we should get back the one map point for these tests.
my $expected = [$mapPoint->getId];

foreach my $keyword (keys %$test_point) {
    my $assetIds = WebGUI::Search->new($session)->search({
        keywords => $test_point->{$keyword},
        lineage => [ $map->get("lineage") ]   #Limit the search to just map points under the newly create map.
    })->getAssetIds;

    is_deeply( $assetIds, $expected, "$keyword found in search" );
}
#my $assetIds = WebGUI::Search->new($session)->search(\%rules)->getAssetIds;

################################################################
#
#  processAjaxEditForm
#
################################################################

#Test isHidden
sleep 1;  #Make sure we have a different revision date
my $test_point_edit = {
    %{$test_point},
    'assetId'  => $mapPoint->getId,
    'isHidden' => 1,
};

$session->request->setup_body($test_point_edit);

$map->www_ajaxEditPointSave;

#Get the newest mapPoint revision
$mapPoint = WebGUI::Asset->newPending($session,$mapPoint->getId);
is($mapPoint->get("isHidden"),1,"isHidden changed");

#TO DO - Try to change isHidden as a user who can add points but cannot edit


#Test isGeocoded
sleep 1; #Make sure we have a different revision date
$test_point_edit = {
    %{$test_point},
    'assetId'    => $mapPoint->getId,
    'isGeocoded' => 1,
};

$session->request->setup_body($test_point_edit);

$map->www_ajaxEditPointSave;

#Get the newest mapPoint revision
$mapPoint = WebGUI::Asset->newPending($session,$mapPoint->getId);
is($mapPoint->get("isGeocoded"),1,"isGeocoded changed");
