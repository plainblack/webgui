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

my $session = WebGUI::Test->session;

use WebGUI::Session;
use WebGUI::VersionTag;
use WebGUI::Asset;

use Test::More;
use Test::Deep;

my $startingTime = time();

my $numTests = 5; # increment this value for each test you create
plan tests => 1 + $numTests;

my $loaded = use_ok('WebGUI::PassiveProfiling');

WebGUI::Test->addToCleanup(SQL => ['delete from passiveProfileLog where dateOfEntry >= ?', $startingTime-1]);
my $home = WebGUI::Test->asset;

my $pageProperties = {
	#            '1234567890123456789012'
	id        => 'layoutAsset01010101010',
	title     => 'mylayout',
	url       => 'mylayout',
	className => 'WebGUI::Asset::Wobject::Layout',
};

my $page = $home->addChild($pageProperties, $pageProperties->{id});

my $snippetProperties = {
	#            '1234567890123456789012'
	id        => 'snippetAsset0101010101',
	title     => 'mysnippet1',
	url       => 'mysnippet1',
	className => 'WebGUI::Asset::Snippet',
};

my $snippet1 = $page->addChild($snippetProperties, $snippetProperties->{id});

##Yes, this is just lazy and evil
$snippetProperties->{id}++;
$snippetProperties->{title}++;
$snippetProperties->{url}++;

my $snippet2 = $page->addChild($snippetProperties, $snippetProperties->{id});

SKIP: {

skip 'Module was not loaded, skipping all tests', $numTests -1 unless $loaded;

$session->setting->set('passiveProfilingEnabled', 0);

WebGUI::PassiveProfiling::add( $session, $home->getId );

my $count = $session->db->quickScalar('select count(*) from passiveProfileLog where assetId=? and dateOfEntry >= ?',[$home->getId, $startingTime]);

is($count, 0, 'add: Nothing added if passive profiling is not enabled');

$session->setting->set('passiveProfilingEnabled', 1);

my $timeLogged;
$timeLogged = time();
WebGUI::PassiveProfiling::add( $session, $page->getId );

my $count = $session->db->quickScalar('select count(*) from passiveProfileLog where assetId=? and dateOfEntry >= ?',[$page->getId, $startingTime]);

is($count, 1, 'add: Enabling passiveProfiling in the settings allows it to work, only 1 log entry added');

my $logEntry = $session->db->quickHashRef('select * from passiveProfileLog where assetId=? and dateOfEntry >= ?',[$page->getId, $startingTime]);

cmp_deeply(
    $logEntry,
    {
        passiveProfileLogId => re($session->id->getValidator),
        userId              => 1,
        sessionId           => $session->getId,
        assetId             => $page->getId,
        dateOfEntry         => num($timeLogged, 2),
    },
    'add: Correct information added for logged asset',
);

$session->setting->set('passiveProfilingEnabled', 0);

WebGUI::PassiveProfiling::addPage( $session, $page->getId );

$count = $session->db->quickScalar('select count(*) from passiveProfileLog where assetId=? and dateOfEntry >= ?',[$page->getId, $startingTime]);

is($count, 1, 'addPage: Nothing added if passive profiling is not enabled');

$session->setting->set('passiveProfilingEnabled', 1);

WebGUI::PassiveProfiling::addPage( $session, $page->getId );

my $loggedAssets = $session->db->buildArrayRef("select assetId from passiveProfileLog where dateOfEntry >= ?",[$startingTime]);

cmp_bag(
    $loggedAssets,
    [ $page->getId, $snippet1->getId, $snippet2->getId ],
    'addPage: All children assets added, but the originating page was not',
);

}

#vim:ft=perl
