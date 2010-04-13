# Little script used to run benchmarks against dev.localhost.localdomain
#
# To profile, run "perl -d:NYTProf benchmark.pl"

use lib '/data/WebGUI/lib';
use WebGUI;
use Plack::Test;
use Plack::Builder;
use HTTP::Request::Common;
my $wg = WebGUI->new( root => '/data/WebGUI', site => 'dev.localhost.localdomain.conf' );
my $app = builder {
    enable '+WebGUI::Middleware::Session', config => $wg->config;
    $wg;
};

test_psgi $app, sub {
    my $cb  = shift;
    $cb->( GET "/" ) for 1..1000;
};