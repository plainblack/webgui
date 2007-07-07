#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2007 Plain Black Corporation.
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

##The goal of this test is to test the creation of Search Wobjects.

use WebGUI::Test;
use WebGUI::Session;
use Test::More tests => 6; # increment this value for each test you create
use WebGUI::Asset::Wobject::Search;

my $session = WebGUI::Test->session;

# Do our work in the import node
my $node = WebGUI::Asset->getImportNode($session);

my $versionTag = WebGUI::VersionTag->getWorking($session);
$versionTag->set({name=>"Search Test"});
my $search = $node->addChild({className=>'WebGUI::Asset::Wobject::Search'});

# Test for a sane object type
isa_ok($search, 'WebGUI::Asset::Wobject::Search');

# Test to see if we can set new values
my $newSearchSettings = {
	templateId=>'testingtestingtesting1',
	searchRoot=>'testingtestingtesting2',
	classLimiter=>'WebGUI::Asset::Wobject::Article',
};
$search->update($newSearchSettings);

foreach my $newSetting (keys %{$newSearchSettings}) {
	is ($search->get($newSetting), $newSearchSettings->{$newSetting}, "updated $newSetting is ".$newSearchSettings->{$newSetting});
}


TODO: {
        local $TODO = "Tests to make later";
        ok(0, 'Test prepareView method');
	ok(0, 'Test view method');
}

END {
	# Clean up after thy self
	$versionTag->rollback();
}

