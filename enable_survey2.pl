#!/data/wre/prereqs/bin/perl
# Enables Survey2 for a given site (see SURVEY@_README.txt for more information)

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
use EnableSurvey2;

#----------------------------------------------------------------------------
# Settings..
Readonly my $USAGE => <<"END_USAGE";
Usage: $0 --config=<WebGUI site config file>
E.g. $0 -c dev.localhost.localdomain
END_USAGE

#----------------------------------------------------------------------------
# Get options
my ( $config, $usage, $force, $demo );
my $options_okay = GetOptions(
    'config=s'       => \$config,
    'usage|help|man' => \$usage,
    'force'          => \$force,
    'demo'          => \$demo,
);
die $USAGE if !$options_okay || !$config || $usage;

unless($force) {
    print "This script will delete all existing Survey objects on your site. Use --force if you really want to continue\n";
    exit 1;
}

#----------------------------------------------------------------------------
### Connecting to: $config
if ( $config !~ /\.conf$/ ) {
    $config .= '.conf';
}
my $config_path = $webguiRoot . '/etc/' . $config;
if ( !-e $config_path ) {
    die "Invalid argument --config: $config.\n File does not exist: $config_path\n";
}
my $session = WebGUI::Session->open( $webguiRoot, $config );

$ENV{VERBOSE} = 1;

EnableSurvey2->apply($session);

say("Finished. Don't forget to restart modperl.");

sub say {
    local $\ = "\n";
    print @_ if $ENV{VERBOSE};
}