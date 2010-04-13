use strict;
use Plack::Builder;
use lib '/data/WebGUI/lib';
use WebGUI;

my $root = '/data/WebGUI';
my $wg = WebGUI->new( root => $root, site => 'dev.localhost.localdomain.conf' );

builder {
    
    enable 'Log4perl', category => 'mysite', conf => "$root/etc/log.conf";
    enable 'Static', root => $root, path => sub { s{^/\*give-credit-where-credit-is-due\*$}{docs/credits.txt} };
    
    # Open/close the WebGUI::Session at the outer-most onion layer
    enable '+WebGUI::Middleware::Session', 
        config => $wg->config,
        error_docs => { 500 => "$root/www/maintenance.html" };
    
    # This one uses the Session object, so it comes after WebGUI::Middleware::Session
    enable '+WebGUI::Middleware::WGAccess', config => $wg->config;
    
    # Return the app
    $wg;
};
