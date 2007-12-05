package WebGUI::Help::Invite;
use strict

our $HELP = {

    'invite form template' => {
        title     => 'invite form template title',
        body      => 'invite form template body',
        variables => [
            {   name     => 'inviteFormError',
                required => 1,
            },
            {   name     => 'formHeader',
                required => 1,
            },
            {   name     => 'formFooter',
                required => 1,
            },
            { name => 'title', },
            { name => 'emailAddressLabel', },
            { name => 'emailAddressForm', },
            { name => 'subjectLabel', },
            { name => 'subjectForm', },
            { name => 'messageLabel', },
            { name => 'messageForm', },
            { name => 'submitButton', },
        ],
        fields  => [],
        related => []
    },

    'invite email template' => {
        title     => 'invite email template title',
        body      => 'invite email template body',
        variables => [ { name => 'inviteFormError', }, { name => 'formHeader', }, ],
        fields    => [],
        related   => []
    },

};

1;    ##All perl modules must return true
