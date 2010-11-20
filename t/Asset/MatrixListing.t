#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2009 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use strict;

##The goal of this test is to test the creation of a MatrixListing Asset.

use WebGUI::Test;
use WebGUI::Session;
use Test::More tests => 2; # increment this value for each test you create
use WebGUI::Asset::Wobject::Matrix;
use WebGUI::Asset::MatrixListing;


my $session = WebGUI::Test->session;
my ($matrix, $matrixListing);
$matrix = WebGUI::Test->asset(className=>'WebGUI::Asset::Wobject::Matrix');
$matrixListing = $matrix->addChild({className=>'WebGUI::Asset::MatrixListing'});

# Test for sane object types
isa_ok($matrix, 'WebGUI::Asset::Wobject::Matrix');
isa_ok($matrixListing, 'WebGUI::Asset::MatrixListing');

# Try to add content under a MatrixListing asset
#my $article = $matrixListing->addChild({className=>'WebGUI::Asset::Wobject::Article'});
#is($article, undef, "Can't add an Article wobject as a child to a Matrix Listing.");

# See if the duplicate method works
#my $wikiPageCopy = $wikipage->duplicate();
#isa_ok($wikiPageCopy, 'WebGUI::Asset::WikiPage');
#my $thirdVersionTag = WebGUI::VersionTag->new($session,$wikiPageCopy->get("tagId"));


#TODO: {
#    local $TODO = "Tests to make later";
#    ok(0, 'Lots and lots to do');
#}
#vim:ft=perl
