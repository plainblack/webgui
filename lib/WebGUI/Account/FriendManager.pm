package WebGUI::Account::FriendManager;

use strict;

use WebGUI::Exception;
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

=head2 editSettingsForm ( )

Creates form elements for the settings page custom to this account module.

=cut

sub editSettingsForm {
    my $self    = shift;
    my $session = $self->session;
    my $i18n    = WebGUI::International->new($session,'Account_FriendManager');
    my $f       = WebGUI::HTMLForm->new($session);

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

    $setting->set("fmViewTemplateId",  $form->process("fmViewTemplateId",  "template"));
    $setting->set("fmEditTemplateId",  $form->process("fmEditTemplateId",  "template"));
    my $groupsToManageFriends = $form->process("groupsToManageFriends", "group");
    $setting->set("groupsToManageFriends", $groupsToManageFriends);
    $setting->set("groupIdAdminFriends",   $form->process("groupIdAdminFriends",   "group"));
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
    my $userId  = $form->get('userId');
    my $user    = WebGUI::User->new($session, $userId);

    ##List users in my friends group.   Each friend gets a delete link.
    my $friendsList = $user->friends->getUserList();
    ##List users in all administrated groups.  Friends are added one at a time.
    my @manageableUsers = ();
    my $groupIds = $session->setting->get('groupsToManageFriends');
    my @groupIds = split "\n", $groupIds;
    foreach my $groupId (@groupIds) {
        my $group = WebGUI::Group->new($session, $groupId);
        next GROUP unless $group->getId || $group->getId eq 'new';
        push @manageableUsers, @{ $group->getUsersNotIn($user->get('friendsGroup'), 'withoutExpired') };
    }
    @manageableUsers = uniq @manageableUsers;
    my %usersToAdd = ();
    my $manager = $session->user;
    foreach my $userId (@manageableUsers) {
        my $user = WebGUI::User->new($session, $userId);
        ##We don't use acceptsFriendsRequests here because it's overkill.
        ##No need to check invitations, since friends are managed.
        ##Existing friends are already filtered out.
        next unless $user->profileField('ableToBeFriend');
        $usersToAdd{$userId} = $user->username;
    }

    my $var;
    $var->{formHeader}  = WebGUI::Form::header($session);
    $var->{addUserForm} = WebGUI::Form::selectBox($session, {
        name        => 'userToAdd',
        options     => \%usersToAdd,
        sortByValue => 1,
    });
    $var->{formFooter} = WebGUI::Form::footer($session);;
    return $self->processTemplate($var,$session->setting->get("fmEditTemplateId"));
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
    USER: foreach my $userId (@{ $group->getUsers} ) {
        my $user = WebGUI::User->new($session, $userId);
        next USER unless $user;
        my $friendsCount = scalar $user->friends->getUsers();
        push @records, {
            userId   => $userId,
            username => $user->username,
            friends  => $friendsCount,
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

The main view page for editing the user's profile.

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
