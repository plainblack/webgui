package WebGUI::Account::FriendManager;

use strict;

use WebGUI::Exception;
use WebGUI::Friends;
use WebGUI::International;
use WebGUI::Pluggable;
use WebGUI::Utility;
use base qw/WebGUI::Account/;

use List::MoreUtils qw/uniq/;
use JSON qw(from_json to_json);

=head1 NAME

Package WebGUI::Account::FriendManager

=head1 DESCRIPTION

Allow friends to be assigned to one another instead of the usual social
networking.

The style and layout settings are always inherited from the main Account
module.

=head1 SYNOPSIS

use WebGUI::Account::FriendManager;

=head1 METHODS

These methods are available from this class:

=cut

#-------------------------------------------------------------------

=head2 canView ( )

Returns whether or not the user can view the the tab for this module

=cut

sub canView {
    my $self    = shift;
    my $session = $self->session;
    return $session->user->isInGroup($session->setting->get('groupIdAdminFriends')); 
}

#-------------------------------------------------------------------

=head2 getLayoutTemplateId ( )

Returns the template Id for the account layout. See L<WebGUI::Account::getLayoutTemplateId>.

=cut

sub getLayoutTemplateId {
    my $self = shift;
    return $self->session->setting->get("fmLayoutTemplateId") || $self->SUPER::getLayoutTemplateId;
}


#-------------------------------------------------------------------

=head2 getStyleTemplateId ( )

Returns the template Id for the main style. See L<WebGUI::Account::getStyleTemplateId>.

=cut

sub getStyleTemplateId {
    my $self = shift;
    return $self->session->setting->get("fmStyleTemplateId") || $self->SUPER::getStyleTemplateId;
}

#-------------------------------------------------------------------

=head2 editSettingsForm ( )

Creates form elements for the settings page custom to this account module.

=cut

sub editSettingsForm {
    my $self    = shift;
    my $session = $self->session;
    my $i18n    = WebGUI::International->new($session,'Account_FriendManager');
    my $f       = WebGUI::HTMLForm->new($session);

    $f->template(
        name      => "fmStyleTemplateId",
        value     => $self->getStyleTemplateId,
        namespace => "style",
        label     => $i18n->get("style template label"),
        hoverHelp => $i18n->get("style template hoverHelp"),
    );
    $f->template(
        name      => "fmLayoutTemplateId",
        value     => $self->getLayoutTemplateId,
        namespace => "Account/Layout",
        label     => $i18n->get("layout template label"),
        hoverHelp => $i18n->get("layout template hoverHelp"),
    );
    $f->group(
        name      => "groupIdAdminFriends",
        value     => $session->setting->get('groupIdAdminFriends'),
        label     => $i18n->get("setting groupIdAdminFriends label"),
        hoverHelp => $i18n->get("setting groupIdAdminFriends hoverHelp"),
    );
    $f->group(
        name      => "groupsToManageFriends",
        value     => $session->setting->get('groupsToManageFriends'),
        multiple  => 1,
        size      => 5,
        label     => $i18n->get("groupsToManageFriends label"),
        hoverHelp => $i18n->get("groupsToManageFriends hoverHelp"),
        defaultValue => [2,3],
    );
    $f->template(
        name      => "fmViewTemplateId",
        value     => $self->session->setting->get("fmViewTemplateId"),
        namespace => "Account/FriendManager/View",
        label     => $i18n->get("view template label"),
        hoverHelp => $i18n->get("view template hoverHelp"),
    );
    $f->template(
        name      => "fmEditTemplateId",
        value     => $self->session->setting->get("fmEditTemplateId"),
        namespace => "Account/FriendManager/Edit",
        label     => $i18n->get("edit template label"),
        hoverHelp => $i18n->get("edit template hoverHelp"),
    );
    $f->yesNo(
        name      => "overrideAbleToBeFriend",
        value     => $self->session->setting->get("overrideAbleToBeFriend"),
        label     => $i18n->get("override abletobefriend label"),
        hoverHelp => $i18n->get("override abletobefriend hoverHelp"),
    );

    return $f->printRowsOnly;
}

#-------------------------------------------------------------------

=head2 editSettingsFormSave ( )

Save

=cut

sub editSettingsFormSave {
    my $self    = shift;
    my $session = $self->session;
    my $setting = $session->setting;
    my $form    = $session->form;

    $setting->set( "fmStyleTemplateId",      $form->process( "fmStyleTemplateId",      "template" ) );
    $setting->set( "fmLayoutTemplateId",     $form->process( "fmLayoutTemplateId",     "template" ) );
    $setting->set( "fmViewTemplateId",       $form->process( "fmViewTemplateId",       "template" ) );
    $setting->set( "fmEditTemplateId",       $form->process( "fmEditTemplateId",       "template" ) );
    $setting->set( "groupsToManageFriends",  $form->process( "groupsToManageFriends",  "group" ) );
    $setting->set( "groupIdAdminFriends",    $form->process( "groupIdAdminFriends",    "group" ) );
    $setting->set( "overrideAbleToBeFriend", $form->process( "overrideAbleToBeFriend", "yesNo" ) );
}

