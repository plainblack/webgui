use strict;
use warnings;
use Test::More tests => 7;

use Plack::Test;
use Plack::Util;
use HTTP::Request::Common;
use WebGUI::Paths;
use WebGUI::Test;

# test things about responses
# this is like t/Session/Http.t but Plack specific

SKIP: {
    skip 'set WEBGUI_LIVE to enable these tests', 7 unless $ENV{WEBGUI_LIVE};

    my $session         = WebGUI::Test->session;

    my $prev_streaming_uploads = $session->config->get('enableStreamingUploads');

    local $ENV{WEBGUI_CONFIG} = WebGUI::Test->file; # tell the share/site.psgi which site to load

    #
    # fire up a Plack to test streaming
    #

    $session->config->set('enableStreamingUploads', 1);

    my $app = Plack::Util::load_psgi( WebGUI::Paths->defaultPSGI ); 

    ok( $app, "created a PSGI app from app.psgi" );

    test_psgi $app, sub {
        my $cb = shift;
        my $res = $cb->( GET "/root/import/gallery-templates/images/previous.gif" );
        is $res->code, 200, 'enableStreamingUploads: 200 response';
        is $res->header('Content-Type'), 'image/gif', '... content type is image/gif';
        ok substr($res->content, 0, 100) =~ m/GIF89/, '... data contains the string GIF89';
    };


    #
    # fire up another Plack to test non-streaming
    #

    $session->config->set('enableStreamingUploads', 0);

    $app = Plack::Util::load_psgi( WebGUI::Paths->defaultPSGI );

    my $redirect_url;

    test_psgi $app, sub {
        my $cb = shift;
        my $res = $cb->( GET "/root/import/gallery-templates/images/previous.gif" );
        is $res->code, 302, 'enableStreamingUploads: 302 response';
        ok $res->header('Location'), '... Location header in response';
        $res = $cb->(GET $res->header('Location') );
        is $res->code, 200, '... following location, we get a 200 response code';
    };

    #
    # put things back how they were
    #

    $session->config->set('enableStreamingUploads', $prev_streaming_uploads);

};

