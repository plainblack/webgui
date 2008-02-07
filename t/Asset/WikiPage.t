#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2008 Plain Black Corporation.
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

##The goal of this test is to test the creation of a WikiPage Asset.

use WebGUI::Test;
use WebGUI::Session;
use Test::More tests => 5; # increment this value for each test you create
use WebGUI::Asset::Wobject::WikiMaster;
use WebGUI::Asset::WikiPage;


my $session = WebGUI::Test->session;
my $node = WebGUI::Asset->getImportNode($session);
my $versionTag = WebGUI::VersionTag->getWorking($session);
$versionTag->set({name=>"Wiki Test"});

my $wiki = $node->addChild({className=>'WebGUI::Asset::Wobject::WikiMaster'});
$versionTag->commit;
my $wikipage = $wiki->addChild({className=>'WebGUI::Asset::WikiPage'});

# Wikis create and autocommit a version tag when a child is added.  Lets get the name so we can roll it back.
my $secondVersionTag = WebGUI::VersionTag->new($session,$wikipage->get("tagId"));

# Test for sane object types
isa_ok($wiki, 'WebGUI::Asset::Wobject::WikiMaster');
isa_ok($wikipage, 'WebGUI::Asset::WikiPage');

# Try to add content under a wiki page
my $article = $wikipage->addChild({className=>'WebGUI::Asset::Wobject::Article'});
is($article, undef, "Can't add an Article wobject as a child to a Wiki Page.");

# See if the duplicate method works
my $wikiPageCopy = $wikipage->duplicate();
isa_ok($wikiPageCopy, 'WebGUI::Asset::WikiPage');
my $thirdVersionTag = WebGUI::VersionTag->new($session,$wikiPageCopy->get("tagId"));

TODO: {
    local $TODO = "Tests to make later";
    ok(0, 'Lots and lots to do');
}

END {
	# Clean up after thy self
	$versionTag->rollback();
	$secondVersionTag->rollback();
	$thirdVersionTag->rollback();
}

