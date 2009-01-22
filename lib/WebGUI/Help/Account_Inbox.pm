package WebGUI::Help::Account_Inbox;

use strict; 

our $HELP = { 

    'common vars' => {
        title   => 'common account variables',
        body    => '',
        private => 1,
        isa => [
            {
                tag => 'common vars',
                namespace => 'Account',
            },
        ],
        fields => [ ],
        variables => [
            { name => 'view_inbox_url', },
            { name => 'view_invitations_url', },
            { name => 'unread_message_count', },
            { name => 'invitation_count', },
            { name => 'invitations_enabled', },
            { name => 'user_invitations_enabled', },
            { name => 'invite_friend_url', },
        ],
        related => [ ],
    },

};

1;
#vim:ft=perl
