use FindBin;
use strict;
use lib "$FindBin::Bin/../lib";

use WebGUI::Test;
use WebGUI::Session;
use WebGUI::Storage;
use Data::Dumper;

use Test::More; # increment this value for each test you create

my $session = WebGUI::Test->session;


my $numTests = 3;
$numTests += 1; #For the use_ok

plan tests => $numTests;

my $macro = 'WebGUI::Macro::PrevNext';
my $loaded = use_ok($macro);

my $versionTag = WebGUI::VersionTag->getWorking($session);

SKIP: {

skip "Unable to load $macro", $numTests-1 unless $loaded;

my $testStart = WebGUI::Asset->getRoot($session)->addChild({className => 'WebGUI::Asset::Wobject::Layout', title => 'Test page'});
$versionTag->set({name=>"PrevNext Macro Test"});

my $topPage1 = $testStart->addChild({
    className => 'WebGUI::Asset::Wobject::Layout',
    title     => 'Top Page 1',
});
my $topPage2 = $testStart->addChild({
    className => 'WebGUI::Asset::Wobject::Layout',
    title     => 'Top Page 2',
});
my $topPage3 = $testStart->addChild({
    className => 'WebGUI::Asset::Wobject::Layout',
    title     => 'Top Page 3',
});
my $subPage11 = $topPage1->addChild({
    className => 'WebGUI::Asset::Wobject::Layout',
    title     => 'Sub Page 1, Top Page 1',
});
my $subPage12 = $topPage1->addChild({
    className => 'WebGUI::Asset::Wobject::Layout',
    title     => 'Sub Page 2, Top Page 1',
});
my $subPage13 = $topPage1->addChild({
    className => 'WebGUI::Asset::Wobject::Layout',
    title     => 'Sub Page 3, Top Page 1',
});

my $goodChild = WebGUI::Macro::PrevNext::getNext($topPage1, $testStart);
is ($goodChild->getTitle, $subPage11->getTitle, 'Getting first child of first page');

my $goodSibling = WebGUI::Macro::PrevNext::getNext($subPage11, $testStart);
is ($goodSibling->getTitle, $subPage12->getTitle, 'Getting first sibling of first subpage');

my $goodSibling2 = WebGUI::Macro::PrevNext::getNext($subPage12, $testStart);
is ($goodSibling2->getTitle, $subPage13->getTitle, 'Getting first sibling of second subpage');


}

END { ##Clean-up after yourself, always
	$versionTag->rollback;
}
