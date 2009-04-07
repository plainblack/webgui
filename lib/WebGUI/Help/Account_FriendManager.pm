package WebGUI::Help::Account_FriendManager;

use strict; 

our $HELP = { 

     'view friend manager' => {
         title   => 'Friend Manager View Template',
         body    => '',
         isa => [
         ],
         fields => [ ],
         variables => [
             { name => 'group_loop',
               variables => [
                 { name => 'groupId',   },
                 { name => 'groupName', },
               ]
             },
          ],
          related => [ ],
      },
};

1;
#vim:ft=perl
