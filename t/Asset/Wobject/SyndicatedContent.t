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
use Test::More tests => 19; # increment this value for each test you create
use WebGUI::Asset::Wobject::SyndicatedContent;

my $session = WebGUI::Test->session;
my %var;
my ($items, @rss_feeds);

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
	rssUrl       => "http://morningmonologue.wordpress.com/feed/", # broken
	#rssUrl       => "http://motivationalmuse.wordpress.com/feed/", #working feed
};

# update the new values for this instance
$syndicated_content->update($newSyndicatedContentSettings);

# Let's check our updated values
foreach my $newSetting (keys %{$newSyndicatedContentSettings}) {
	is ($syndicated_content->get($newSetting), $newSyndicatedContentSettings->{$newSetting}, "updated $newSetting is ".$newSyndicatedContentSettings->{$newSetting});
}

# Can we get the rss url?
ok($syndicated_content->getRssUrl, 'getRSSUrl returns something.');

# test getContentLastModified
ok($syndicated_content->getContentLastModified, 'getContentLastModified returns something.');

# Test max headlines parsed from feed
my $max_headlines = $syndicated_content->_getMaxHeadlines;
ok($syndicated_content->_getMaxHeadlines, "Max Headlines returned a value [$max_headlines]");

# Limit the headlines so the test will complete in a reasonable amount of time.
# default is 100K titles, which is way too much for a test
$syndicated_content->{maxHeadlines} = "3";
my @validated_urls = $syndicated_content->_getValidatedUrls;
ok($syndicated_content->_getValidatedUrls, "Validated Urls returned a value [@validated_urls]");

# Lets make sure the view method returns something.
is ($syndicated_content->{_viewTemplate}, undef, 'internal template cache unset until prepareView is called');

$syndicated_content->prepareView;
isnt ($syndicated_content->{_viewTemplate}, undef, 'internal template cache set by prepare view');
isa_ok ($syndicated_content->{_viewTemplate}, 'WebGUI::Asset::Template', 'internal template cache');

my $output = $syndicated_content->view('2.0');
isnt ($output, "", 'Default view method returns something for RSS 2.0 format');

my $output = $syndicated_content->view('1.0');
isnt ($output, "", 'Default view method returns something for RSS 1.0 format');

# Not really sure what this does...
my $hasTermsRegex = "" ; #$syndicated_content->_make_regex( $syndicated_content->getValue('hasTerms') );
#is ($hasTermsRegex, $hasTermsRegex, " hasTermsRegex Terms Returned [ $hasTermsRegex ]");

my $rss_info = WebGUI::Asset::Wobject::SyndicatedContent::_get_rss_data($session,$newSyndicatedContentSettings->{'rssUrl'});
ok(ref($rss_info) eq 'HASH',  "Hashref returned from _get_rss_data");
push(@rss_feeds, $rss_info) ;

my $xml_list = WebGUI::Asset::Wobject::SyndicatedContent::_create_interleaved_items($items, \@rss_feeds  , $max_headlines, $hasTermsRegex);
ok($xml_list , "Got results back from XML " );

my($item_loop,$rss_feeds) = $syndicated_content->_get_items(\@validated_urls, $max_headlines);
ok(ref($item_loop) eq 'ARRAY',"Arrayref of items returned from _get_items" );
ok(ref($rss_feeds) eq 'ARRAY',"Arrayref of feeds returned from _get_items" );

# update var with item_loop for the upcoming template processing
$var{item_loop} = $item_loop;

# create a new template object in preparation for rendering
my $template = WebGUI::Asset::Template->new($session, $syndicated_content->get("templateId"));
$template->prepare;
isa_ok($template, 'WebGUI::Asset::Template');

$syndicated_content->{_viewTemplate} = $template;

# Is a WebGUI URL created for the RSS feed? 
my $url = $syndicated_content->_createRSSURLs(\%var);
ok($url,"A URL was created for RSS feed");

# processTemplate, this is where we run into trouble...
my $processed_template = $syndicated_content->processTemplate(\%var,undef,$template);
ok($processed_template, "A response was received from processTemplate.");


END {
	# Clean up after thy self
	$versionTag->rollback();
}

