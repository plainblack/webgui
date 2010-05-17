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
use File::Spec;
use lib "$FindBin::Bin/../../lib";

use Data::Dumper;

# The goal of this test is to test the creation of 
# and expose any bugs of SyndicatedContent Wobjects.

use WebGUI::Test;
use WebGUI::Session;
use Test::More tests => 27; # increment this value for each test you create
use Test::Deep;
use WebGUI::Asset::Wobject::SyndicatedContent;
use XML::FeedPP;
use WebGUI::Cache;

my $session = WebGUI::Test->session;
my %var;

##############################
##          SETUP           ##
##############################
# Do our work in the import node
my $node = WebGUI::Asset->getImportNode($session);

# Create a version tag to work in
my $versionTag = WebGUI::VersionTag->getWorking($session);
$versionTag->set({name=>"SyndicatedContent Test"});
addToCleanup($versionTag);
my $syndicated_content = $node->addChild({className=>'WebGUI::Asset::Wobject::SyndicatedContent'});

##############################
##      Start Test          ##
##############################

# Test for a sane object type
isa_ok($syndicated_content, 'WebGUI::Asset::Wobject::SyndicatedContent');

# Test to see if we can set new values
my $newSyndicatedContentSettings = {
	cacheTimeout => 124,
	templateId   => "PBtmpl0000000000000065", 
    rssUrl      => 'http://svn.webgui.org/svnweb/plainblack/rss/WebGUI/',
};

# update the new values for this instance
$syndicated_content->update($newSyndicatedContentSettings);

# Let's check our updated values
foreach my $newSetting (keys %{$newSyndicatedContentSettings}) {
	is ($syndicated_content->get($newSetting), $newSyndicatedContentSettings->{$newSetting}, "updated $newSetting is ".$newSyndicatedContentSettings->{$newSetting});
}

my $feed = $syndicated_content->generateFeed;
isa_ok($feed, 'XML::FeedPP', 'Got an XML::FeedPP object');
isnt($feed->title,'', 'the feed has data');

# Lets make sure the view method returns something.
is ($syndicated_content->{_viewTemplate}, undef, 'internal template cache unset until prepareView is called');

$syndicated_content->prepareView;
isnt ($syndicated_content->{_viewTemplate}, undef, 'internal template cache set by prepare view');
isa_ok ($syndicated_content->{_viewTemplate}, 'WebGUI::Asset::Template', 'internal template cache');

ok($syndicated_content->view(), 'it generates some output');

my $output = $syndicated_content->www_viewRss;
my $feed = XML::FeedPP->new($output);
cmp_ok($feed->get_item, ">", 0, 'RSS has items');

my $output = $syndicated_content->www_viewRdf;
my $feed = XML::FeedPP->new($output);
cmp_ok($feed->get_item, ">", 0, 'RDF has items');

my $output = $syndicated_content->www_viewAtom;
my $feed = XML::FeedPP->new($output);
cmp_ok($feed->get_item, ">", 0, 'Atom has items');

# create a new template object in preparation for rendering
my $template = WebGUI::Asset::Template->new($session, $syndicated_content->get("templateId"));
$template->prepare;
isa_ok($template, 'WebGUI::Asset::Template');

$syndicated_content->{_viewTemplate} = $template;

# check out the template vars

my $var = $syndicated_content->getTemplateVariables($feed);

isnt($var->{channel_description}, '', 'got a channel description');
isnt($var->{channel_title}, '', 'got a channel title');
isnt($var->{channel_link}, '', 'got a channel link');
cmp_ok(scalar(@{$var->{item_loop}}), '>', 0, 'the item loop has items');

# processTemplate, this is where we run into trouble...
my $processed_template = eval {$syndicated_content->processTemplate($var,undef,$template) };
ok($processed_template, "A response was received from processTemplate.");

####################################################################
#
#  getTemplateVariables
#
####################################################################

##Construct a feed with no description so the resulting template variables can
##be checked for an undef description
my $feed = XML::FeedPP->new(<<EOFEED);
<?xml version="1.0" encoding="UTF-8" ?>
<feed xmlns="http://purl.org/atom/ns#" version="0.3" xmlns:admin="http://webns.net/mvcb/" xmlns:syn="http://purl.org/rss/1.0/modules/syndication/" xmlns:taxo="http://purl.org/rss/1.0/modules/taxonomy/">
<title type="text/plain">Revision Log - /WebGUI/</title>
<link rel="alternate" type="text/html" href="https://svn.webgui.org/svnweb/plainblack/log/WebGUI/" />
<author>
<name></name>
</author>
<modified>1970-01-01T00:53:41</modified>
<entry>
<title type="text/plain">12312 - Ready for 7.7.20 development.
</title>
<link rel="alternate" type="text/html" href="https://svn.webgui.org/svnweb/plainblack/revision?rev=12312" />
<author>
<name>colin</name>
</author>
<id>https://svn.webgui.org/svnweb/plainblack/revision?rev=12312</id>
<issued>1970-01-01T00:53:41</issued>
<modified>1970-01-01T00:53:41</modified>
</entry>
EOFEED

