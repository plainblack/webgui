package WebGUI::Middleware::Debug;
use strict;
use parent qw(Plack::Middleware);
use Plack::Middleware::StackTrace;
use Plack::Middleware::Debug;
use Plack::Middleware::HttpExceptions;

=head1 NAME

WebGUI::Middleware::Debug - 

=head1 DESCRIPTION

This is PSGI middleware for WebGUI that 

=cut

sub call {
    my ( $self, $env ) = @_;

    my $session = $env->{'webgui.session'} or die 'WebGUI::Session missing';

    my $app = $self->app;

    if ( $session->log->canShowDebug ) {
        warn 'seeing webgui.debug';
        $env->{'webgui.debug'} = 1;
        $app = Plack::Middleware::StackTrace->wrap($app);
        $app = Plack::Middleware::Debug->wrap( $app,
            panels => [qw(Environment Response Timer Memory Session DBITrace PerlConfig Response)] );
    }
    
    # Turn exceptions into HTTP errors
    $app = Plack::Middleware::HTTPExceptions->wrap( $app );

    return $app->($env);
}

1;
