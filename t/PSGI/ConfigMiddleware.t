use strict;
use warnings;
use Test::More tests => 3;

use Plack::Test;
use Plack::Util;
use HTTP::Request::Common;
use WebGUI::Paths;
use WebGUI::Test;

SKIP: {
    skip 'set WEBGUI_LIVE to enable these tests', 3 unless $ENV{WEBGUI_LIVE};

    my $session         = WebGUI::Test->session;
    $session->config->addToArray( 'plackMiddleware', '+WebGUI::Middleware::SHOUTING' );

    local $ENV{WEBGUI_CONFIG} = WebGUI::Test->file; # tell the share/site.psgi which site to load

    my $app = Plack::Util::load_psgi( WebGUI::Paths->defaultPSGI );

    ok( $app, "created a PSGI app from app.psgi" );

    test_psgi $app, sub {
        my $cb = shift;
        my $res = $cb->( GET "/home" );
        is $res->code, 200, 'able to fetch pages with WebGUI::Middleware::SHOUTING installed';
        like $res->content, qr/EASY TO USE WEB APPLICATION FRAMEWORK/, 'contains the text "EASY TO USE WEB APPLICATION FRAMEWORK"';
    };

    $session->config->deleteFromArray( 'plackMiddleware', '+WebGUI::Middleware::SHOUTING' );
}

package WebGUI::Middleware::SHOUTING;
BEGIN { $INC{'WebGUI/Middleware/SHOUTING.pm'} = __FILE__; };

use parent 'Plack::Middleware';

sub call {
    my($self, $env) = @_;
    my $res = $self->app->($env);
    for ( ref $res->[2] ? @{ $res->[2] } : ( $res->[2] ) ) {
        s{>(.*?)<}{'>' . uc($1) . '<'}gse;
    }
    return $res;
}

