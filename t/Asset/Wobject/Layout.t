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
use File::Spec;
use lib "$FindBin::Bin/../../lib";

use Test::MockTime qw/:all/;  ##Must be loaded before all other code
use WebGUI::Test;
use WebGUI::Session;
use Test::More tests => 5; # increment this value for each test you create
use WebGUI::Asset::Wobject::Layout;
use WebGUI::Asset::Template;

my $session = WebGUI::Test->session;

# Do our work in the import node
my $node = WebGUI::Asset->getImportNode($session);

################################################################
#
# getContentLastModifiedBy
#
################################################################

my $revised_user1 = WebGUI::User->new($session, 'new');
my $revised_user2 = WebGUI::User->new($session, 'new');
WebGUI::Test->addToCleanup($revised_user1, $revised_user2 );
$session->user({userId => 3});
set_relative_time(-600);
WebGUI::Test->addToCleanup(sub { restore_time(); });
my $versionTag = WebGUI::VersionTag->getWorking($session);
my $page   = $node->addChild({
    className       => 'WebGUI::Asset::Wobject::Layout',
}, undef, 12);
$session->user({user => $revised_user1});
my $snip1 = $page->addChild({
    className       => 'WebGUI::Asset::Snippet',
}, undef, 14);

set_relative_time(-500);
$session->user({user => $revised_user2});
my $snip2 = $page->addChild({
    className       => 'WebGUI::Asset::Snippet',
}, undef, 16);

$page = $page->cloneFromDb;
$snip1 = $snip1->cloneFromDb;
$snip2 = $snip2->cloneFromDb;
WebGUI::Test->addToCleanup($page);
is $page->getContentLastModifiedBy, $snip2->get('revisedBy'), 'getContentLastModifiedBy returns revisedBy for most recent child asset';
is $page->getContentLastModifiedBy, $revised_user2->userId, '... real userId check';
$session->user({user => $revised_user1});

set_relative_time(-100);

$snip1 = $snip1->addRevision({ title => 'titular', }, 18);
is $page->getContentLastModifiedBy, $revised_user1->userId, '... check that a new revision tracks';

# inheriting mobileStyleTemplateId and mobileTemplateId; from ``Mobile template is not being inherited  (#12246)'' 

my $importNode = WebGUI::Asset::Template->getImportNode($session);
my $template1 = $importNode->addChild({className=>"WebGUI::Asset::Template"});
my $template2 = $importNode->addChild({className=>"WebGUI::Asset::Template"});
WebGUI::Test->addToCleanup($template1, $template2);

my $mobileStyleTemplateId = $template1->getId;
my $mobileTemplateId = $template2->getId;
$page->update({ mobileStyleTemplateId => $mobileStyleTemplateId, mobileTemplateId => $mobileTemplateId });
my $url = $page->get('url') . '/layout_child_test';
my $html   = WebGUI::Test->getPage($page, "www_add", {
     userId      => 3,
     formParams  => { 
         class => 'WebGUI::Asset::Wobject::Layout',  
         url   => $page->get('url') . '/layout_child_test',
     },
});

like $html, qr/name="mobileTemplateId" value="$mobileTemplateId"/, 'child PageLayout inherited parents mobileTempaleId';
like $html, qr/name="mobileStyleTemplateId" value="$mobileStyleTemplateId"/, 'child PageLayout inherited parents mobileStyleTempaleId';

