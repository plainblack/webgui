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
use File::Spec;
use lib "$FindBin::Bin/../../lib";

use Data::Dumper;

# The goal of this test is to test the creation of 
# and expose any bugs of SyndicatedContent Wobjects.

use WebGUI::Test;
use WebGUI::Session;
use Test::More tests => 20; # increment this value for each test you create
use WebGUI::Asset::Wobject::SyndicatedContent;
use XML::FeedPP;

my $session = WebGUI::Test->session;
my %var;
my (@rss_feeds);

##############################
##          SETUP           ##
##############################
# Do our work in the import node
my $node = WebGUI::Asset->getImportNode($session);

# Create a version tag to work in
my $versionTag = WebGUI::VersionTag->getWorking($session);
$versionTag->set({name=>"SyndicatedContent Test"});
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

END {
	# Clean up after thy self
	$versionTag->rollback();
}

