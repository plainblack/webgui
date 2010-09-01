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

# Test the API of the DataTable form control
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


#----------------------------------------------------------------------------
# Tests

plan tests => 11;        # Increment this number for each test you create

#----------------------------------------------------------------------------
# DataTable creation
use_ok( "WebGUI::Form::DataTable" );
my $dt  = WebGUI::Form::DataTable->new( $session, { } );
isa_ok( $dt, 'WebGUI::Form::DataTable' );

#----------------------------------------------------------------------------
# Default value
cmp_deeply( 
    JSON->new->decode( $dt->getDefaultValue ),
    { 
        columns 
            => bag( { 
                key             => "New Column",
                formatter       => "text",
            } ), 
        rows 
            => bag( { 
                "New Column"    => "Value",
            } ), 
    },
    "Default value contains proper data structure and dummy data",
);

#----------------------------------------------------------------------------
# getValue
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

# Passing in JSON
is( ref $dt->getValue( $value ), '', 'getValue( $value ) returns scalar' );
cmp_deeply( 
    JSON->new->decode( $dt->getValue( $value ) ),
    hash( $value ),
    'getValue( $value ) returns proper JSON data structure',
);

#----------------------------------------------------------------------------
# getOriginalValue
# Set at beginning
$dt = WebGUI::Form::DataTable->new( $session, {
    name    => "test",
    value   => JSON->new->encode( $value ),
    id      => "test",
} );
cmp_deeply(
    JSON->new->decode( $dt->getOriginalValue ),
    hash( $value ),
    'getOriginalValue returns proper JSON data structure',
);

#----------------------------------------------------------------------------
# getTableHtml
my $html    = $dt->getTableHtml( JSON->new->decode( $dt->getOriginalValue ) );
like( $html, qr{^<div[^>]*class="yui-skin-sam"}, "getTableHtml contains a div with skin class" );
like( $html, qr{^<div[^>]*id="test-container"}, "getTableHtml div has ID" );
like( $html, qr{<table.*</table>}, "getTableHtml contains a table" );
like( $html, qr{<table[^>]*id="test-container-table"}, "getTableHtml table has ID" );

#----------------------------------------------------------------------------
# toHtml
my $html    = $dt->toHtml;
ok( $dt->get( "showEdit" ), "showEdit gets set by toHtml" );

#vim:ft=perl
