BEGIN {

    # This is just a temporary hack
    our $WEBGUI_ROOT    = '/data/WebGUI';
    our $WEBGUI_DOMAINS = '/data/domains';
    our $WEBGUI_CONFIG  = 'dev.localhost.localdomain';
}
use local::lib $WEBGUI_ROOT;
use WebGUI;
use Plack::Middleware;
use Plack::Builder;

my $app = sub {
    my $env = shift;
    $env->{'wg.WEBGUI_ROOT'}             = $WEBGUI_ROOT;
    $env->{'wg.WEBGUI_CONFIG'}           = "$WEBGUI_CONFIG.conf";
    $env->{'wg.DIR_CONFIG.WebguiRoot'}   = $env->{'wg.WEBGUI_ROOT'};
    $env->{'wg.DIR_CONFIG.WebguiConfig'} = $env->{'wg.WEBGUI_CONFIG'};
    WebGUI::handle_psgi($env);
};

# Apply some Middleware
builder {

    # /extras
    add 'Plack::Middleware::Static',
        path => qr{^/extras/},
        root => "$WEBGUI_ROOT/www/";

    # /uploads (ignore .wgaccess for now..)
    add 'Plack::Middleware::Static',
        path => qr{^/uploads/},
        root => "$WEBGUI_DOMAINS/dev.localhost.localdomain/public/";

    add 'Plack::Middleware::XFramework',
        framework => 'WebGUI';

    # Already enabled by plackup script
    # add 'Plack::Middleware::AccessLog', 
    #    format => "combined";

    $app;
}