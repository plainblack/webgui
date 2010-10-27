# Test what happens when the WebGUI PSGI app throws exceptions
use strict;
use WebGUI;
use WebGUI::Test;
use Plack::Test;
use Plack::Builder;
use HTTP::Request::Common;
use Test::More;
use HTTP::Exception;

my $wg = WebGUI->new(config => WebGUI::Test->config);

my $regular_app = builder {
    enable '+WebGUI::Middleware::Session', config => $wg->config;
    enable '+WebGUI::Middleware::HTTPExceptions';
    $wg;
};

my $generic_dead_app = builder {
    enable '+WebGUI::Middleware::HTTPExceptions';
    
    # Pretend that WebGUI dies during request handling
    sub { die 'WebGUI died' }
};

my $specific_dead_app = builder {
    enable '+WebGUI::Middleware::HTTPExceptions';
    
    # Pretend that WebGUI throws a '501 - Not Implemented' HTTP error
    sub { HTTP::Exception->throw(501) };
};

my $fatal_app = builder {
    enable '+WebGUI::Middleware::Session', config => $wg->config;
    enable '+WebGUI::Middleware::HTTPExceptions';
    
    # Pretend that WebGUI calls $session->log->fatal during request handling
    sub { 
        my $env = shift;
        
        WebGUI::Test->addToCleanup($env->{'webgui.session'});
        $env->{'webgui.session'}->log->fatal('Fatally yours');
    }
};

my $not_found_app = builder {
    enable '+WebGUI::Middleware::Session', config => $wg->config;
    enable '+WebGUI::Middleware::HTTPExceptions';
    
    sub {
        my $env = shift;
        WebGUI::Test->addToCleanup($env->{'webgui.session'});
        HTTP::Exception->throw(404)
    };
};

test_psgi $regular_app, sub {
    my $cb  = shift;
    my $res = $cb->( GET "/" );
    is $res->code, 200, 'regular app, status code';
    like $res->content, qr/My Company/, 'testing regular app';
};

# N.B. The die() is caught thanks to WebGUI::Middleware::HTTPExceptions, 
# but generates a warning to STDOUT - should perhaps be silenced?
test_psgi $generic_dead_app, sub {
    my $cb  = shift;
    my $res = $cb->( GET "/" );
    is $res->code, 500, 'generic dead app, status code';
    is $res->content, 'Internal Server Error', '... status description';
};

test_psgi $specific_dead_app, sub {
    my $cb  = shift;
    my $res = $cb->( GET "/" );
    is $res->code, 501, 'specific dead app, status code';
    is $res->content, 'Not Implemented', '... status description'; # how apt
};

test_psgi $not_found_app, sub {
    my $cb  = shift;
    my $res = $cb->( GET "/" );
    is $res->code, 404, 'not found app, status code';
    is $res->content, 'Not Found', '... status description'; # how apt
};

test_psgi $fatal_app, sub {
    my $cb  = shift;
    my $res = $cb->( GET "/" );
    is $res->code, 500, 'fatal app, status code';
    
    # WebGUI doesn't know who you are, so it displays the generic error page
    like $res->content, qr/Fatally yours/, '... status description is $@ stringified from the logged fatal';
};

test_psgi $fatal_app, sub {
    my $cb  = shift;
    
    local *WebGUI::Session::Log::canShowDebug = sub {1};
    my $res = $cb->( GET "/" );
    is $res->code, 500, 'generic dead app, debug, status code';
    
    # We canShowDebug, so WebGUI gives us more info
    like $res->content, qr/Fatally yours/, '... status description';
};

done_testing;
