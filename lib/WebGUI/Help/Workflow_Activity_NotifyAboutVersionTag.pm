package WebGUI::Help::Workflow_Activity_NotifyAboutVersionTag;
use strict;

our $HELP = {

    'email template' => {
        title     => 'email template title',
        body      => '',
        variables => [
            { 'name' => 'message' },
            { 'name' => 'comments' },
            { 'name' => 'url' },
        ],
        fields    => [],
        related   => [],
    },

};

1;
