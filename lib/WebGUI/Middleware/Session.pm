package WebGUI::Middleware::Session;
use strict;
use parent qw(Plack::Middleware);
use WebGUI::Config;
use WebGUI::Session;

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

=cut

sub call {
    my ( $self, $env ) = @_;

    my $config = $self->config or die 'Mandatory config parameter missing';

    # Open the Session
    $env->{'webgui.session'} = WebGUI::Session->open( $config->getWebguiRoot, $config, $env );

    # Run the app
    my $res = $self->app->($env);

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
