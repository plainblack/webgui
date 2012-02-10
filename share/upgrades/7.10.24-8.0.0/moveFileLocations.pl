use WebGUI::Upgrade::Script;

use File::Basename;
use Cwd qw(realpath);
use File::Spec::Functions;
use WebGUI::Paths;

start_step "Moving preload files";

my $webgui_root = realpath( catdir( dirname( $INC{'WebGUI/Upgrade/Script.pm'} ), (updir) x 3 ) );

unlink catfile($webgui_root, 'lib', 'default.ttf');

unlink catfile($webgui_root, 'sbin', 'preload.custom.example');
unlink catfile($webgui_root, 'sbin', 'preload.exclude.example');

rename catfile($webgui_root, 'sbin', 'preload.custom'), WebGUI::Paths->preloadCustom;
rename catfile($webgui_root, 'sbin', 'preload.exclude'), WebGUI::Paths->preloadExclusions;

done;
