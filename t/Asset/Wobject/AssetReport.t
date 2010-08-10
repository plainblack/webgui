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

# This tests the AssetReport asset
# 
#

use FindBin;
use strict;
use lib "$FindBin::Bin/../../lib";
use Test::More;
use Test::Deep;
use JSON;
use WebGUI::Test; # Must use this before any other WebGUI modules
use WebGUI::Session;

#----------------------------------------------------------------------------
# Init
my $session         = WebGUI::Test->session;
my $node            = WebGUI::Asset->getImportNode( $session );

#----------------------------------------------------------------------------
# Tests

plan tests => 3;        # Increment this number for each test you create

#----------------------------------------------------------------------------
# Asset Report creation
use_ok( "WebGUI::Asset::Wobject::AssetReport" );
my $ar  = $node->addChild( {
    className   => 'WebGUI::Asset::Wobject::AssetReport',
} );

isa_ok( $ar, 'WebGUI::Asset::Wobject::AssetReport' );
WebGUI::Test->addToCleanup($ar);

my $f = $node->addChild({
    className => 'WebGUI::Asset::Wobject::Folder',
    title     => 'Asset Report Test',
});
WebGUI::Test->addToCleanup($f);

my $sn = $f->addChild({
    className => 'WebGUI::Asset::Snippet',
    title     => 'Shawshank',
});

#----------------------------------------------------------------------------
# Value and variables
my $value = {
    isNew       => "false",
    className   => "WebGUI::Asset::Snippet",
    startNode   => $f->getId,
    anySelect   => "or",
    where       => {
        1   =>  {
            opSelect    =>  "=",
            propSelect  =>  "assetData.title",
            valText     =>  "'Shawshank'"
        },
    },
    whereCount  => "2",
    order       => {
        1   =>  {
            dirSelect   => "desc",
            orderSelect => "assetData.title"
        },
    },
    orderCount  => "2",
    limit       => "0",
};

my $settings  = JSON->new->encode( $value );

$ar->update( {
    settings        => $settings,
    paginateAfter   => 50,
} );

#----------------------------------------------------------------------------
# getTemplateVars

cmp_deeply(
    $ar->getTemplateVars,
    hash( {
        %{ $ar->get },
        'settings'                          => $settings,
        'paginateAfter'                     => 50,
        'templateId'                        => 'sJtcUCfn0CVbKdb4QM61Yw',
        'pagination.firstPageUrl'           => ignore(),
        'pagination.isLastPage'             => ignore(),
        'pagination.nextPage'               => ignore(),
        'pagination.previousPageUrl'        => ignore(),
        'pagination.lastPageText'           => ignore(),
        'pagination.pageCount'              => ignore(),
        'pagination.firstPageText'          => ignore(),
        'pagination.previousPage'           => ignore(),
        'pagination.pageLoop'               => ignore(),
        'pagination.lastPage'               => ignore(),
        'pagination.lastPageUrl'            => ignore(),
        'pagination.pageNumber'             => ignore(),
        'pagination.pageList.upTo10'        => ignore(),
        'pagination.pageCount.isMultiple'   => ignore(),
        'pagination.pageList'               => ignore(),
        'pagination.previousPageText'       => ignore(),
        'pagination.nextPageUrl'            => ignore(),
        'pagination.pageLoop.upTo10'        => ignore(),
        'pagination.pageList.upTo20'        => ignore(),
        'pagination.pageLoop.upTo20'        => ignore(),
        'pagination.isFirstPage'            => ignore(),
        'pagination.nextPageText'           => ignore(),
        'pagination.firstPage'              => ignore(),
        'asset_loop'                        => [{ %{ $sn->get } }],
    } ),
    "getTemplateVars returns complete and correct data structure",
);


#vim:ft=perl
