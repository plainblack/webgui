package WebGUI::Account::User;

use strict;

use WebGUI::Exception;
use WebGUI::International;
use WebGUI::Pluggable;
use WebGUI::Operation::Auth;

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

=head2 canView ( )

    Returns whether or not the user can view the inbox tab

=cut

sub canView {
    my $self    = shift;
    return ($self->uid eq ""); 
}

#-------------------------------------------------------------------

=head2 editSettingsForm ( )

  Creates form elements for user settings page custom to this account module

=cut

sub editSettingsForm {
    my $self    = shift;
    my $session = $self->session;
    my $setting = $session->setting;
    my $i18n    = WebGUI::International->new($session,'Account_User');
    my $f       = WebGUI::HTMLForm->new($session);

    $f->template(
		name      => "userAccountStyleTemplateId",
		value     => $self->getStyleTemplateId,
		namespace => "style",
		label     => $i18n->get("user style template label"),
        hoverHelp => $i18n->get("user style template hoverHelp")
    );
    $f->template(
		name      => "userAccountLayoutTemplateId",
		value     => $self->getLayoutTemplateId,
		namespace => "Account/Layout",
		label     => $i18n->get("user layout template label"),
        hoverHelp => $i18n->get("user layout template hoverHelp")
    );
    $f->raw(q{<tr><td class="formDescription" colspan="2">&nbsp</td></tr>});
    $f->readOnly (
        value     => $i18n->get("templates in auth method message"),
    );

    return $f->printRowsOnly;
}

#-------------------------------------------------------------------

=head2 editSettingsFormSave ( )

  Creates form elements for user settings page custom to this account module

=cut

sub editSettingsFormSave {
    my $self    = shift;
    my $session = $self->session;
    my $setting = $session->setting;
    my $form    = $session->form;

    $setting->set("userAccountStyleTemplateId", $form->process("userAccountStyleTemplateId","template"));
    $setting->set("userAccountLayoutTemplateId", $form->process("userAccountLayoutTemplateId","template"));
}

#-------------------------------------------------------------------

=head2 getLayoutTemplateId ( )

This method returns the template ID for the account layout.

=cut

sub getLayoutTemplateId {
    my $self = shift;
    return $self->session->setting->get("userAccountLayoutTemplateId") || "9ThW278DWLV0-Svf68ljFQ";
}


#-------------------------------------------------------------------

=head2 getStyleTemplateId ( )

This method returns the template ID for the main style.

=cut

sub getStyleTemplateId {
    my $self = shift;
    return $self->session->setting->get("userAccountStyleTemplateId") || $self->SUPER::getStyleTemplateId;
}


#-------------------------------------------------------------------

=head2 www_view ( )

The main view page for editing the user's profile.

=cut

sub www_view {
    my $self    = shift;
    my $session = $self->session;

    my $auth = WebGUI::Operation::Auth::getInstance($session);
    
    return $auth->displayAccount;
}


1;
