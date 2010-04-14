use strict;
use Plack::Builder;
use lib '/data/WebGUI/lib';
use WebGUI;

my $root = '/data/WebGUI';
my $wg = WebGUI->new( root => $root, site => 'dev.localhost.localdomain.conf' );
my $config = $wg->config;

builder {
    
    enable 'Log4perl', category => 'mysite', conf => "$root/etc/log.conf";
    
    # Reproduce URL handler functionality with middleware
    enable '+WebGUI::Middleware::Snoop';
    enable 'Static', root => $root, path => sub { s{^/\*give-credit-where-credit-is-due\*$}{docs/credits.txt} };
    enable 'Status', path => qr{^/uploads/dictionaries}, status => 401;
    # For PassThru, use Plack::Builder::mount
    
    # Extras fallback (you should be using something else to serve static files in production)
    my ($extrasURL, $extrasPath) = ( $config->get('extrasURL'), $config->get('extrasPath') );
    enable 'Static', root => "$extrasPath/", path => sub { s{^$extrasURL/}{} };
    
    # Open/close the WebGUI::Session at the outer-most onion layer
    enable '+WebGUI::Middleware::Session', 
        config => $config,
        error_docs => { 500 => "$root/www/maintenance.html" };
    
    # This one uses the Session object, so it comes after WebGUI::Middleware::Session
    enable '+WebGUI::Middleware::WGAccess', config => $config;
    
    # Return the app
    $wg->psgi_app;
};
