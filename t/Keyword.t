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
use lib "$FindBin::Bin/lib";
use WebGUI::Test;
use WebGUI::Session;
use WebGUI::Keyword;
use WebGUI::Asset;
# load your modules here

use Test::More tests => 15; # increment this value for each test you create
use Test::Deep;
use Data::Dumper;

my $session = WebGUI::Test->session;

# put your tests here
my $home = WebGUI::Asset->getDefault($session);

isa_ok($home, "WebGUI::Asset");
my $keyword = WebGUI::Keyword->new($session);
isa_ok($keyword, "WebGUI::Keyword");

$keyword->setKeywordsForAsset({ asset=>$home, keywords=>"test key, word, foo bar"});
my ($count) = $session->db->quickArray("select count(*) from assetKeyword where assetId=?", [$home->getId]);
is($count, 3, "setKeywordsForAsset() create");
cmp_bag(
    $keyword->getKeywordsForAsset({ asset => $home,  asArrayRef => 1}),
    ['test key', 'word', 'foo bar'],
    '... check correct keywords set, returns array ref'
);

my $keywords = $keyword->getKeywordsForAsset({ asset => $home, });
my @keywords = split ',\s*', $keywords;
cmp_bag(
    \@keywords,
    ['test key', 'word', 'foo bar'],
    '... check correct keywords set, returns string'
);

$keyword->setKeywordsForAsset({ asset=>$home, keywords=>"webgui, rules"});
my ($count) = $session->db->quickArray("select count(*) from assetKeyword where assetId=?", [$home->getId]);
is($count, 2, "setKeywordsForAsset() update");

is(scalar(@{$keyword->getKeywordsForAsset({ asset=>$home, asArrayRef=>1})}), 2, "getKeywordsForAsset()");

like($keyword->generateCloud({startAsset=>$home, displayFunc=>"showKeyword" }), qr/rules/, "getLatestVersionNumber()");

$keyword->replaceKeyword({currentKeyword => "rules", newKeyword=>"owns"});
like($keyword->getKeywordsForAsset({asset=>$home }), qr/owns/, "getLatestVersionNumber()");

$keyword->deleteKeyword({keyword => "owns"});
unlike($keyword->getKeywordsForAsset({asset=>$home }), qr/owns/, "getLatestVersionNumber()");

my $snippet = $home->addChild({
    className => 'WebGUI::Asset::Snippet',
    title     => 'keyword snippet',
    snippet   => 'keyword snippet',
    keywords  => 'webgui',
});

my $tag = WebGUI::VersionTag->getWorking($session);
WebGUI::Test->tagsToRollback($tag);
$tag->commit;

my $assetIds = $keyword->getMatchingAssets({ keyword => 'webgui', });

cmp_deeply(
    $assetIds,
    [$snippet->getId, $home->getId, ],
    'getMatchingAssets, by keyword, assetIds in order by creationDate, descending'
);

$snippet->trash();

cmp_deeply(
    $keyword->getMatchingAssets({ keyword => 'webgui', }),
    [$home->getId, ],
    '... only published assets'
);

cmp_deeply(
    $keyword->getMatchingAssets({ keyword => 'webgui', states => [ qw/published trash/, ]}),
    [$snippet->getId, $home->getId, ],
    '... retrieving assets in more than one state'
);

cmp_deeply(
    $keyword->getTopKeywords(),
    { 'webgui' => '2' },
    'check getTopKeywords returns correctly'
);

$keyword->deleteKeywordsForAsset($home);
is(scalar(@{$keyword->getKeywordsForAsset({ asset=>$home, asArrayRef=>1})}), 0, "getKeywordsForAsset()");

