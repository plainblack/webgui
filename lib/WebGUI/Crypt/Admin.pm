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
    $ac->addSubmenuItem( $session->url->page('op=crypt;func=providers'), $i18n->get('Manage Providers') );
    $ac->addSubmenuItem( $session->url->page('op=crypt;func=settings'),  $i18n->get('Settings') );
    return $ac;
}

#----------------------------------------------------------------------------

=head2 getWorkflowStatus ( session )

Returns true if an instance of the CryptUpdateFieldProviders workflow is active.

=cut

sub getWorkflowStatus {
    my $session = shift;
    my ( $running, $startDate, $endDate, $userId )
        = $session->db->quickArray('select running, startDate, endDate, userId from cryptStatus');
    if (wantarray) {
        return $running, $startDate, $endDate, WebGUI::User->new( $session, $userId );
    }
    return $running;
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

    my ( $running, $startDate, $endDate, $user ) = getWorkflowStatus($session);

    if ($error) {
        $error = qq|<div class="error">$error</div>\n|;
    }
    elsif ( !$session->setting->get('cryptEnabled') ) {
        my $settingsUrl = $session->url->page('op=crypt;func=settings');
        $error
            = qq|<div class="error">Crypt is currently disabled. You can enable it on the <a href="$settingsUrl">Settings</a> page.</div>\n|;
    }
    elsif ( !$session->config->get('crypt') ) {
        $error = qq|<div class="error">Please add one or more Providers to begin using Crypt.</div>\n|;
    }
    elsif ($endDate) {
        $error = qq|<div class="error">UpdateProviders Workflow completed on $endDate</div>\n|;
    }

    my $i18n = WebGUI::International->new( $session, 'Crypt' );
    my $ac = getAdminConsole($session);

    my $addmenu = '<div style="float: left; width: 200px; font-size: 11px;">';
    $addmenu .= sprintf '<a href="%s">%s</a>',
        $session->url->page('op=crypt;func=editProvider'),
        $i18n->get('Add a provider');
    $addmenu .= '</div>';

    my $f = WebGUI::HTMLForm->new($session);
    $f->hidden(
        name  => 'op',
        value => 'crypt'
    );
    $f->hidden(
        name  => 'func',
        value => 'editProviderSave'
    );

    if ($running) {
        $f->raw( sprintf <<END_HTML, $startDate, $user->username );
<tr><td colspan="2">UpdateProviders Workflow is currently running. It was started at %s by %s</td></tr>
END_HTML
    }
    elsif ( $session->setting->get('cryptEnabled') && $session->config->get('crypt') ) {
        $f->submit( value => $i18n->get('Start UpdateProviders Workflow') );
    }

    my $providerTable;
    if ( my $providers = $session->config->get('crypt') ) {
        $providerTable = <<END_HTML;
<table class="content">
    <thead class="tableHeader">
        <tr>
            <td></td>
            <td>Name</td>
            <td>Provider</td>
        </tr>
    </thead>
    <tbody class="tableData">
END_HTML

        my @providerTableRows;
        while ( my ( $providerId, $provider ) = each %{$providers} ) {
            my $icon       = $session->icon;
            my $iconDelete = $icon->delete( "op=crypt;func=deleteProvider;providerId=$providerId",
                undef, $i18n->get('confirm delete provider') );
            my $iconEdit = $icon->edit("op=crypt;func=editProvider;providerId=$providerId");
            $provider->{provider} =~ s/WebGUI::Crypt::Provider:://;
            push @providerTableRows, {
                name => $provider->{name},
                html => <<END_HTML,
        <tr>
            <td>$iconDelete $iconEdit</td>
            <td>$provider->{name}</td>
            <td>$provider->{provider}</td>
        </tr>
END_HTML
            };
        }
        @providerTableRows = map { $_->{html} } sort { $a->{name} cmp $b->{name} } @providerTableRows;
        $providerTable .= join "\n", @providerTableRows;
        $providerTable .= <<END_HTML
    </tbody>
</table>
<div style="clear: both;"></div>
END_HTML
    }

    return $ac->render( $error . $f->print . $addmenu . $providerTable, $i18n->get('Crypt Settings') );
}

#-------------------------------------------------------------------

=head2 www_providersSave ( session )

Save Crypt providers.

=cut

sub www_providersSave {
    my ($session) = validate_pos( @_, { isa => 'WebGUI::Session' } );
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
    my ($session) = validate_pos( @_, { isa => 'WebGUI::Session' } );
    return $session->privilege->insufficient() unless canView($session);
    my $form = $session->form;
    $session->setting->set( 'cryptEnabled', $form->process( 'enabled', 'yesNo' ) );
    return www_settings($session);
}

1;
