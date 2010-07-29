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

# Test the asset dispatch system
# 
#

use FindBin;
use strict;
use lib "$FindBin::Bin/../lib";
use Test::More;
use WebGUI::Test; # Must use this before any other WebGUI modules
use WebGUI::Session;

#----------------------------------------------------------------------------
# Init
my $session         = WebGUI::Test->session;

BEGIN {
    $INC{'WebGUI/Asset/TestDispatch.pm'} = __FILE__;
}

package WebGUI::Asset::TestDispatch;

our @ISA = ('WebGUI::Asset');

# Override dispatch to handle special /foo URL
sub dispatch {
    my ( $self, $fragment ) = @_;

    if ( $fragment eq '/foo' ) {
        return "bar";
    }

    return $self->SUPER::dispatch( $fragment );
}

sub www_view {
    return "www_view";
}

sub www_edit {
    return "www_edit";
}

package main;

my $tag = WebGUI::VersionTag->getWorking( $session );
WebGUI::Test->addToCleanup( $tag );

#----------------------------------------------------------------------------
# Tests

plan tests => 10;        # Increment this number for each test you create

#----------------------------------------------------------------------------
# Test dispatch

# Add a TestDispatch asset and test
my $td  = WebGUI::Asset->getImportNode( $session )->addChild( { 
    url         => 'testDispatch',
    className   => 'WebGUI::Asset::TestDispatch',
} );
is( $td->dispatch, "www_view", "dispatch with no fragment shows www_view" );
is( $td->dispatch( '/foo' ), 'bar', 'dispatch detects fragment and returns' );
ok( !$td->dispatch( '/unhandled' ), 'dispatch with unknown fragment returns false' );

# Test func=
$session->request->setup_body( {
    func        => 'edit',
} );
is( $td->dispatch, "www_edit", "dispatch handles ?func= query param" );
is( $td->dispatch( '/foo' ), "bar", "overridden dispatch trumps ?func= query param" );

# Test func= can only be run on the exact asset we requested
my $output = $td->dispatch( '/bar' );
is( $output, undef, "dispatch returned undef, meaning that it declined to handle the request for a func but the wrong URL" );
isnt( $output, "www_edit", "?func= dispatch cancelled because of unhandled fragment" );

# Test unhandled options
$session->request->setup_body( {
    func        => 'notAMethod',
} );
is( $td->dispatch, "www_view", "requests for non-existant methods return www_view method" );

$session->request->setup_body( { } );
$output = $td->dispatch( '/not-foo' );
is( $output, undef, "dispatch returned undef, meaning that it declined to handle the request for the wrong URL" );
isnt( $output, "www_view", "?func= dispatch cancelled because of unhandled fragment" );

#vim:ft=perl
