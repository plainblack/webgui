use lib "../lib";
use strict;
use Getopt::Long;
use WebGUI::Pluggable;
use WebGUI::Session;

$|++;

# Get arguments
my $class       = $ARGV[0];

# Get options
my ( $configFile, $remove );
GetOptions(
    'configFile=s'  => \$configFile,
    'remove'        => \$remove,
);

# Open the session
my $session     = WebGUI::Session->open("..",$configFile);
$session->user({ userId => 3 });

# Install or uninstall the asset
WebGUI::Pluggable::load( $class );
if ( !$remove ) {
    print "Installing $class... ";
    $class->install( $session );
    print "DONE!\n";
}
else {
    print "Removing $class... ";
    $class->uninstall( $session );
    print "DONE!\n";
}

print "Please restart Apache.\n";

# End the session
$session->var->end;
$session->close;
