package WebGUI::i18n::English::Account_FriendManager;
use strict;

our $I18N = {

    'setting groupIdAdminFriends label' => {
        message     => q{Friends Manager},
        lastUpdated => 0,
    },

    'setting groupIdAdminFriends hoverHelp' => {
        message     => q{Group to manage friends, to assign people to one another and to view the interface for managing friends.},
        lastUpdated => 0,
    },
    
    'style template label' => {
        message     => q|Style Template|,
        lastUpdated => 0
	},

    'style template hoverHelp' => {
        message     => q|Select a style template from the list to enclose the Friend Manager tab in.|,
        lastUpdated => 0
	},

    'layout template label' => {
        message     => q|Layout Template|,
        lastUpdated => 0
	},

    'layout template hoverHelp' => {
        message     => q{Choose a layout template in which to enclose the content from the various methods within the Friend Manager tab},
        lastUpdated => 0
    },

    'view template label' => {
        message     => q{View Template},
        lastUpdated => 0,
    },

    'view template hoverHelp' => {
        message     => q{This template renders the Friend Manager itself, inside the layout and style templates.},
        lastUpdated => 0,
    },

    'edit template label' => {
        message     => q{Edit Friends Template},
        lastUpdated => 0,
    },

    'edit template hoverHelp' => {
        message     => q{This template renders the interface for adding or removing friends for a user.},
        lastUpdated => 0,
    },

    'groupsToManageFriends label' => {
        message     => q{Groups to Manage as Friends},
        lastUpdated => 0,
    },

    'groupsToManageFriends hoverHelp' => {
        message     => q{Choose groups of users whose Friends Networks you want to Manage.},
        lastUpdated => 0,
    },

    'override abletobefriend label' => {
        message     => q{Override ableToBeFriend profile setting?},
        lastUpdated => 0,
    },

    'override abletobefriend hoverHelp' => {
        message     => q{If a user has set their ableToBeFriend profile option to 'No', then the Friend Manager will not display them as a friend to be added.  If this option is set to Yes, then the Friend Manager will allow managing them.},
        lastUpdated => 0,
    },

    'title' => {
        message     => q{Friend Manager},
        lastUpdated => 0,
    },

    'remove friends' => {
        message     => q{Remove Friends},
        lastUpdated => 0,
    },

    'add new friends' => {
        message     => q{Add New Friends},
        lastUpdated => 0,
    },

    'Friend Manager View Template' => {
        message     => q{Friend Manager View Template},
        lastUpdated => 0,
    },

    'group_loop' => {
        message     => q{A loop containing 1 entry for each group that is set to be managed.},
        lastUpdated => 0,
    },

    'groupId' => {
        message     => q{The GUID of the group.},
        lastUpdated => 0,
    },

    'groupName' => {
        message     => q{The name of the group.},
        lastUpdated => 0,
    },

    'Friend Manager Edit Template' => {
        message     => q{Friend Manager Edit Template},
        lastUpdated => 0,
    },

    'formHeader' => {
        message     => q{HTML code to begin the form for editing a user's list of friends.},
        lastUpdated => 0,
    },

    'username' => {
        message     => q{The name of the user whose friends you are managing.},
        lastUpdated => 0,
    },

    'userId' => {
        message     => q{The GUID of the user whose friends you are managing.},
        lastUpdated => 0,
    },

    'manageUrl' => {
        message     => q{The URL back to the Friend Manager main screen},
        lastUpdated => 1248798355,
    },

    'back to friend manager' => {
        message     => q{Back to the Friend Manager.},
        lastUpdated => 0,
    },

    'addUserForm' => {
        message     => q{A dropdown box with a list of users who can be added to this user's Friends.},
        lastUpdated => 0,
    },

    'hasFriends' => {
        message     => q{A boolean which is true if the user currently has friends.},
        lastUpdated => 0,
    },

    'friend_loop' => {
        message     => q{A loop containing a list of the this user's current friends.},
        lastUpdated => 0,
    },

    'new userId' => {
        message     => q{The GUID of a user.},
        lastUpdated => 0,
    },

    'new username' => {
        message     => q{The username of a user.},
        lastUpdated => 0,
    },

    'checkForm' => {
        message     => q{A checkbox for this user.  If set when the form is submitted, this user will be removed from the user's list of friends.},
        lastUpdated => 0,
    },

    'removeAll' => {
        message     => q{A checkbox to remove all friends from this user.},
        lastUpdated => 0,
    },

    'remove all' => {
        message     => q{Remove all},
        context     => q{Template label.  To remove all members of a set, to emtpy it.},
        lastUpdated => 0,
    },

    'addManagers' => {
        message     => q{A checkbox to add all users in the Friend Manager group to this users's list of Friends.},
        lastUpdated => 0,
    },

    'Add Friend Managers' => {
        message     => q{Add Friend Managers},
        context     => q{Template label.  To add all Friend Managers to this list of friends.},
        lastUpdated => 0,
    },

    'submit' => {
        message     => q{A button with internationalized label to submit the form.},
        lastUpdated => 0,
    },

    'formFooter' => {
        message     => q{HTML code to end the form.},
        lastUpdated => 0,
    },

    'view users from all groups' => {
        message     => q{View users from all groups.},
        lastUpdated => 0,
    },

    'friends count' => {
        message     => q{Friends Count},
        lastUpdated => 0,
    },

};

1;
