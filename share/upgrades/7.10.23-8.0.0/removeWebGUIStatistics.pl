use WebGUI::Upgrade::Script;
use File::Spec;
use WebGUI::Paths;
use Cwd qw(realpath);

start_step "Removing WebGUI statistics workflows and code";

config->deleteFromHash( 'adminConsole', 'statistics' );

my $workflow = WebGUI::Workflow->new(session, 'send_webgui_statistics');
$workflow->delete;
##This may not be in there if it is not enabled.
my $task = WebGUI::Workflow::Cron->new(session, 'send_webgui_statistics');
$task && $task->delete;

my $webgui_root = realpath( File::Spec->catdir( WebGUI::Paths->configBase, (File::Spec->updir) x 1 ) );
unlink File::Spec->catfile($webgui_root, 'lib', 'WebGUI', 'Operation', 'Statistics.pm');
unlink File::Spec->catfile($webgui_root, 'lib', 'WebGUI', 'Workflow', 'Activity', 'SendWebguiStats.pm');

done;
