use FindBin;
use strict;
use lib "$FindBin::Bin/../lib";

use WebGUI::Test;
use WebGUI::Session;
use WebGUI::Storage;
use Data::Dumper;
use JSON;
use Test::Deep;

use Test::More; # increment this value for each test you create

my $session = WebGUI::Test->session;

my $numTests = 39;
$numTests += 1; #For the use_ok

plan tests => $numTests;

my $macro = 'WebGUI::Macro::PrevNext';
my $loaded = use_ok($macro);

my $versionTag = WebGUI::VersionTag->getWorking($session);

SKIP: {

skip "Unable to load $macro", $numTests-1 unless $loaded;

############################################
#
# Setup assets in hierarchy
#
############################################

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
my $topPage4 = $testStart->addChild({
    className => 'WebGUI::Asset::Wobject::Layout',
    title     => 'Top Page 4',
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
my $subPage4_1 = $topPage4->addChild({
    className => 'WebGUI::Asset::Wobject::Layout',
    title     => 'Sub Page 1, Top Page 4',
    groupIdView => 3,
});
my $subPage4_2 = $topPage4->addChild({
    className => 'WebGUI::Asset::Wobject::Layout',
    title     => 'Sub Page 2, Top Page 4',
    groupIdView => 3,
});
my $subPage4_3 = $topPage4->addChild({
    className => 'WebGUI::Asset::Wobject::Layout',
    title     => 'Sub Page 3, Top Page 4',
});

my $templateBody = <<EOTMPL;
{
"hasPrevious":<tmpl_var hasPrevious>,
"hasNext":<tmpl_var hasNext>,
"nextUrl":"<tmpl_var nextUrl>",
"previousUrl":"<tmpl_var previousUrl>",
"startingPageTitle":"<tmpl_var startingPageTitle>"
}
EOTMPL

my $jsonTemplate = $testStart->addChild({className=>'WebGUI::Asset::Template', namespace => 'Macro/PrevNext', template=>$templateBody});

my ($goodChild, $goodSibling, $nextParent, $lastPage, $previousParent, $previousChild);

############################################
#
# getStartPage
#
############################################

my $startPage;

$startPage = WebGUI::Macro::PrevNext::getStartPage($testStart, $topPage1, 0);
is($startPage->getTitle, $testStart->getTitle, 'getStartPage: with depth=0, startPage = testStart');

$startPage = WebGUI::Macro::PrevNext::getStartPage($testStart, $topPage2, 0);
is($startPage->getTitle, $testStart->getTitle, 'getStartPage: with depth=0, startPage = topPage2');

$startPage = WebGUI::Macro::PrevNext::getStartPage($testStart, $subPage1_1, 0);
is($startPage->getTitle, $testStart->getTitle, 'getStartPage: with depth=0, startPage = subPage1_1');

$startPage = WebGUI::Macro::PrevNext::getStartPage($testStart, $topPage1, 1);
is($startPage->getTitle, $topPage1->getTitle, 'getStartPage: with depth=1, startPage = topPage1');

$startPage = WebGUI::Macro::PrevNext::getStartPage($testStart, $subPage2_2, 1);
is($startPage->getTitle, $topPage2->getTitle, 'getStartPage: with depth=1, startPage = topPage2');

############################################
#
# getNext
#
############################################

$goodChild = WebGUI::Macro::PrevNext::getNext($testStart, $testStart);
is($goodChild->getTitle, $topPage1->getTitle, 'next: Getting first child of test start');

$goodChild = WebGUI::Macro::PrevNext::getNext($topPage1, $testStart);
is ($goodChild->getTitle, $subPage1_1->getTitle, 'next: page with children returns first child');

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

$goodChild = WebGUI::Macro::PrevNext::getNext($topPage4, $testStart);
is ($goodChild->getTitle, $subPage4_3->getTitle, "next: Obeys viewing rules from parent as Visitor");

$goodChild = WebGUI::Macro::PrevNext::getNext($subPage4_1, $testStart);
is ($goodChild->getTitle, $subPage4_3->getTitle, "next: Obeys viewing rules from child as Visitor");

$session->user({userId => 3});

$goodChild = WebGUI::Macro::PrevNext::getNext($topPage4, $testStart);
is ($goodChild->getTitle, $subPage4_1->getTitle, "next: Obeys viewing rules from parent as Admin");

$goodChild = WebGUI::Macro::PrevNext::getNext($testStart, $topPage1);
is ($goodChild, undef, "next: No next link when the current page is above the top page");

$goodChild = WebGUI::Macro::PrevNext::getNext($subPage1_Last, $topPage1);
is ($goodChild, undef, "next: works 1 level down");

############################################
#
# getPrevious
#
############################################

$session->user({userId => 7});

$previousParent = WebGUI::Macro::PrevNext::getPrevious($testStart, $testStart);
is($previousParent, undef, 'previous: Test start has no previous page');

$previousParent = WebGUI::Macro::PrevNext::getPrevious($testStart, $topPage1);
is($previousParent, undef, 'previous: Page above start page has no previous page');

$goodSibling = WebGUI::Macro::PrevNext::getPrevious($subPage1_2, $testStart);
is ($goodSibling->getTitle, $subPage1_1->getTitle, "previous: Getting first sibling");

$previousParent = WebGUI::Macro::PrevNext::getPrevious($subPage1_1, $topPage1);
is ($previousParent->getTitle, $topPage1->getTitle, "previous: Getting parent when start asset is the first child");

$previousChild = WebGUI::Macro::PrevNext::getPrevious($topPage2, $testStart);
is ($previousChild->getTitle, $subPage1_Last->getTitle, "previous: Getting child of previous parent");

$previousParent = WebGUI::Macro::PrevNext::getPrevious($topPage1, $testStart);
is ($previousParent->getTitle, $testStart->getTitle, "previous: Getting parent when start asset is the first child and parent is the top asset");

$goodChild = WebGUI::Macro::PrevNext::getPrevious($subPage1_1, $topPage1);
is ($goodChild->getTitle, $topPage1->getTitle, "previous: first child returns parent");

$previousChild = WebGUI::Macro::PrevNext::getPrevious($topPage3, $testStart);
is ($previousChild->getTitle, $subPage2_1->getTitle, "previous: Only gets Layouts");

$previousParent = WebGUI::Macro::PrevNext::getPrevious($subPage4_3, $testStart);
is ($previousParent->getTitle, $topPage4->getTitle, "previous: Obeys viewing rules from child as Visitor");

$session->user({userId => 3});

$previousChild = WebGUI::Macro::PrevNext::getPrevious($subPage4_3, $testStart);
is ($previousChild->getTitle, $subPage4_2->getTitle, "previous: Obeys viewing rules from child as Admin");

############################################
#
# Macro output
#
############################################

my ($jsonOutput, $jsonData, $macroOutput);

$session->asset($topPage2);
$jsonOutput = WebGUI::Macro::PrevNext::process($session, $testStart->getUrl, 0, $jsonTemplate->getId);
$jsonData = JSON::from_json($jsonOutput);
cmp_deeply(
    $jsonData,
    {
        hasPrevious => 1,
        hasNext     => 1,
        previousUrl => $subPage1_Last->getUrl,
        nextUrl     => $subPage2_1->getUrl, 
        startingPageTitle => ignore(),
    },
    'Previous and Next both exist, variables'
);

$macroOutput = WebGUI::Macro::PrevNext::process($session, $testStart->getUrl);
like($macroOutput, qr/wgx-prev-btn/, 'previous and next, default template, previous button link exists');
like($macroOutput, qr/wgx-next-btn/, 'previous and next, default template, next button link exists');

$session->asset($testStart);
$jsonOutput = WebGUI::Macro::PrevNext::process($session, $testStart->getUrl, 0, $jsonTemplate->getId);
$jsonData = JSON::from_json($jsonOutput);
cmp_deeply(
    $jsonData,
    {
        hasPrevious => 0,
        hasNext     => 1,
        previousUrl => '',
        nextUrl     => $topPage1->getUrl, 
        startingPageTitle => ignore(),
    },
    'Testing next only, variables'
);

$macroOutput = WebGUI::Macro::PrevNext::process($session, $testStart->getUrl);
unlike($macroOutput, qr/wgx-prev-btn/, 'previous button link does not exist');
like($macroOutput, qr/wgx-next-btn/, 'previous button link exists');

$session->asset($topPageLast);
$jsonOutput = WebGUI::Macro::PrevNext::process($session, $testStart->getUrl, 0, $jsonTemplate->getId);
$jsonData = JSON::from_json($jsonOutput);
cmp_deeply(
    $jsonData,
    {
        hasPrevious => 1,
        hasNext     => 0,
        previousUrl => $subPage4_3->getUrl,
        nextUrl     => '', 
        startingPageTitle => ignore(),
    },
    'Testing previous only, variables'
);

$macroOutput = WebGUI::Macro::PrevNext::process($session, $testStart->getUrl);
like($macroOutput, qr/wgx-prev-btn/, 'previous button link exists');
unlike($macroOutput, qr/wgx-next-btn/, 'previous button link does not exist');

$session->asset($topPage1);
$jsonOutput = WebGUI::Macro::PrevNext::process($session, $testStart->getUrl, 1, $jsonTemplate->getId);
$jsonData = JSON::from_json($jsonOutput);
cmp_deeply(
    $jsonData,
    {
        hasPrevious => 0,
        hasNext     => 1,
        previousUrl => '',
        nextUrl     => $subPage1_1->getUrl, 
        startingPageTitle => $topPage1->getTitle,
    },
    'depth=1, no previous'
);

$session->asset($subPage1_1);
$jsonOutput = WebGUI::Macro::PrevNext::process($session, $testStart->getUrl, 1, $jsonTemplate->getId);
$jsonData = JSON::from_json($jsonOutput);
cmp_deeply(
    $jsonData,
    {
        hasPrevious => 1,
        hasNext     => 1,
        previousUrl => $topPage1->getUrl,
        nextUrl     => $subPage1_2->getUrl, 
        startingPageTitle => $topPage1->getTitle,
    },
    'Previous and Next both exist, variables'
);

$session->asset($subPage1_Last);
$jsonOutput = WebGUI::Macro::PrevNext::process($session, $testStart->getUrl, 1, $jsonTemplate->getId);
$jsonData = JSON::from_json($jsonOutput);
cmp_deeply(
    $jsonData,
    {
        hasPrevious => 1,
        hasNext     => 0,
        previousUrl => $subPage1_2->getUrl,
        nextUrl     => '', 
        startingPageTitle => $topPage1->getTitle,
    },
    'depth=1, last child has only previous'
);

}


END { ##Clean-up after yourself, always
	$versionTag->rollback;
}
