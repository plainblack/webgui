use Plack::Builder;
use lib '/data/WebGUI/lib';
use WebGUI;

my $wg = WebGUI->new(
    root   => '/data/WebGUI',
    config => 'dev.localhost.localdomain.conf',
);

builder {

    # Handle /extras via Plack::Middleware::Static
    # (or Plack::Middleware::WebGUI could do this for us by looking up extrasPath and extrasURL in site.conf)
#    enable 'Plack::Middleware::Static',
#      path => '^' . $wg->config->get('extrasURL') . '/',
#      root => $wg->config->get('extrasPath');
#
#    # Handle /uploads via Plack::Middleware::WGAccess (including .wgaccess)
#    # (or Plack::Middleware::WebGUI could do this for us by looking up uploadsPath and uploadsURL in site.conf)
#    #enable 'Plack::Middleware::WGAccess',
#    #    path => '^' . $wg->config->get('uploadsURL') . '/',
#    #    root => $wg->config->get('uploadsPath');
#
#    enable 'Plack::Middleware::Static',
#      path => '^' . $wg->config->get('uploadsURL') . '/',
#      root => $wg->config->get('uploadsPath');

    sub { $wg->run(@_) };
}
