package WebGUI::Account::FriendManager;

use strict;

use WebGUI::Exception;
use WebGUI::International;
use WebGUI::Pluggable;
use WebGUI::Utility;
use base qw/WebGUI::Account/;

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
        name      => "friendManagerViewTemplateId",
        value     => $self->session->setting->get("friendManagerViewTemplateId"),
        namespace => "Account/FriendManager/View",
        label     => $i18n->get("view template label"),
        hoverHelp => $i18n->get("view template hoverHelp"),
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

    $setting->set("friendManagerViewTemplateId",  $form->process("friendManagerViewTemplateId",  "template"));
    my $groupsToManageFriends = $form->process("groupsToManageFriends", "group");
    $setting->set("groupsToManageFriends", $groupsToManageFriends);
    $setting->set("groupIdAdminFriends",   $form->process("groupIdAdminFriends",   "group"));
}

#-------------------------------------------------------------------

=head2 www_getFriendsAsJson ( )

For each user in a group, count how many friends they have and return that data
as JSON.

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
    my %results;
    $results{totalRecords} = scalar @records;
    $results{records}      = \@records;
    #$results{'sort'}       = undef;
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

    return $self->processTemplate($var,$session->setting->get("friendManagerViewTemplateId"));
}


1;
