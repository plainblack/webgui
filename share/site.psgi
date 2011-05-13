use strict;
use Plack::Builder;
use Plack::App::File;
use WebGUI;

builder {
    my $wg = WebGUI->new( config => $ENV{WEBGUI_CONFIG} );
    my $config = $wg->config;
    my $streaming_uploads = $config->get('enableStreamingUploads'); # have to restart for changes to this to take effect

    enable 'Log4perl', category => $config->getFilename, conf => WebGUI::Paths->logConfig;
    enable 'SimpleContentFilter', filter => sub {
        if ( utf8::is_utf8($_) ) {
            utf8::encode($_);
        }
    };

    # Reproduce URL handler functionality with middleware
    enable '+WebGUI::Middleware::Snoop';
    enable 'Status', path => qr{^/uploads/dictionaries}, status => 401;

    # For PassThru, use Plack::Builder::mount

    # Serve "Extras"
    # Plack::Middleware::Static is fallback (you should be using something else to serve static files in production,
    # unless you're using the corona Plack server, then it doesn't matter nearly so much)

    my ( $extrasURL, $extrasPath ) = ( $config->get('extrasURL'), $config->get('extrasPath') );
    enable_if {   $streaming_uploads } 'XSendfile';
    enable_if { ! $streaming_uploads } 'Static', root => "$extrasPath/", path => sub {s{^\Q$extrasURL/}{}};

    # Open/close the WebGUI::Session at the outer-most onion layer
    enable '+WebGUI::Middleware::Session', config => $config;

    enable '+WebGUI::Middleware::HTTPExceptions';

    enable 'ErrorDocument', 503 => $config->get('maintenancePage');
    enable_if { ! $_[0]->{'webgui.debug'} } 'ErrorDocument', 500 => $config->get('maintenancePage');

    enable '+WebGUI::Middleware::Maintenance';

    # enable_if { $_[0]->{'webgui.debug'} } 'StackTrace';
    enable_if { $_[0]->{'webgui.debug'} } '+WebGUI::Middleware::StackTrace';

    enable_if { $_[0]->{'webgui.debug'} } 'Debug', panels => [
        'Timer',
        'Memory',
        'Session',
        'Parameters',
        'PerlConfig',
        [ 'MySQLTrace', skip_packages => qr/\AWebGUI::SQL(?:\z|::)/ ],
        'Response',
        'Logger',
    ];
    enable_if { $_[0]->{'webgui.debug'} } '+WebGUI::Middleware::Debug::Environment';
    enable_if { $_[0]->{'webgui.debug'} } '+WebGUI::Middleware::Debug::Performance';

    # This one uses the Session object, so it comes after WebGUI::Middleware::Session
    mount $config->get('uploadsURL') => builder {
        enable '+WebGUI::Middleware::WGAccess';
        Plack::App::File->new(root => $config->get('uploadsPath'));
    };

    # enable config defined Middleware

    for my $mw ( @{ $config->get('plackMiddleware') || [] } ) {
        enable $mw;
    }

    # Return the app
    mount '/' => $wg->to_app;
};

