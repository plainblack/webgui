# Test what happens when the WebGUI PSGI app throws exceptions
use strict;
use FindBin;
use lib "$FindBin::Bin/../lib";
use WebGUI;
use WebGUI::Test;
use Plack::Test;
use Plack::Builder;
use HTTP::Request::Common;
use Test::More tests => 9;
use HTTP::Exception;

my $wg = WebGUI->new(config => WebGUI::Test->config);

my $regular_app = builder {
    enable '+WebGUI::Middleware::Session', config => $wg->config;
    $wg;
};

my $generic_dead_app = builder {
    enable '+WebGUI::Middleware::Session', config => $wg->config;
    
    # Pretend that WebGUI dies during request handling
    sub { die 'WebGUI died' }
};

my $specific_dead_app = builder {
    enable '+WebGUI::Middleware::Session', config => $wg->config;
    
    # Pretend that WebGUI throws a '501 - Not Implemented' HTTP error
    sub { HTTP::Exception::501->throw }
};

my $fatal_app = builder {
    enable '+WebGUI::Middleware::Session', config => $wg->config;
    
    # Pretend that WebGUI calls $session->log->fatal during request handling
    sub { 
        my $env = shift;
        
        $env->{'webgui.session'}->log->fatal('Fatally yours');
    }
};

test_psgi $regular_app, sub {
    my $cb  = shift;
    my $res = $cb->( GET "/" );
    like $res->content, qr/My Company/;
};

# N.B. The die() is caught thanks to WebGUI::Middleware::HTTPExceptions, 
# but generates a warning to STDOUT - should perhaps be silenced?
test_psgi $generic_dead_app, sub {
    my $cb  = shift;
    my $res = $cb->( GET "/" );
    is $res->code, 500;
    is $res->content, 'Internal Server Error';
};

test_psgi $specific_dead_app, sub {
    my $cb  = shift;
    my $res = $cb->( GET "/" );
    is $res->code, 501;
    is $res->content, 'Not Implemented'; # how apt
};

test_psgi $fatal_app, sub {
    my $cb  = shift;
    my $res = $cb->( GET "/" );
    is $res->code, 500;
    
    # WebGUI doesn't know who you are, so it displays the generic error page
    like $res->content, qr/Problem With Request/;
};

test_psgi $fatal_app, sub {
    my $cb  = shift;
    
    local *WebGUI::Session::ErrorHandler::canShowDebug = sub {1};
    my $res = $cb->( GET "/" );
    is $res->code, 500;
    
    # We canShowDebug, so WebGUI gives us more info
    like $res->content, qr/Fatally yours/;
};

