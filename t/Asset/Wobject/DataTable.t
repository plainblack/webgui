# vim:syntax=perl
#-------------------------------------------------------------------
# WebGUI is Copyright 2001-2012 Plain Black Corporation.
#-------------------------------------------------------------------
# Please read the legal notices (docs/legal.txt) and the license
# (docs/license.txt) that came with this distribution before using
# this software.
#------------------------------------------------------------------
# http://www.plainblack.com                     info@plainblack.com
#------------------------------------------------------------------

# This tests the DataTable asset
# 
#

use strict;
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

plan tests => 6;        # Increment this number for each test you create

#----------------------------------------------------------------------------
# Datatable creation
use_ok( "WebGUI::Asset::Wobject::DataTable" );
my $dt  = $node->addChild( {
    className   => 'WebGUI::Asset::Wobject::DataTable',
} );
isa_ok( $dt, 'WebGUI::Asset::Wobject::DataTable' );
WebGUI::Test->addToCleanup($dt);

#----------------------------------------------------------------------------
# Value and variables
my $value   = {
    columns     => [
        {
            key         => "Col1",
            formatter   => "number",
        },
        {
            key         => "Col2",
            formatter   => "text",
        },
    ],
    rows        => [
        {
            Col1    => "1",
            Col2    => "two",
        },
        {
            Col1    => "2",
            Col2    => "three",
        },
        {
            Col1    => "3",
            Col2    => "four",
        },
    ],
};

$dt->update( {
    data => JSON->new->encode( $value ),
} );

cmp_deeply(
    JSON->new->decode( $dt->getDataJson ),
    hash( $value ),
    "getDataJson returns JSON data structure",
);

cmp_deeply(
    JSON->new->decode( $dt->www_ajaxGetData ),
    hash( $value ),
    "www_ajaxGetData returns JSON data structure",
);

#----------------------------------------------------------------------------
# getTemplateVars and getDataTemplateVars
cmp_deeply(
    $dt->getDataTemplateVars,
    hash( {
        columns => [
            subhashof( { key => "Col1", formatter => "number" } ),
            subhashof( { key => "Col2", formatter => "text" } ),
        ],
        rows    => [
            {
                row_columns => [
                    subhashof( { key => "Col1", formatter => "number", value => 1 } ),
                    subhashof( { key => "Col2", formatter => "text", value => "two" } ),
                ],
                Col1        => "1",
                Col2        => "two",
            },
            {
                row_columns => [
                    subhashof( { key => "Col1", formatter => "number", value => 2 } ),
                    subhashof( { key => "Col2", formatter => "text", value => "three" } ),
                ],
                Col1        => "2",
                Col2        => "three",
            },
            {
                row_columns => [
                    subhashof( { key => "Col1", formatter => "number", value => 3 } ),
                    subhashof( { key => "Col2", formatter => "text", value => "four" } ),
                ],
                Col1        => "3",
                Col2        => "four",
            },
        ],
    } ),
    "getDataTemplateVars returns complete and correct data structure",
);

cmp_deeply(
    $dt->getTemplateVars,
    hash( {
        %{ $dt->getTemplateVars },
        %{ $dt->get },
        url         => $dt->getUrl,
        dataJson    => $dt->getDataJson,
        dataTable   => $dt->getDataTable,
    } ),
    "getTemplateVars returns complete and correct data structure",
);

#vim:ft=perl
