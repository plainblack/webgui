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

# Test the operation of the Asset Manager
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
use WebGUI::Content::AssetManager;

#----------------------------------------------------------------------------
# Init
my $session         = WebGUI::Test->session;
$session->http->{_http}->{noHeader} = 1;  ##Workaround for cookie processing

# Create a folder with some stuff to test the AssetManager
my $folder = WebGUI::Asset->getImportNode( $session )->addChild( {
    className       => "WebGUI::Asset::Wobject::Folder",
    url             => 'shawshank_penitentary',
} );

my $snippet_one = $folder->addChild( {
    className       => 'WebGUI::Asset::Snippet',
    title           => "one",
} );

my $snippet_two = $folder->addChild( {
    className       => 'WebGUI::Asset::Snippet',
    title           => "two",
} );

my $article = $folder->addChild( {
    className       => 'WebGUI::Asset::Wobject::Article',
    title           => "three",
} );


#----------------------------------------------------------------------------
# Tests

plan tests => 1;        # Increment this number for each test you create

#----------------------------------------------------------------------------
# Test update rank

$session->user({ userId => 3 });
$session->request->uri( $folder->get('url') ); # haha!
$session->request->setup_body( {
    op                              => 'assetManager',
    method                          => 'setRanks',
    "action_update"                 => 1, # button
    assetId                         => [ $snippet_one->getId, $snippet_two->getId, $article->getId ], # checkboxes
    $snippet_one->getId . '_rank'   => 3, # rank box
    $snippet_two->getId . '_rank'   => 1, # rank box
    $article->getId . '_rank'       => 2, # rank box
} );

WebGUI::Content::AssetManager::handler( $session );

cmp_deeply( 
    $folder->getLineage(['children']), 
    [ $snippet_two->getId, $article->getId, $snippet_one->getId, ], 
    "Asset Manager updates rank correctly"
) 
or diag( 
    Dumper( $folder->getLineage(['children']) ), 
    Dumper( [ $snippet_two->getId, $article->getId, $snippet_one->getId ] ),
);

#----------------------------------------------------------------------------
# Cleanup
END {
    WebGUI::VersionTag->getWorking( $session )->rollback;
}
#vim:ft=perl
