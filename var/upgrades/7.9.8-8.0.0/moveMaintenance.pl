use WebGUI::Upgrade::Script;

use File::Spec::Functions;
use Cwd qw(realpath);

my $webgui_root = realpath( catdir( dirname( $INC{'WebGUI/Upgrade/Script.pm'} ), (updir) x 3 ) );

report "\tMoving maintenance file ";

unlink catfile($webgui_root, 'docs', 'maintenance.html');

done;
