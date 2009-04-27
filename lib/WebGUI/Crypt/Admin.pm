package WebGUI::Crypt::Admin;

use strict;
use Tie::IxHash;
use WebGUI::AdminConsole;
use WebGUI::HTMLForm;
use WebGUI::International;
use WebGUI::Pluggable;
use WebGUI::Utility;
use WebGUI::HTMLForm;
use WebGUI::Workflow;
use WebGUI::Workflow::Instance;
use WebGUI::User;
use WebGUI::Text;

=head1 NAME

Package WebGUI::Crypt::Admin

=head1 DESCRIPTION

Web interface for Crypt Admin.

=cut

#----------------------------------------------------------------------------

=head2 canView ( session [, user] )

Returns true if the user can administrate this operation. user defaults to 
the current user.

=cut

sub canView {
    my $session = shift;
    my $user = shift || $session->user;
    return $user->isInGroup(3);
}

#-------------------------------------------------------------------

=head2 www_settings ( session )

Configure Crypt settings.

=cut

sub www_settings {
    my $session = shift;
    my $error   = shift;
    return $session->privilege->insufficient() unless canView($session);
    if ($error) {
        $error = qq|<div class="error">$error</div>\n|;
    }
    my $i18n = WebGUI::International->new( $session, "Crypt" );
    my $f = WebGUI::HTMLForm->new($session);
    $f->hidden(
        name  => 'op',
        value => 'crypt'
    );
    $f->hidden(
        name  => 'func',
        value => 'settingsSave'
    );
    $f->yesNo(
        name      => 'enabled',
        value     => $session->form->get('enabled') || $session->setting->get('cryptEnabled') || 0,
        label     => $i18n->get('Enabled?'),
        hoverHelp => $i18n->get('Enabled? help'),
    );
    $f->submit();
    my $ac = WebGUI::AdminConsole->new( $session, 'crypt' );
    $ac->addSubmenuItem( $session->url->page('op=crypt;func=settings'), $i18n->get('Crypt Settings') );
    return $ac->render( $error . $f->print, $i18n->get('Crypt Settings') );
}

#-------------------------------------------------------------------

=head2 www_settingsSave ( session )

Save Crypt settings.

=cut

sub www_settingsSave {
    my $session = shift;
    return $session->privilege->insufficient() unless canView($session);
    my $form = $session->form;
    $session->setting->set( 'cryptEnabled', $form->process( 'enabled', 'yesNo' ) );
    return www_settings($session);
}

1;
