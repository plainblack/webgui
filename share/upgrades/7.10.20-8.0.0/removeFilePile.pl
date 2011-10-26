use WebGUI::Upgrade::Script;
use File::Spec;
use WebGUI::Paths;
use Cwd qw(realpath);

start_step "Removing FilePile asset from config file";

session->config->delete( 'assets/FilePile' );

done;

start_step "Removing FilePile asset module";

my $webgui_root = realpath( File::Spec->catdir( WebGUI::Paths->configBase, (File::Spec->updir) x 1 ) );
unlink File::Spec->catfile($webgui_root, 'lib', 'WebGUI', 'Asset', 'FilePile.pm');

done;
