package WebGUI::Auth::Twitter;

=head1 LEGAL

 -------------------------------------------------------------------
  WebGUI is Copyright 2001-2009 Plain Black Corporation.
 -------------------------------------------------------------------
  Please read the legal notices (docs/legal.txt) and the license
  (docs/license.txt) that came with this distribution before using
  this software.
 -------------------------------------------------------------------
  http://www.plainblack.com                     info@plainblack.com
 -------------------------------------------------------------------

=cut

use strict;
use base 'WebGUI::Auth';
use Net::Twitter;

=head1 NAME

WebGUI::Auth::Twitter -- Twitter auth for WebGUI

=head1 DESCRIPTION

Allow WebGUI to authenticate to WebGUI

=head1 METHODS

These methods are available from this class:

=cut

#----------------------------------------------------------------------------

=head2 new ( ... )

Create a new object

=cut

sub new {
    my $self    = shift->SUPER::new(@_);
    return bless $self, __PACKAGE__; # Auth requires rebless
}

#----------------------------------------------------------------------------

=head2 createTwitterUser ( twitterUserId, username )

    my $user    = $self->createTwitterUser( $twitterUserId, $username );

Create a new Auth::Twitter user with the given twitter userId and screen name.

=cut

sub createTwitterUser {
    my ( $self, $twitterUserId, $username ) = @_;
    my $user    = WebGUI::User->create( $self->session );
    $user->username( $username );
    $self->saveParams( $user->userId, $self->authMethod, { 
        "twitterUserId" => $twitterUserId,
    } );
    return $user;
}

#----------------------------------------------------------------------------

=head2 editUserSettingsForm ( )

Return the form to edit the settings of this Auth module

=cut

sub editUserSettingsForm {
    my $self = shift;
    my $session = $self->session;
    my ( $setting ) = $session->quick(qw( setting ));
    my $i18n = WebGUI::International->new( $session, 'Auth_Twitter' );

    my $keyUrl  = 'http://dev.twitter.com/apps/new';

    my $f = WebGUI::HTMLForm->new( $session );

    $f->yesNo(
        name        => 'twitterEnabled',
        value       => $setting->get( 'twitterEnabled' ),
        label       => $i18n->get('enabled'),
        hoverHelp   => $i18n->get('enabled help'),
    );

    $f->text(
        name        => 'twitterConsumerKey',
        value       => $setting->get( 'twitterConsumerKey' ),
        label       => $i18n->get('consumer key'),
        hoverHelp   => $i18n->get('consumer key help'),
        subtext     => sprintf( $i18n->get('get key'), ($keyUrl) x 2 ),
    );

    $f->text(
        name        => 'twitterConsumerSecret',
        value       => $setting->get( 'twitterConsumerSecret' ),
        label       => $i18n->get('consumer secret'),
        hoverHelp   => $i18n->get('consumer secret help'),
    );

    $f->template(
        name        => 'twitterTemplateIdChooseUsername',
        value       => $setting->get( 'twitterTemplateIdChooseUsername' ),
        label       => $i18n->get('choose username template'),
        hoverHelp   => $i18n->get('choose username template help'),
        namespace   => 'Auth/Twitter/ChooseUsername',
    );

    return $f->printRowsOnly;
}

#----------------------------------------------------------------------------

=head2 editUserSettingsFormSave ( )

Process the form for this Auth module's settings

=cut

sub editUserSettingsFormSave {
    my $self    = shift;
    my $session = $self->session;
    my ( $form, $setting ) = $session->quick(qw( form setting ));

    my @fields  = qw( 
        twitterEnabled twitterConsumerKey twitterConsumerSecret 
        twitterTemplateIdChooseUsername 
    );
    for my $field ( @fields ) {
        $setting->set( $field, $form->get( $field ) );
    }

    return;
}

#----------------------------------------------------------------------------

=head2 getTemplateChooseUsername ( )

Get the template to choose a username

=cut

sub getTemplateChooseUsername {
    my ( $self ) = @_;
    my $templateId  = $self->session->setting->get('twitterTemplateIdChooseUsername');
    return WebGUI::Asset->newById( $self->session, $templateId );
}

#----------------------------------------------------------------------------

=head2 getTwitter ( )

Get the Net::Twitter object with the appropriate keys

=cut

