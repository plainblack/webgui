use WebGUI::Upgrade::Script;

use File::Basename;
use Cwd qw(realpath);
use File::Spec::Functions;
use WebGUI::Paths;

start_step "Moving preload files";

my $webgui_root = realpath( catdir( dirname( $INC{'WebGUI/Upgrade/Script.pm'} ), (updir) x 3 ) );

config->set('maintenancePage', catfile( $webgui_root, 'www', 'maintenance.html' ));

done;
