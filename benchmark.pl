# Little script used to run benchmarks against dev.localhost.localdomain
#
# To profile, run "perl -d:NYTProf benchmark.pl"
use Devel::Leak::Object qw(GLOBAL_bless);
$Devel::Leak::Object::TRACKSOURCELINES = 1;

use lib '/data/WebGUI/lib';
use WebGUI;
use Plack::Test;
use HTTP::Request::Common;
my $wg = WebGUI->new( root => '/data/WebGUI', site => 'dev.localhost.localdomain.conf' );
my $app = $wg->psgi_app;

test_psgi $app, sub {
    my $cb  = shift;
    my $res = $cb->( GET "/" );
} for 1..100;