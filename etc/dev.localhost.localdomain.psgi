use Plack::Builder;
use lib '/data/WebGUI/lib';
use WebGUI;
WebGUI->init( root => '/data/WebGUI', config => 'dev.localhost.localdomain.conf' );

builder {

    # Handle /extras via Plack::Middleware::Static
    # (or Plack::Middleware::WebGUI could do this for us by looking up extrasPath and extrasURL in site.conf)
    enable 'Plack::Middleware::Static',
        path => qr{^/extras/},
        root => '/data/WebGUI/www';

    # Handle /uploads via Plack::Middleware::WGAccess (including .wgaccess)
    # (or Plack::Middleware::WebGUI could do this for us by looking up uploadsPath and uploadsURL in site.conf)
    #enable 'Plack::Middleware::WGAccess',
    #    path     => qr{^/uploads/},
    #    root => '/data/domains/dev.localhost.localdomain/public';
        
    enable 'Plack::Middleware::Static',
        path     => qr{^/uploads/},
        root => '/data/domains/dev.localhost.localdomain/public';

    sub { WebGUI::handle_psgi(shift) };
}
