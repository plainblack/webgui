package WebGUI::Account::Profile;

use strict;

use WebGUI::Exception;
use WebGUI::International;
use WebGUI::Pluggable;
use WebGUI::Utility;
use base qw/WebGUI::Account/;

=head1 NAME

Package WebGUI::Account::Profile

=head1 DESCRIPTION

This is the class which is used to display a users's profile information

=head1 SYNOPSIS

 use WebGUI::Account::Profile;

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
    my $i18n    = WebGUI::International->new($session,'Account_Profile');
    my $f       = WebGUI::HTMLForm->new($session);

	$f->template(
		name      => "profileStyleTemplateId",
		value     => $self->getStyleTemplateId,
		namespace => "style",
		label     => $i18n->get("profile style template label"),
        hoverHelp => $i18n->get("profile style template hoverHelp")
	);
	$f->template(
		name      => "profileLayoutTempalteId",
		value     => $self->getLayoutTemplateId,
		namespace => "Account/Layout",
		label     => $i18n->get("profile layout template label"),
        hoverHelp => $i18n->get("profile layout template hoverHelp")
	);
	$f->template(
        name      => "profileViewTemplateId",
        value     => $self->getViewTemplateId,
        namespace => "Account/Profile/View",
        label     => $i18n->get("profile view template label"),
        hoverHelp => $i18n->get("profile view template hoverHelp")
	);
    $f->template(
        name      => "profileEditTemplateId",
        value     => $setting->get("profileEditTemplateId"),
        namespace => "Account/Profile/Edit",
        label     => $i18n->get("profile edit template label"),
        hoverHelp => $i18n->get("profile edit template hoverHelp")
	);

    return $f->printRowsOnly;
}

#-------------------------------------------------------------------

=head2 getDisplayTemplateId ( )

This method returns the template ID for the account layout.

=cut

sub getDisplayTemplateId {
    my $self = shift;
    return $self->session->setting->get("profileDisplayTempalteId") || "defaultAssetId";
}

#-------------------------------------------------------------------

=head2 getLayoutTemplateId ( )

This method returns the template ID for the account layout.

=cut

sub getLayoutTemplateId {
    my $self = shift;
    return $self->session->setting->get("profileLayoutTempalteId") || $self->SUPER::getLayoutTemplateId;
}

#-------------------------------------------------------------------

=head2 getStyleTemplateId ( )

This method returns the template ID for the main style.

=cut

sub getStyleTemplateId {
    my $self = shift;
    return $self->session->setting->get("profileStyleTemplateId") || $self->SUPER::getStyleTemplateId;
}

#-------------------------------------------------------------------

=head2 getViewTemplateId ( )

This method returns the template ID for the main view.

=cut

sub getViewTemplateId {
    my $self = shift;
    return $self->session->setting->get("profileViewTemplateId") || "75CmQgpcCSkdsL-oawdn3Q";
}

#-------------------------------------------------------------------

=head2 www_view ( )

The main view page for the user's profile.

=cut

sub www_view {
    my $self    = shift;
    my $session = $self->session;
    my $var     = {};

    return $self->processTemplate($var,$session->setting->get("profileViewTemplateId"));
}


1;
