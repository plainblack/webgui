use strict;
use warnings;
use Test::More tests => 4;

use Plack::Test;
use Plack::Util;
use HTTP::Request::Common;
use WebGUI::Paths;
use WebGUI::Test;

my $app = Plack::Util::load_psgi( WebGUI::Paths->defaultPSGI );

SKIP: {
    skip 'set WEBGUI_LIVE to enable these tests', 4 unless $ENV{WEBGUI_LIVE};

    no warnings 'redefine';

    local *WebGUI::Asset::Template::www_die = sub {
        my $self = shift;
        $self->session->log->fatal("Invalid fill color");
    };

    my $session         = WebGUI::Test->session;

    my $prev_showDebug = $session->setting->get( 'showDebug' );
    my $prev_ipDebug = $session->setting->get( 'ipDebug' );

    $session->setting->set( 'showDebug', 1 );
    $session->setting->set( 'ipDebug', '' );

    local $ENV{HTTP_ACCEPT} = 'text/html';
    open(local *STDERR, '>', "/dev/null") or die $!;

    test_psgi $app, sub {
        my $cb = shift;
        my $res = $cb->( GET "/make_page_printable?func=die" );
        is $res->code, 500, '500 return code on booby-trapped with showDebug/ipDebug set to show errors';
        like $res->content, qr/Error trace/, 'Error trace contains the text "Error trace"';
        like $res->content, qr/Show function arguments/, 'Error trace contains the text "Show function arguments"';
        like $res->content, qr/Show lexical variables/, 'Error trace contains the text "Show lexical variables"';
    };

    $session->setting->set( 'showDebug', $prev_showDebug );
    $session->setting->set( 'ipDebug', $prev_ipDebug );

}

