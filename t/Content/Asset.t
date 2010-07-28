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

$INC{'WebGUI::Asset::TestDispatch'} = __FILE__;
$INC{'WebGUI::Asset::TestDecline'} = __FILE__;

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

sub www_edit {
    my ( $self ) = @_;
    return "www_edit " . $self->get('title');
}

sub www_view {
    my ( $self ) = @_;
    return "www_view " . $self->get('title');
}

package WebGUI::Asset::TestDecline;

our @ISA = ( 'WebGUI::Asset' );

# Override dispatch to decline everything
sub dispatch { return; }

sub www_edit { return "you'll never see me!" }

package main;

my $td
    = WebGUI::Asset->getImportNode( $session )->addChild( {
        title           => "one",
        className       => 'WebGUI::Asset::TestDispatch',
        url             => 'testdispatch',
    } );

WebGUI::Test->addToCleanup( WebGUI::VersionTag->getWorking( $session ) );

#----------------------------------------------------------------------------
# Tests

plan tests => 11;        # Increment this number for each test you create

#----------------------------------------------------------------------------
# test getUrlPermutation( url ) method

cmp_deeply( 
    WebGUI::Content::Asset::getUrlPermutations( ),
    [ ],
    "Handles no URL gracefully",
);
cmp_deeply( 
    WebGUI::Content::Asset::getUrlPermutation( "one" ),
    [ 'one' ],
);
cmp_deeply(
    WebGUI::Content::Asset::getUrlPermutation( "/one" ),
    [ '/one', ],
);
cmp_deeply(
    WebGUI::Content::Asset::getUrlPermutation( "/one/two/three" ),
    [ '/one/two/three', '/one/two', '/one', ],
);
cmp_deeply(
    WebGUI::Content::Asset::getUrlPermutation( "/one/two/three.rss" ),
    [ '/one/two/three.rss', '/one/two/three', '/one/two', '/one', ],
    ".ext is a seperate URL permutation",
);


#----------------------------------------------------------------------------
# test dispatch( session, url ) method
is(
    WebGUI::Content::Asset::dispatch( $session, "testdispatch" ),
    "www_view one",
    "Regular www_view",
);

is(
    WebGUI::Content::Asset::dispatch( $session, "testdispatch/foo" ),
    "bar",
    "special /foo handler",
);

# Add an asset that clobbers the TestDispatch's /foo
my $clobberingTime
    = WebGUI::Asset->getImportNode( $session )->addChild( {
        title       => "two",
        className   => 'WebGUI::Asset::TestDispatch',
        url         => $td->get('url') . '/foo',
    } );

is(
    WebGUI::Content::Asset::dispatch( $session, "testdispatch/foo" ),
    "www_view two",
    "dispatch to the asset with the longest URL",
);

$clobberingTime->purge;

# Add an asset that declines everything instead
my $declined
    = WebGUI::Asset->getImportNode( $session )->addChild( {
        title       => "three",
        className   => 'WebGUI::Asset::TestDecline',
        url         => $td->get('url') . '/foo',
    } );

is(
    WebGUI::Content::Asset::dispatch( $session, "testdispatch/foo" ),
    "bar",
    "Dispatch passes to TestDispatch asset after declined",
);

# Test ?func= dispatch with declined asset
$session->request->setup_body({
    func        => "edit",
});

my $output  = WebGUI::Content::Asset::dispatch( $session, "testdispatch/foo" );
isnt( $output, "you'll never see me!", "func=edit was declined" );
isnt( $output, "www_edit one", "func=edit was not for us" );

#vim:ft=perl
