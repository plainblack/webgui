package WebGUI::Auth::Twitter;

use strict;
use base 'WebGUI::Auth';
use Net::Twitter;

sub new {
    my $self    = shift->SUPER::new(@_);
    return bless $self, __PACKAGE__; # Auth requires rebless
}

sub createTwitterUser {
    my ( $self, $twitterUserId, $twitterScreenName ) = @_;
    my $user    = WebGUI::User->create( $self->session );
    $user->username( $twitterScreenName );
    $self->saveParams( $user->userId, $self->authMethod, { 
        "twitterUserId" => $twitterUserId,
    } );
    return $user;
}

sub editUserSettingsForm {
    my $self = shift;
    my $session = $self->session;
    my ( $setting ) = $session->quick(qw( setting ));

    my $f = WebGUI::HTMLForm->new( $session );

    $f->yesNo( 
        name        => 'twitterEnabled',
        value       => $settings->get( 'twitterEnabled' ),
        label       => 'Enabled?',
        hoverHelp   => 'Enabled Twitter-based login',
    );

    return $f->printRowsOnly;
}

sub editUserSettingsFormSave {
    my $self    = shift;
    my $session = $self->session;
    my ( $form, $setting ) = $session->quick(qw( form setting ));

    my @fields  = qw( twitterEnabled );
    for my $field ( @fields ) {
        $setting->set( $field, $form->get( $field ) );
    }

    return;
}

sub www_login {
    my ( $self ) = @_;
    my $session = $self->session;
    my ( $url, $scratch ) = $session->quick( qw( url scratch ) );

    my $nt = Net::Twitter->new(
        traits          => [qw/API::REST OAuth/],
        consumer_key    => '3hvJpBr73pa4FycNrqw',
        consumer_secret => 'E4M5DJ66RAXiHgNCnJES96yTqglttsUes6OBcw9A',
    );

    my $url = $nt->get_authorization_url(
                    callback => $url->getSiteURL . $url->page('op=auth&authType=Twitter&method=callback'),
                );

    $scratch->set( 'AuthTwitterToken', $nt->request_token );
    $scratch->set( 'AuthTwitterTokenSecret', $nt->request_token_secret );

    $session->http->setRedirect($url);
    return "redirect";
}

sub www_callback {
    my ( $self ) = @_;
    my $session = $self->session;
    my ( $form, $scratch, $db ) = $session->quick(qw( form scratch db ));

    my $verifier = $form->get('oauth_verifier');

    my $nt = Net::Twitter->new(
        traits => [qw/API::REST OAuth/],
        consumer_key    => '3hvJpBr73pa4FycNrqw',
        consumer_secret => 'E4M5DJ66RAXiHgNCnJES96yTqglttsUes6OBcw9A',
    );
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
    $scratch->set( "AuthTwitterUserId", $twitterUserId );
    my $output  = '<h1>Choose a Username</h1>'
                . sprintf( '<p>Your twitter screen name "%s" is already taken. Please choose a new username.</p>', $twitterScreenName )
                . '<form><input type="hidden" name="op" value="auth" />'
                . '<input type="hidden" name="authType" value="Twitter" />'
                . '<input type="hidden" name="method" value="setUsername" />'
                . '<input type="text" name="newUsername" value="" />'
                . '<input type="submit" />'
                . '</form>'
                ;
    return $output;
}

sub www_setUsername {
    my ( $self ) = @_;
    my $session = $self->session;
    my ( $form, $scratch, $db ) = $session->quick(qw( form scratch db ));

    my $username    = $form->get('newUsername');
    if ( !WebGUI::User->newByUsername( $session, $username ) ) {
        my $twitterUserId = $scratch->get( "AuthTwitterUserId" );
        my $user = $self->createTwitterUser( $twitterUserId, $username );
        $self->user( $user );
        return $self->login;
    }

    # Username is again taken! Noooooo!
    my $output  = '<h1>Choose a Username</h1>'
                . sprintf( '<p>The username "%s" is already taken. Please choose a new username.</p>', $username )
                . '<form><input type="hidden" name="op" value="auth" />'
                . '<input type="hidden" name="authType" value="Twitter" />'
                . '<input type="hidden" name="method" value="setUsername" />'
                . '<input type="text" name="newUsername" value="" />'
                . '<input type="submit" />'
                . '</form>'
                ;
    return $output;
}

1;
