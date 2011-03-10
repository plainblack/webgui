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

# This tests the AssetReport asset
# 
#

use Test::MockTime qw/:all/;
use FindBin;
use strict;
use lib "$FindBin::Bin/../../lib";
use Test::More;
use Test::Deep;
use Clone qw/clone/;

use WebGUI::Test; # Must use this before any other WebGUI modules
use WebGUI::Session;
use WebGUI::Cache;

#----------------------------------------------------------------------------
# Init
my $session         = WebGUI::Test->session;
my $node            = WebGUI::Asset->getImportNode( $session );

#----------------------------------------------------------------------------
# Tests

my $can_test  = 1;

my $partnerId = $session->config->get('testing/WeatherData_partnerId');
if (!$partnerId) {
    $partnerId = 'partnerId';
    $can_test  = 0;
}

my $licenseKey = $session->config->get('testing/WeatherData_licenseKey');
if (!$licenseKey) {
    $partnerId = 'licenseKey';
    $can_test  = 0;
}

if ($can_test) {
    plan tests => 7;        # Increment this number for each test you create
}
else {
    plan skip_all => 'Missing credentials for Weather.com';
}

#----------------------------------------------------------------------------
# Asset Report creation

                 #1234567890123456789012#
my $templateId = 'FAKE_WEATHER_TEMPLATEq';

my $templateMock = Test::MockObject->new({});
$templateMock->set_isa('WebGUI::Asset::Template');
$templateMock->set_always('getId', $templateId);
my $templateVars;
$templateMock->mock('process', sub { $templateVars = clone $_[1]; } );

my $asset  = $node->addChild( {
    className     => 'WebGUI::Asset::Wobject::WeatherData',
    cacheTimeout  => 2000,
    partnerId     => $partnerId,
    licenseKey    => $licenseKey,
    locations     => "53715",
    templateId    => $templateId,
} );
WebGUI::Test->addToCleanup($asset);

my $now = time();
diag $now;
set_relative_time(-1000);
diag time();

WebGUI::Test->mockAssetId($templateId, $templateMock);
$asset->prepareView();
$asset->view();

my $weather_data = $templateVars->{'ourLocations.loop'}->[0];

is $weather_data->{cityState}, 'Madison, WI (53715)', 'data from weather.com returned';
my $last_fetch = $weather_data->{last_fetch};
diag $last_fetch;
cmp_ok $last_fetch, '<', $now-500, 'last_fetch set in the past';

my $cache = WebGUI::Cache->new($session, [$asset->getId, '53715']);
is $cache->get()->{'locations'}->[0]->{cityState}, 'Madison, WI (53715)', 'cache loaded with valid data';

restore_time();

$cache = WebGUI::Cache->new($session, [$asset->getId, '53715']);
is $cache->get()->{'locations'}->[0]->{cityState}, 'Madison, WI (53715)', 'cache loaded with valid data';

$asset->update({locations => "53715\n97123"});

$asset->view();
$weather_data = $templateVars->{'ourLocations.loop'};
is $weather_data->[1]->{cityState}, 'Hillsboro, OR (97123)', 'weather data fetch successful, new location';
is $weather_data->[0]->{cityState}, 'Madison, WI (53715)', '...cached weather data';
is $weather_data->[0]->{last_fetch}, $last_fetch,  '53715 lookup was cached';

#vim:ft=perl
