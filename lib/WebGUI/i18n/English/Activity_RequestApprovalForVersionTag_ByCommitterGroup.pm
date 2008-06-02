package WebGUI::i18n::English::Activity_RequestApprovalForVersionTag_ByCommitterGroup;

use strict; 

our $I18N = { 
    'committerGroupId label' => {
        message     => q{Committer Group to Require Approval},
        lastUpdated => 0,
        context     => q{Label for activity property},
    },
    'committerGroupId description' => {
        message     => q{The group that needs approval from this activity. If the committer is not
                        a member of this group, the workflow will continue with the next activity. },
        lastUpdated => 0,
        context     => q{Description of activity property},
    },
    topicName => {
        message     => q{Request Approval By Committer Group},
        lastUpdated => 0,
    },
};

1;
