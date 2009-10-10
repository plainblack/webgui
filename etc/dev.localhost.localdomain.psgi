BEGIN {
    # Define your site settings here
    # These are the config values that normally appear in your wre's 
    # site.modperl.conf and site.modproxy.conf
    our $WEBGUI_ROOT   = '/data/WebGUI';
    our $WEBGUI_CONFIG = 'dev.localhost.localdomain';
    our $DOCUMENT_ROOT = '/data/domains/dev.localhost.localdomain/public';
}
use local::lib $WEBGUI_ROOT;
use WebGUI;
use Plack::Builder;

my %SETTINGS = (
    'wg.WEBGUI_ROOT'             => $WEBGUI_ROOT,
    'wg.WEBGUI_CONFIG'           => "$WEBGUI_CONFIG.conf",
    'wg.DOCUMENT_ROOT'           => $DOCUMENT_ROOT,
    'wg.DIR_CONFIG.WebguiRoot'   => $WEBGUI_ROOT,
    'wg.DIR_CONFIG.WebguiConfig' => "$WEBGUI_CONFIG.conf",
);

my $wg = sub {
    my $env = shift;
    @{$env}{ keys %SETTINGS } = values %SETTINGS;
    WebGUI::handle_psgi($env);
};

builder {

    # /extras - deliver via Plack::Middleware::Static
    add 'Plack::Middleware::Static',
        path => qr{^/extras/},
        root => "$SETTINGS{'wg.WEBGUI_ROOT'}/www/";

    # /uploads - deliver via Plack::Middleware::WGAccess
    # This takes the place of WebGUI::URL::Uploads in handling .wgaccess and 
    # delivery of static files in /uploads
    add 'Plack::Middleware::WGAccess',
        path     => qr{^/uploads/},
        settings => {%SETTINGS};

    add 'Plack::Middleware::XFramework', framework => 'WebGUI';

    # AccessLog already enabled by default if you are using the plackup script
    # add 'Plack::Middleware::AccessLog',
    #    format => "combined";

    $wg;
}
