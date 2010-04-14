package WebGUI::Middleware::Session;
use strict;
use parent qw(Plack::Middleware);
use WebGUI::Config;
use WebGUI::Session;
use Try::Tiny;
use Plack::Middleware::StackTrace;
use Plack::Middleware::Debug;
use WebGUI::Middleware::HTTPExceptions;
use Plack::Middleware::ErrorDocument;
use Plack::Middleware::SimpleLogger;

use Plack::Util::Accessor qw( config error_docs );

=head1 NAME

WebGUI::Middleware::Session - Opens and closes the per-request WebGUI::Session

=head1 DESCRIPTION

This is PSGI middleware for WebGUI that instantiates, opens and closes the 
L<WebGUI::Session> object. It does this as early and as late as possible, so
that all intermediate middleware (and the WebGUI app itself) can grab
the session out of the PSGI env hash:

    $env->{'webgui.session'};

and not worry about closing it.

=cut

sub call {
    my ( $self, $env ) = @_;

    my $app = $self->app;
    my $config = $self->config or die 'Mandatory config parameter missing';
    
    # Logger fallback
    if (!$env->{'psgix.logger'}) {
        $app = Plack::Middleware::SimpleLogger->wrap( $app );
    }

    my $session = try {
        $env->{'webgui.session'} = WebGUI::Session->open( $config->getWebguiRoot, $config, $env );
    } catch {
        # We don't have a logger object, so for now just warn() the error
        warn "Unable to instantiate WebGUI::Session - $_";
    };

    if ( !$session ) {

        # We don't have access to a db connection to find out if the user is allowed to see
        # a verbose error message or not, so resort to a generic Internal Server Error
        # (using the error_docs mapping)
        if ($self->error_docs) {
            return Plack::Middleware::ErrorDocument->wrap( sub { [ 500, [], [] ] }, %{ $self->error_docs } )->($env);
        } else {
            return [ 500, [ 'Content-Type' => 'text/plain' ], [ 'Internal Server Error' ] ];
        }
    }

    my $debug = $session->log->canShowDebug;
    if ($debug) {
        $app = Plack::Middleware::StackTrace->wrap($app);
        $app = Plack::Middleware::Debug->wrap( $app,
            panels => [qw(Environment Response Timer Memory Session DBITrace PerlConfig Response WgLogger)] );
    }

    # Turn exceptions into HTTP errors
    $app = WebGUI::Middleware::HTTPExceptions->wrap($app);

    # HTTP error document mapping
    if ( !$debug && $self->error_docs ) {
        $app = Plack::Middleware::ErrorDocument->wrap( $app, %{ $self->error_docs } );
    }

    # Run the app
    my $res = $app->($env);

    # Use callback style response
    return $self->response_cb(
        $res,
        sub {
            my $res = shift;

            # Close the Session
            $env->{'webgui.session'}->close();
            delete $env->{'webgui.session'};
        }
    );
}

1;
