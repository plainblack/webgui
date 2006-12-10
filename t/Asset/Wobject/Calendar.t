#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2006 Plain Black Corporation.
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

##The goal of this test is to test the creation of Calendar Wobjects.

use WebGUI::Test;
use WebGUI::Session;
use Test::More tests => 3; # increment this value for each test you create
use WebGUI::Asset::Wobject::Calendar;
use WebGUI::Asset::Event;

my $session = WebGUI::Test->session;

# Do our work in the import node
my $node = WebGUI::Asset->getImportNode($session);

my $versionTag = WebGUI::VersionTag->getWorking($session);
$versionTag->set({name=>"Calendar Test"});
my $cal = $node->addChild({className=>'WebGUI::Asset::Wobject::Calendar'});

# Test for a sane object type
isa_ok($cal, 'WebGUI::Asset::Wobject::Calendar');

# Test addChild to make sure we can only add Event assets as children to the calendar
my $event = $cal->addChild({className=>'WebGUI::Asset::Event'});
isa_ok($event, 'WebGUI::Asset::Event','Can add Events as a child to the calendar.');

my $article = $cal->addChild({className=>"WebGUI::Asset::Wobject::Article"});
isnt(ref $article, 'WebGUI::Asset::Wobject::Article', "Can't add an article as a child to the calendar.");

TODO: {
        local $TODO = "Tests to make later";
        ok(0, 'Lots more to test');
}

END {
	# Clean up after thy self
	$versionTag->rollback($versionTag->getId);
}

