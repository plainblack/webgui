package WebGUI::Account::FriendManager;

use strict;

use WebGUI::Exception;
use WebGUI::International;
use WebGUI::Pluggable;
use WebGUI::Utility;
use base qw/WebGUI::Account/;

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
        hoverHelp => $i18n->get("setting groupIdAdminFriends hoverHelp")
    );
    $f->group(
		name      => "groupsToManageFriends",
		value     => $session->setting->get('groupsToManageFriends'),
        multiple  => 1,
		label     => $i18n->get("groupsToManageFriends label"),
        hoverHelp => $i18n->get("groupsToManageFriends hoverHelp")
    );
    $f->template(
		name      => "friendManagerViewTemplateId",
		value     => $self->session->setting->get("friendManagerViewTemplateId"),
		namespace => "Account/FriendManager/View",
		label     => $i18n->get("view template label"),
        hoverHelp => $i18n->get("view template hoverHelp")
    );

    return $f->printRowsOnly;
}

#-------------------------------------------------------------------

=head2 editSettingsFormSave ( )

  Creates form elements for the settings page custom to this account module

=cut

sub editSettingsFormSave {
    my $self    = shift;
    my $session = $self->session;
    my $setting = $session->setting;
    my $form    = $session->form;

    $setting->set("moduleViewTemplateId", $form->process("moduleViewTemplateId","template"));
}

#-------------------------------------------------------------------

=head2 www_view ( )

The main view page for editing the user's profile.

=cut

sub www_view {
    my $self    = shift;
    my $session = $self->session;
    my $var     = {};

    return $self->processTemplate($var,$session->setting->get("moduleViewTemplateId"));
}


1;
