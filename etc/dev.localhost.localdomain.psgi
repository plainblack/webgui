use lib '/data/WebGUI/lib';
use WebGUI;

my $app = WebGUI->new( root => '/data/WebGUI', site => 'dev.localhost.localdomain.conf' )->psgi_app;