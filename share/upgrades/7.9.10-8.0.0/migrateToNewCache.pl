use WebGUI::Upgrade::Script;
use Module::Find;

start_step "Migrating to new cache";

rm_lib
    findallmod('WebGUI::Cache'),
    'WebGUI::Workflow::Activity::CleanDatabaseCache',
    'WebGUI::Workflow::Activity::CleanFileCache',
;

config->set("cache", {
    'driver'            => 'FastMmap',
    'expires_variance'  => '0.10',
    'root_dir'          => '/tmp/WebGUICache',
});

config->set('hotSessionFlushToDb', 600);
config->delete('disableCache');
config->delete('cacheType');
config->delete('fileCacheRoot');
config->deleteFromArray('workflowActivities/None', 'WebGUI::Workflow::Activity::CleanDatabaseCache');
config->deleteFromArray('workflowActivities/None', 'WebGUI::Workflow::Activity::CleanFileCache');

sql 'DROP TABLE IF EXISTS cache';
sql 'DELETE FROM WorkflowActivity WHERE className in (?,?)',
        'WebGUI::Workflow::Activity::CleanDatabaseCache',
        'WebGUI::Workflow::Activity::CleanFileCache',
;
sql 'DELETE FROM WorkflowActivityData WHERE activityId IN (?,?)',
        'pbwfactivity0000000002',
        'pbwfactivity0000000022',
;

done;

