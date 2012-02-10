#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2012 Plain Black Corporation.
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
use Test::More;
use WebGUI::Asset::Wobject::Layout;
use WebGUI::Asset;

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

$session->setting->set('useMobileStyle', 1);
$session->setting->set('anonymousRegistration', 1);

my $importNode = WebGUI::Asset->getImportNode($session);
my $template1 = $importNode->addChild({className=>"WebGUI::Asset::Template", namespace => 'style', });
my $template2 = $importNode->addChild({className=>"WebGUI::Asset::Template", namespace => 'Layout', });

my $mobileStyleTemplateId = $template1->getId;
my $mobileTemplateId = $template2->getId;

my $mobile_page = $importNode->addChild({
    className             => "WebGUI::Asset::Wobject::Layout",
    mobileStyleTemplateId => $mobileStyleTemplateId,
    mobileTemplateId      => $mobileTemplateId, }
);
WebGUI::Test->addToCleanup($template1, $template2);

my $tag = WebGUI::VersionTag->getWorking($session);
$tag->commit;
WebGUI::Test->addToCleanup($tag);

my $mech = WebGUI::Test::Mechanize->new( config => WebGUI::Test->config );
$mech->get_ok('/');
$mech->session->user({userId => 3});
$mech->get_ok($mobile_page->getUrl('func=add;userId=3;className=WebGUI::Asset::Wobject::Layout'));
my ($mobileTemplateInput) = $mech->find_all_inputs(name => 'mobileTemplateId');
is $mobileTemplateInput->value, $mobileTemplateId, 'child PageLayout inherited parents mobileTemplateId';
my ($mobileStyleTemplateInput) = $mech->find_all_inputs(name => 'mobileStyleTemplateId');
is $mobileStyleTemplateInput->value, $mobileStyleTemplateId, 'child PageLayout inherited parents mobileStyleTemplateId';

done_testing;
