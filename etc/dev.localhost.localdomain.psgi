use Plack::Builder;
use lib '/data/WebGUI/lib';
use WebGUI;

builder {
    
    # Populate $env from site.conf
    add 'Plack::Middleware::WebGUI', 
        root => '/data/WebGUI',
        config => 'dev.localhost.localdomain.conf';

    # Handle /extras via Plack::Middleware::Static
    # (or Plack::Middleware::WebGUI could do this for us by looking up extrasPath and extrasURL in site.conf)
    add 'Plack::Middleware::Static',
        path => qr{^/extras/},
        root => '/data/WebGUI/www';

    # Handle /uploads via Plack::Middleware::WGAccess (including .wgaccess)
    # (or Plack::Middleware::WebGUI could do this for us by looking up uploadsPath and uploadsURL in site.conf)
    add 'Plack::Middleware::WGAccess',
        path     => qr{^/uploads/},
        root => '/data/domains/dev.localhost.localdomain/public';

    sub { WebGUI::handle_psgi(shift) };
}
