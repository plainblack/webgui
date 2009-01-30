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
use warnings;
use lib "$FindBin::Bin/lib"; ##t/lib

use WebGUI::Test;
use WebGUI::Session;
use WebGUI::Asset::Template;

#The goal of this test is to find hard coded extras paths in templates or in
#the extraHeadTags of any assets.

use Test::More; # increment this value for each test you create
my $numTests = 0;
plan skip_all => 'set CODE_COP to enable this test' unless $ENV{CODE_COP};

my $session = WebGUI::Test->session;
my $lib = WebGUI::Test->lib;

my $hardcodedExtras = qr!(?:href|src)=.\^?/[(;]?extras/!;

# put your tests here

my @hardcodedExtras;

my $getATemplate = WebGUI::Asset::Template->getIsa($session);
TEMPLATE: while (my $templateAsset = $getATemplate->()) {
    my $template = $templateAsset->get('template');
    next TEMPLATE unless $template;
    if ($template =~ m!$hardcodedExtras! ) {
        push @hardcodedExtras, {
            url        => $templateAsset->getUrl,
            id         => $templateAsset->getId,
            title      => $templateAsset->getTitle,
            type       => 'Template',
        }
    }
}

my $getAnAsset = WebGUI::Asset->getIsa($session);
ASSET: while (my $asset = $getAnAsset->()) {
    my $headTags = $asset->get('extraHeadTags');
    next ASSET unless $headTags;
    if ($headTags =~ m!$hardcodedExtras! ) {
        push @hardcodedExtras, {
            url        => $asset->getUrl,
            id         => $asset->getId,
            title      => $asset->getTitle,
            type       => 'Asset',
        }
    }
}

$numTests = scalar @hardcodedExtras;

plan tests => $numTests;

foreach my $template ( @hardcodedExtras ) {
	fail(
        sprintf "%s with hardcoded extras url:  %s, id: %s, url: %s", @{ $template }{qw/type title id url/}
    );
}
