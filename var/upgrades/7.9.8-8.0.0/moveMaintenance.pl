use WebGUI::Upgrade::Script;

use File::Spec::Functions;
use File::Basename;
use Cwd qw(realpath);

my $webgui_root = realpath( catdir( dirname( $INC{'WebGUI/Upgrade/Script.pm'} ), (updir) x 3 ) );

start_step "Moving maintenance file";

unlink catfile($webgui_root, 'docs', 'maintenance.html');

done;
