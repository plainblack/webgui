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

     'edit friend manager' => {
         title   => 'Friend Manager Edit Template',
         body    => '',
         isa => [
         ],
         fields => [ ],
         variables => [
             { name     => 'formHeader',
               required => 1,             },
             { name     => 'username',    },
             { name     => 'userId',      },
             { name     => 'manageUrl',   },
             { name     => 'addUserForm', },
             { name     => 'hasFriends',  },
             { name     => 'friend_loop',
               variables=> [
                 { name     => 'userId',
                   description => 'new userId',   },
                 { name     => 'username',
                   description => 'new username', },
                 { name     => 'checkForm',       },
               ],
             },
             { name     => 'removeAll',   },
             { name     => 'addManagers', },
             { name     => 'submit',
               required => 1,        },
             { name     => 'formFooter',
               required => 1,        },
          ],
          related => [ ],
      },

};

1;
#vim:ft=perl
