package WebGUI::Test::Mechanize;

use strict;
use warnings;

=head1 NAME

WebGUI::Test::Mechanize - Test from the user's perspective

=head1 SYNOPSIS

  use WebGUI::Test;
  my $mech  = WebGUI::Test::Mechanize->new( config => WebGUI::Test->file );
  $mech->get_ok( '/home?func=edit' );

  # To change the user running
  $mech     = WebGUI::Test::Mechanize->new( config => WebGUI::Test->file );
  $mech->get_ok( '/' ); # Open a session
  $mech->session->user({ userId => 3 });
  # Continue on our merry way

  # ... See Test::WWW::Mechanize::PSGI for more

=head1 DESCRIPTION

Use a Test::WWW::Mechanize syntax to test your PSGI app without having another 
process running!

=head1 SEE ALSO

 Test::WWW::Mechanize::PSGI
 WebGUI::Test

=cut

use parent 'Test::WWW::Mechanize::PSGI';

use WebGUI;
use WebGUI::Config;
use WebGUI::Session;
use WebGUI::Middleware::Session;
use Plack::Middleware::NullLogger;
use Try::Tiny;

sub new {
    my $class = shift;
    my %options = @_;
    my $config_file = delete $options{config};
    my $wg = WebGUI->new( config => $config_file );
    my $app = $wg->to_app;
    $app = WebGUI::Middleware::Session->wrap($app, config => $wg->config);
    #$app = Plack::Middleware::NullLogger->wrap($app);
    $options{app} = $app;
    my $self = $class->SUPER::new(%options);
    $self->{_webgui_config} = $wg->config;
    return $self;
}

sub session {
    my $self = shift;
    if( @_ ) {
        $self->{_webgui_session} = shift;  # take session as an arg
        $self->{_webgui_sessionId} ||= $self->{_webgui_session}->getId;
    }
    return $self->{_webgui_session}
        if $self->{_webgui_session};
    my $session = WebGUI::Session->open($self->{_webgui_config}, undef, $self->sessionId) or die;
    $self->{_webgui_session} = $session;
    $self->{_webgui_sessionId} ||= $session->getId; # sessionId() sets it from
    return $session;
}

sub sessionId {
    my $self = shift;
    return $self->{_webgui_sessionId}
        if $self->{_webgui_sessionId};
    my $sessionId;
    my $cookieName = $self->{_webgui_config}->get('cookieName');
    $self->cookie_jar->scan(sub {
        my ($key, $value) = @_[1,2];
        if ($key eq $cookieName) {
            $sessionId = $value;
        }
    });
    if (! $sessionId) {
        # die "Unable to find session cookie!";
        # when called from session() above, there is no session yet and no sessionId; that's okay
        return; # empty list; make WebGUI::Session generate one for us
    }
    $self->{_webgui_sessionId} = $sessionId;
    return $sessionId;
}

sub DESTROY {
    my $self = shift;
    try {
        my $session = $self->session;
        $session->end;
        $session->close;
    };
}

1;

