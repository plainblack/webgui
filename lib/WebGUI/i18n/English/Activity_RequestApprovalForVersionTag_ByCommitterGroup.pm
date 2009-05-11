package WebGUI::i18n::English::Activity_RequestApprovalForVersionTag_ByCommitterGroup;

use strict; 

our $I18N = { 
    'committerGroupId label' => {
        message     => q{Committer Group to Require Approval},
        lastUpdated => 0,
        context     => q{Label for activity property},
    },
    'committerGroupId description' => {
        message     => q{The group that needs approval to use this activity. If the committer is not
                        a member of this group, the workflow will continue with the next activity. },
        lastUpdated => 1213631384,
        context     => q{Description of activity property},
    },
    'invertGroupSetting label' => {
        message     => q{Invert Group Setting},
        lastUpdated => 1232298054,
        context     => q{Label for activity property},
    },
    'invertGroupSetting description' => {
        message     => q{If selected yes, only users that are not members of the selected committer
                         group will require approval for using this activity. If the committer is a
                         member of this group, the workflow will continue with the next activity. },
        lastUpdated => 1232298054,
        context     => q{Description of activity property},
    },
    topicName => {
        message     => q{Request Approval By Committer Group},
        lastUpdated => 0,
    },
};

1;