sub getTwitter {
    my ( $self ) = @_;
    my $setting     = $self->session->setting;
    if ( !$self->{_twitter} ) {
        my $nt = Net::Twitter->new(
            traits          => [qw/API::REST OAuth/],
            consumer_key    => $setting->get( 'twitterConsumerKey' ),       # Test: '3hvJpBr73pa4FycNrqw',
            consumer_secret => $setting->get( 'twitterConsumerSecret' ),    # Test: 'E4M5DJ66RAXiHgNCnJES96yTqglttsUes6OBcw9A',
        );

        $self->{_twitter} = $nt;
    }
    return $self->{_twitter};
}

#----------------------------------------------------------------------------

=head2 www_login ( )

Begin the login procedure

=cut

sub www_login {
    my ( $self ) = @_;
    my $session = $self->session;
    my ( $url, $scratch, $setting ) = $session->quick( qw( url scratch setting ) );

    my $nt  = $self->getTwitter;

    my $auth_url = $nt->get_authentication_url(
                    callback => $url->getSiteURL . $url->page('op=auth&authType=Twitter&method=callback'),
                );

    $scratch->set( 'AuthTwitterToken', $nt->request_token );
    $scratch->set( 'AuthTwitterTokenSecret', $nt->request_token_secret );

    $session->http->setRedirect($auth_url);
    return "redirect";
}

#----------------------------------------------------------------------------

=head2 www_callback ( )

Callback from the Twitter authentication. Try to log the user in, creating a 
new user account if necessary. 

If the username is taken, allow the user to choose a new one.

=cut

sub www_callback {
    my ( $self ) = @_;
    my $session = $self->session;
    my ( $form, $scratch, $db, $setting ) = $session->quick(qw( form scratch db setting ));

    my $verifier = $form->get('oauth_verifier');

    my $nt      = $self->getTwitter;
    $nt->request_token( $scratch->get('AuthTwitterToken') );
    $nt->request_token_secret( $scratch->get('AuthTwitterTokenSecret') );

    my ($access_token, $access_token_secret, $twitterUserId, $twitterScreenName )
        = $nt->request_access_token(verifier => $verifier);

    ### Log the user in
    # Find their twitter user ID
    my $userId  = $db->quickScalar( 
        "SELECT userId FROM authentication WHERE authMethod = ? AND fieldName = ? AND fieldData = ?",
        [ "Twitter", "twitterUserId", $twitterUserId ],
    );

    # Returning user
    if ( $userId ) {
        my $user    = WebGUI::User->new( $session, $userId );
        $self->user( $user );
        return $self->login;
    }
    # Otherwise see if their screen name exists and create a user
    elsif ( !WebGUI::User->newByUsername( $session, $twitterScreenName ) ) {
        my $user = $self->createTwitterUser( $twitterUserId, $twitterScreenName );
        $self->user( $user );
        return $self->login;
    }

    # Otherwise ask them for a new username to use
    my $i18n = WebGUI::International->new( $session, 'Auth_Twitter' );
    $scratch->set( "AuthTwitterUserId", $twitterUserId );
    my $tmpl    = $self->getTemplateChooseUsername;
    my $var     = {
        message     => sprintf( $i18n->get("twitter screen name taken"), $twitterScreenName ),
    };

    return $tmpl->process( $var );
}

#----------------------------------------------------------------------------

=head2 www_setUsername ( )

Set the username for a twitter user. Only used as part of the initial twitter
registration.

=cut

sub www_setUsername {
    my ( $self ) = @_;
    my $session = $self->session;
    my ( $form, $scratch, $db ) = $session->quick(qw( form scratch db ));
    my $i18n = WebGUI::International->new( $session, 'Auth_Twitter' );

    # Don't allow just anybody to set a username
    return unless $scratch->get('AuthTwitterUserId');

    my $username    = $form->get('newUsername');
    if ( !WebGUI::User->newByUsername( $session, $username ) ) {
        my $twitterUserId = $scratch->get( "AuthTwitterUserId" );
        my $user = $self->createTwitterUser( $twitterUserId, $username );
        $self->user( $user );
        return $self->login;
    }

    # Username is again taken! Noooooo!
    my $tmpl    = $self->getTemplateChooseUsername;
    my $var     = {
        message     => sprintf( $i18n->get("webgui username taken"), $username ),
    };

    return $tmpl->process( $var );
}

1;
