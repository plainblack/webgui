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
use lib "$FindBin::Bin/../../lib";

##The goal of this test is to test permissions handling for the WikiMaster and WikiPage.

use WebGUI::Test;
use WebGUI::Session;
use Test::More tests => 31; # increment this value for each test you create
use WebGUI::Asset::Wobject::WikiMaster;
use WebGUI::Asset::WikiPage;


my $session = WebGUI::Test->session;
my $node = WebGUI::Asset->getImportNode($session);
my $versionTag = WebGUI::VersionTag->getWorking($session);
$versionTag->set({name=>"Wiki Test"});
addToCleanup($versionTag);

my $assetEdit    = WebGUI::Group->new($session, "new");
my $wikiAdmin    = WebGUI::Group->new($session, "new");
my $wikiEditPage = WebGUI::Group->new($session, "new");
addToCleanup($assetEdit, $wikiAdmin, $wikiEditPage);

my $assetEditor       = WebGUI::User->create($session);
$assetEdit->addUsers([$assetEditor->userId]);
my $wikiAdministrator = WebGUI::User->create($session);
$wikiAdmin->addUsers([$wikiAdministrator->userId]);
my $wikiPageEditor    = WebGUI::User->create($session);
$wikiEditPage->addUsers([$wikiPageEditor->userId]);
my $wikiOwner         = WebGUI::User->create($session);
my $wikiPageOwner     = WebGUI::User->create($session);
addToCleanup($assetEditor, $wikiAdministrator, $wikiPageEditor, $wikiOwner, $wikiPageOwner);

$session->user({user => $wikiOwner});
my $wiki = $node->addChild({
    className         => 'WebGUI::Asset::Wobject::WikiMaster',
    groupIdEdit       => $assetEdit->getId,
    groupToAdminister => $wikiAdmin->getId,
    groupToEditPages  => $wikiEditPage->getId,
    ownerUserId       => $wikiOwner->getId,
}, undef, undef, {skipAutoCommitWorkflows => 1, skipNotification => 1});
$versionTag->commit;
my $wikipage = $wiki->addChild({
    className   => 'WebGUI::Asset::WikiPage',
    ownerUserId => $wikiPageOwner->userId,
}, undef, undef, {skipAutoCommitWorkflows => 1, skipNotification => 1});
is $wikipage->get('ownerUserId'), $wikiPageOwner->userId, 'wiki page owned by correct user';

# Wikis create and autocommit a version tag when a child is added.  Lets get the name so we can roll it back.
my $secondVersionTag = WebGUI::VersionTag->new($session,$wikipage->get("tagId"));
$secondVersionTag->commit;
addToCleanup($secondVersionTag );

# Test for sane object types
isa_ok($wiki, 'WebGUI::Asset::Wobject::WikiMaster');
isa_ok($wikipage, 'WebGUI::Asset::WikiPage');

note "wiki canAdminister";
$session->user({userId => 3});
ok (  $wiki->canAdminister, 'Site admin');
$session->user({user => $assetEditor});
ok (  $wiki->canAdminister, 'asset editor');
$session->user({user => $wikiAdministrator});
ok (  $wiki->canAdminister, 'wiki admin');
$session->user({user => $wikiPageEditor});
ok (! $wiki->canAdminister, 'wiki page editor');
$session->user({user => $wikiOwner});
ok (  $wiki->canAdminister, 'wiki owner');
$session->user({user => $wikiPageOwner});
ok (! $wiki->canAdminister, 'wiki page owner');
$session->user({userId => 1});
ok (! $wiki->canAdminister, 'visitor');

note "wiki canEditPages";
$session->user({userId => 3});
ok (  $wiki->canEditPages, 'Site admin');
$session->user({user => $assetEditor});
ok (  $wiki->canEditPages, 'asset editor');
$session->user({user => $wikiAdministrator});
ok (  $wiki->canEditPages, 'wiki admin');
$session->user({user => $wikiPageEditor});
ok (  $wiki->canEditPages, 'wiki page editor');
$session->user({user => $wikiOwner});
ok (  $wiki->canEditPages, 'wiki owner');
$session->user({user => $wikiPageOwner});
ok (! $wiki->canEditPages, 'wiki page owner');  ##A wiki page owner should not be able to edit _all_ pages, just their own
$session->user({userId => 1});
ok (! $wiki->canEditPages, 'visitor');

note "wiki canEdit";
$session->user({userId => 3});
ok (  $wiki->canEdit, 'Site admin');
$session->user({user => $assetEditor});
ok (  $wiki->canEdit, 'asset editor');
$session->user({user => $wikiAdministrator});
ok (! $wiki->canEdit, 'wiki admin');
$session->user({user => $wikiPageEditor});
ok (! $wiki->canEdit, 'wiki page editor');
$session->user({user => $wikiOwner});
ok (  $wiki->canEdit, 'wiki owner');
$session->user({user => $wikiPageOwner});
ok (! $wiki->canEdit, 'wiki page owner');  ##A wiki page owner should not be able to edit _all_ pages, just their own
$session->user({userId => 1});
ok (! $wiki->canEdit, 'visitor');

note "wikipage canEdit";
$session->user({userId => 3});
ok (  $wikipage->canEdit, 'Site admin');
$session->user({user => $assetEditor});
ok (  $wikipage->canEdit, 'asset editor');
$session->user({user => $wikiAdministrator});
ok (  $wikipage->canEdit, 'wiki admin');
$session->user({user => $wikiPageEditor});
ok (  $wikipage->canEdit, 'wiki page editor');
$session->user({user => $wikiOwner});
ok (  $wikipage->canEdit, 'wiki owner');
$session->user({user => $wikiPageOwner});
ok (! $wikipage->canEdit, 'wiki page owner');
$session->user({userId => 1});
ok (! $wikipage->canEdit, 'visitor');
