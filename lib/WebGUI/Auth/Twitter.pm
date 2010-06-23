package WebGUI::Auth::Twitter;

use base 'WebGUI::Auth';
use Net::Twitter;

sub new {
    my $self    = shift->SUPER::new(@_);
    return bless $self, __PACKAGE__; # Auth requires rebless
}

sub www_login {
    my ( $self ) = @_;
    my $session = $self->session;
    my ( $url ) = $session->quick( qw( url ) );

    my $nt = Net::Twitter->new(
        traits          => [qw/API::REST OAuth/],
        consumer_key    => '3hvJpBr73pa4FycNrqw',
        consumer_secret => 'E4M5DJ66RAXiHgNCnJES96yTqglttsUes6OBcw9A',
    );

    unless ( $nt->authorized ) {
        $session->scratch->set( 'AuthTwitterToken', $nt->request_token );
        $session->scratch->set( 'AuthTwitterTokenSecret', $nt->request_token_secret );

        my $url = $nt->get_authorization_url(
                        callback => $url->page('?op=auth;authType=Twitter;method=callback'),
                    );

        $session->http->redirect($url);
        return "redirect";
    }
}

sub www_callback {

}


1;
