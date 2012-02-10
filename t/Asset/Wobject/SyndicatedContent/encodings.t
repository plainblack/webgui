#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2012 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#-------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#-------------------------------------------------------------------

use FindBin;
use strict;
use File::Spec;
use lib "$FindBin::Bin/../../../lib";

# The goal of this test is to test the creation of 
# and expose any bugs of SyndicatedContent Wobjects.

use WebGUI::Test;
use Test::More; # increment this value for each test you create
use WebGUI::Session;
plan tests    => 13; # increment this value for each test you create
use Test::Deep;
use WebGUI::Asset::Wobject::SyndicatedContent;
use XML::FeedPP;

my $session = WebGUI::Test->session;
my %var;

##############################
##          SETUP           ##
##############################

# Do our work in the import node
my $node = WebGUI::Test->asset;

# Create a version tag to work in
my $syndicated_content = $node->addChild({className=>'WebGUI::Asset::Wobject::SyndicatedContent'});

####################################################################
#
#  Encoding tests
#
####################################################################

my $UTF8_BOM = "\xEF\xBB\xBF";

my $testFeedUrl = 'http://www.example.com/feed.rss';
$syndicated_content->update({
    hasTerms => '',
    rssUrl   => $testFeedUrl,
});
$session->cache->set($testFeedUrl, , 60);

my $utf8_es = slurp_rss('utf8-es.rss');
my $utf8_ru = slurp_rss('utf8-ru.rss');
my $entity_es = slurp_rss('entity-es.rss');
my $entity_ru = slurp_rss('entity-ru.rss');
my $utf8_no_prolog = Encode::decode_utf8(slurp_rss('utf8-no-prolog-encoding.rss'));
my $iso_8859_1 = slurp_rss('iso-8859-1.rss');
my $iso_8859_5 = slurp_rss('iso-8859-5.rss');

my $es_title = "PM captur\x{00F3} a tres delincuentes que robaron agencia bancaria en San Mart\x{00ED}n";
my $ru_title = "\x{412}\x{438}\x{43a}\x{438}\x{43f}\x{435}\x{434}\x{438}\x{44f}  - \x{421}\x{432}\x{435}\x{436}\x{438}\x{435} \x{43f}\x{440}\x{430}\x{432}\x{43a}\x{438} [ru]";

$session->cache->set($testFeedUrl, $utf8_es, 60);
is $syndicated_content->generateFeed->title, $es_title, 'Latin-1 compatible, UTF-8 encoded';

$session->cache->set($testFeedUrl, $utf8_ru, 60);
is $syndicated_content->generateFeed->title, $ru_title, 'Russian, UTF-8 encoded';

$session->cache->set($testFeedUrl, $entity_es, 60);
is $syndicated_content->generateFeed->title, $es_title, 'Latin-1 compatible, Entity encoded, utf8 flag off';

$session->cache->set($testFeedUrl, $entity_ru, 60);
is $syndicated_content->generateFeed->title, $ru_title, 'Russian, Entity encoded, utf8 flag off';

$session->cache->set($testFeedUrl, $UTF8_BOM . $utf8_es, 60);
is $syndicated_content->generateFeed->title, $es_title, 'Latin-1 compatible, UTF-8 encoded, With BOM';

$session->cache->set($testFeedUrl, Encode::decode_utf8($utf8_es), 60);
is $syndicated_content->generateFeed->title, $es_title, 'Latin-1 compatible, Decoded';

$session->cache->set($testFeedUrl, Encode::decode_utf8($utf8_ru), 60);
is $syndicated_content->generateFeed->title, $ru_title, 'Russian, Decoded';

$session->cache->set($testFeedUrl, $UTF8_BOM . $utf8_es, 60);
is $syndicated_content->generateFeed->title, $es_title, 'Latin-1, Entity encoded, utf8 flag on';

$session->cache->set($testFeedUrl, Encode::decode_utf8($entity_ru), 60);
is $syndicated_content->generateFeed->title, $ru_title, 'Russian, Entity encoded, utf8 flag on';

$session->cache->set($testFeedUrl, $UTF8_BOM . Encode::decode_utf8($utf8_es), 60);
is $syndicated_content->generateFeed->title, $es_title, 'Latin-1 compatible, Decoded, With BOM';

$session->cache->set($testFeedUrl, $utf8_no_prolog, 60);
is $syndicated_content->generateFeed->title, $es_title, 'No encoding in prolog, Decoded';

$session->cache->set($testFeedUrl, $iso_8859_1, 60);
is $syndicated_content->generateFeed->title, $es_title, 'ISO-8859-1 encoded';

$session->cache->set($testFeedUrl, $iso_8859_5, 60);
is $syndicated_content->generateFeed->title, $ru_title, 'ISO-8859-5 encoded';

$session->cache->remove($testFeedUrl);

sub slurp_rss {
    my $file = shift;
    my $filepath = WebGUI::Test->getTestCollateralPath('rss/' . $file);
    open my $fh, '<', $filepath
        or die "Unable to get RSS file $file: $!";
    my $content = do { local $/; <$fh> };
    close $fh;
    return $content;
}
