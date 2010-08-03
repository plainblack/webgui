package WebGUI::Middleware::Session;
use strict;
use parent qw(Plack::Middleware);
use WebGUI::Config;
use WebGUI::Session;
use Try::Tiny;
use WebGUI::Middleware::HTTPExceptions;
use Plack::Util::Accessor qw( config );

=head1 NAME

WebGUI::Middleware::Session - Opens and closes the per-request WebGUI::Session

=head1 DESCRIPTION

This is PSGI middleware for WebGUI that instantiates, opens and closes the 
L<WebGUI::Session> object. It does this as early and as late as possible, so
that all intermediate middleware (and the WebGUI app itself) can grab
the session out of the PSGI env hash:

    $env->{'webgui.session'};

and not worry about closing it.

It also sets C<webgui.debug> as appropriate.

=cut

sub call {
    my ( $self, $env ) = @_;

    my $app = $self->app;

    my $config = $self->config or die 'Mandatory config parameter missing';

    # Logger fallback
    if (!$env->{'psgix.logger'}) {
        require Plack::Middleware::SimpleLogger;
        $app = Plack::Middleware::SimpleLogger->wrap( $app );
    }

    my $session = try {
        $env->{'webgui.session'} = WebGUI::Session->open( $config, $env );
    } catch {
        # We don't have a logger object, so for now just warn() the error
        warn "Unable to instantiate WebGUI::Session - $_";
        return; # make sure $session assignment is undef
    };

    if ( !$session ) {

        # We don't have access to a db connection to find out if the user is allowed to see
        # a verbose error message or not, so resort to a generic Internal Server Error
        return [ 500, [ 'Content-Type' => 'text/plain' ], [ 'Internal Server Error' ] ];
    }

    my $debug = $env->{'webgui.debug'} = $self->canShowDebug($env);

    # Run the app
    my $res = $app->($env);

    # Use callback style response
    return $self->response_cb(
        $res,
        sub {
            my $res = shift;

            # Close the Session if we aren't streaming
            if ( !$env->{'webgui.session'}->response->streaming ) { 
                $env->{'webgui.session'}->close();
                delete $env->{'webgui.session'};
            }

            # If we are streaming, the session will be closed inside of 
            # WebGUI.pm
        }
    );
}

sub canShowDebug {
    my $self = shift;
    my $env = shift;
    my $session = $env->{'webgui.session'};

    my $canShow = $session->setting->get("showDebug");
    return
        unless $canShow;

    my $ips = $session->setting->get('ipDebug');
    return 1
        if $ips eq '';
    $ips =~ s/\s+//g;
    my @ips = split /,/, $ips;
    my $ok = Net::CIDR::Lite->new(@ips)->find($env->{REMOTE_ADDR});
    return $ok;
}

1;
