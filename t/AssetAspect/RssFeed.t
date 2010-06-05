# vim:syntax=perl
#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2009 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#------------------------------------------------------------------

# Write a little about what this script tests.
# 
#

use FindBin;
use strict;
use lib "$FindBin::Bin/../lib";
use Test::More;
use Test::Deep;
use File::Path;
use Data::Dumper;

use WebGUI::Test; # Must use this before any other WebGUI modules
use WebGUI::Session;
use WebGUI::Asset;

use WebGUI::Asset::RssAspectDummy;

#----------------------------------------------------------------------------
# Init
my $session         = WebGUI::Test->session;

WebGUI::Test->originalConfig('exportPath');

#----------------------------------------------------------------------------
# Tests

plan tests => 24;        # Increment this number for each test you create

#----------------------------------------------------------------------------
# put your tests here

my $dummy = WebGUI::Asset->getDefault($session)->addChild({
    className   => 'WebGUI::Asset::RssAspectDummy',
    url         => '/home/shawshank',
    title       => 'Dummy Title',
    synopsis    => 'Dummy Synopsis',
    description => 'Dummy Description',
});
WebGUI::Test->addToCleanup($dummy);

#####################################################
#
# get URLs
#
#####################################################

can_ok($dummy, qw/getAtomFeedUrl getRssFeedUrl getRdfFeedUrl/);

is($dummy->getAtomFeedUrl, '/home/shawshank?func=viewAtom', 'getAtomFeedUrl');
is($dummy->getRssFeedUrl,  '/home/shawshank?func=viewRss',  'getRssFeedUrl');
is($dummy->getRdfFeedUrl,  '/home/shawshank?func=viewRdf',  'getRdfFeedUrl');

can_ok($dummy, qw/getStaticAtomFeedUrl getStaticRssFeedUrl getStaticRdfFeedUrl/);

is($dummy->getStaticAtomFeedUrl, '/home/shawshank.atom', 'getStaticAtomFeedUrl');
is($dummy->getStaticRssFeedUrl,  '/home/shawshank.rss',  'getStaticRssFeedUrl');
is($dummy->getStaticRdfFeedUrl,  '/home/shawshank.rdf',  'getStaticRdfFeedUrl');

$session->scratch->set('isExporting', 1);

is($dummy->getAtomFeedUrl, '/home/shawshank.atom', 'export mode, getAtomFeedUrl');
is($dummy->getRssFeedUrl,  '/home/shawshank.rss',  '... getRssFeedUrl');
is($dummy->getRdfFeedUrl,  '/home/shawshank.rdf',  '... getRdfFeedUrl');

$session->scratch->delete('isExporting');
$dummy->update({ url => 'dot.extension', });

is($dummy->getAtomFeedUrl, '/dot.extension?func=viewAtom', 'getAtomFeedUrl, url with extension');
is($dummy->getRssFeedUrl,  '/dot.extension?func=viewRss',  'getRssFeedUrl, url with extension');
is($dummy->getRdfFeedUrl,  '/dot.extension?func=viewRdf',  'getRdfFeedUrl, url with extension');

is($dummy->getStaticAtomFeedUrl, '/dot.extension.atom', 'getStaticAtomFeedUrl, url with extension');
is($dummy->getStaticRssFeedUrl,  '/dot.extension.rss',  'getStaticRssFeedUrl, url with extension');
is($dummy->getStaticRdfFeedUrl,  '/dot.extension.rdf',  'getStaticRdfFeedUrl, url with extension');

$dummy->update({ url => '/home/shawshank', });

#####################################################
#
# getFeed
#
#####################################################

my $feed = XML::FeedPP::RSS->new();

my $newFeed = $dummy->getFeed($feed);

isa_ok($newFeed, 'XML::FeedPP::RSS');
is($newFeed, $feed, 'getFeed returns the same object');
cmp_deeply(
    $feed,
    methods(
        title        => 'Dummy Title',
        description  => 'Dummy Synopsis',  ##Not description
        link         => $session->url->getSiteURL . '/home/shawshank',
        copyright    => undef,
    ),
    '... title, description, link inherit from asset by default, copyright unset'
);
cmp_bag(
    [ $feed->get_item() ],
    [
        methods(
            title       => 'this title',
            description => 'this description',
            'link'      => 'this link',
            guid        => 'this link',
        ),
        methods(
            title       => 'another title',
            description => 'another description',     ##Not description
            guid        => re('^[a-zA-Z0-9\-_]{22}'), ##GUID is a GUID since there's no link
        ),
        
    ],
    '... contains 2 feed items with the correct contents'
);

$dummy->update({
    feedCopyright   => 'copyright 2009 Plain Black Corporation',
    feedTitle       => 'Rita Hayworth and the Shawshank Redemption',
    feedDescription => 'A good movie, providing loads of testing collateral',
});
$feed = $dummy->getFeed(XML::FeedPP::RSS->new());

cmp_deeply(
    $feed,
    methods(
        title        => 'Rita Hayworth and the Shawshank Redemption',
        description  => 'A good movie, providing loads of testing collateral',
        link         => $session->url->getSiteURL . '/home/shawshank',
        copyright    => 'copyright 2009 Plain Black Corporation',
    ),
    '... feed settings override asset defaults, copyright'
);

#####################################################
#
# exportAssetCollateral
#
#####################################################

my $exportStorage = WebGUI::Storage->create($session);
WebGUI::Test->storagesToDelete($exportStorage);
my $basedir = Path::Class::Dir->new($exportStorage->getPath);
my $assetdir = $basedir->subdir('shawshank');
my $indexfile = $assetdir->file('index.html');
mkpath($assetdir->stringify);
$dummy->exportAssetCollateral($indexfile, {}, $session);

cmp_bag(
    $exportStorage->getFiles(),
    [qw/
        shawshank.rss        shawshank
        shawshank.atom
        shawshank.rdf
    /],
    'exportAssetCollateral: feed files exported, index.html file'
);

$exportStorage = WebGUI::Storage->create($session);
WebGUI::Test->storagesToDelete($exportStorage);
$basedir   = Path::Class::Dir->new($exportStorage->getPath);
my $assetfile = $basedir->file('shawshank.html');
$dummy->exportAssetCollateral($assetfile, {}, $session);

cmp_bag(
    $exportStorage->getFiles(),
    [qw/
        shawshank.html.rss
        shawshank.html.atom
        shawshank.html.rdf
    /],
    'exportAssetCollateral: feed files exported, shawshank.html file'
);

#vim:ft=perl
