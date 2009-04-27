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
use Params::Validate qw(:all);
Params::Validate::validation_options( on_fail => sub { WebGUI::Error::InvalidParam->throw( error => shift ) } );

=head1 NAME

Package WebGUI::Crypt::Admin

=head1 DESCRIPTION

Web interface for Crypt Admin.

=cut

#----------------------------------------------------------------------------

=head2 getAdminConsole ( session )

Returns the common Admin Console object

=cut

sub getAdminConsole {
    my ($session) = validate_pos( @_, { isa => 'WebGUI::Session' } );
    my $i18n = WebGUI::International->new( $session, "Crypt" );
    my $ac = WebGUI::AdminConsole->new( $session, 'crypt' );
    $ac->addSubmenuItem( $session->url->page('op=crypt;func=settings'),  $i18n->get('Settings') );
    $ac->addSubmenuItem( $session->url->page('op=crypt;func=providers'), $i18n->get('Providers') );
    return $ac;
}

#----------------------------------------------------------------------------

=head2 canView ( session [, user] )

Returns true if the user can administrate this operation. user defaults to 
the current user.

=cut

sub canView {
    my ( $session, $user )
        = validate_pos( @_, { isa => 'WebGUI::Session' }, { isa => 'WebGUI::User', optional => 1 } );
    $user ||= $session->user;
    return $user->isInGroup(3);
}

#-------------------------------------------------------------------

=head2 www_providers ( session )

Manage Providers

=cut

sub www_providers {
    my ( $session, $error ) = validate_pos( @_, { isa => 'WebGUI::Session' }, 0 );
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
        value => 'providersSave'
    );
    $f->submit();
    my $ac = getAdminConsole($session);
    return $ac->render( $error . $f->print, $i18n->get('Crypt Settings') );
}

#-------------------------------------------------------------------

=head2 www_providersSave ( session )

Save Crypt providers.

=cut

sub www_providersSave {
    my ( $session ) = validate_pos( @_, { isa => 'WebGUI::Session' } );
    return $session->privilege->insufficient() unless canView($session);
    my $form = $session->form;
    return www_providers($session);
}

#-------------------------------------------------------------------

=head2 www_settings ( session )

Configure Crypt settings.

=cut

sub www_settings {
    my ( $session, $error ) = validate_pos( @_, { isa => 'WebGUI::Session' }, 0 );
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
        label     => $i18n->get('Enable?'),
        hoverHelp => $i18n->get('Enable? help'),
    );
    $f->submit();
    my $ac = getAdminConsole($session);
    return $ac->render( $error . $f->print, $i18n->get('Crypt Settings') );
}

#-------------------------------------------------------------------

=head2 www_settingsSave ( session )

Save Crypt settings.

=cut

sub www_settingsSave {
    my ( $session ) = validate_pos( @_, { isa => 'WebGUI::Session' } );
    return $session->privilege->insufficient() unless canView($session);
    my $form = $session->form;
    $session->setting->set( 'cryptEnabled', $form->process( 'enabled', 'yesNo' ) );
    return www_settings($session);
}

1;
