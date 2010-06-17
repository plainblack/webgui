package WebGUI::Test::Mechanize;

use strict;
use warnings;

use parent 'Test::WWW::Mechanize::PSGI';

use WebGUI;
use WebGUI::Config;
use WebGUI::Session;
use WebGUI::Middleware::Session;
use Plack::Middleware::NullLogger;
use Try::Tiny;
BEGIN {
    @Plack::Middleware::NullLogger::ISA = qw(Plack::Middleware);
}

sub new {
    my $class = shift;
    my %options = @_;
    my $config_file = delete $options{config};
    my $wg = WebGUI->new( config => $config_file );
    my $app = $wg->to_app;
    $app = WebGUI::Middleware::Session->wrap($app, config => $wg->config);
    $app = Plack::Middleware::NullLogger->wrap($app);
    $options{app} = $app;
    my $self = $class->SUPER::new(%options);
    $self->{_webgui_config} = $wg->config;
    return $self;
}

sub session {
    my $self = shift;
    return $self->{_webgui_session}
        if $self->{_webgui_session};
    my $session = WebGUI::Session->open($self->{_webgui_config}, undef, $self->sessionId);
    $self->{_webgui_session} = $session;
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
        die "Unable to find session cookie!";
    }
    $self->{_webgui_sessionId} = $sessionId;
    return $sessionId;
}

sub DESTROY {
    my $self = shift;
    try {
        my $session = $self->session;
        $session->var->end;
        $session->close;
    };
}

1;

