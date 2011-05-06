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

use strict;
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

use WebGUI::Asset;
use WebGUI::Exception;
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

sub www_alsoView {
    return;
}

sub www_brokenTemplate {
    my $self = shift;
    WebGUI::Error::ObjectNotFound::Template->throw(
            error      => qq{Template not found},
            templateId => "This is a GUID",
            assetId    => $self->getId,
    );
}

sub www_dies {
    my $self = shift;
    die "...aside from that bullet\n";
}

package main;

#----------------------------------------------------------------------------
# Tests

plan tests => 18;        # Increment this number for each test you create

#----------------------------------------------------------------------------
# Test dispatch

# Add a TestDispatch asset and test
my $td  = WebGUI::Test->asset->addChild( { 
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

# Test unhandled options
$session->request->setup_body( {
    func        => 'alsoView',
} );
is( $td->dispatch, "www_view", "if a query method returns undef, view is still returned" );

$session->request->setup_body( { } );
$output = $td->dispatch( '/not-foo' );
is( $output, undef, "dispatch returned undef, meaning that it declined to handle the request for the wrong URL" );
isnt( $output, "www_view", "?func= dispatch cancelled because of unhandled fragment" );

$td->cut();
$output = $td->dispatch();
is $output, undef, 'dispatch returns undef when trying to access an asset that is not published, and admin is not on';
$session->user({ userId => 3 });
$output = $td->dispatch();
is $output, 'www_view', 'when admin is on, the asset can be accessed';

$td->publish();
$session->user({ userId => 1 });
$output = $td->dispatch();
is $output, 'www_view', 'asset state restored for next tests';

# Test template exceptions
$session->request->setup_body( {
    func        => 'brokenTemplate',
} );
WebGUI::Test->interceptLogging(sub {
    my $log_data = shift;
    is( $td->dispatch, "www_view", "if a query method throws a Template exception, view is returned instead" );
    is $log_data->{error}, 'Template not found templateId: This is a GUID assetId: '. $td->getId, '... and logged an error';
});

WebGUI::Test->interceptLogging(sub {
    my $log_data = shift;
    $session->request->setup_body( {
        func        => 'dies',
    } );
    is( $td->dispatch, "www_view", "if a query method dies, view is returned instead" );
    is $log_data->{warn}, "Couldn't call method www_dies on asset for url: / Root cause: ...aside from that bullet\n", '.. and logged a warn';
});

#vim:ft=perl
