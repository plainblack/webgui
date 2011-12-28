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
use Test::More tests => 3; # increment this value for each test you create
use WebGUI::Asset::Wobject::Folder;

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
my $folder   = $node->addChild({
    className       => 'WebGUI::Asset::Wobject::Folder',
}, undef, 12);
$session->user({user => $revised_user1});
my $snip1 = $folder->addChild({
    className       => 'WebGUI::Asset::Snippet',
}, undef, 14);

set_relative_time(-500);
$session->user({user => $revised_user2});
my $snip2 = $folder->addChild({
    className       => 'WebGUI::Asset::Snippet',
}, undef, 16);

$folder = $folder->cloneFromDb;
$snip1 = $snip1->cloneFromDb;
$snip2 = $snip2->cloneFromDb;
WebGUI::Test->addToCleanup($folder);
is $folder->getContentLastModifiedBy, $snip2->get('revisedBy'), 'getContentLastModifiedBy returns revisedBy for most recent child asset';
is $folder->getContentLastModifiedBy, $revised_user2->userId, '... real userId check';
$session->user({user => $revised_user1});

set_relative_time(-100);

$snip1 = $snip1->addRevision({ title => 'titular', }, 18);
is $folder->getContentLastModifiedBy, $revised_user1->userId, '... check that a new revision tracks';


