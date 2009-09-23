#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2009 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use FindBin;
use strict;
use lib "$FindBin::Bin/../lib";

##The goal of this test is to check the creation and purging of
##versions.

use WebGUI::Test;
use WebGUI::Session;
use WebGUI::Utility;
use WebGUI::Asset::Template;
use Test::More; # increment this value for each test you create
plan tests => 26;

my $session = WebGUI::Test->session;

my $propertyHash = {
	template  => "Hi, I'm a template",
	url       => '/template/versionTest',
	title     => 'Version Test Template',
	menuTitle => 'Version Test Template',
	namespace => 'Article',
	className => 'WebGUI::Asset::Template',
};

my $root = WebGUI::Asset->getRoot($session);

my $originalVersionTags = $session->db->quickScalar(q{select count(*) from assetVersionTag});

################################################################
#
# purgeRevision
#
################################################################

note "purgeRevision tests";
my $template = $root->addChild($propertyHash);
$template->commit;

is (ref $template, "WebGUI::Asset::Template", "Template Asset created");
checkTableEntries($template->getId, 1,1,1,1);

sleep 1;

my $templatev2 = $template->addRevision({template => 'Hello, I am a template with formal grammar'});
$templatev2->commit;

is ($templatev2->getId, $template->getId, 'Both versions of the asset have the same assetId');
checkTableEntries($templatev2->getId, 1,2,2,1);

$templatev2->purgeRevision;

checkTableEntries($templatev2->getId, 1,1,1,1);

undef $templatev2;

my $templatev2a = $template->addRevision({template => 'Hey, yall!  Ima template.'});
$templatev2a->commit;

$template->purgeRevision;

checkTableEntries($template->getId, 1,1,1,1);

$template->purgeRevision;
checkTableEntries($template->getId, 0,0,0,0);

my $versionTagCheck;
$versionTagCheck = $session->db->quickScalar(q{select count(*) from assetVersionTag});
is($versionTagCheck, $originalVersionTags, 'version tag cleaned up by deleting last version');

################################################################
#
# purge
#
################################################################

$template = $root->addChild($propertyHash);
my $tag1 = WebGUI::VersionTag->getWorking($session);
$tag1->commit;
WebGUI::Test->tagsToRollback($tag1);
sleep 1;
$templatev2 = $template->addRevision({template => 'Vie gates.  Ich bin ein templater.'});
my $tag2 = WebGUI::VersionTag->getWorking($session);
$tag2->commit;
WebGUI::Test->tagsToRollback($tag2);
note "purge";
checkTableEntries($templatev2->getId, 1,2,2);
$versionTagCheck = $session->db->quickScalar(q{select count(*) from assetVersionTag});
is($versionTagCheck, $originalVersionTags+2, 'created two version tags');

$template->purge;
checkTableEntries($templatev2->getId, 0,0,0);
$versionTagCheck = $session->db->quickScalar(q{select count(*) from assetVersionTag});
is($versionTagCheck, $originalVersionTags, 'purge deleted both tags');

################################################################
#
# Utility routines
#
################################################################

sub checkTableEntries {
	my ($assetId, $assetNum, $assetDataNum, $templateNum) = @_;
	my ($count) = $session->db->quickArray('select COUNT(*) from asset where assetId=?', [$assetId]);
	is ($count, $assetNum,
		sprintf 'Expecting %d Assets with that id in asset', $assetNum);

	($count) = $session->db->quickArray('select COUNT(*) from assetData where assetId=?', [$assetId]);
	is ($count, $assetDataNum,
		sprintf 'Expecting %d Assets with that id in assetData', $assetDataNum);

	($count) = $session->db->quickArray('select COUNT(*) from template where assetId=?', [$assetId]);
	is ($count, $templateNum,
		sprintf 'Expecting %d Assets with that id in template', $templateNum);
}
