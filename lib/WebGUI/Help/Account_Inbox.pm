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
            { name => 'userFilter', },
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
             {
                 tag => 'pagination template variables',
                 namespace => 'WebGUI',
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
             { name => 'message_rpp', },
             { name     => 'form_header',
               required => 1,             },
             { name     => 'form_footer',
               required => 1,             },
             {
               name => 'message_loop',
               variables => [
                    { name => 'message_id', },
                    { name => 'message_url', },
                    { name => 'subject', },
                    { name => 'status', },
                    { name => 'status_class', },
                    { name => 'isRead', },
                    { name => 'isReplied', },
                    { name => 'isPending', },
                    { name => 'isCompleted', },
                    { name => 'from_id', },
                    { name => 'from_url', },
                    { name => 'from', },
                    { name => 'dateStamp', },
                    { name => 'dateStamp_formatted', },
                    { name => 'inbox_form_delete', },
               ],
             },
          ],
          related => [ ],
      },
};

1;
#vim:ft=perl
