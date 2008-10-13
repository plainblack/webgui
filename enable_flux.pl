# Enables Flux for a given site (see FLUX_README.txt for more information)

our ($webguiRoot);

BEGIN {
    use FindBin;
    $webguiRoot = "$FindBin::Bin";
    unshift( @INC, $webguiRoot . "/lib" );
}

use strict;
use warnings;
use Getopt::Long;
use Readonly;
use WebGUI::Session;
use Carp;
use EnableFlux;

#----------------------------------------------------------------------------
# Settings..
Readonly my $USAGE => <<"END_USAGE";
Usage: $0 --config=<WebGUI site config file>
E.g. $0 -c dev.localhost.localdomain.conf
END_USAGE

#----------------------------------------------------------------------------
# Get options
my ( $config, $usage, $force );
my $options_okay = GetOptions(
    'config=s'       => \$config,
    'usage|help|man' => \$usage,
    'force'          => \$force,
);
die $USAGE if !$options_okay || !$config || $usage;

#----------------------------------------------------------------------------
### Connecting to: $config
my $config_path = $webguiRoot . '/etc/' . $config;
if ( !-e $config_path ) {
    die "Invalid argument --config: $config.\n File does not exist: $config_path\n";
}
my $session = WebGUI::Session->open( $webguiRoot, $config );

if ( $session->db->quickScalar('select count(*) from settings where name = "fluxEnabled"') && !$force ) {
    print "Looks like Flux is already enabled, use --force if you really want to re-apply changes\n";
    exit 1;
}

# Ok, let's do it
EnableFlux::apply($session, 1);