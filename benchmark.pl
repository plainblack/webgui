# Little script used to run benchmarks against dev.localhost.localdomain
#
# To profile, run "perl -d:NYTProf benchmark.pl"

use lib '/data/WebGUI/lib';
use WebGUI;
use Plack::Test;
use HTTP::Request::Common;
my $app = WebGUI->new( root => '/data/WebGUI', site => 'dev.localhost.localdomain.conf' )->psgi_app;

test_psgi $app, sub {
    my $cb  = shift;
    my $res = $cb->( GET "/" );
} for 1..100;
