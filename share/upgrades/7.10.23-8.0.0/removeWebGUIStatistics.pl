use WebGUI::Upgrade::Script;
use File::Spec;
use WebGUI::Paths;
use Cwd qw(realpath);

start_step "Removing WebGUI statistics workflows and code";

config->deleteFromHash( 'adminConsole', 'statistics' );

report "Deleting Workflow Activities";
my $activity = dbh->write(q|delete from WorkflowActivity where className='WebGUI::Workflow::Activity::SendWebguiStats'|);

report "Deleting Workflow and Cron";
my $workflow = WebGUI::Workflow->new(session, 'send_webgui_statistics');
$workflow->delete;
##This may not be in there if it is not enabled.
my $task = WebGUI::Workflow::Cron->new(session, 'send_webgui_statistics');
$task && $task->delete;

report "Deleting files";
rm_lib 'WebGUI::Operation::Statistics';
rm_lib 'WebGUI::Workflow::Activity::SendWebguiStats';

done;
