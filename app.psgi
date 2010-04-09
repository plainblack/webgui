use strict;
use Plack::Builder;
use lib '/data/WebGUI/lib';
use WebGUI;

my $wg = WebGUI->new( root => '/data/WebGUI', site => 'dev.localhost.localdomain.conf' );

builder {
    enable 'Debug', panels => [ qw(Environment Response Timer Memory Session DBITrace PerlConfig Response) ];
    
    # Open/close the WebGUI::Session at the outer-most onion layer
    enable '+WebGUI::Middleware::Session', config => $wg->config;

    # Any additional WebGUI Middleware goes here
    # ..
    
    # Return the app
    $wg;
};
