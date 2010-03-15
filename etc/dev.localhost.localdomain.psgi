use Plack::Builder;
use lib '/data/WebGUI/lib';
use WebGUI;

my $wg = WebGUI->new( root => '/data/WebGUI', site => 'dev.localhost.localdomain.conf' );

$wg->psgi_app;