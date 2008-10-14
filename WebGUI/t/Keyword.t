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
use lib "$FindBin::Bin/lib";
use WebGUI::Test;
use WebGUI::Session;
use WebGUI::Keyword;
use WebGUI::Asset;
# load your modules here

use Test::More tests => 9; # increment this value for each test you create

my $session = WebGUI::Test->session;

# put your tests here
my $home = WebGUI::Asset->getDefault($session);

isa_ok($home, "WebGUI::Asset");
my $keyword = WebGUI::Keyword->new($session);
isa_ok($keyword, "WebGUI::Keyword");

$keyword->setKeywordsForAsset({ asset=>$home, keywords=>"test key word foo bar"});
my ($count) = $session->db->quickArray("select count(*) from assetKeyword where assetId=?", [$home->getId]);
is($count, 5, "setKeywordsForAsset() create");

$keyword->setKeywordsForAsset({ asset=>$home, keywords=>"webgui rules"});
my ($count) = $session->db->quickArray("select count(*) from assetKeyword where assetId=?", [$home->getId]);
is($count, 2, "setKeywordsForAsset() update");

is(scalar(@{$keyword->getKeywordsForAsset({ asset=>$home, asArrayRef=>1})}), 2, "getKeywordsForAsset()");

like($keyword->generateCloud({startAsset=>$home, displayFunc=>"showKeyword" }), qr/rules/, "getLatestVersionNumber()");

$keyword->replaceKeyword({currentKeyword => "rules", newKeyword=>"owns"});
like($keyword->getKeywordsForAsset({asset=>$home }), qr/owns/, "getLatestVersionNumber()");

$keyword->deleteKeyword({keyword => "owns"});
unlike($keyword->getKeywordsForAsset({asset=>$home }), qr/owns/, "getLatestVersionNumber()");

$keyword->deleteKeywordsForAsset($home);
is(scalar(@{$keyword->getKeywordsForAsset({ asset=>$home, asArrayRef=>1})}), 0, "getKeywordsForAsset()");
undef $keyword;
undef $home;

