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

     'view inbox' => {
         title   => 'view inbox template',
         body    => '',
         isa => [
             {
                 tag => 'common vars',
                 namespace => 'Account_Inbox',
             },
         ],
         fields => [ ],
         variables => [
             { name => 'subject_url', },
             { name => 'status_url', },
             { name => 'from_url', },
             { name => 'dateStamp_url', },
             { name => 'rpp_url', },
             { name => 'has_messages', },
             { name => 'message_total', },
             { name => 'new_message_url', },
             { name => 'canSendMessages', },
             {
               name => 'message_loop',
               variables => [],
             },
          ],
          related => [ ],
      },
};

1;
#vim:ft=perl
