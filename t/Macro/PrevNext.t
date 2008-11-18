use FindBin;
use strict;
use lib "$FindBin::Bin/../lib";

use WebGUI::Test;
use WebGUI::Session;
use WebGUI::Storage;
use Data::Dumper;

use Test::More; # increment this value for each test you create

my $session = WebGUI::Test->session;


my $numTests = 10;
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
    title     => 'Top Page 2',
});
my $topPageLast = $testStart->addChild({
    className => 'WebGUI::Asset::Wobject::Layout',
    title     => 'Top Page Last',
});
my $subPage1_1 = $topPage1->addChild({
    className => 'WebGUI::Asset::Wobject::Layout',
    title     => 'Sub Page 1, Top Page 1',
});
my $subPage1_2 = $topPage1->addChild({
    className => 'WebGUI::Asset::Wobject::Layout',
    title     => 'Sub Page 2, Top Page 1',
});
my $subPage1_Last = $topPage1->addChild({
    className => 'WebGUI::Asset::Wobject::Layout',
    title     => 'Sub Page 3, Top Page 1',
});
my $subPage2_1 = $topPage2->addChild({
    className => 'WebGUI::Asset::Wobject::Layout',
    title     => 'Sub Page 1, Top Page 2',
});
my $subPage2_2 = $topPage2->addChild({
    className => 'WebGUI::Asset::Wobject::Article',
    title     => 'Sub Page 1, Top Page 2',
});

my ($goodChild, $goodSibling, $nextParent, $lastPage, $previousParent);

$goodChild = WebGUI::Macro::PrevNext::getNext($topPage1, $testStart);
is ($goodChild->getTitle, $subPage1_1->getTitle, 'next: Getting first child of first page');

$goodSibling = WebGUI::Macro::PrevNext::getNext($subPage1_1, $testStart);
is ($goodSibling->getTitle, $subPage1_2->getTitle, 'next: Getting first sibling of first subpage');

$goodSibling = WebGUI::Macro::PrevNext::getNext($subPage1_2, $testStart);
is ($goodSibling->getTitle, $subPage1_Last->getTitle, 'next: Getting first sibling of second subpage');

$nextParent = WebGUI::Macro::PrevNext::getNext($subPage1_Last, $testStart);
is ($nextParent->getTitle, $topPage2->getTitle, "next: Last sibling in a set returns the parent's first sibling");

$lastPage = WebGUI::Macro::PrevNext::getNext($topPageLast, $testStart);
is ($lastPage, undef, "next: Last page returns undef");

$nextParent = WebGUI::Macro::PrevNext::getNext($subPage2_1, $testStart);
is ($nextParent->getTitle, $topPage3->getTitle, "next: With no valid siblings, return next parent");

$goodSibling = WebGUI::Macro::PrevNext::getPrevious($subPage1_2, $testStart);
is ($goodSibling->getTitle, $subPage1_1->getTitle, "previous: Getting first sibling");

$previousParent = WebGUI::Macro::PrevNext::getPrevious($subPage1_1, $testStart);
is ($previousParent->getTitle, $topPage1->getTitle, "previous: Getting parent when start asset is the first child");

$previousParent = WebGUI::Macro::PrevNext::getPrevious($topPage1, $testStart);
is ($previousParent->getTitle, $testStart->getTitle, "previous: Getting parent when start asset is the first child and parent is the top asset");

$previousParent = WebGUI::Macro::PrevNext::getPrevious($testStart, $testStart);
is ($previousParent->getTitle, $testStart->getTitle, "previous: Getting parent when start asset is the top asset");

}

END { ##Clean-up after yourself, always
	$versionTag->rollback;
}
