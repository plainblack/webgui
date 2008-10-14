package WebGUI::i18n::English::Activity_RequestApprovalForVersionTag_ByLineage;

use strict; 

our $I18N = { 
    'assetId label' => {
        message     => q{Ancestor Asset},
        lastUpdated => 0,
        context     => q{Label for activity property},
    },
    'assetId description' => {
        message     => q{The ancestor of the content that requires approval by this activity.
                        All content must be under this ancestor, otherwise the workflow will
                        continue on with the next activity.},
        lastUpdated => 0,
        context     => q{Description of activity property},
    },
    topicName => {
        message     => q{Request Approval By Asset Lineage},
        lastUpdated => 0,
    },
};

1;
