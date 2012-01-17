use WebGUI::Upgrade::Script;
use File::Spec;
use WebGUI::Paths;
use Cwd qw(realpath);

start_step "Removing FilePile asset from config file";

config->deleteFromHash( 'assets', 'WebGUI::Asset::FilePile' );

done;

start_step "Removing FilePile asset module";

rm_lib('WebGUI::Asset::FilePile');

done;
