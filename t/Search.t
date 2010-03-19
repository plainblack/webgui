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
use lib "$FindBin::Bin/lib";
use Test::More;
use Test::Deep;
use WebGUI::Test; # Must use this before any other WebGUI modules
use WebGUI::Session;

#----------------------------------------------------------------------------
# Init
my $session         = WebGUI::Test->session;


#----------------------------------------------------------------------------
# Tests

plan tests => 10;        # Increment this number for each test you create

#----------------------------------------------------------------------------
# put your tests here

use_ok('WebGUI::Search');
use_ok('WebGUI::Search::Index');

my $search = WebGUI::Search->new($session);

################################################
#
# _isStopword
#
################################################

ok(! $search->_isStopword('not a stopword'), '_isStopword: not a stopword');
ok(  $search->_isStopword('the'),            '_isStopword: "the" is a stopword');
ok(  $search->_isStopword('all*'),           '_isStopword: regex metacharacter * does not crash the search');
ok(  $search->_isStopword('anybody+'),       '_isStopword: regex metacharacter + does not crash the search');
ok(  $search->_isStopword('maybe?'),         '_isStopword: regex metacharacter ? does not crash the search');
ok(! $search->_isStopword('private.+'),      '_isStopword: regex metacharacters .+ do not crash the search');

################################################
#
# Chinese ideograph handling
#
################################################
SKIP: {
    use utf8;

    my $min_word_length = $session->db->quickScalar('SELECT @@ft_min_word_len');
    skip 'MySQL minimum word length too long to support ideograms', 2
        if $min_word_length > 2;

    # Create an article to index
    my $article         = WebGUI::Asset->getImportNode( $session )->addChild( {
        className       => 'WebGUI::Asset::Wobject::Article',
        title           => 'Chinese ideograph experiment',
        description     => "甲骨文",
    } );
    my $tag = WebGUI::VersionTag->getWorking( $session );
    $tag->commit;
    WebGUI::Test->tagsToRollback($tag);
    WebGUI::Search::Index->create( $article );
    my $searcher = WebGUI::Search->new($session);
    my $assetIds = $searcher->search({ keywords => "Chinese", })->getAssetIds;
    cmp_deeply( $assetIds, [ $article->getId ], 'basic test for search works');
    my $searcher = WebGUI::Search->new($session);
    my $assetIds = $searcher->search({ keywords => "甲", })->getAssetIds;
    cmp_deeply( $assetIds, [ $article->getId ], 'ideograph search works');
}

#----------------------------------------------------------------------------
# Cleanup
END {

}
#vim:ft=perl
