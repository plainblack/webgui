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

##The goal of this test is to check the creation and purging of
##versions.

use WebGUI::Test;
use WebGUI::Session;
use WebGUI::Asset::Snippet;
use Test::More; # increment this value for each test you create
plan tests => 26;

my $session = WebGUI::Test->session;

my %propertyHash = ( 
	template  => "Hi, I'm a snippet",
	url       => '/template/versionTest',
	title     => 'Version Test Snippet',
	menuTitle => 'Version Test Snippet',
	namespace => 'Snippet',
	className => 'WebGUI::Asset::Snippet',
);

my $root = WebGUI::Asset->getRoot($session);

my $originalVersionTags = $session->db->quickScalar(q{select count(*) from assetVersionTag});
my $tag = WebGUI::VersionTag->getWorking( $session );
WebGUI::Test->addToCleanup($tag);

################################################################
#
# purgeRevision
#
################################################################

note "purgeRevision tests";
my $snippet = $root->addChild({%propertyHash,});
$snippet->commit;

isa_ok $snippet, "WebGUI::Asset::Snippet";
checkTableEntries($snippet->getId, 1,1,1,1);

my $snippetv2 = $snippet->addRevision({snippet => 'Hello, I am a snippet with formal grammar',},time+1);
$snippetv2->commit;

is ($snippetv2->getId, $snippet->getId, 'Both versions of the asset have the same assetId');
checkTableEntries($snippetv2->getId, 1,2,2,1);

$snippetv2->purgeRevision;

checkTableEntries($snippetv2->getId, 1,1,1,1);

undef $snippetv2;

my $snippetv2a = $snippet->addRevision({snippet => 'Hey, yall!  Ima snippet.',},time+2);
$snippetv2a->commit;

$snippet->purgeRevision;

checkTableEntries($snippet->getId, 1,1,1,1);

$snippet->purgeRevision;
checkTableEntries($snippet->getId, 0,0,0,0);

my $versionTagCheck;
$versionTagCheck = $session->db->quickScalar(q{select count(*) from assetVersionTag});
is($versionTagCheck, $originalVersionTags, 'version tag cleaned up by deleting last version');

################################################################
#
# purge
#
################################################################

$snippet = $root->addChild({%propertyHash,});
my $tag1 = WebGUI::VersionTag->getWorking($session);
$tag1->commit;
WebGUI::Test->addToCleanup($tag1);
my $snippet = $snippet->cloneFromDb;
my $tag2 = WebGUI::VersionTag->getWorking($session);
WebGUI::Test->addToCleanup($tag2);
$snippetv2 = $snippet->addRevision({snippet => 'Vie gates.  Ich bin ein snippetr.',}, time+3);
$tag2->commit;
note "purge";
checkTableEntries($snippetv2->getId, 1,2,2);
$versionTagCheck = $session->db->quickScalar(q{select count(*) from assetVersionTag});
is($versionTagCheck, $originalVersionTags+2, 'created two version tags');

$snippet->purge;
checkTableEntries($snippetv2->getId, 0,0,0);
$versionTagCheck = $session->db->quickScalar(q{select count(*) from assetVersionTag});
is($versionTagCheck, $originalVersionTags, 'purge deleted both tags');

################################################################
#
# Utility routines
#
################################################################

sub checkTableEntries {
	my ($assetId, $assetNum, $assetDataNum, $snippetNum) = @_;
	my ($count) = $session->db->quickArray('select COUNT(*) from asset where assetId=?', [$assetId]);
	is ($count, $assetNum,
		sprintf 'Expecting %d Assets with that id in asset', $assetNum);

	($count) = $session->db->quickArray('select COUNT(*) from assetData where assetId=?', [$assetId]);
	is ($count, $assetDataNum,
		sprintf 'Expecting %d Assets with that id in assetData', $assetDataNum);

	($count) = $session->db->quickArray('select COUNT(*) from snippet where assetId=?', [$assetId]);
	is ($count, $snippetNum,
		sprintf 'Expecting %d Assets with that id in snippet', $snippetNum);
}
