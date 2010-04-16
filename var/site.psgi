use strict;
use Plack::Builder;
use WebGUI;
use WebGUI::Paths;

my $config = $ENV{WEBGUI_CONFIG};
builder {
    my $wg = WebGUI->new( site => $ENV{WEBGUI_CONFIG} );
    my $config = $wg->config;

    enable 'Log4perl', category => $config->getFilename, conf => WebGUI::Paths->logConfig;

    # Reproduce URL handler functionality with middleware
    enable '+WebGUI::Middleware::Snoop';
    enable 'Status', path => qr{^/uploads/dictionaries}, status => 401;

    # For PassThru, use Plack::Builder::mount

    # Extras fallback (you should be using something else to serve static files in production)
    my ( $extrasURL, $extrasPath ) = ( $config->get('extrasURL'), $config->get('extrasPath') );
    enable 'Static', root => "$extrasPath/", path => sub {s{^$extrasURL/}{}};

    # Open/close the WebGUI::Session at the outer-most onion layer
    enable '+WebGUI::Middleware::Session',
        config     => $config,
        error_docs => { 500 => $config->get('maintenancePage') };

    enable_if { $_[0]->{'webgui.debug'} } 'StackTrace';
    enable_if { $_[0]->{'webgui.debug'} } 'Debug', panels => [
        'Environment',
        'Response',
        'Timer',
        'Memory',
        'Session',
        'PerlConfig',
        [ 'MySQLTrace', skip_packages => qr/\AWebGUI::SQL(?:\z|::)/ ],
        'Response',
        'Logger',
        sub { WebGUI::Middleware::Debug::Performance->wrap($_[0]) },
    ];

    # This one uses the Session object, so it comes after WebGUI::Middleware::Session
    enable '+WebGUI::Middleware::WGAccess', config => $config;

    # Return the app
    $wg->to_app;
};

