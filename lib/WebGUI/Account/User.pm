package WebGUI::Account::User;

use strict;

use WebGUI::Exception;
use WebGUI::International;
use WebGUI::Pluggable;
use WebGUI::Utility;
use base qw/WebGUI::Account/;

=head1 NAME

Package WebGUI::Account::User

=head1 DESCRIPTION

This is the class which is used to display a users's account details

=head1 SYNOPSIS

 use WebGUI::Account::User;

=head1 METHODS

These subroutines are available from this package:

=cut


#-------------------------------------------------------------------

=head2 editSettingsForm ( )

  Creates form elements for user settings page custom to this account module

=cut

sub editUserSettingsForm {
    my $self    = shift;
    my $session = $self->session;
    my $setting = $session->setting;
    my $i18n    = WebGUI::International->new($session,'Account_User');
    my $f       = WebGUI::HTMLForm->new($session);

#   $f->template(
#		name      => "profileStyleTemplateId",
#		value     => $self->getStyleTemplateId,
#		namespace => "style",
#		label     => $i18n->get("profile style template label"),
#       hoverHelp => $i18n->get("profile style template hoverHelp")
#   );

    return $f->printRowsOnly;
}

#-------------------------------------------------------------------

=head2 editSettingsFormSave ( )

  Creates form elements for user settings page custom to this account module

=cut

sub editUserSettingsFormSave {
}

#-------------------------------------------------------------------

=head2 getLayoutTemplateId ( )

This method returns the template ID for the account layout.

=cut

sub getLayoutTemplateId {
    my $self = shift;
    return $self->session->setting->get("userLayoutTempalteId") || $self->SUPER::getLayoutTemplateId;
}


#-------------------------------------------------------------------

=head2 getStyleTemplateId ( )

This method returns the template ID for the main style.

=cut

sub getStyleTemplateId {
    my $self = shift;
    return $self->session->setting->get("userStyleTemplateId") || $self->SUPER::getStyleTemplateId;
}

#-------------------------------------------------------------------

=head2 getViewTemplateId ( )

This method returns the template ID for the main view.

=cut

sub getViewTemplateId {
    my $self = shift;
    return $self->session->setting->get("userViewTemplateId") || "defaultAssetId";
}

#-------------------------------------------------------------------

=head2 www_view ( )

The main view page for editing the user's profile.

=cut

sub www_view {
    my $self    = shift;
    my $session = $self->session;
    my $var     = {};

    return $self->processTemplate($var,$self->getViewTemplateId);
}


1;
