use strict;

use WebGUI::Paths -preload;

use Log::Log4perl;
use DBI;
use WebGUI;
use WebGUI::Config;
use Apache2::Cookie;
use Apache2::ServerUtil;

Log::Log4perl->init( WebGUI::Paths->logConfig );
DBI->install_driver("mysql");

if ( $ENV{MOD_PERL} ) {
    # Add WebGUI to Apache version tokens
    my $server = Apache2::ServerUtil->server;
    $server->push_handlers(PerlPostConfigHandler => sub {
        $server->add_version_component('WebGUI/' . $WebGUI::VERSION);
    });
}

$| = 1;

print "\nStarting WebGUI ".$WebGUI::VERSION."\n";

WebGUI::Config->loadAllConfigs;

1;