my $vars = $syndicated_content->getTemplateVariables($feed);
ok( defined $vars->{item_loop}->[0]->{description}, 'getTemplateVariables: description is not undefined');

##Construct a feed with a wrapped description, to check for paragraph handling.
$feed = XML::FeedPP->new(<<EOFEED);
<?xml version="1.0" encoding="UTF-8" ?>
<rss version="2.0">
<channel>
<title>The WebGUI buglist</title>
<link>/tbb</link>
<copyright /><pubDate>Mon, 12 Oct 2009 11:54:28 -0500</pubDate>
<description />
<item>
<title>Description with wrapped HTML paragraphs</title>
<link>http://www.webgui.org/use/bugs/tracker/11563</link>
<author>serif</author>
<epochDate>1254854387</epochDate>
<guid isPermaLink="true">http://www.webgui.org/use/bugs/tracker/11563</guid>
<pubDate>Mon, 14 May 2010 8:12:00 -0500</pubDate>
<description>
&lt;p&gt;In the attached feed, there is a hidden return line character from the
Rich Text editor in the first sentence of the description. When using a Syndicated Content
for the feed, the variable descriptionFirstParagraph variable cuts off at this return line
character, creating invalid markup.&lt;/p&gt;
&lt;p&gt;No more text is shown of the first paragraph beyond the bold characters of the first line.&lt;/p&gt;
&lt;p&gt;Third paragraph, for completeness.&lt;/p&gt;
</description>
</item>
</channel>
</rss>
EOFEED

$vars = $syndicated_content->getTemplateVariables($feed);
is $vars->{item_loop}->[0]->{descriptionFirstParagraph},
"<p>In the attached feed, there is a hidden return line character from the Rich Text editor in the first sentence of the description. When using a Syndicated Content for the feed, the variable descriptionFirstParagraph variable cuts off at this return line character, creating invalid markup.</p>",
'... first paragraph, when HTML is used';
is $vars->{item_loop}->[0]->{descriptionFirst2paragraphs},
"<p>In the attached feed, there is a hidden return line character from the Rich Text editor in the first sentence of the description. When using a Syndicated Content for the feed, the variable descriptionFirstParagraph variable cuts off at this return line character, creating invalid markup.</p><p>No more text is shown of the first paragraph beyond the bold characters of the first line.</p>",
'... first paragraph, when HTML is used';

####################################################################
#
#  generateFeed, hasTerms
#
####################################################################

sub withCachedFeed {
    my ($url, $path, $block) = @_;
    $syndicated_content->update({ rssUrl => $url });

    open my $file, '<', WebGUI::Test->getTestCollateralPath($path)
        or die "Unable to get RSS file: $path";
    my $content = do { local $/; <$file> };
    close $file;

    my $cache = WebGUI::Cache->new($session, $url, 'RSS');
    $cache->set($content, 60);
    $block->();
    $cache->delete;
}

sub titles_are {
    my ($expected, $message) = @_;
    my $feed = $syndicated_content->generateFeed;
    my @got = map { $_->title } $feed->get_item;
    cmp_deeply \@got, $expected, $message;
}

$syndicated_content->update({ hasTerms => 'WebGUI' });

withCachedFeed 'http://www.plainblack.com/tbb.rss', 'tbb.rss', sub {
    titles_are(
        [
            'Google Picasa Plugin for WebGUI Gallery',
            'WebGUI Roadmap',
            'WebGUI 8 Performance',
        ],
        'generateFeed: filters items based on the terms being in title, or description'
    );
};

####################################################################
#
#  Odd feeds
#
####################################################################

##Feed with no links or pubDates.
$syndicated_content->update({
    hasTerms     => '',
    maxHeadlines => 50,
});

withCachedFeed 'http://www.oncp.gob.ve/oncp.xml', 'oncp.xml', sub {
    my $oddFeed1 = $syndicated_content->generateFeed();

    my @oddItems = $oddFeed1->get_item();
    is (@oddItems, 13, 'feed has items even without pubDates or links');
};

####################################################################
#
#  sorting
#
####################################################################


withCachedFeed 'http://www.plainblack.com/tbb.rss', 'tbb_odd.rss', sub {
    my @ascending  = (
        'I have arrived in Lisboa!',
        'WebGUI 8 Performance',
        'WebGUI Roadmap',
        'Google Picasa Plugin for WebGUI Gallery',
    );
    my @descending = reverse @ascending;
    my @feed       = (
        'WebGUI Roadmap',
        'Google Picasa Plugin for WebGUI Gallery',
        'I have arrived in Lisboa!',
        'WebGUI 8 Performance',
    );

    $syndicated_content->update({ sortItems => 'pubDate_asc' });
    titles_are \@ascending, 'ascending sort';

    $syndicated_content->update({ sortItems => 'pubDate_des' });
    titles_are \@descending, 'descending sort';

    $syndicated_content->update({ sortItems => 'feed' });
    titles_are \@feed, 'feed order';
};
