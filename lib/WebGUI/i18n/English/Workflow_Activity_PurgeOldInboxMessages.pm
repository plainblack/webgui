package WebGUI::i18n::English::Workflow_Activity_PurgeOldInboxMessages;

use strict;

our $I18N = {
    'activityName'  => {
        message     => q{Purge Old Inbox Messages},
        lastUpdated => 0,
        context     => 'Title of workflow activity',
    },

    'editForm purgeAfter label' => {
        message     => q{Purge After},
        lastUpdated => 0,
        context     => 'Label for workflow property',
    },

    'editForm purgeAfter description' => {
        message     => q{The length of time a message is allowed to remain in the inbox after it has been set to "completed"},
        lastUpdated => 0,
        context     => 'Description of workflow property',
    },
};

1;
