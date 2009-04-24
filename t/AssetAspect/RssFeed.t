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
use Data::Dumper;

use WebGUI::Test; # Must use this before any other WebGUI modules
use WebGUI::Session;
use WebGUI::Asset;

use WebGUI::Asset::RssAspectDummy;

#----------------------------------------------------------------------------
# Init
my $session         = WebGUI::Test->session;


#----------------------------------------------------------------------------
# Tests

plan tests => 18;        # Increment this number for each test you create

#----------------------------------------------------------------------------
# put your tests here

my $dummy = WebGUI::Asset->getDefault($session)->addChild({
    className   => 'WebGUI::Asset::RssAspectDummy',
    url         => '/home/shawshank',
    title       => 'Dummy Title',
    synopsis    => 'Dummy Synopsis',
    description => 'Dummy Description',
});

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
        title       => 'Dummy Title',
        description => 'Dummy Synopsis',  ##Not description
        link        => '/home/shawshank',
    ),
    '... title, description, link inherit from asset by default'
);
cmp_bag(
    [ $feed->get_item() ],
    [
        methods(
            title       => 'this title',
            description => 'this description',
        ),
        methods(
            title       => 'another title',
            description => 'another description',  ##Not description
        ),
        
    ],
    '... contains 2 feed items with the correct contents'
);

#----------------------------------------------------------------------------
# Cleanup
END {
    $dummy->purge;
    my $tag = WebGUI::VersionTag->getWorking($session, 'noCreate');
    $tag->rollback if $tag;
}
#vim:ft=perl
