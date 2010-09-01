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

# Test the featured page of the Wiki
# 
#

use strict;
use Test::More;
use Test::Deep;
use WebGUI::Test; # Must use this before any other WebGUI modules
use WebGUI::Session;

#----------------------------------------------------------------------------
# Init
my $session         = WebGUI::Test->session;
my $import          = WebGUI::Asset->getImportNode( $session );

my $wiki
    = $import->addChild( {
        className       => 'WebGUI::Asset::Wobject::WikiMaster',
    } );

my $page
    = $wiki->addChild( {
        className       => 'WebGUI::Asset::WikiPage',
    }, undef, undef, { skipAutoCommitWorkflows => 1 } );

my $featuredPage
    = $wiki->addChild( {
        className       => 'WebGUI::Asset::WikiPage',
        isFeatured      => 1,
        title           => "Escape From Shawshank!",
        content         => 'A how-to book',
    }, undef, undef, { skipAutoCommitWorkflows => 1 } );

WebGUI::Test->addToCleanup( WebGUI::VersionTag->getWorking( $session ) );

#----------------------------------------------------------------------------
# Tests

plan tests => 2;        # Increment this number for each test you create

#----------------------------------------------------------------------------
# 

cmp_deeply(
    $wiki->getFeaturedPageIds,
    [ $featuredPage->getId ],
    "getFeaturedPageIds contains only featured pages",
);

cmp_deeply(
    $wiki->appendFeaturedPageVars({}, $featuredPage),
    superhashof( {
        featured_title      => $featuredPage->get('title'),
        featured_content    => $featuredPage->get('content'),
    } ),
    "appendFeaturedPageVars returns correct variables, prefixed with 'featured_'",
);


#vim:ft=perl