#-------------------------------------------------------------------

=head2 www_editFriends ( )

Edit the friends for a user.  Uses the form variable userId, to determine which user.
Only users in the managed groups are shown.  Group inheritance is supported, but
only for WebGUI defined groups.

=cut

sub www_editFriends {
    my $self    = shift;
    my $session = $self->session;
    my $form    = $session->form;
    my $userId  = shift || $form->get('userId', 'guid');
    my $user    = WebGUI::User->new($session, $userId);

    my $groupName = shift || $form->get('groupName');

    ##List users in my friends group.   Each friend gets a delete link.
    my $friendsList = $user->friends->getUserList();
    my @friends_loop = ();
    while (my ($userId, $username) = each %{ $friendsList }) {
        push @friends_loop, {
            userId => $userId,
            username => $username,
            checkForm => WebGUI::Form::checkbox($session, {
                name  => 'friendToAxe',
                value => $userId,
            }),
        };
    }

    ##List users in all administrated groups.  Friends are added one at a time.
    my @manageableUsers = ();
    if ($groupName) {
        my $group = WebGUI::Group->find($session, $groupName);
        push @manageableUsers, @{ $group->getUsersNotIn($user->{_user}->{'friendsGroup'}, 'withoutExpired') };
    }
    else {
        my $groupIds = $session->setting->get('groupsToManageFriends');
        my @groupIds = split "\n", $groupIds;
        foreach my $groupId (@groupIds) {
            my $group = WebGUI::Group->new($session, $groupId);
            next GROUP unless $group->getId || $group->getId eq 'new';
            push @manageableUsers, @{ $group->getUsersNotIn($user->{_user}->{'friendsGroup'}, 'withoutExpired') };
        }
        @manageableUsers = uniq @manageableUsers;
    }
    my %usersToAdd = ();
    tie %usersToAdd, 'Tie::IxHash';
    my $manager = $session->user;
    my $i18n = WebGUI::International->new($session);
    $usersToAdd{0} = $i18n->get('Select One');
    my @usersToAdd = ();
    my $overrideProfile = $session->setting->get('overrideAbleToBeFriend');
    USERID: foreach my $newFriendId (@manageableUsers) {
        next USERID if $newFriendId eq $userId;
        my $user = WebGUI::User->new($session, $newFriendId);
        ##We don't use acceptsFriendsRequests here because it's overkill.
        ##No need to check invitations, since friends are managed.
        ##Existing friends are already filtered out.
        next USERID unless $user->profileField('ableToBeFriend') || $overrideProfile;
        push @usersToAdd, [ $newFriendId, $user->username ];
    }

    @usersToAdd = sort { $a->[1] cmp $b->[1] } @usersToAdd;
    foreach my $newFriend (@usersToAdd) {
        $usersToAdd{$newFriend->[0]} = $newFriend->[1];
    }

    my $var;
    $var->{formHeader}  = WebGUI::Form::formHeader($session, {
                            action => $self->getUrl('module=friendManager;do=editFriendsSave'),
                          })
                        . WebGUI::Form::hidden($session, { name => 'userId', value => $user->userId } );
    if ($groupName) {
        $var->{formHeader} .= WebGUI::Form::hidden($session, { name => 'groupName', value => $groupName });
    }
    $var->{addUserForm} = WebGUI::Form::selectBox($session, {
        name        => 'userToAdd',
        options     => \%usersToAdd,
    });
    $var->{friends_loop} = \@friends_loop;
    $var->{has_friends}  = scalar @friends_loop;
    $var->{submit}       = WebGUI::Form::submit($session);
    $var->{formFooter}   = WebGUI::Form::formFooter($session);
    $var->{username}     = $user->username;
    $var->{userId}       = $user->userId;
    $var->{manageUrl}    = $self->getUrl('module=friendManager;do=view');
    $var->{removeAll}    = WebGUI::Form::checkbox($session, { name => 'removeAllFriends', value => 'all', });
    if (! $groupName) {
        $var->{addManagers}  = WebGUI::Form::checkbox($session, { name => 'addManagers', value => 'addManagers', });
    }
    if ($groupName) {
        $var->{groupName}  = $groupName;
        $var->{viewAllUrl} = $self->getUrl('module=friendManager;do=editFriends;userId='.$userId);
    }
    return $self->processTemplate($var,$session->setting->get("fmEditTemplateId"));
}

