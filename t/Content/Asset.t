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

use strict;
use Test::More;
use Test::MockObject::Extends;
use Test::Deep;
use Data::Dumper;
use WebGUI::Test; # Must use this before any other WebGUI modules
use WebGUI::Session;
use WebGUI::Content::Asset;
use Encode;

my $output;

#----------------------------------------------------------------------------
# Init
my $session         = WebGUI::Test->session;

BEGIN {
    $INC{'WebGUI/Asset/TestDispatch.pm'} = __FILE__;
    $INC{'WebGUI/Asset/TestDecline.pm'} = __FILE__;
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

my $utf8_url = "Viel-spa\x{00DF}";
utf8::upgrade $utf8_url;
my $utf8
    = WebGUI::Asset->getImportNode( $session )->addChild( {
        title           => "utf8",
        className       => 'WebGUI::Asset::TestDispatch',
        url             => $utf8_url,
    } );

WebGUI::Test->addToCleanup( WebGUI::VersionTag->getWorking( $session ) );

#----------------------------------------------------------------------------
# test getUrlPermutation( url ) method

cmp_deeply( 
    WebGUI::Content::Asset::getUrlPermutations( ),
    [ '/' ],
    "No URL returns /",
);
cmp_deeply( 
    WebGUI::Content::Asset::getUrlPermutations( '/' ),
    [ '/' ],
    "URL with only slash is handled",
);
cmp_deeply( 
    WebGUI::Content::Asset::getUrlPermutations( "one" ),
    [ 'one' ],
    "simple one element URL",
);
cmp_deeply(
    WebGUI::Content::Asset::getUrlPermutations( "/one" ),
    [ '/one', ],
    "simple one element URL with leading slash",
);
cmp_deeply(
    WebGUI::Content::Asset::getUrlPermutations( "one/two/three" ),
    [ 'one/two/three', 'one/two', 'one', ],
    "three element URL",
);
cmp_deeply(
    WebGUI::Content::Asset::getUrlPermutations( "/one/two/three" ),
    [ '/one/two/three', '/one/two', '/one', ],
    "three element URL with leading slash",
);
cmp_deeply(
    WebGUI::Content::Asset::getUrlPermutations( "/one/two/three.rss" ),
    [ '/one/two/three.rss', '/one/two/three', '/one/two', '/one', ],
    ".ext is a seperate URL permutation",
);
cmp_deeply(
    WebGUI::Content::Asset::getUrlPermutations( $utf8_url ),
    [ $utf8_url ],
    "UTF-8 handling for URLs",
);

#----------------------------------------------------------------------------
# test dispatch( session, url ) method
is ($session->asset, undef, 'session asset is not defined, yet');
$output = WebGUI::Content::Asset::dispatch( $session, "testdispatch" );
is $output, "www_view one", "Regular www_view";

is $session->asset && $session->asset->getId, $td->getId, 'dispatch set the session asset';

my $_asset = WebGUI::Asset->newByUrl($session, $utf8_url);
isa_ok $_asset, 'WebGUI::Asset::TestDispatch';

$output = WebGUI::Content::Asset::dispatch( $session, $utf8_url );
is $output, "www_view utf8", "dispatch for utf8 urls";

$output = WebGUI::Content::Asset::dispatch( $session, "testdispatch/foo" );
is $output, "bar", "special /foo handler";

# Add an asset that clobbers the TestDispatch's /foo
my $clobberingTime
    = WebGUI::Asset->getImportNode( $session )->addChild( {
        title       => "two",
        className   => 'WebGUI::Asset::TestDispatch',
        url         => $td->get('url') . '/foo',
    } );
WebGUI::Test->addToCleanup($clobberingTime);

is(
    WebGUI::Content::Asset::dispatch( $session, "testdispatch/foo" ),
    "www_view two",
    "dispatch to the asset with the longest URL",
);
is ($session->asset->getId, $clobberingTime->getId, 'dispatch reset the session asset');

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

$output  = WebGUI::Content::Asset::dispatch( $session, "testdispatch/foo" );
isnt( $output, "you'll never see me!", "func=edit was declined" );
isnt( $output, "www_edit one", "func=edit was not for us" );

# Test that empty URL returns the default page.
$session->request->setup_body({ });
my $originalDefaultPage = $session->setting->get('defaultPage');
$session->setting->set('defaultPage', $td->getId);
$output  = WebGUI::Content::Asset::dispatch( $session );
is $output, 'www_view one', 'an empty URL returns the default asset';
$session->setting->set('defaultPage', $originalDefaultPage);

#----------------------------------------------------------------------------
# 304 Content Not Modified response

my $newAsset = WebGUI::Asset->getImportNode( $session )->addChild( {
    className       => 'WebGUI::Asset::Wobject::Article',
} );

my $tag = WebGUI::VersionTag->getWorking( $session );
$tag->commit;
WebGUI::Test->addToCleanup( $tag );

my $http_request = HTTP::Request::Common::GET('http://'.$session->config->get('sitename')->[0]);
$http_request->header('If-Modified-Since' => $session->datetime->epochToHttp(time + 20)); # 20 seconds into the future!
my $notModifiedSession  = WebGUI::Test->newSession( undef, $http_request);
WebGUI::Test->addToCleanup( $notModifiedSession );

my $output = WebGUI::Content::Asset::handler( $notModifiedSession );
is( $output, "chunked", "304 returns chunked" );
is( $notModifiedSession->http->getStatus, "304", "http status code set" );
ok( !$notModifiedSession->closed, "session is not closed" );

$notModifiedSession  = WebGUI::Test->newSession( undef, $http_request);
WebGUI::Test->addToCleanup( $notModifiedSession );
$notModifiedSession->user({ userId => 3});
my $output = WebGUI::Content::Asset::handler( $notModifiedSession );
isnt( $notModifiedSession->http->getStatus, "304", "logged in user doesn't get 304" );
ok( !$notModifiedSession->closed, "session is not closed" );

# Test that requesting a URL that doesn't exist, but one of the permutations does exist, returns undef

$session->request->setup_body({ });
my $nonexistant_url = WebGUI::Asset->getDefault($session)->get('url');
$nonexistant_url = join '/', $nonexistant_url, 'nothing_here_to_see';
$output  = WebGUI::Content::Asset::dispatch( $session, $nonexistant_url );
is $output, undef, 'getting a URL which does not exist returns undef';
is $session->asset, undef, '... session asset is not set';

use WebGUI::Asset::RssAspectDummy;
my $dummy = WebGUI::Asset->getImportNode($session)->addChild({
    className   => 'WebGUI::Asset::RssAspectDummy',
    url         => '/home/shawshank',
    title       => 'Dummy Title',
    synopsis    => 'Dummy Synopsis',
    description => 'Dummy Description',
});
WebGUI::Test->addToCleanup($dummy);
$output  = WebGUI::Content::Asset::dispatch( $session, '/home/shawshank/no-child-here' );
is $output, undef, 'RSS Aspect propagates the fragment';

done_testing;

#vim:ft=perl