#-------------------------------------------------------------------

=head2 www_editFriendsSave ( )

Handle adding and removing people from a user's friend group.  The userId of
the user to modify will be in the userId from variable.  One userId to add will be
in userToAdd.

Users to delete will be listed in checkboxes with the name, friendToAxe

=cut

sub www_editFriendsSave () {
    my $self    = shift;
    my $session = $self->session;
    my $form    = $session->form;
    my $userId    = $form->process('userId', 'guid');
    my $user      = WebGUI::User->new($session, $userId);
    my $ufriend   = WebGUI::Friends->new($session, $user);

    my $userToAdd = $form->process('userToAdd', 'guid');
    if ($userToAdd) {
        $ufriend->add([$userToAdd]);
    }
    my $addManagers = $form->process('addManagers', 'checkbox');
    if ($addManagers eq 'addManagers') {
        my $managerGroup = WebGUI::Group->new($session, $session->setting->get('groupIdAdminFriends'));
        $ufriend->add($managerGroup->getUsers());
    }

    ##Remove all has priority, that way we don't delete friends twice.
    my $removeAll     = $form->process('removeAllFriends','checkbox');
    my @usersToRemove = $form->process('friendToAxe', 'checkList');
    if ($removeAll eq 'all') {
        $ufriend->delete($user->friends->getUsers());
    }
    elsif (scalar @usersToRemove) {
        $ufriend->delete(\@usersToRemove);
    }

    my $groupName = $form->process('groupName');
    return $self->www_editFriends($userId, $groupName);
}

#-------------------------------------------------------------------

=head2 www_getFriendsAsJson ( )

For each user in a group, count how many friends they have and return that data
as JSON.  Uses the form variable, groupId, to return users for that group.

=cut

sub www_getFriendsAsJson  {
    my $self    = shift;
    my $session = $self->session;
    return $session->privilege->insufficient
        unless $session->user->isInGroup($session->setting->get('groupIdAdminFriends'));
    my $form    = $session->form;
    my $groupId = $form->get('groupId');
    if (! $groupId) {;
        $session->log->warn("No groupId: >$groupId<");
        return '{}';
    }
    my $group   = WebGUI::Group->new($session, $groupId);
    return '{}' if $group->getId eq 'new';
    if ($group->getId eq 'new') {;
        $session->log->warn("New group created");
        return '{}';
    }
    my @records = ();
    my $groups = $session->setting->get('groupsToManageFriends');
    my @groupIds = split "\n", $groups;
    if (scalar @groupIds > 1) {
        @groupIds = grep { $_ ne $groupId } @groupIds;
    }
    my $groupNames = join "\n",
                        map { $_->name }
                        map { WebGUI::Group->new($session, $_) }
                        @groupIds;
    USER: foreach my $userId (@{ $group->getUsers} ) {
        my $user = WebGUI::User->new($session, $userId);
        next USER unless $user;
        my $friendsList = $user->friends->getUserList();
        my $friendsCount = scalar keys %{ $friendsList };
        my $friends = '';
        NAME: foreach my $name ( values %{ $friendsList }) {
            if (length $friends + length $name < 45) {
                if ($friends) {
                    $friends .= ', ';
                }
                $friends .= $name;
            }
            else {
                last NAME;
            }
        }
        push @records, {
            userId        => $userId,
            username      => $user->username,
            friendsCount  => $friendsCount,
            friends       => $friends,
            groups        => $groupNames,
        };
    }
    ##Sort by username to make the datatable happy
    @records = map { $_->[1] }
              sort { $a->[0] cmp $b->[0] }
               map { [ $_->{username}, $_ ] } @records;
    my %results;
    $results{totalRecords} = scalar @records;
    $results{records}      = \@records;
    $results{'sort'}       = 'username';
    $self->bare(1);
    $session->http->setMimeType('application/json');
    my $json = JSON::to_json(\%results);
    return $json;
}

#-------------------------------------------------------------------

=head2 www_view ( )

The main view page for editing the user's friends.

=cut

sub www_view {
    my $self    = shift;
    my $session = $self->session;
    my $var     = {};
    $var->{group_loop} = [];

    my $groupIds = $session->setting->get('groupsToManageFriends');
    my @groupIds = split "\n", $groupIds;
    GROUP: foreach my $groupId (@groupIds) {
        my $group = WebGUI::Group->new($session, $groupId);
        next GROUP unless $group->getId || $group->getId eq 'new';
        push @{ $var->{group_loop} }, {
            groupId   => $groupId,
            groupName => $group->name,
        };
    }

    return $self->processTemplate($var,$session->setting->get("fmViewTemplateId"));
}


1;
